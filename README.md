# `miraicle` - Docker image for `mirai-console-loader`

[简体中文](README.zh.md) | English

## Motivation

Someone has to pack these stuff together eventually. 
I guess I'll just be the one who's in the barrel.

## Using the image

**Manual assemblies required**, see later sections.

With `docker-compose`

```
$ docker-compose up -d && docker attach mirai
```

This opens a interactive console provided by `mirai-console-loader`. 
Then you can use it just as a normal, pre-configured `mirai` bot. 

Configurations are supplied through the mounted volumes and passing them 
as environment variables will no longer works. See below for details.

## Manual Assemblies

### 1. Mounting the Volumes

If you are using `docker-compose`, then this step is already done for you. 
You can skip to the next section.

You will need to create a volume that is used to store all the goodies of 
`mirai-*`. If you need to view or edit them on the host, use this command: 

```
docker volume create -d local -o type=none -o o=bind -o device=./mcl mcl
```

It is recommended to use an absolute path for volume creation. We used 
a relative path here just for brevity.

This will create a Docker volume binded to `./mcl`. The directory will be 
populated with the content of the image on the first run, and after that 
you can modify the content and it will reflect into the container.

However, it is NOT recommended to edit these bind volumes wile the 
application is running. None of these applications support hot reloading.

To bind this volume into the image when running, use the `-v` argument:

```
$ docker run -v mcl:/app/mcl dousha99/miraicle
```

### 2. (Optional) Passing Boot Parameters

It is possible to pass parameters to `./mcl` script. The default parameter is 
`-u` which prevent the loader from automatically upgrading runtime libraries. 
Passing new arguments to `docker run` will override the default arguments, 
thus allowing users to customize with the loader script.

### 3. Device Mock Data

For an ideal IM service, there shall be an offical way to create bots. 
QQ is clearly not ideal. I could understand it's a complex decision, but 
it can be frustrating in some cases. Dingtalk on the other hand, does 
allow you to create bots however you please, but it hasn't catch on yet. 

Device mock data is used to ... well, mock a login device. Since we are 
using Mobile QQ protocol, mocking a device became a necessity. Otherwise 
the account could be easily banned. Mirai does have the ability to 
generate mock data, but you have to authenticate this device on the server 
since it's considered a 'new device'.

Though the authentication process could be done within CLI (with help 
from another device with GUI), it is highly advised that one shall download 
`mirai-console-loader` and initiate authentication process to obtain a 
`device.json` for the account. 

Sharing the same `device.json` may lead to unexpected results including 
need to re-authenticate, cannot login even permanently banned.

As the progress of `mirai-console`, it's now possible to authenticate with 
help from other graphical terminals. You don't have to obtain a copy of 
`device.json` in advance. If you are still interested in how to get such a 
copy, read the quoted section below.

> To obtain your own copy of `device.json`, follow these steps:
>
> * Install Git
> * Install Java 11+
> * Install Gradle because `mirai-console-loader` doesn't come with a wrapper (!)
> 
> ```
> -- Clone and build the console loader
> -- Have a cup of whatever you like while waiting. Stay hydrated.
> 
> $ git clone https://github.com/iTXTech/mirai-console-loader.git
> $ cd mirai-console-loader
> $ gradle build
> $ cp build/libs/mirai-console-loader*.jar ./mcl.jar
> $ chmod +x mcl
> $ ./mcl
> 
> -- In the interactive console
>
> /login YOUR_USER_ID YOUR_PASSWORD
>
> -- It would prompt you to authenticate the device
> -- After the process, type the command below to close the app:
>
> /shutdown (or /stop in later versions. If none of these works, 
> press Ctrl + C).
>
> -- The device.json will appear in the CWD
> ```
>
> After obtaining your `device.json`, you can use it to replace 
> `config/device.json`.

Note that this does **NOT** create a universal device data. 
New accounts logging in with this device data for the first time 
may need to re-authenticate. In addition, it's not possible to 
login more than 2 accounts on the same device at the same time. 
It is highly advised to create separate containers with different 
`device.json` for multiple account, even if they share the same 
code base.

### 4. HTTP Plugin Configurations

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

## FAQ

### Why doesn't it work???

It's a miracle to have `mirai-*` running on the first place since the 
project itself is extremely volatile and always introducing breaking changes 
in **every single component almost everyday**, packing a image that works 
is even harder. (Hence the name `miraicle`.)

I apologize for all the inconvenience. Since I am not working fulltime on 
this, bug fixes may come late. I will try my best to track all the fatal 
issues and resolve them ASAP.

Check out the issues section for updates. Usually the `bleeding` tag would 
contain the latest code and fixes and the `latest` tag would contain the 
most recent stable build of `bleeding`. If the `latest` tag is broken, you 
can try `bleeding` for luck.

Usually the issues are caused by the changes made by upstream projects. 
In that case the issue could be forwarded to respective developers. 

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

### What's inside?

This image ships with the latest version of 
[`mirai-console-loader`](https://github.com/iTXTech/mirai-console-loader) 
and [`mirai-api-http`](https://github.com/project-mirai/mirai-api-http) 
with a default configuration file.

The image still needs some manual assemblies. Specifically 
the `/app/mcl/device.json` used to mock a device is not provided and have 
to be generated on the first login. In addition, the first login of an 
account usually would trigger a 2FA process that need a GUI to continue.

### My account got banned for using this?

This is unfortunate. But I'm afraid I can't help you with that since the 
EULA of QQ explicitly specified that using a third-party client is not 
accepted and may lead to the termination of service. Permabanning is 
annoying, but we can do literally nothing about it.

And please recheck all the plugins you have installed. There might be 
some malicious plugins that will abuse your account to spam, which would 
lead to banning. Sending messages too frequently will also trigger the 
abuse alarm.

The content of the image is always inspectable from `Dockerfile` and I 
will audit the plugins added into the image. If you suspect that some 
of these plugins (which is the HTTP plugin by now) is abusive or malicious, 
please report it in the issues.

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

