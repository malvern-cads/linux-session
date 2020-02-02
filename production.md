# Instructions

These instructions should give you a rough guide on setting up an environment for running something similar to us. This can easily be setup in a couple of hours with good Linux and Docker knowledge.

## 1. Server

First, you will need to organise a system to deploy onto. We decided upon renting a [Hetzner](https://console.hetzner.cloud/) server for ~2 days, although you could do this on a laptop on the same network. It's a good idea to give it a hostname of a real domain (e.g. linux.<YOUR_DOMAIN>) and have that real domain point to the server's IP.

## 2. Docker

Then you will need to login and install Docker (as root):

```
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

## 3. Portainer

I installed Portainer to give us a UI for managing all of the containers, although this is optional:

```
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```

Now, head over to http://linux.<YOUR_DOMAIN>:9000/ and setup a new account and select 'Local' and hit the 'Connect' button.


## 4. Internal Network

It's a good practice to have an internal network for the containers to communicate over. All of the containers will be on the same internal network so that the Web SSH client can talk to the Linux containers and vice-versa.

```
docker network create cads
```

## 5. Web SSH

Next up, we'll create a container for running the Web SSH that people will use for connecting into the Linux containers. For a large setup, it's probably a good idea to have 2 of these with load balancing. We'll be running this through a reverse proxy for adding HTTPS and extra security.

```
docker run -d --network cads --name webssh -p :8080 --restart=unless-stopped snsyzb/webssh
```

This container will be launched with a random port, in my case `32768`, so heading over to http://linux.<YOUR_DOMAIN>:32768/, I can see that it seems to be working ok.

## 6. Reverse Proxy

It's not very user friendly to be typing in a URL with a port, so let's set it up so that we are listeining on just linux.<YOUR_DOMAIN>. We can use something like Nginx or Caddy. I'm a fan of Caddy because it 'just works' without much configuration.

Create a new file at `/root/Caddyfile` with these contents:

```
linux.<YOUR_DOMAIN> {
    log stdout
    errors stderr

    tls <EMAILHERE>

    proxy / http://webssh.cads:8080 {
        transparent
        websocket
    }
}
```

This file tells Caddy to listen on the domain `linux.<YOUR_DOMAIN>`, send the logs to the console, setup HTTPS with the email, proxy all traffic to the webshell container and allow websocket traffic.

Then launch the Caddy container:

```
docker volume create caddy_certs
docker run -d --name caddy --network cads -p 80:80 -p 443:443 -v /root/Caddyfile:/etc/Caddyfile -v caddy_certs:/root/.caddy -e ACME_AGREE=true --restart=unless-stopped abiosoft/caddy:1.0.3
```

Then after waiting a couple of seconds for the container to warm up and fetch certificates, we can head to linux.<YOUR_DOMAIN> and we have the web SSH client with a valid HTTPS certificate.

## 7. Create containers

Install Docker Compose:

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Download `docker-compose.yml` from the GitHub repository, if you need a different number of instances, you can use the script `generate-compose.py` to create a new compose file.

Execute `docker-compose up -d` to create the Linux containers.

## 8. Profit

It should be ready now. Test it out by going to https://linux.<YOUR_DOMAIN> (or your own domain name) and type in the hostname `linux01.cads`, port `22`, username `root` and password `cads` and check if the connection works.
