# `miraicle` - Docker image for `mirai-console-loader`

## Motivation

Someone has to pack these stuff together eventually. 
I guess I'll just be the one who's in the barrel.

## Using the image

**Manual assemblies required**, see later sections.

Quick and dirty start:

```
$ docker run -it dousha99/miraicle -p 8080:8080 -e USER=1234567890 -e PASS=p455w0rd!
```

This opens a interactive console provided by `mirai-console-loader`. 
Then you can use it just as a normal, pre-configured `mirai` bot. 
The account specified with `USER` and `PASS` should login automatically.

Future versions may introduce a method to configure all those 
things with environment variables, making the use of `docker-compose.yml` 
or `kubectl apply -f deployment.yaml` possible. 

## Manual Assemblies

### Device Mock Data

For an ideal IM service, there shall be an offical way to create bots. 
QQ is clearly not ideal. I could understand it's a complex decision, but 
it can be frustrating in some cases. Dingtalk on the other hand, does 
allow you to create bots however you please, but it hasn't catch on yet. 

Device mock data is used to ... well, mock a login device. Since we are 
using Mobile QQ protocol, mocking a device became a necessity. Otherwise 
the account could be easily banned. Mirai does have the ability to 
generate mock data, but you have to authenticate this device on the server 
since it's considered a 'unfamiliar device'.

It is highly advised that one shall download `mirai-console-loader` and 
initiate authentication process to obtain a `device.json` for the account. 
Sharing the same `device.json` may lead to unexpected results including 
the needing to re-authenticate, cannot login even permanently banned.

To obtain your own copy of `device.json`, follow these steps:

* Install Git
* Install Java 11+
* Install Gradle because `mirai-console-loader` doesn't come with a wrapper (!)

```
-- Clone and build the console loader
-- Have a cup of whatever you like while waiting. Stay hydrated.

$ git clone https://github.com/iTXTech/mirai-console-loader.git
$ cd mirai-console-loader
$ gradle build
$ cp build/libs/mirai-console-loader*.jar ./mcl.jar
$ chmod +x mcl
$ ./mcl

-- In the interactive console

/login YOUR_USER_ID YOUR_PASSWORD

-- It would prompt you to authenticate the device
-- After the process, type the command below to close the app:

/shutdown

-- The device.json will appear in the CWD
```

After obtaining your `device.json`, you can map it 
into the container:

```
$ docker run ... -v device.json:/app/mcl/device.json ...
```

Note that this does **NOT** create a universal device data. 
New accounts logging in with this device data for the first time 
may need to re-authenticate. In addition, it's not possible to 
login more than 2 accounts on the same device at the same time. 
It is highly advised to create separate containers with different 
`device.json` for multiple account, even if they share the same 
code base.

### HTTP Plugin Configurations

This image is **INSECURE** by default since it uses a shared authentication 
key for the HTTP plugin. This means for anyone who can access your container, 
they can easily access your account without your authorization.

The best method to prevent unauthorized access is set up proper firewall 
rules; especially for you who are running this image on machines with no 
firewall presets or a open firewall present. Note that [firewalld does not 
play well with docker](https://github.com/firewalld/firewalld/issues/461). 
You may have to do some tweaks like move the `docker0` interface to 
the `trusted` zone.

If you find fiddling with firewalls is not an option, you can at least 
change the authentication key in the configuration files. 
To change the `authKey`. You can either map the configuration folder 
`/app/mcl/config` out to host drives (which you may eventually have to do 
since you need to install more plugins), or just open a shell and edit the 
file in place.

```
$ docker run -it dousha99/miraicle -v config:/app/mcl/config -p 8080:8080 -e USER=... -e PASS=...
- or -
$ docker exec -it <CONTAINER_ID> bash
```

## FAQ

### What's inside?

This image ships with the latest version of 
[`mirai-console-loader`](https://github.com/iTXTech/mirai-console-loader) 
and [`mirai-api-http`](https://github.com/project-mirai/mirai-api-http) 
with a default configuration file.

The image still needs some manual assemblies. Specifically 
the `/app/mcl/device.json` used to mock a device is not provided and have 
to be generated on the first login. In addition, the first login of an 
account usually would trigger a 2FA process that need a GUI to continue.

### It doesn't work / There is an issue with this image ...

Please report bugs to respective application developers. 
This repository only accepts issues on image packaging, 
which is not very likely to fail.

However, if you found that the issue is caused by the packaging process, 
feel free to open an issue or make a pull request! Mirai is quite a 
community-driven project and contributions are welcome.

I just wish there could be detailed documents on how to get started. 
Sometimes there is no document or the document is outdated. You have 
to grep the code and make (un-)educated guesses. To make things even worse, 
they are using the bleeding edge version of Kotlin which I don't have a 
firm grasp on. I may make questionable, even completely wrong assumptions 
about the code, leading to a failure. But hey, isn't that what open-source 
is meanted to fix?

### I hate containers. Can't you just pack everything up without shoving it into a container?

Then you might be interested in [MiraiOK](https://github.com/LXY1226/MiraiOK), 
which ironically has [a lot of docker images](https://github.com/search?q=MiraiOK).

A little update: It seems that the developer of MiraiOk 
is not actively maintaining the project. However, you can 
still follow the instructions presented in `Dockerfile` to 
manually build the thing.

Note: You will need Gradle 6.2+ and JDK 11+ to build things 
properly. Otherwise mysterious errors may pop up.

### There is an image on Docker Hub doing the same thing. Are you reinventing the wheel?

Not quite. There is an image named `mirai-cqhttp` and it's already 
quite known. But `privileged: true` in the 
`docker-compose.yml` made me skeptical. I have to build my 
own image to verify if using privileged container is 
necessary. I will elaborate on the usage provided it is 
required.

Besides, I thought it would be better (or worse depending on 
your opinion) to use vanilla plugins. If your application 
relies heavily on `CQHttp`, it would play nicer with 
`mirai-cqhttp`.

### There is no one using this image. Where did you get these FAQs?

I got these questions through reflections. Get it? :P

