# Instructions

These instructions should give you a rough guide on setting up an environment for running something similar to us. This can easily be setup in a couple of hours with good Linux and Docker knowledge.

If you want to setup **just** the challenge containers with an exposed SSH port, you can skip steps 5 and 6 and ensure that you are exposing ports inside the Docker Compose config.

<!-- TOC -->

- [1. Server](#1-server)
- [2. Docker](#2-docker)
- [3. Portainer](#3-portainer)
- [4. Internal Network](#4-internal-network)
- [5. Web SSH](#5-web-ssh)
- [6. Reverse Proxy](#6-reverse-proxy)
- [7. Create containers](#7-create-containers)
- [8. Profit](#8-profit)
- [9. Maintainance](#9-maintainance)

<!-- /TOC -->

## 1. Server

First, you will need to organise a system to deploy onto.

We decided upon renting a [Hetzner](https://console.hetzner.cloud/) server for ~2 days, although you could do this on any computer such as laptop on the same network. For our setup which was hosting about 20-30 people simultaneously, we went for a `CX41` server from Hetzner which had 4 vCPUs, 16 GB of RAM and 160 GB SSD, but that ended up being overkill, because when everyone was logged in and completing challenges we were using under 4 GB RAM and only about 10% of CPU, so a `CX21` would have worked fine.

> For the rest of the guide, I will be referring to the server as `linux.cadscheme.co.uk`, so you will have to replace this either with your server's IP address or your own domain name that points to your server.

## 2. Docker

Then you will need to login and install Docker (as root):

```
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
```

Then run `docker version` to ensure that you have everything setup correctly, if there are no errors, you're good to move on.

## 3. Portainer

Portainer is a management GUI for Docker which allows you to see and interact with running containers. This is an optional step and we didn't end up using it much.

```
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
```

Now, head over to http://linux.cadscheme.co.uk:9000/ and setup a new account and select 'Local' and hit the 'Connect' button. You should now see a list of the running containers (which should just be the Portainer one at the moment).


## 4. Internal Network

When using Docker, it's a good practice to have an internal network (other than the default one) for the containers to communicate over. All of the containers will be on the same internal network so that the Web SSH client can talk to the Linux containers and vice-versa.

```
docker network create cads
```

We will be putting the rest of the containers on this network. A container with a hostname of `linux01`, for example, will be able to be accessed from anywhere else on the network by using `linux01.cads`.

## 5. Web SSH

Next up, we'll create a container for running the Web SSH that people will use for connecting into the Linux containers. We'll be running this through a reverse proxy for adding HTTPS and extra security.

```
docker run -d --network cads --name webssh -p :8080 --restart=unless-stopped snsyzb/webssh
```

This container will be launched with a random port, in my case `32768`, so heading over to http://linux.cadscheme.co.uk:32768/, I can see that it seems to be working ok.

## 6. Reverse Proxy

It's not very user friendly to be typing in a URL with a port, so let's set it up so that we are listening on just linux.cadscheme.co.uk. We can use something like Nginx or Caddy. I'm a fan of Caddy because it 'just works' without much configuration.

Create a new file at `/root/Caddyfile` with these contents:

```
linux.cadscheme.co.uk {
    log stdout
    errors stderr

    tls <EMAILHERE>

    proxy / http://webssh.cads:8080 {
        transparent
        websocket
    }
}
```

This file tells Caddy to listen on the domain `linux.cadscheme.co.uk`, send the logs to the console, setup HTTPS with the email, proxy all traffic to the container at `webssh.cads` on port `8080` and allow websocket traffic.

Then launch the Caddy container:

```
docker volume create caddy_certs
docker run -d --name caddy --network cads -p 80:80 -p 443:443 -v /root/Caddyfile:/etc/Caddyfile -v caddy_certs:/root/.caddy -e ACME_AGREE=true --restart=unless-stopped abiosoft/caddy:1.0.3
```

Then after waiting a couple of seconds for the container to warm up and fetch certificates, we can head to linux.cadscheme.co.uk and we have the web SSH client with a valid HTTPS certificate.

## 7. Create containers

Install Docker Compose:

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

Download `docker-compose.yml` from the GitHub repository (which creates 30 instances), if you need a different number of instances, you can use the script `generate-compose.py` to create a new compose file. This downloads the docker compose file from the GitHub repository:

```
wget https://git.io/JvGJo -O docker-compose.yml
```

Then we need to create all of the containers using the command:

```
docker-compose up -d
```

## 8. Profit

It should be ready now. Test it out by going to https://linux.cadscheme.co.uk (or your own domain name) and type in the hostname `linux01.cads`, port `22`, username `root` and password `cads` and check if the connection works.

## 9. Maintainance

If you need to reset all of the containers (including data stored on them) you can run:

```
docker-compose down -v
docker-compose up -d
```

If you need to upgrade the container images you can run:

```
docker-compose down
docker-compose pull
docker-compose up
```
