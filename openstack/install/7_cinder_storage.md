https://docs.openstack.org/cinder/queens/install/cinder-storage-install-rdo.html

### Prerequisites

1. Install the supporting utility packages:
```
yum install lvm2 device-mapper-persistent-data
```

```
systemctl enable lvm2-lvmetad.service
# systemctl start lvm2-lvmetad.service

```

2. 创建 LVM physical volume /dev/sdb:
```
# pvcreate /dev/sdb

Physical volume "/dev/sdb" successfully created
```
3.  创建LVM volume group cinder-volumes:

```
# vgcreate cinder-volumes /dev/sdb

Volume group "cinder-volumes" successfully created
```

4. 只有实例可以访问块存储卷。但是，底层操作系统管理与卷相关联的设备。

默认情况下，LVM卷扫描工具扫描/dev目录中包含卷的块存储设备。如果项目在其卷上使用LVM，那么扫描工具将检测这些卷并试图缓存它们，这会导致底层操作系统和项目卷出现各种问题。必须重新配置LVM，以便只扫描包含cinders -volume卷组的设备。编辑/etc/lvm/lvm.conf文件并完成以下操作:

* 在设备部分，添加一个接受/dev/sdb设备 并 拒绝所有其他设备的 过滤器:


filter array 以a作为可接受的开头,r作为拒绝的开头。 数组需要以  r/.\*/ 结束,以拒绝所有的设备。

### Install and configure components
 1. 安装包

 ```
  yum install openstack-cinder targetcli python-keystone
 ```

 2. vim /etc/cinder/cinder.conf 
