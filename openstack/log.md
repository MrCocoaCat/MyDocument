
[](https://blog.csdn.net/zanshichun/article/details/72672945)
openstack错误日志查看方法
2017年05月24日 08:44:05 z_Dc 阅读数：4313

日志对于一个稳定的系统来说相当重要，对于OpenStack这样一个大型的系统，日志当然也是必不可少，理解Openstack系统的日志对于保证OpenStack环境稳定非常重要。对于出现系统错误，查看日志是一个很好的习惯。

OpenStack通过生成大量日志信息来帮助排查系统安装运行期间出现的问题，接下来介绍几个常见服务的相关日志位置。
Nova日志

OpenStack计算服务日志位于/var/log/nova，默认权限拥有者是nova用户。需要注意的是，并不是每台服务器上都包含所有的日志文件,例如nova-compute.log仅在计算节点生成。

    nova-compute.log：虚拟机实例在启动和运行中产生的日志
    nova-network.log：关于网络状态、分配、路由和安全组的日志
    nova-manage.log：运行nova-manage命令时产生的日志
    nova-scheduler.log：有关调度的，分配任务给节点以及消息队列的相关日志
    nova-objectstore.log：镜像相关的日志
    nova-api.log：用户与OpenStack交互以及OpenStack组件间交互的消息相关日志
    nova-cert.log：nova-cert过程的相关日志
    nova-console.log：关于nova-console的VNC服务的详细信息
    nova-consoleauth.log：关于nova-console服务的验证细节
    nova-dhcpbridge.log：与dhckbridge服务先关的网络信息

Dashboard日志

Dashboard是一个DJango的web应用程序，默认运行在Apache服务器上，相应的运行日志也都记录在Apache的日志中，用户可以在/var/log/apache2/中查看。
存储日志

对象存储Swift默认日志写到syslog中，在Ubuntu系统中，可以通过/var/log/syslog查看，在其他系统中，可能位于/var/log/messages中。
块存储Cinder产生的日志默认存放在/var/log/cinder目录中
- cinder-api.log：关于cinder-api服务的细节
- cinder-scheduler.log：关于cinder调度服务的操作的细节
- cinder-volume.log：与cinder卷服务相关的日志项
Keystone日志

身份认证Keystone服务的日志记录在/var/log/keystone/keystone.log中。
Glance日志

镜像服务Glance的日志默认存放在/var/log/glance目录中
- api.log：Glance API相关的日志
- registry.log：Glance registry服务相关的日志
根据日志配置的不同，会保存诸如元信息更新和访问记录这些信息。
Neutron日志

网络服务Neutron的日志默认存放在/var/log/neutron目录中
- dhcp-agent.log：关于dhcp-agent的日志
- l3-agent.log：与l3代理及其功能相关的日志
- metadata-agent.log：通过neutron代理给Nova元数据服务的相关日志
- openvswitch-agent.log：与openvswitch相关操作的日志项，在具体实现OpenStack网络时，如果使用了不同的插件，就会有相应的日志文件名
- server.log：与Neutron API服务相关的日志

日志的格式

OpenStack 的日志格式都是统一的，如下

<时间戳><日志等级><代码模块><Request ID><日志内容><源代码位置>

简单说明一下
时间戳 日志记录的时间，包括 年 月 日 时 分 秒 毫秒
日志等级 有INFO WARNING ERROR DEBUG等
代码模块 当前运行的模块Request ID 日志会记录连续不同的操作，为了便于区分和增加可读性，每个操作都被分配唯一的Request ID,便于查找
日志内容 这是日志的主体，记录当前正在执行的操作和结果等重要信息
源代码位置 日志代码的位置，包括方法名称，源代码文件的目录位置和行号。这一项不是所有日志都有

下面举例说明

2015-12-10 20:46:49.566 DEBUG nova.virt.libvirt.config [req-5c973fff-e9ba-4317-bfd9-76678cc96584 None None] Generated XML ('<cpu>\n  <arch>x86_64</arch>\n  <model>Westmere</model>\n  <vendor>Intel</vendor>\n  <topology sockets="2" cores="3" threads="1"/>\n  <feature name="avx"/>\n  <feature name="ds"/>\n  <feature name="ht"/>\n  <feature name="hypervisor"/>\n  <feature name="osxsave"/>\n  <feature name="pclmuldq"/>\n  <feature name="rdtscp"/>\n  <feature name="ss"/>\n  <feature name="vme"/>\n  <feature name="xsave"/>\n</cpu>\n',) to_xml /opt/stack/nova/nova/virt/libvirt/config.py:82

这条日志我们可以得知：

    代码模块是 nova.virt.libvirt.config，由此可知应该是 Hypervisor Libvirt 相关的操作

    日志内容是生成 XML

    如果要跟踪源代码，可以到 /opt/stack/nova/nova/virt/libvirt/config.py 的 82 行，方法是 to_xml

又例如下面这条日志：

2015-12-10 20:46:49.671 ERROR nova.compute.manager [req-5c973fff-e9ba-4317-bfd9-76678cc96584 None None] No compute node record for host devstack-controller

这条日志我们可以得知：

    这是一个 ERROR 日志

    具体内容是 “No compute node record for host devstack-controller”

    该日志没有指明源代码位置

关于日志的几点说明

    学习 OpenStack 需要看日志吗？这个问题的答案取决于你是谁。如果你只是 OpenStack 的最终用户，那么日志对你不重要。你只需要在 GUI上 操作，如果出问题直接找管理员就可以了。但如果你是 OpenStack 的运维和管理人员，日志对你就非常重要了。因为 OpenStack 操作如果出错，GUI 上给出的错误信息是非常笼统和简要的，日志则提供了大量的线索，特别是当 debug 选项打开之后。如果你正处于 OpenStack 的学习阶段，正如我们现在的状态，那么也强烈建议你多看日志。日志能够帮助你更加深入理解 OpenStack 的运行机制。

    日志能够帮助我们深入学习 OpenStack 和排查问题。但要想高效的使用日志还得有个前提：必须先掌握 OpenStack 的运行机制，然后针对性的查看日志。就拿 Instance Launch 操作来说，如果之前不了解 nova-* 各子服务在操作中的协作关系，如果没有理解流程图，面对如此多和分散的日志文件，我们也很难下手不是。

    对于 OpenStack 的运维和管理员来说，在大部分情况下，我们都不需要看源代码。因为 OpenStack 的日志记录得很详细了，足以帮助我们分析和定位问题。但还是有一些细节日志没有记录，必要时可以通过查看源代码理解得更清楚。即便如此，日志也会为我们提供源代码查看的线索，不需要我们大海捞针。这一点我们会在后面的操作分析中看到。


改变日志级别

每个OpenStack服务的默认日志级别均为警告级（Warning），该级别的日志对于了解运行中系统的状态或者基本的错误定位已经够用，但是有时候需要上调日志级别来帮助诊断问题，或者下调日志级别以减少日志噪声。由于各个服务的日志设置方式类似，因此这里就以Nova服务为例。
设置Nova服务的日志级别

vi /etc/nova/logging.conf
将列出的服务的日志级别修改为DEBUG、INFO或WARNING

<code class="hljs makefile has-numbering" style="display: block; padding: 0px; color: inherit; box-sizing: border-box; font-family: 'Source Code Pro', monospace;font-size:undefined; white-space: pre; border-radius: 0px; word-wrap: normal; background: transparent;">[logger_root] <span class="hljs-constant" style="box-sizing: border-box;">level</span> = WARNING <span class="hljs-constant" style="box-sizing: border-box;">handlers</span> = null [logger_nova] <span class="hljs-constant" style="box-sizing: border-box;">level</span> = INFO <span class="hljs-constant" style="box-sizing: border-box;">handlers</span> = stderr <span class="hljs-constant" style="box-sizi
