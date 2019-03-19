### Boot Stages

为了能够提供它所执行的功能，必须以相对可控的方式将cloud-init集成到boot中。

其中包含5个阶段：
1. Generator
2. Local
3. Network
4. Config
5. Final

### Generator
在systemd下启动时，将运行一个生成器，确定cloud-init.target是否应包含在引导目标中。默认情况下，此生成器将启用cloud-init。 如果有以下情况，它将不会启用cloud-init：

* 有文件存在于 /etc/cloud/cloud-init.disabled 目录下
* 在/proc/cmdline 的内核命令行包含cloud-init=disabled。当在容器中运行时，内核命令不生效，cloud-init读取KERNEL_CMDLINE环境变量作为替代。

### Local

* 系统服务: cloud-init-local.service
* 运行： 当/ 挂载读写时即运行
* 阻塞： 尽可能多的boot，必须阻塞网络开启
* 模块： 无

Local 阶段的目的是：
* 找到本地数据源
* 将网络配置应用于系统（包括 “Fallback”）


在大多数情况下，这个阶段并没有做太多的工作。 它找到数据源并确定要使用的网络配置。 该网络配置可以来自：
* 数据源（datasource）
* fallback: Cloud-init的fallback网络包括的过程与“dhcp on eth0”相同，这是历史上最受欢迎的网络配置机制。
* none: 在/etc/cloud/cloud.cfg中写入‘network: {config: disabled}’,可以完全禁用网络配置

如果这是实例的首次引导，则呈现所选的网络配置。
这包括清除所有先前（陈旧）配置，包括所使用的设备名称及旧的MAC地址

这个阶段必须阻止网络，否则一些陈旧的配置可能被应用。这可能会产生负面影响，例如DHCP钩子或广播旧主机名。 它还会使系统从奇怪的状态以从中恢复，因为它可能必须重新启动网络设备。

**Note**:过去，本地数据源只是那些没有网络的可用数据源（例如'ConfigDrive'）。 但是，正如最近添加的DigitalOcean数据源所示，即使是需要网络的数据源也可以在此阶段运行。

### Network

* 系统服务: cloud-init.service
* 运行： local阶段之后，并且网络开启时
* 阻塞： 尽可能多的 remaining  boot
* 模块： 在 /etc/cloud/cloud.cfg中的cloud_init_modules

此阶段要求所有已配置的网络都处于联机状态，因为它将完全处理找到的所有用户数据。 这里，处理意味着：

* 检索任何#include或#include-once（递归）包括http
* 解压缩任何压缩内容
* 运行找到的任何part-handler。

这个阶段运行 disk_setup 及 mounts模块，可以分区和格式化磁盘并配置挂载点（例如 /etc/fstab ）。这些模块无法提前运行，因为它们可能从仅通过网络可用的源接收配置输入。 例如，用户可能已经在网络资源中提供了用户数据，该网络资源描述了应该如何进行本地安装。

在某些云（如Azure）上，此阶段将创建要挂载的文件系统，包括在/etc/fstab中具有过时（先前实例）引用的文件系统。 因此，除了cloud-init运行所必需的条目之外的条目/etc/fstab不应该在此阶段之后完成。

部分处理程序将在此阶段运行，包括cloud-config bootcmd在内的boothook也将运行。 此功能的用户必须知道系统在其代码运行时正在boot。

### Config

* 系统服务: cloud-config.service
* 运行： Network阶段之后
* 阻塞： 无
* 模块： 在 /etc/cloud/cloud.cfg中的cloud_config_modules

此阶段仅运行配置模块。 在这里运行对其他启动阶段没有影响的模块。

### Final

* 系统服务: cloud-final.service
* 运行： boot 的最后一个部分
* 阻塞： 无
* 模块： 在 /etc/cloud/cloud.cfg中的cloud_final_modules

此阶段尽可能在启动后运行。用户在登录系统后习惯于运行的任何脚本都应该在这里正确运行。在这里运行的事情包括

* 安装包
* 配置管理插件
* user-scripts

对于cloud-init外部的脚本，等待cloud-init完成，cloud-init status子命令可以帮助阻止外部脚本，直到完成cloud-init，而无需编写自己的systemd单元依赖链。 有关详细信息，请参阅cloud-init状态。
