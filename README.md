# Linux Session

This repository includes the material that used for a session at CADS which involved teaching some basic Linux command line knowledge.

We decided the best way to learn would be a hands on approach. There's lots of solutions already such as [Katacoda](https://www.katacoda.com/), [Codecademy](https://www.codecademy.com/learn/learn-the-command-line) and [Linux Survival](https://linuxsurvival.com/) but we were having trouble getting some of them working through our school's firewall and others didn't offer enough flexability (so that we could create our own 'course'), so we decided that it would be a good idea to roll our own solution.

The best way to solve this would to have a big server running a bunch of VMs that each person connects to individually. This requires a lot of compute power to run though and we didn't have a big budget. Another way, would to have one Linux server with lots of accounts which are then dished out to each person. I had a lot of experience using [Docker](https://www.docker.com/) which is a way of packaging applications into small 'VMs' called 'containers', so that's what we settled for in the end (although this isn't really what Docker is designed for and does have a couple of gotchas (see later)).

A docker image allows us to install programs and add files/folders which will then be consistent for each instance of the container and we can create as many instances of the container for however many people turn up at the session.

You could just have our custom 'CADS Linux' containers with SSH open and have each person connect to them using a computer with SSH installed, but we still had the problem of connecting from a school computer, so we needed something in the middle to let us connect. We used a browser SSH client which allows a browser talk to an SSH server through the browser SSH client.

![](setup.svg)

The final setup had a reverse proxy which listens for traffic from a domain (e.g. linux.cadscheme.co.uk) and forwards it to the internally hosted SSH client. When someone connects through the SSH client it will communicate through an internal network to the relavent 'CADS Linux' container.

## Structure

- The [**`instructions`** folder](https://github.com/malvern-cads/linux-session/tree/master/instructions) contains all of the text files that have the levels inside. The idea is that the user opens `level1.txt` to start off with and then moves on to `level2.txt` and so on. This folder is copied to `/root` (which is the home directory of the `root` user that they will be using) and to `/etc/skel` (which means that any new users will also have the instructions folder copied into their home folder).
- The [**`level_files`** folder](https://github.com/malvern-cads/linux-session/tree/master/level_files) contains all of the files that are copied to various places on the machine for different challenges. For example, `animals` is copied into `/root`, `research` is copied to `/root/research` and `alkenes.txt` is copied to `/var/backups/research/`.
- [**`cheatsheet.md`**](cheatsheet.md) gives a quick summary of the Linux commands that were used throughout the different levels. We gave each person one of these to help them out with commands.
- **`docker-compose.yml`** is a configuration file for [Docker Compose](https://docs.docker.com/compose/) which is a tool which quickly allows you to spin up large numbers of containers programatically. The config in the repository spins up 30 containers, but this can be configured to more or less by running `generate-compose.py`.
- **`Dockerfile`** is a set of instructions that are used for creating the Docker image. So we have installed some programs that are needed and copied the instructions and level files into their relevant places.
- **`generate-compose.py`** is a Python script for generating a Docker Compose file, as it is quite time consuming to keep copying and pasting (to edit parameters, you need to edit the variables at the top of the file).

## Development

To test the container on a local computer for development, you will need:

- [Docker](https://www.docker.com/products/docker-desktop)
- Docker Compose (may install with Docker Desktop)

First, build the image for the container (this runs all of the instructions such as copying files):

```
docker build -t cads-linux .
```

Then run an instance of the container and attach your terminal into it (run `exit` to quit):

```
docker run -it cads-linux /bin/bash
```

## Production Setup

We have created [some instructions](production.md) for setting up something identical to what we did.

### Containers

- **[`caddy/caddy`](https://hub.docker.com/r/caddy/caddy)** - Reverse proxy for listening on a domain and forwarding to the internal web SSH container.
- **[`snsyzb/webssh`](https://hub.docker.com/r/snsyzb/webssh)** - Web SSH for allowing users to SSH into each of the containers through the internal network.
- **[`cadscheme/cads-linux`](https://hub.docker.com/r/cadscheme/cads-linux)** - The container setup with challenges.
