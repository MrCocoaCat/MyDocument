### quagga安装
刚开始接触，关于quagga中的基础知识，后续补充。

#### 安装过程
1. 首先下载quagga源码，这里我选择的是1.2.4版本。下载后，解压到相应文件夹，进入该文件夹。

```
$ cd quagga-1.2.4
```

接下来三步走：
```
configure
make
make install
```

$ ./configure --enable-vtysh --enable-user=root --enable-group=root --enable-vty-group=root
上述命令为打开vty功能并给予相应权限,在这个命令执行中，可能会出现很多error，基本要么是需要sudo权限，要么是缺少相应的动态链接库，根据报错信息，缺什么装什么就好。

#### 错误及解决
一些可能遇到的缺少文件的错误及解决方法：
1. 缺少gawk：

```
$ sudo apt-get install gawk
```

2. 缺少libreadline

```
$ sudo apt-get install libreadline6-dev
```

3. 缺少libcares
```
下载相应的c-ares资源文件，解压之后三步走就好。
```
4.
apt-get install -y pkg-config


>$ sudo apt-get install XX
大部分缺少的都可以通过这个命令安装，不可以的话网上查一下相应资源文件，下载后三步走就好。

>$ make
$ make install
这两条指令执行过程中，可能会出现找不到XX.conf文件或者没有权限等错误，配置文件位于/usr/local/etc下，ls后可以看到配置文件基本为XX.conf.sample,执行下面指令修改为.conf即可。
$ sudo cp XX.conf.sample /usr/local/etc/XX.conf
顺利执行完没有报错的话，基本安装过程就结束了。


顺利执行完没有报错的话，基本安装过程就结束了。

科普：/etc/services文件是记录网络服务名和它们对应使用的端口号及协议。文件中的每一行对应一种服务，它由4个字段组成，中间用TAB或空格分隔，分别表示“服务名称”、“使用端口”、“协议名称”以及“别名”。/etc/services文件包含了服务名和端口号之间的映射，很多的系统程序要使用这个文件。一般情况下，不要修改该文件的内容，因为这些设置都是Internet标准的设置。一旦修改，可能会造成系统冲突，使用户无法正常访问资源。Linux系统的端口号的范围为0–65535，不同范围有不同的意义。
0 不使用
1–1023 系统保留，只能由root用户使用
1024—4999 由客户端程序自由分配
5000—65535 由服务器端程序自由分配
（科普部分内容摘自：原博地址）

>$ vim /etc/services
可以看到路由相关协议的端口号





————————————————
版权声明：本文为CSDN博主「LLXIN7」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/xinLLX/article/details/88172471
