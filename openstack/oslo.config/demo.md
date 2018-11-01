OpenStack的oslo项目旨在独立出系统中可重用的基础功能，oslo.config就是其中一个被广泛使用的库，该项工作的主要目的就是解析OpenStack中命令行（CLI）或配置文件（.conf）中的配置信息。

在本文的语境下，有这么几个概念：

* 配置文件：　　

用来配置OpenStack各个服务的ini风格的配置文件，通常以.conf结尾；

* 配置项(options)：　　　

配置文件或命令行中给出的配置信息的左值， 如：enabled_apis = ec2, osapi_keystone, osapi_compute中的“enabled_apis”；

* 配置项的值：    

配置文件或命令行中给出的配置信息的右值，如：enabled_apis = ec2, osapi_keystone, osapi_compute中的“ec2, osapi_keystone, osapi_compute”；

* 配置组(option groups)：　　　

一组配置项，在配置文件中通过[...]来表示，如my.conf文件中的[rabbit]字段表示接下来开始一个名为rabbit的配置组；

* 其他模块：　　

运行时需要根据配置项的值实现具体操作的模块；

* 配置项的模式(option schemas)：

在解析配置文件、获取配置项的值之前，其他模块声明自己需要的配置项。配置文件通常是针对一个完整的服务的，因此其他模块中可能用不到配置文件中的所有配置项，这样就必须告诉系统自己依赖于哪些配置项，这个过程就是设置配置项的模式。包括声明配置项在配置文件的名称、设置配置项的默认值（一旦配置文件中没有该配置项而其他模块又依赖于该配置项，就使用这里声明的默认值）等等；

* 引用(reference)：　　　　

其他模块解析配置文件，获取配置项的值后，就可以在下面的实现中使用这些具体的配置值了；

* 注册(register)：　　　　

其他模块在引用配置项的值之前，必须注册自己将要引用的那些配置项的模式。也就是说，配置文件中的配置项其他模块不一定都为其声明模式，声明了模式的配置项也不一定为其进行注册，当然如果不注册，即使声明了模式，也无法引用。


### 过程
　　下面先给一个high-level的过程说明一下如何使用这个库，OpenStack中配置文件的解析主要有以下几个步骤：

　　* step1. 正确配置各个服务主配置文件（\*.conf文件），本步骤在各个服务（如：keystone）中完成。

　　* step2. 在要使用到配置信息的模块中声明将用到的那些配置项的模式，包括配置项的名称、数据类型、默认值和说明等；

　　* step3. 创建一个对象，创建该对象的类充当配置管理器，这个对象作为容器以后将存储配置项的值。

　　* step4. 调用step3创建的对象中相应的注册方法（如：register_opt()），注册step2中声明的配置项模式。这个过程不会解析配置文件，只是为step3中创建的对象开辟相应的字段。

　　* step5. 直接调用step3中创建的对象，传入配置文件路径等信息。此时将会解析配置文件，如果未指定配置文件则全部使用step2模式中的默认值。解析过程会提取step4中注册了的配置项的值，然后这些配置项就作为step3创建的对象的属性可以被直接引用。

　　

### 一个完整的实例如下：

　　我们使用my.conf来存放所有的配置信息，使用config.py来表示一个依赖于my.conf中配置信息的模其他模块。

　　先设置my.conf文件，在oslo.config语境下，[DEFAULT]字段不可省略。
```
#-*-coding:utf-8-*-
# my.conf

[DEFAULT]
#[DEFAULT]不可省略
enabled_apis = ec2, osapi_keystone, osapi_compute
bind_host = 196.168.1.111
bind_port = 9999

[rabbit]
host = 127.0.0.1
port = 12345
use_ssl=true
user_id = guest
password = guest
```

