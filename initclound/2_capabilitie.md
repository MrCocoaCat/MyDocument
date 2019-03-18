### 功能 Capabilities
* 设置默认语言环境
* 设置实例名称
* 生成实例SSH 私钥
* 添加SSH keys 到用户的.ssh/authorized_keys，使其能够登陆
* 配置网络设备

### 用户可配置 User configurability
cloud-init的行为可以通过user-data进行配置。
User-data 可以在实例启动时由用户指定，[ User-Data Formats](https://cloudinit.readthedocs.io/en/latest/topics/format.html#user-data-formats) 可接受的数据内容

通过参数 --user-data 或者 --user-data-file 使ec2-run-instances 运行
* 检查本地客户端的文档，了解如何在实例创建时向cloud-init提供用户数据字符串或用户数据文件。

### 特征检测 Feature detection
新版本的cloud-init 可能会支持一系列的新功能。这允许其他应用程序检测已安装的cloud-init支持哪些功能，而无需解析其版本号。如果存在，新特性列表放置在cloudinit.version.FEATURES
当前定义的功能名称包括：
* NETWORK_CONFIG_V1 支持v1版的网络配置。[](https://cloudinit.readthedocs.io/en/latest/topics/network-config-format-v1.html#network-config-v1)
* NETWORK_CONFIG_V2 支持v2版的网络配置。[](https://cloudinit.readthedocs.io/en/latest/topics/network-config-format-v2.html#network-config-v2)

### 命令行接口 CLI Interface
可以在任何cloud-init安装的系统上访问命令行文档

```
% cloud-init --help
usage: cloud-init [-h] [--version] [--file FILES]
                  [--debug] [--force]
                  {init,modules,single,query,dhclient-hook,features,analyze,devel,collect-logs,clean,status}
                                                       ...

optional arguments:
  -h, --help            show this help message and exit
  --version, -v         show program's version number and exit
  --file FILES, -f FILES
                        additional yaml configuration files to use
  --debug, -d           show additional pre-action logging (default: False)
  --force               force running even if no datasource is found (use at
                        your own risk)

Subcommands:
  {init,modules,single,query,dhclient-hook,features,analyze,devel,collect-logs,clean,status}
    init                initializes cloud-init and performs initial modules
    modules             activates modules using a given configuration key
    single              run a single module
    query               Query instance metadata from the command line
    dhclient-hook       run the dhclient hookto record network info
    features            list defined features
    analyze             Devel tool: Analyze cloud-init logs and data
    devel               Run development tools
    collect-logs        Collect and tar all cloud-init debug info
    clean               Remove logs and artifacts so cloud-init can re-run
    status              Report cloud-init status or wait on completion
```

### CLI子命令详细信息
#### cloud-init features
打印出支持的每个功能。 如果cloud-init没有features子命令，则它也不支持本文档中描述的任何功能。

```
% cloud-init features
NETWORK_CONFIG_V1
NETWORK_CONFIG_V2
```

#### cloud-init status
报告cloud-init是否正在运行，已完成，已禁用或已出错。 如果在cloud-init中检测到错误，则退出非零。

* –long: 显示详细的状态信息。
* –wait: 阻塞等待至cloud-init完成。

```
% cloud-init status --long
status: done
time: Wed, 17 Jan 2018 20:41:59 +0000
detail:
DataSourceNoCloud [seed=/var/lib/cloud/seed/nocloud-net][dsmode=net]

# Cloud-init running still short versus long options
% cloud-init status
status: running
% cloud-init status --long
status: running
time: Fri, 26 Jan 2018 21:39:43 +0000
detail:
Running in stage: init-local
```

#### cloud-init collect-logs

收集和打包 cloud-init生成的日志，数据文件和系统信息以进行分类。 此子命令与apport集成。

* Logs collected are：
* /var/log/cloud-init*log
* /run/cloud-init
* cloud-init package version
* dmesg output
* journalctl output
* /var/lib/cloud/instance/user-data.txt


### cloud-init查询
查询cloud-init抓取的标准化云实例元数据存贮在/run/cloud-init/instance-data.json。这是一个方便的命令行界面，用于引用cloud-init在引导实例时抓取的任何缓存配置元数据。 有关详细信息，请参阅实例元数据。

* -all：将所有可用的实例数据转储为可以查询的json。
* -instance-data：指向查询源的不同instance-data.json文件的可选路径。
* -list-keys：从缓存的实例数据中列出可用的查询键。

```
# List all top-level query keys available (includes standardized aliases)
% cloud-init query --list-keys
availability_zone
base64_encoded_keys
cloud_name
ds
instance_id
local_hostname
region
v1
```

* <varname>：进入instance-data.json的以点分隔的变量路径

```
# Query cloud-init standardized metadata on any cloud
% cloud-init query v1.cloud_name
aws  # or openstack, azure, gce etc.

# Any standardized instance-data under a <v#> key is aliased as a top-level
# key for convenience.
% cloud-init query cloud_name
aws  # or openstack, azure, gce etc.

# Query datasource-specific metadata on EC2
% cloud-init query ds.meta_data.public_ipv4
```
* - format:将使用jinja-template语法呈现字符串的字符串
更换
```
# Generate a custom hostname fqdn based on instance-id, cloud and region
% cloud-init query --format 'custom-{{instance_id}}.{{region}}.{{v1.cloud_name}}.com'
custom-i-0e91f69987f37ec74.us-east-2.aws.com
```

### cloud-init analyze
获取有关cloud-init花费大部分时间的详细信息

* blame 以开销大小进行排序显示。
* dump  将所有cloud-init跟踪事件转换为机器可读JSON格式。
* show 在每个boot阶段的操作消耗的时间进行排序显示

### cloud-init devel
正在积极开发的开发工具集合，这些工具在稳定时可能会升级为顶级子命令。
* -logs：可选择删除/var/log/cloud-init \*日志文件。
* -reboot：删除工件后重新启动系统。

### cloud-init init

通常由OS init系统运行，以执行cloud-init的阶段init和init-local。有关详细信息，请参阅引导阶段。可以在命令行上运行，但由于/var/lib/cloud/instance/sem/和/var/lib/cloud/sem中的信号量，通常只能运行一次。

* –local: Run init-local stage instead of init.

### cloud-init modules
通常由OS init系统运行以执行模块：配置和模块：最终启动阶段。
这将执行配置为在init，config和final阶段运行的云配置模块。声明模块在文件/etc/cloud/cloud.cfg中的各个引导阶段运行，密钥为cloud_init_modules，cloud_init_modules和cloud_init_modules。可以在命令行上运行，但由于/var/lib/cloud/中的信号量，每个模块只能运行一次。

### cloud-init single
Attempt to run a single named cloud config module. The following example re-runs the cc_set_hostname module ignoring the module default frequency of once-per-instance:

–name: The cloud-config module name to run
–frequency: Optionally override the declared module frequency with one of (always|once-per-instance|once)

```
% cloud-init single --name set_hostname --frequency always
```
