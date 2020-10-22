# `miraicle` - Docker image for `mirai-console-loader`

## Motivation

Someone has to pack these stuff together eventually. 
I guess I'll just be the one who's in the barrel.

## Using the image

Quick and dirty start:

```
$ docker run -it dousha99/miraicle -p 8080:8080
```

This opens a interactive console provided by `mirai-console-loader`. 
Then you can use it just as a normal, pre-configured `mirai` bot.

Future versions may introduce a method to configure all those 
things with environment variables, making the use of `docker-compose.yml` 
or `kubectl apply -f deployment.yaml` possible.

Note that this image is **INSECURE**. You have to edit the 
configuration file to change the `authKey`. You can either map the 
configuration folder `/app/mcl/config` out to host drives, or just 
open a shell and edit the file in place.

```
$ docker run -it dousha99/miraicle -v config:/app/mcl/config -p 8080:8080
- or -
$ docker exec -it <CONTAINER_ID> bash
```

You can also set up firewall rules to reject or restrict incoming connections 
to the host port, which is the common practice.

## FAQ

### What's inside?

This images ships with the latest version of 
[`mirai-console-loader`](https://github.com/iTXTech/mirai-console-loader) 
and [`mirai-api-http`](https://github.com/project-mirai/mirai-api-http) 
with a default configuration file.

The image is yet to be configured. I. e. manual configuration is 
required. You cannot pull a `docker-compose.yml` and configure 
everything with environment variables yet -- the applications inside 
doesn't seem to support that just yet.

### There is an issue with this image ...

Please report bugs to respective application developers. 
This repository only accepts issues on image packaging, 
which is not very likely to fail.

### I hate containers. Can't you just pack everything up without shoving it into a container?

Then you might be interested in [MiraiOK](https://github.com/LXY1226/MiraiOK), 
which ironically has [a lot of docker images](https://github.com/search?q=MiraiOK).

### There is an image on Docker Hub doing the same thing?

Yes. But `privileged: true` in the `docker-compose.yml` made me 
skeptical. I have to build my own image to verify if using 
privileged container is necessary. I will elaborate on the 
usage provided it is required.

### There is no one using this image. How come these FAQs?

I got these questions through reflections. Get it? :P
