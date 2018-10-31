
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
