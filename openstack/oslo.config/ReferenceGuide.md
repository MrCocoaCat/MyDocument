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

### Opt and Subclasses
*class oslo_config.cfg.Opt (name, type=None, dest=None, short=None, default=None, positional=False, metavar=None, help=None, secret=False, required=False, deprecated_name=None, deprecated_group=None, deprecated_opts=None, sample_default=None, deprecated_for_removal=False, deprecated_reason=None, deprecated_since=None, mutable=False, advanced=False)*
所有配置选项的基类。
唯一需要的参数是选项的名称。但是，通常还为所有选项提供默认和帮助字符串。

Parameters:
* name – the option’s name
* type – the option’s type. Must be a callable object that takes string and returns converted and validated value
* dest – 对应的ConfigOpts属性的名称
* short – a single character CLI option name
* default – 选项的默认值
* positional – True if the option is a positional CLI argument
* metavar – the option argument to show in –help
* help – 解释如何使用该选项
* secret – 如果在日志输出模糊该值，则为真
* required – 如果必须为此选项提供值，则为true
* deprecated_name – deprecated name option. Acts like an alias
* deprecated_group – the group containing a deprecated alias
* deprecated_opts – list of DeprecatedOpt
* sample_default – 示例配置文件的默认字符串
* deprecated_for_removal – indicates whether this opt is planned for removal in a future release
* deprecated_reason – indicates why this opt is planned for removal in a future release. Silently ignored if deprecated_for_removal is False
* deprecated_since – indicates which release this opt was deprecated in. Accepts any string, though valid version strings are encouraged. Silently ignored if deprecated_for_removal is False
* mutable – (可变的)如果此选项可能被重新加载，则为真
* advanced – a bool True/False value if this option has advanced usage and is not normally used by the majority of users

Opt对象没有公共方法，但是有一些公共属性:

* name
选项的名称，其中可能包含连字符

* type
一个可调用的对象，它接受字符串并返回经过转换和验证的值。 Default types are available from oslo_config.types

* dest
the (hyphen-less) ConfigOpts property which contains the option value

* short
a single character CLI option name

* default
选项的默认值

* sample_default
示例配置文件中包含的默认值字符串

* positional
True if the option is a positional CLI argument

* metavar
the name shown as the argument to a CLI option in –help output

* help
a string explaining how the option’s value is used

* advanced
在样例文件中，bool值指示该选项是高级的

*class oslo_config.cfg.StrOpt(name, choices=None, quotes=None, regex=None, ignore_case=False, max_length=None, **kwargs)*

字符串类型选项，配置oslo_config.types.String类型

Parameters:
* name – 选项名称
* choices –选项序列，有效值或带有描述的有效值元组。
* quotes –如果True并且string是用单引号或双引号括起来的，将去掉这些引号。
* regex – Optional regular expression (string or compiled regex) that the value must match on an unanchored search.
* ignore_case – 如果为真， case differences  ‘choices’ 与 ‘regex’ 之间的差异将被忽略.
* max_length – 如果是正整数，则该值必须小于或等于该参数。
* \**kwargs – 传递给Opt的任意关键字参数

*class oslo_config.cfg.BoolOpt(name, **kwargs)*
Boolean选项.
Bool opts are set to True or False on the command line using –optname or –nooptname respectively.

In config files, boolean values are cast with Boolean type.

Parameters:
*  name – the option’s name
* \**kwargs – arbitrary keyword arguments passed to Opt

*class oslo_config.cfg.IntOpt(name, min=None, max=None, **kwargs)*
整数选项
配置oslo_config.types.Integer类型

Parameters:
* name – the option’s name
* min – minimum value the integer can take
* max – maximum value the integer can take
* \**kwargs – arbitrary keyword arguments passed to Opt


*class oslo_config.cfg.FloatOpt(name, min=None, max=None, **kwargs)*
Float选项
配置oslo_config.types.Float类型
Parameters:
* name – the option’s name
* min – minimum value the float can take
* max – maximum value the float can take
* \**kwargs – arbitrary keyword arguments passed to Opt


*class oslo_config.cfg.ListOpt(name, item_type=None, bounds=None, **kwargs)*
Option with List(String) type

Option with type oslo_config.types.List

Parameters:
* name – the option’s name
* item_type – type of items (see oslo_config.types)
* bounds – if True the value should be inside “[” and “]” pair
* \**kwargs – arbitrary keyword arguments passed to Opt

*class oslo_config.cfg.DictOpt(name, **kwargs)*
Option with Dict(String) type

Option with type oslo_config.types.Dict

Parameters:
* name – the option’s name
* \**kwargs – arbitrary keyword arguments passed to Opt

*class oslo_config.cfg.MultiOpt(name, item_type, **kwargs)*
Multi-value option.

多重选择值是可指定多次的类型选择。opt值是一个包含所有指定值的列表。

Parameters:
* name – the option’s name
* item_type – Type of items (see oslo_config.types)
* \**kwargs – arbitrary keyword arguments passed to Opt

例如
```
cfg.MultiOpt('foo',
             item_type=types.Integer(),
             default=None,
             help="Multiple foo option")
```
命令行 -foo=1 -foo=2将导致cfg.CONF.foo包含[1,2]

