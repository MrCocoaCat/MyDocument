### oslo_config 函数库

oslo.config是OpenStack的oslo项目中一个被广泛使用的库，该项工作的主要目的就是解析OpenStack中命令行（CLI）或配置文件（.conf）中的配置信息。

其官网地址

1. 配置文件：　　

用来配置OpenStack各个服务的ini风格的配置文件，通常以.conf结尾

2. 配置项(options)：　　　

配置文件或命令行中给出的配置信息的左值
如：enabled_apis = ec2中的“enabled_apis”

3. 配置项的值：    

配置文件或命令行中给出的配置信息的右值
如：enabled_apis = ec2,中的“ec2”；

4. 配置组(option groups)：　　　

一组配置项，在配置文件中通过[...]来表示
如my.conf文件中的[rabbit]字段表示接下来开始一个名为rabbit的配置组；



在 cfg.py 中包含如下代码
```
CONF = oslo_config.cfg.ConfigOpts()
```

在manager.py 中含有如下代码

```
CONF = cfg.CONF
CONF.register_cli_opts([
    cfg.ListOpt('app-lists', default=[],
                help='application module name to run'),
    cfg.MultiStrOpt('app', positional=True, default=[],
                    help='application module name to run'),
    cfg.StrOpt('pid-file', default=None, help='pid file name'),
    cfg.BoolOpt('enable-debugger', default=False,
                help='don\'t overwrite Python standard threading library'
                '(use only for debugging)'),
    cfg.StrOpt('user-flags', default=None,
               help='Additional flags file for user applications'),
])
```

引用：
https://www.cnblogs.com/Security-Darren/p/3854797.html