　　接着写一个脚本文件config.py，该脚本的功能非常简单，直接执行时打印该脚本使用到的配置项的值。
```
#-*-coding:utf-8-*-
# config.py
# Author: D. Wang

from oslo.config import cfg
# 声明配置项模式
# 单个配置项模式
enabled_apis_opt = cfg.ListOpt('enabled_apis',
                                   default=['ec2', 'osapi_compute'],
                                   help='List of APIs to enable by default.')
# 多个配置项组成一个模式
common_opts = [
        cfg.StrOpt('bind_host',
                   default='0.0.0.0',
                   help='IP address to listen on.'),

        cfg.IntOpt('bind_port',
                   default=9292,
                   help='Port number to listen on.')
    ]
# 配置组
rabbit_group = cfg.OptGroup(
    name='rabbit',
    title='RabbitMQ options'
)
# 配置组中的模式，通常以配置组的名称为前缀（非必须）
rabbit_ssl_opt = cfg.BoolOpt('use_ssl',
                             default=False,
                             help='use ssl for connection')
# 配置组中的多配置项模式
rabbit_Opts = [
    cfg.StrOpt('host',
                  default='localhost',
                  help='IP/hostname to listen on.'),
    cfg.IntOpt('port',
                 default=5672,
                 help='Port number to listen on.')
]

# 创建对象CONF，用来充当容器
CONF = cfg.CONF
# 注册单个配置项模式
CONF.register_opt(enabled_apis_opt)

# 注册含有多个配置项的模式
CONF.register_opts(common_opts)

# 配置组必须在其组件被注册前注册！
CONF.register_group(rabbit_group)

# 注册配置组中含有多个配置项的模式，必须指明配置组
CONF.register_opts(rabbit_Opts, rabbit_group)

# 注册配置组中的单配置项模式，指明配置组
CONF.register_opt(rabbit_ssl_opt, rabbit_group)

# 接下来打印使用配置项的值
if __name__ =="__main__":
# 调用容器对象，传入要解析的文件（可以多个）
　　CONF(default_config_files=['my.conf'])

    for i in CONF.enabled_apis:
        print ("DEFAULT.enabled_apis: " + i)

    print("DEFAULT.bind_host: " + CONF.bind_host)
    print ("DEFAULT.bind_port: " + str(CONF.bind_port))
    print("rabbit.use_ssl: "+ str(CONF.rabbit.use_ssl))
    print("rabbit.host: " + CONF.rabbit.host)
    print("rabbit.port: " + str(CONF.rabbit.port))
```
执行config.py，结果如下：
```
DEFAULT.enabled_apis: ec2
DEFAULT.enabled_apis: osapi_keystone
DEFAULT.enabled_apis: osapi_compute
DEFAULT.bind_host: 196.168.1.111
DEFAULT.bind_port: 9999
rabbit.use_ssl: True
rabbit.host: 127.0.0.1
rabbit.port: 12345
```

下面的config_test.py不指定配置文件

```
# config_test.py

from config import CONF

if __name__ =="__main__":
#   CONF(default_config_files=['my.conf'])
    CONF()
    for i in CONF.enabled_apis:
        print ("DEFAULT.enabled_apis: " + i)

    print("DEFAULT.bind_host: " + CONF.bind_host)
    print ("DEFAULT.bind_port: " + str(CONF.bind_port))
    print("rabbit.use_ssl: "+ str(CONF.rabbit.use_ssl))
    print("rabbit.host: " + CONF.rabbit.host)
    print("rabbit.port: " + str(CONF.rabbit.port))
```
执行config_test.py比较结果差别：

```
DEFAULT.enabled_apis: ec2
DEFAULT.enabled_apis: osapi_compute
DEFAULT.bind_host: 0.0.0.0
DEFAULT.bind_port: 9292
rabbit.use_ssl: False
rabbit.host: localhost
rabbit.port: 5672
```

　　可以发现，执行config.py时，成功读取了配置项的值，而执行config_test.py时，由于没有指定要解析的配置文件，所以使用的都是设置模式时指定的默认值。

　　OpenStack的oslo.config项目提供了一种开放的配置项解析工具，可以在其上实现自己需要的命令行和配置文件解析工具，也可以直接应用到自己的项目中，本文对于oslo.config项目的使用方法就介绍到这里。
