(安装地址)[http://docs.ceph.com/docs/master/rbd/rbd-openstack/]
(官方中文文档)[http://docs.ceph.org.cn/rbd/rbd-openstack/]

### CREATE A POOL
默认情况下，Ceph块设备使用rbd池。您可以使用任何可用的池。我们建议创建一个用于Cinder的池和一个用于Glanc的池。确保Ceph集群正在运行，然后创建池。
```
ceph osd pool create volumes 128
ceph osd pool create images 128
ceph osd pool create backups 128
ceph osd pool create vms 128
```
新创建的池必须在使用之前进行初始化。使用rbd工具初始化池
```
rbd pool init volumes
rbd pool init images
rbd pool init backups
rbd pool init vms
```

### CONFIGURE OPENSTACK CEPH CLIENTS

运行glous -api、cinders -volume、nova-compute和cinbackup备份的节点充当Ceph客户机。每个都需要ceph配置文件:

```
ssh {your-openstack-server} sudo tee /etc/ceph/ceph.conf </etc/ceph/ceph.conf
```

**INSTALL CEPH CLIENT PACKAGES**

在glance-api 节点,需要为librbd安装 Python bindings

```
sudo yum install python-rbd
```

在 nova-compute, cinder-backup 及 cinder-volume 节点, use both the Python bindings and the client command line tools:

```
sudo yum install ceph-common
```

**SETUP CEPH CLIENT AUTHENTICATION**
添加认证信息

1. 创建新的用户

* 监视器能力： 监视器能力包括 r 、 w 、 x 和 allow profile {cap} ，例如
* OSD 能力： OSD 能力包括 r 、 w 、 x 、 class-read 、 class-write 和 profile osd 。另外， OSD 能力还支持存储池和命名空间的配置。


创建client.glance用户,

```
ceph auth get-or-create client.glance mon 'profile rbd' osd 'profile rbd pool=images'
```
创建client.cinder用户

```
ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images'
```

创建client.cinder-backup用户
```
ceph auth get-or-create client.cinder-backup mon 'profile rbd' osd 'profile rbd pool=backups'

```

2. 添加key

为glance 添加key

```
ceph auth get-or-create client.glance | ssh {your-glance-api-server} sudo tee /etc/ceph/ceph.client.glance.keyring

ssh {your-glance-api-server} sudo chown glance:glance /etc/ceph/ceph.client.glance.keyring
```
192.168.125.125
>ceph auth get-or-create client.glance | ssh 192.168.125.125 sudo tee /etc/ceph/ceph.client.glance.keyring

>ssh 192.168.125.125 sudo chown glance:glance /etc/ceph/ceph.client.glance.keyring


为cinder添加key
```
ceph auth get-or-create client.cinder | ssh {your-volume-server} sudo tee /etc/ceph/ceph.client.cinder.keyring

ssh {your-cinder-volume-server} sudo chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
```

为cinder-backup添加key
```
ceph auth get-or-create client.cinder-backup | ssh {your-cinder-backup-server} sudo tee /etc/ceph/ceph.client.cinder-backup.keyring

ssh {your-cinder-backup-server} sudo chown cinder:cinder /etc/ceph/ceph.client.cinder-backup.keyring
```

运行 nova-compute的节点需要keyring文件
```
ceph auth get-or-create client.cinder | ssh {your-nova-compute-server} sudo tee /etc/ceph/ceph.client.cinder.keyring
```

他们还需要存储 client.cinder 的秘密密钥在libvirt中。libvirt进程需要它访问集群，同时从Cinder附加块设备。
在运行nova-compute的节点上创建密钥的临时副本:

```
ceph auth get-key client.cinder | ssh {your-compute-node} tee client.cinder.key

```

然后，在计算节点上，向libvirt添加密钥，并删除密钥的临时副本:
```
uuidgen
9191d801-4d57-476e-acfb-84bf55d0bd54
```

```
cat > secret.xml <<EOF
<secret ephemeral='no' private='no'>
  <uuid>9191d801-4d57-476e-acfb-84bf55d0bd54</uuid>
  <usage type='ceph'>
    <name>client.cinder secret</name>
  </usage>
</secret>
EOF
```

```
sudo virsh secret-define --file secret.xml
Secret 457eb676-33da-42ec-9a8c-9293d545c337 created

sudo virsh secret-set-value --secret 9191d801-4d57-476e-acfb-84bf55d0bd54 --base64 $(cat client.cinder.key)&&rm client.cinder.key secret.xml
```
稍后保存秘密的uuid，以便配置nova-compute。

************************

### CONFIGURE OPENSTACK TO USE CEPH

#### 配置GLANCE

Glance可以使用多个后端来存储镜像。要默认使用Ceph块设备，请像下面这样配置Glance。
*KILO 及之后版本*

编辑 /etc/glance/glance-api.conf文件

 ```

 [glance_store]
stores = rbd
default_store = rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8

 ```
**ENABLE COPY-ON-WRITE CLONING OF IMAGES（开启）**
注意，这将通过Glance的API公开后端位置，因此启用此选项的端点不应公开访问。
如果你想允许使用 image 的写时复制克隆，MITAKA 之外的版本。还可以在[DEFAULT]部分下添加:

```
[DEFAULT]
show_image_direct_url = True
```

**DISABLE CACHE MANAGEMENT**

关闭 the Glance cache management 以防止镜像cached 在 /var/lib/glance/image-cache/, 假设您的配置文件flavor = keystone+cachemanagement:

```
[paste_deploy]
flavor = keystone
```

**IMAGE PROPERTIES**

建议使用如下设置

增加virtio-scsi控制器，获得更好的性能和对丢弃操作的支持

```
hw_scsi_model=virtio-scsi
```
链接控制节点的每一个cinder block devices
```
hw_disk_bus=scsi
```

开启QEMU guest agent
```
hw_qemu_guest_agent=yes
```

通过QEMU客户代理发送fs-freeze/thaw调用
```
os_require_quiesce=yes
```

重启glance

```
systemctl restart openstack-glance-api
```
#### 配置 CINDER
OpenStack需要驱动程序与Ceph块设备进行交互。还必须为块设备指定池名。
在OpenStack 节点上, 编辑文件 /etc/cinder/cinder.conf 并添加一下内容

```
[DEFAULT]
...
enabled_backends = ceph
glance_api_version = 2
...
[ceph]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = ceph
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
```

如果添加了身份认证，

```
rbd_user = cinder
rbd_secret_uuid = 457eb676-33da-42ec-9a8c-9293d545c337
```

#### 配置 NOVA


为了将所有虚拟机直接引导到Ceph，必须配置Nova的临时后端。建议在Ceph配置文件中启用RBD缓存(默认情况下启用，因为是Giant)。此外，启用管理套接字在进行故障排除时带来了很多好处。使用Ceph块设备让每个虚拟机有一个套接字将有助于调查性能和/或错误行为。
这个套接字可以这样访问:
```
ceph daemon /var/run/ceph/ceph-client.cinder.19195.32310016.asok help
```

在每一个计算节点编辑 Ceph配置文件 :

```
[client]
    rbd cache = true
    rbd cache writethrough until flush = true
    admin socket = /var/run/ceph/guests/$cluster-$type.$id.$pid.$cctid.asok
    log file = /var/log/qemu/qemu-guest-$pid.log
    rbd concurrent management ops = 20
```

为这些路径配置permissions权限

```
mkdir -p /var/run/ceph/guests/ /var/log/qemu/
chown qemu:libvirtd /var/run/ceph/guests /var/log/qemu/
```
