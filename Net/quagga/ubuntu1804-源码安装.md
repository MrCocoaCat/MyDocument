#### 安装依赖
一些可能遇到的缺少文件的错误及解决方法：
1. 安装gawk：

```
$ sudo apt-get install gawk
```

2. 安装libreadline

```
$ sudo apt-get install libreadline6-dev
```

3. 安装libcares

源码安装 c-ares-1.15.0.tar.gz 解压之后三步走就好。


4. 安装pkg
apt-get install -y pkg-config


>$ make
$ make install
这两条指令执行过程中，可能会出现找不到XX.conf文件或者没有权限等错误，配置文件位于/usr/local/etc下，ls后可以看到配置文件基本为XX.conf.sample,执行下面指令修改为.conf即可。
$ sudo cp XX.conf.sample /usr/local/etc/XX.conf
顺利执行完没有报错的话，基本安装过程就结束了。

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


```
./configure --enable-vtysh --enable-user=root --enable-group=root --localstatedir=/var/run/quagga --sysconfdir=/etc/quagga

```
* --enable-vtysh 生成vtysh，vtysh是一个可以直接配置其他Quagga进程的shell。不使用vtysh的话，需要telnet到每个进程中去配置，比较麻烦。
* --enable-user=root --enable-group=root 默认运行用户为quagga，这里修改为root，可以不用改变文件夹的属性，也不用单独增加用户。
* --localstatedir=/var/run/quagga 运行时的PID文件位置
* --sysconfdir=/etc/quagga 运行时的配置文件目录，默认位置在/usr/local/etc中



#### 错误及解决

默认情况下，编译器只会使用/lib和/usr/lib这两个目录下的库文件，通常通过源码包进行安装时，如果不指定--prefix，会将库安装在/usr/local/lib目录下；当运行程序需要链接动态库时，提示找不到相关的.so库，会报错。也就是说，/usr/local/lib目录不在系统默认的库搜索目录中，需要将目录加进去。

1. 首先打开/etc/ld.so.conf文件

2. 加入动态库文件所在的目录：执行vi /etc/ld.so.conf，在
```
include ld.so.conf.d/*.conf
/usr/local/lib。
```

3. 保存后，在命令行终端执行：/sbin/ldconfig -v；其作用是将文件/etc/ld.so.conf列出的路径下的库文件缓存到/etc/ld.so.cache以供使用，因此当安装完一些库文件，或者修改/etc/ld.so.conf增加了库的新搜索路径，需要运行一下ldconfig，使所有的库文件都被缓存到文件/etc/ld.so.cache中，如果没做，可能会找不到刚安装的库。

　　经过以上三个步骤，"error while loading shared libraries"的问题通常情况下就可以解决了。


>科普：/etc/services文件是记录网络服务名和它们对应使用的端口号及协议。文件中的每一行对应一种服务，它由4个字段组成，中间用TAB或空格分隔，分别表示“服务名称”、“使用端口”、“协议名称”以及“别名”。/etc/services文件包含了服务名和端口号之间的映射，很多的系统程序要使用这个文件。一般情况下，不要修改该文件的内容，因为这些设置都是Internet标准的设置。一旦修改，可能会造成系统冲突，使用户无法正常访问资源。Linux系统的端口号的范围为0–65535，不同范围有不同的意义。

0 不使用
1–1023 系统保留，只能由root用户使用
1024—4999 由客户端程序自由分配
5000—65535 由服务器端程序自由分配
（科普部分内容摘自：原博地址）

>$ vim /etc/services
可以看到路由相关协议的端口号

### 配置qugga
启动zebra -d
```
$ sudo zebra -d
```

————————————————
版权声明：本文为CSDN博主「LLXIN7」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/xinLLX/article/details/88172471
