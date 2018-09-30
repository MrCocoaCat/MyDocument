### Basic Configuration
Glance有许多选项，您可以使用它们来配置Glance API服务器、Glance注册服务器和各种存储后端，这些后端可以用来存储映像。大多数配置是通过配置文件完成的，其中Glance API服务器和Glance Registry服务器使用单独的配置文件。在启动Glance服务器时，可以指定要使用的配置文件(请参阅controller Glance服务器上的文档)。如果没有指定配置文件，Glance将在以下目录中查找配置文件，顺序如下

* ~/.glance
* ~/
* /etc/glance
* /etc
