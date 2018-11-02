### Basic Configuration
Glance有许多选项，您可以使用它们来配置Glance API服务器、Glance注册服务器和各种存储后端，这些后端可以用来存储映像。大多数配置是通过配置文件完成的，其中Glance API服务器和Glance Registry服务器使用单独的配置文件。在启动Glance服务器时，可以指定要使用的配置文件(请参阅controller Glance服务器上的文档)。如果没有指定配置文件，Glance将在以下目录中查找配置文件，顺序如下

* ~/.glance
* ~/
* /etc/glance
* /etc
Glance API服务器配置文件应该命名为gls-api.conf。类似地，Glance注册中心服务器配置文件应该命名为gls-registry.conf。由于Glance为每个服务维护一个配置文件，因此还有许多其他配置文件。
如果您通过操作系统的包管理系统安装了Glance，很可能会在/etc/ glance中安装示例配置文件。


# 制作windows 镜像
https://blog.csdn.net/das_chao12138/article/details/51586938
