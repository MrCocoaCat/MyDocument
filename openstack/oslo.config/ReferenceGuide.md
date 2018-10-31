### Choosing group names for configuration options
应用程序应该使用没有前缀的有意义的名称。对于Oslo库，在为配置选项命名组时使用库本身的名字而不是描述性的名字来帮助避免冲突。
如果库名称具有名称空间，那么在组名中使用' _ '作为分隔符。
例如， oslo.log库应该使用oslo_log作为组名。

### Accessing Option Values In Your Code
默认组中的选项值作为配置管理器上的属性/属性引用;组也是配置管理器上的属性，每个选项的属性都与组相关联:

```
server.start(app, conf.bind_port, conf.bind_host, conf)

self.connection = kombu.connection.BrokerConnection(
    hostname=conf.rabbit.host,
    port=conf.rabbit.port,
    ...)

```
### Loading Configuration Files
config manager有两个默认定义的CLI选项——config-file和config-dir:
```
class ConfigOpts(object):

    def __call__(self, ...):

        opts = [
            MultiStrOpt('config-file',
                    ...),
            StrOpt('config-dir',
                   ...),
        ]

        self.register_cli_opts(opts)
```

使用oslo_config.iniparser从任何提供的配置文件解析选项值。如果没有指定，则使用默认设置，例如gls-api.conf和gl-common.conf:
配置文件中的行不应该以空格开头。配置文件还支持以' # '或';'开头的注释。配置文件中的选项值和命令行中的选项值将按顺序解析。相同的选项(包括弃用的选项名和当前选项名)可以在配置文件或命令行中多次出现。后面的值总是覆盖前面的值。
同一配置目录中配置文件的顺序由其文件名的字母排序顺序定义。
对CLI args和配置文件的解析是通过调用配置管理器来启动的，例如:
```
conf = cfg.ConfigOpts()
conf.register_opt(cfg.BoolOpt('verbose', ...))
conf(sys.argv[1:])
if conf.verbose:
    ...
```
#### Option Value Interpolation
选项值可以使用PEP 292字符串替换引用其他值:
```
opts = [
    cfg.StrOpt('state_path',
               default=os.path.join(os.path.dirname(__file__), '../'),
               help='Top-level directory for maintaining nova state.'),
    cfg.StrOpt('sqlite_db',
               default='nova.sqlite',
               help='File name for SQLite.'),
    cfg.StrOpt('sql_connection',
               default='sqlite:///$state_path/$sqlite_db',
               help='Connection string for SQL database.'),
]
```

### Command Line Options
#### Positional Command Line Arguments

位置命令行参数通过一个“位置”Opt构造函数参数得到支持:
```
>>> conf = cfg.ConfigOpts()
>>> conf.register_cli_opt(cfg.MultiStrOpt('bar', positional=True))
True
>>> conf(['a', 'b'])
>>> conf.bar
['a', 'b']
```
#### Sub-Parsers
也可以使用SubCommandOpt类的argparse“子解析器”来分析额外的命令行参数:
```
>>> def add_parsers(subparsers):
...     list_action = subparsers.add_parser('list')
...     list_action.add_argument('id')
...
>>> conf = cfg.ConfigOpts()
>>> conf.register_cli_opt(cfg.SubCommandOpt('action', handler=add_parsers))
True
>>> conf(args=['list', '10'])
>>> conf.action.name, conf.action.id
('list', '10')
```

### Option Deprecation

如果您想重命名一些选项，将它们移动到另一个组或完全删除，您可以使用Opt构造函数将其声明更改为deprecated_name、deprecated_group和deprecated_for_removal参数:
```
from oslo_config import cfg

conf = cfg.ConfigOpts()

opt_1 = cfg.StrOpt('opt_1', default='foo', deprecated_name='opt1')
opt_2 = cfg.StrOpt('opt_2', default='spam', deprecated_group='DEFAULT')
opt_3 = cfg.BoolOpt('opt_3', default=False, deprecated_for_removal=True)

conf.register_opt(opt_1, group='group_1')
conf.register_opt(opt_2, group='group_2')
conf.register_opt(opt_3)

conf(['--config-file', 'config.conf'])

assert conf.group_1.opt_1 == 'bar'
assert conf.group_2.opt_2 == 'eggs'
assert conf.opt_3
```
假设文件配置有以下内容:
```
[group_1]
opt1 = bar

[DEFAULT]
opt_2 = eggs
opt_3 = True
```
脚本会成功，但是会记录三个关于给定的弃用选项的警告。
还有deprecated_reason和deprecated_since参数，用于指定关于弃用的一些额外信息。所有这些参数都可以以任意组合混合在一起。
### Global ConfigOpts
这个模块还包含ConfigOpts类的全局实例，以支持OpenStack中的通用使用模式
```
from oslo_config import cfg

opts = [
    cfg.StrOpt('bind_host', default='0.0.0.0'),
    cfg.PortOpt('bind_port', default=9292),
]

CONF = cfg.CONF
CONF.register_opts(opts)

def start(server, app):
    server.start(app, CONF.bind_port, CONF.bind_host)
```
