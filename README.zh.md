# `miraicle` - 基于 `mirai-console-loader` 的 Docker 镜像

简体中文 | [English](README.md)

## 动机

总得有人把这些东西打包好并分发给其他人。我寻思着这事我可以。

## 前置知识

我将默认在 \*nix 环境下进行操作。
Windows 也可以使用 Docker, 但是要更复杂一些。

我将默认读者具备一定的 \*nix 操作基础和 Docker 基础。

## 使用方法

**需要手动配置**。见下文。

使用 `docker-compose` 一键启动（但不是一键配置，见配置小节）：

```
$ docker-compose up -d && docker attach mirai
```

这个命令将会打开 `mirai-console-loader` 的交互式终端。这个终端是预配置过的，一般保证各组件的正常运行。

目前版本中，除了基本的环境设置以外，应用配置文件需要手动修改或者通过命令生成。在未来版本可能会加入通过环境变量自动生成配置。

## 配置

### 1. 挂载 Docker 卷

如果你在用 `docker-compose`, 那么这一步已经做好了。对于希望自己编写启动脚本或者 `docker-compose.yml` 的同志请继续阅读。

我们目前的规划是将整个容器的应用层映射出来，即 `/app/mcl` 应该映射到主机。所以，首先我们需要创建一个本地卷：

```
$ docker volume create -d local -o type=none -o o=bind -o device=./mcl mcl
```

推荐使用绝对路径创建 Docker 卷。如果你不希望打一长串东西的话，可以把 `.` 替换为 `${PWD}`.

这会在当前目录下创建 `mcl/` 并作为 `mcl` 卷。这个文件夹将在首次运行时把对应位置的文件映射出来，并将更改映射进容器。

现在，我们将该卷挂载到容器内：

```
$ docker run -it -v mcl:/app/mcl dousha99/miraicle
```

注意到程序本身并不支持热更新，所以任何更改都应在程序停止后进行。

### 2. （可选）传递启动参数

你可以在使用 `docker run` 启动时使用自定义的参数。默认的启动参数是 `-u`, 即阻止 `mirai-console-loader` 自动更新。自定义参数将改写默认的启动参数。

### 3. 设备数据

<del>你需要自行提供一份验证过的 `device.json`. 
目前尚未测试在 `docker` 内能否正常启动验证过程，因为缺少图形环境，很有可能验证窗格不能打开。所以提前准备已经验证过的 `device.json` 有益身心健康。</del>

经过测试，可以在没有图形界面的情况下获取认证链接并借助其他有图形环境的设备完成验证。提前准备 `device.json` 已经不再必要。如果你希望了解如何准备 `device.json` 则阅读以下引用部分：

> 获取 `device.json` 的方法如下：
> 
> * 安装 Git
> * 安装 Java 11+
> * 安装 Gradle
> 
> ```
> -- 克隆并构建 mirai-console-loader
> 
> $ git clone https://github.com/iTXTech/mirai-console-loader.git
> $ cd mirai-console-loader
> $ gradle build
> $ cp build/libs/mirai-console-loader*.jar ./mcl.jar
> $ chmod +x mcl
> $ ./mcl
> 
> -- 现在，进入了交互式终端
> 
> /login 你的QQ 你的密码
> 
> -- 此时会提示设备验证
> -- 验证完成之后
>
> /shutdown (或者 /stop 或者 Ctrl + C)
> ```
>
> `device.json` 会在根目录下出现。
>
> 你可能会意识到，自己刚刚不就启动了 `mirai` 了么？我要这镜像有何用？？
>
> 或许是为了批量部署吧。

### 4. HTTP 插件配置

HTTP 插件配置在 `/app/mcl/config/MiraiApiHttp/setting.yml`. （注意没有 `s`。）

需要修改的部分是 `authKey` 以及其他对应的信息（比如 WebSocket 端口、上报信息等等）。如果你计划不修改 `authKey`, 那么请务必做好防火墙配置。

注意到 `firewalld` 会影响 `docker` 和 `docker-compose` 的运行。你可能需要手动设置 `docker0` 和 `br-\*` 到 `trusted` 区域。或者让 Docker 使用主机网络运行。

## 常见问题

### 你这玩意不能用啊？？

有些时候由于上游的不兼容变更，`latest` 和 `bleeding` 镜像可能会炸掉。我会在 Issue 中进行说明。以及如果你发现这个问题来自镜像打包过程本身而不在上游的话，可以开 Issue 提示。

一般的，`bleeding` 包含最新版本的代码和修复；`latest` 将会在 `bleeding` 稳定后更新。

我并不全职搞这玩意，所以修复和更新的速度并不会很快。当然我会尽力处理好每一个问题。

### 镜像里面有什么？

镜像打包了最新版本的 [`mirai-console-loader`](https://github.com/iTXTech/mirai-console-loader) 和 [`mirai-api-http`](https://github.com/project-mirai/mirai-api-http). 以及一个用于固定版本的 `config.json`.

注意：镜像不自带 `device.json`, 这需要你自行生成，见上文。

### 我账号被封了？？？

啊这。先充个心悦三，请。

如果你自行安装了其他插件或脚本，那么请自行核查这些插件与脚本的安全性。以及自行写的脚本如果发送消息过于频繁也会导致账号被封。

我们会核查容器使用的每一个插件当前使用的版本。如果你认为是容器内自带的插件有问题，请务必开 Issue 反馈。

如果是初次登录就被秒封，这个大概率是可以通过申诉解锁的。服务器抽风是常有的事情，尤其是对于新注册的账号。

如果是用了一段时间才被封，那除了祝好运我们也没别的事情可做了。

### 非得用容器么？

如果你对容器不是很感兴趣，那么你可能会考虑一下 [MiraiOK](https://github.com/LXY1226/MiraiOK). 但这玩意其实[也有很多容器镜像](https://github.com/search?q=MiraiOK)。

由于 MiraiOK 似乎弃坑了，新出现的 [mirua](https://github.com/zkonge/mirua) 或许值得一试。

### 不是已经有类似的容器了么？（而且做得比你好？）

是的，已经有 `mirai-cqhttp` 这个容器斩获了 10k+ 的下载量。但问题是它的 `docker-compose.yml` 里面有一行 `privileged: true`, 让人感觉不是很舒服。所以我需要自己构建整套镜像看看究竟是哪需要提权。

以及我寻思着全部用原生插件应该效果会比较好。CQHTTP 毕竟只是一个兼容层。当然如果你有很多东西是依赖于原先的 CQHTTP 工程的话，用 `mirai-cqhttp` 会好很多。

### 能不能帮我配置？

可以。请转账付费。

