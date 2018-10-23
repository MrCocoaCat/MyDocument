### Introduction to the Block Storage service
块存储服务提供计算实例可以使用的持久块存储资源。这包括类似于Amazon Elastic Block storage (EBS)的二级附加存储。此外，还可以将图像写入块存储设备，以便计算将其用作可引导的持久实例。
块存储服务与Amazon EBS服务略有不同。块存储服务不提供像NFS那样的共享存储解决方案。使用块存储服务，您只能将设备附加到一个实例。
**块存储服务提供:**
* cinder-api
一个WSGI应用程序，它在整个块存储服务中验证和路由请求。它只支持OpenStack api，尽管有一种转换可以通过计算的EC2接口完成，该接口调用块存储客户端。

* cinder-schedule
调度程序将请求路由到适当的卷服务。根据您的配置，这可能是对正在运行的卷服务的简单轮询调度，也可能通过使用Filter Scheduler而变得更加复杂。Filter Scheduler是默认值，它支持对容量、可用性区域、卷类型和功能以及自定义过滤器等内容进行筛选。

* cinder-volume
管理块存储设备，特别是后端设备本身

* cinder-backup
提供一种将块存储卷备份到OpenStack对象存储(swift)的方法。

**块存储服务包含以下组件:**
* Back-end Storage Devices
块存储服务需要构建服务的某种形式的后端存储。默认实现是在名为“cinders -volume”的本地卷组上使用LVM。除了基本驱动实现之外，块存储服务还提供了增加对其他存储设备(如外部Raid阵列或其他存储设备)支持的方法。当使用KVM或QEMU作为管理程序时，这些后端存储设备可能具有定制的块大小。

* Users and Tenants (Projects)
使用基于角色的访问分配，许多不同的云计算客户可以使用块存储服务。角色控制允许用户执行的操作。在默认配置中，大多数操作不需要特定的角色，但是系统管理员可以在维护规则的适当json文件中配置该角色。用户对特定卷的访问受到租户的限制，但是每个用户都要分配用户名和密码。允许每个用户访问卷的密钥对是启用的，但是控制跨可用硬件资源的资源消耗的配额是每个租户的。


对于租户，可采取配额管制，以限制:
  * 可以创建的卷的数量。
  * 可以创建的快照数量。
  * 每个租户允许的GBs总数(快照和卷之间共享)。
您可以使用块存储CLI修改默认配额值，因此配额设置的限制可以由管理员用户进行编辑。
* Volumes, Snapshots, and Backups
块存储服务提供的基本资源是卷和快照，它们来自卷和卷备份:

**卷(Volumes)**——分配的块存储资源，可以作为辅助存储附加到实例，也可以作为根存储用于引导实例。卷是持久的R/W块存储设备，通常通过iSCSI连接到计算节点。
**快照(Snapshots)**——卷的只读时间点副本。快照可以从当前正在使用的卷(通过使用force True)或处于可用状态创建。然后，可以使用快照创建一个新的卷。
**备份(Backups)**——当前存储在对象存储(swift)中的卷的存档副本。

### 更改cinder配额限制
1. 显示现有项目
```
$ openstack project list
+----------------------------------+------+
| ID                               | Name |
+----------------------------------+------+
| 1c619f4c392e419683fc3525c7fa2200 | demo |
+----------------------------------+------+
```

2. 显示制定项目的quato值
```
$ cinder quota-show 1c619f4c392e419683fc3525c7fa2200

+----------------------+-------+
| Property             | Value |
+----------------------+-------+
| backup_gigabytes     | 1000  |
| backups              | 1000  |
| gigabytes            | 1000  |
| groups               | 10    |
| per_volume_gigabytes | -1    |
| snapshots            | 10    |
| volumes              | 15    |
+----------------------+-------+
```

3. 更新制定项目的配额
```
$ cinder quota-update --volumes 1000 1c619f4c392e419683fc3525c7fa2200

+----------------------+-------+
| Property             | Value |
+----------------------+-------+
| backup_gigabytes     | 1000  |
| backups              | 1000  |
| gigabytes            | 1000  |
| groups               | 10    |
| per_volume_gigabytes | -1    |
| snapshots            | 10    |
| volumes              | 1000  |
+----------------------+-------+

```

### Cinder Configuration Options
()[]https://docs.openstack.org/cinder/queens/sample_config.html