*class oslo_config.cfg.MultiStrOpt(name, **kwargs)*
MultiOpt with a MultiString item_type.

MultiOpt with a default oslo_config.types.MultiString item type.

Parameters:
* name – the option’s name
* \**kwargs – arbitrary keyword arguments passed to MultiOpt


*class oslo_config.cfg.IPOpt(name, version=None, **kwargs)*
IPAddress 类型配置

Option with type oslo_config.types.IPAddress

Parameters:
* name – the option’s name
* version – one of either 4, 6, or None to specify either version.
* \**kwargs – arbitrary keyword arguments passed to Opt


*class oslo_config.cfg.PortOpt(name, min=None, max=None, choices=None, **kwargs)*

TCP/IP 端口号配置选项. 端口范围为 0 至 65535.
选项类型为oslo_config.types.Integer

Parameters:
* name – the option’s name
* min – minimum value the port can take
* max – maximum value the port can take
* choices – Optional sequence of either valid values or tuples of * valid values with descriptions.
* \**kwargs – arbitrary keyword arguments passed to Opt

*class oslo_config.cfg.HostnameOpt(name, **kwargs)*

hostname选项. Only accepts valid hostnames.
选项类型为oslo_config.types.Hostname

Parameters:
* name – the option’s name
* \**kwargs – arbitrary keyword arguments passed to Opt

*class oslo_config.cfg.HostAddressOpt(name, version=None, **kwargs)*
配置IP或hostname.
接受可用的 hostnames 或可用的IP地址.
选项类型为 oslo_config.types.HostAddress

Parameters:
* name – the option’s name
* version – one of either 4, 6, or None to specify either version.
* \**kwargs – arbitrary keyword arguments passed to Opt

*class oslo_config.cfg.URIOpt(name, max_length=None, schemes=None, **kwargs)*
Opt with URI type

Option with type oslo_config.types.URI

Parameters:
* name – the option’s name
* max_length – If positive integer, the value must be less than or equal to this parameter.
* schemes – list of valid URI schemes, e.g. ‘https’, ‘ftp’, ‘git’
* \**kwargs – arbitrary keyword arguments passed to Opt

*class oslo_config.cfg.DeprecatedOpt(name, group=None)*
Represents a Deprecated option.

Here’s how you can use it:
```
oldopts = [cfg.DeprecatedOpt('oldopt1', group='group1'),
           cfg.DeprecatedOpt('oldopt2', group='group2')]
cfg.CONF.register_group(cfg.OptGroup('group1'))
cfg.CONF.register_opt(cfg.StrOpt('newopt', deprecated_opts=oldopts),
                      group='group1')
```
For options which have a single value (like in the example above), if the new option is present (“[group1]/newopt” above), it will override any deprecated options present (“[group1]/oldopt1” and “[group2]/oldopt2” above).

If no group is specified for a DeprecatedOpt option (i.e. the group is None), lookup will happen within the same group the new option is in. For example, if no group was specified for the second option ‘oldopt2’ in oldopts list:
```
oldopts = [cfg.DeprecatedOpt('oldopt1', group='group1'),
           cfg.DeprecatedOpt('oldopt2')]
cfg.CONF.register_group(cfg.OptGroup('group1'))
cfg.CONF.register_opt(cfg.StrOpt('newopt', deprecated_opts=oldopts),
                      group='group1')
```
then lookup for that option will happen in group ‘group1’.

If the new option is not present and multiple deprecated options are present, the option corresponding to the first element of deprecated_opts will be chosen.

Multi-value options will return all new and deprecated options. So if we have a multi-value option “[group1]/opt1” whose deprecated option is “[group2]/opt2”, and the conf file has both these options specified like so:

[group1]
opt1=val10,val11

[group2]
opt2=val21,val22
Then the value of “[group1]/opt1” will be [‘val10’, ‘val11’, ‘val21’, ‘val22’].



*class oslo_config.cfg.SubCommandOpt(name, dest=None, handler=None, title=None, description=None, help=None)*
Sub-command options.

Sub-command options allow argparse sub-parsers to be used to parse additional command line arguments.

The handler argument to the SubCommandOpt constructor is a callable which is supplied an argparse subparsers object. Use this handler callable to add sub-parsers.

The opt value is SubCommandAttr object with the name of the chosen sub-parser stored in the ‘name’ attribute and the values of other sub-parser arguments available as additional attributes.

Parameters:
* name – the option’s name
* dest – the name of the corresponding ConfigOpts property
* handler – callable which is supplied subparsers object when invoked
* title – title of the sub-commands group in help output
* description – description of the group in help output
* help – a help string giving an overview of available sub-commands
class oslo_config.cfg.OptGroup(name, title=None, help=None, dynamic_group_owner='', driver_option='')¶
Represents a group of opts.

CLI opts in the group are automatically prefixed with the group name.

Each group corresponds to a section in config files.

An OptGroup object has no public methods, but has a number of public string properties:

name
the name of the group

title
the group title as displayed in –help

help
the group description as displayed in –help

Parameters:
* name (str) – the group name
* title (str) – the group title for –help
* help (str) – the group description for –help
* dynamic_group_owner (str) – The name of the option that controls repeated instances of this group.
* driver_option (str) – The name of the option within the group that controls which driver will register options
