### 定义选项
配置选项可以在命令行或配置文件中设置。每个选项的模式都是使用Opt类或其子类定义的，例如:

```
from oslo_config import cfg
from oslo_config import types

PortType = types.Integer(1, 65535)

common_opts = [
    cfg.StrOpt('bind_host',
               default='0.0.0.0',
               help='IP address to listen on.'),
    cfg.Opt('bind_port',
            type=PortType,
            default=9292,
            help='Port number to listen on.')
]
```

#### Option Types
选项可以通过Opt构造函数的类型参数拥有任意类型。类型参数是一个可调用的对象，
它接受一个字符串，如果该字符串不能转换，则返回该特定类型的值或引发ValueError。
为了方便起见，oslo_config中有预定义的选项子类，设置选项类型如下表所示:


|Type     |	Option    |
|:-------:|:---------:|
|oslo_config.types.String|oslo_config.cfg.StrOpt|
|oslo_config.types.String|oslo_config.cfg.SubCommandOpt
|oslo_config.types.Boolean|oslo_config.cfg.BoolOpt|
|oslo_config.types.Integer|oslo_config.cfg.IntOpt|
|oslo_config.types.Float|oslo_config.cfg.FloatOpt|
|oslo_config.types.Port|oslo_config.cfg.PortOpt|
|oslo_config.types.List|oslo_config.cfg.ListOpt|
|oslo_config.types.Dict|oslo_config.cfg.DictOpt|
|oslo_config.types.IPAddress|oslo_config.cfg.IPOpt|
|oslo_config.types.Hostname|oslo_config.cfg.HostnameOpt|
|oslo_config.types.HostAddress|oslo_config.cfg.HostAddressOpt|
|oslo_config.types.URI|oslo_config.cfg.URIOpt|


#### Registering Options(注册选项)
选项模式在运行时向配置管理器注册，但在引用选项之前:
```
class ExtensionManager(object):

    enabled_apis_opt = cfg.ListOpt(...)

    def __init__(self, conf):
        self.conf = conf
        self.conf.register_opt(enabled_apis_opt)
        ...

    def _load_extensions(self):
        for ext_factory in self.conf.osapi_compute_extension:
            ....
```

一个常见的使用模式 是在使用选项的模块或类中定义每个选项模式:
```
opts = ...

def add_common_opts(conf):
    conf.register_opts(opts)

def get_bind_host(conf):
    return conf.bind_host

def get_bind_port(conf):
    return conf.bind_port
```

可以选择通过命令行提供一个选项。在解析命令行之前，必须向config manager注册这些选项(为了-help和CLI arg验证的目的):

```
cli_opts = [
    cfg.BoolOpt('verbose',
                short='v',
                default=False,
                help='Print more verbose output.'),
    cfg.BoolOpt('debug',
                short='d',
                default=False,
                help='Print debugging output.'),
]

def add_common_opts(conf):
    conf.register_cli_opts(cli_opts)

```

#### Option Groups(选项组)
选项可以注册为属于一个组:
```
rabbit_group = cfg.OptGroup(name='rabbit',
                            title='RabbitMQ options')

rabbit_host_opt = cfg.StrOpt('host',
                             default='localhost',
                             help='IP/hostname to listen on.'),
rabbit_port_opt = cfg.PortOpt('port',
                              default=5672,
                              help='Port number to listen on.')

def register_rabbit_opts(conf):
    conf.register_group(rabbit_group)
    # options can be registered under a group in either of these ways:
    conf.register_opt(rabbit_host_opt, group=rabbit_group)
    conf.register_opt(rabbit_port_opt, group='rabbit')
```
例如，如果除了组名之外不需要组属性，则不需要显式注册组
```
def register_rabbit_opts(conf):
    # The group will automatically be created, equivalent calling:
    #   conf.register_group(OptGroup(name='rabbit'))
    conf.register_opt(rabbit_port_opt, group='rabbit')
```

如果没有指定组，选项属于配置文件的“默认”部分:
```
glance-api.conf:
  [DEFAULT]
  bind_port = 9292
  ...

  [rabbit]
  host = localhost
  port = 5672
  use_ssl = False
  userid = guest
  password = guest
  virtual_host = /
```
组中的命令行选项自动以组名作为前缀:
```
--rabbit-host localhost --rabbit-port 9999
```
#### Dynamic Groups(动态组)

组可以通过应用程序代码动态注册。这给示例生成器、发现机制和验证工具带来了挑战，因为它们事先不知道所有组的名称。构造函数的dynamic_group_owner参数指定在另一个组中注册的选项的全名，该组控制动态组的重复实例。这个选项通常是一个MultiStrOpt。例如，Cinder支持多个存储后端设备和服务。为了配置Cinder以与多个后端通信，enabled_backends选项设置为后端名称列表。每个后端组都包含与该设备或服务通信的选项。

#### Driver Groups
要解决这个问题，可以使用driver_option参数来命名组的驱动选项。每个驱动程序选项都应该定义自己的发现入口点名称空间，以返回该驱动程序的选项集，使用前缀“oslo.config.opts”加上驱动程序选项名。
在上面描述的Cinder案例中，volume_backend_name选项是组的静态定义的一部分，因此driver_option应该被设置为“volume_backend_name”。
并且插件应该在oslo.config.opts下注册。使用与主插件相同的名称注册“oslo.config.opts”。
居住在Cinder代码库中的驱动程序有一个名为“cinder”的入口点注册。

#### Special Handling Instructions
可根据需要声明选项，以便在用户不为选项提供值时引发错误:
```
opts = [
    cfg.StrOpt('service_name', required=True),
    cfg.StrOpt('image_id', required=True),
    ...
]
```
选项可能被声明为机密，以便它们的值不会泄漏到日志文件中:
```
opts = [
   cfg.StrOpt('s3_store_access_key', secret=True),
   cfg.StrOpt('s3_store_secret_key', secret=True),
   ...
]
```

#### Dictionary Options(字典的选择)

如果您需要最终用户指定一个键/值对字典，那么您可以使用DictOpt:
```
opts = [
    cfg.DictOpt('foo',
                default={})
]
```

最终用户可以在配置文件中指定foo选项，如下所示:

```
[DEFAULT]
foo = k1:v1,k2:v2
```
#### Advanced Option (高级选项)
如果您需要在示例文件中将某个选项标记为advanced，则使用该选项，表明大多数用户通常不使用该选项，并且可能对稳定性和/或性能产生重大影响:
```
from oslo_config import cfg

opts = [
    cfg.StrOpt('option1', default='default_value',
                advanced=True, help='This is help '
                'text.'),
    cfg.PortOpt('option2', default='default_value',
                 help='This is help text.'),
]

CONF = cfg.CONF
CONF.register_opts(opts)
```
这将导致将选项推到名称空间的底部，并在示例文件中标记为advanced，并标记可能的影响:
```
[DEFAULT]
...
# This is help text. (string value)
# option2 = default_value
...
<pushed to bottom of section>
...
# This is help text. (string value)
# Advanced Option: intended for advanced users and not used
# by the majority of users, and might have a significant
# effect on stability and/or performance.
# option1 = default_value
```
