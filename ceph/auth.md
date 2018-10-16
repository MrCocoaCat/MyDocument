[官方文档](http://docs.ceph.org.cn/rados/operations/user-management/)

#### 授权（能力）
Ceph 用能力（ capabilities, caps ）这个术语来描述给认证用户的授权，这样才能使用监视器、 OSD 、和元数据服务器的功能。能力也用于限制对一存储池内的数据或某个名字空间的访问。 Ceph 的管理用户可在创建或更新某用户时赋予他能力。

能力的语法符合下面的形式：

{daemon-type} 'allow {capability}' [{daemon-type} 'allow {capability}']
* 监视器能力： 监视器能力包括 r 、 w 、 x 和 allow profile {cap} ，例如：
```
mon 'allow rwx'
mon 'allow profile osd'
```
* OSD 能力： OSD 能力包括 r 、 w 、 x 、 class-read 、 class-write 和 profile osd 。另外， OSD 能力还支持存储池和命名空间的配置。
```
osd 'allow {capability}' [pool={poolname}] [namespace={namespace-name}]
```

* 元数据服务器能力： 元数据服务器能力比较简单，只需要 allow 或者空白，也不会解析更多选项。

```
mds 'allow'
```
>Note Ceph 对象网关守护进程（ radosgw ）是 Ceph 存储集群的一种客户端，
所以它没被表示成一种独立的 Ceph 存储集群守护进程类型。

下面描述了各种能力。

* allow
描述:	在守护进程的访问设置之前，仅对 MDS 隐含 rw 。

* r
描述:	授予用户读权限，监视器需要它才能搜刮 CRUSH 图。

* w
描述:	授予用户写对象的权限。

* x
描述:	授予用户调用类方法的能力，即同时有读和写，且能在监视器上执行 auth 操作。

* class-read
描述:	授予用户调用类读取方法的能力， x 的子集。

* class-write
描述:	授予用户调用类写入方法的能力， x 的子集。

* *
描述:	授权此用户读、写和执行某守护进程/存储池，且允许执行管理命令。

* profile osd
描述:	授权一个用户以 OSD 身份连接其它 OSD 或监视器。授予 OSD 们允许其它 OSD 处理复制、心跳流量和状态报告。

* profile mds
描述:	授权一个用户以 MDS 身份连接其它 MDS 或监视器。

* profile bootstrap-osd
描述:	授权一用户自举引导一 OSD 。授予部署工具，像 ceph-disk 、 ceph-deploy 等等，这样它们在自举引导 OSD 时就有权限增加密钥了。

* profile bootstrap-mds
描述:	授权一用户自举引导一元数据服务器。授予像 ceph-deploy 一样的部署工具，这样它们在自举引导元数据服务器时就有权限增加密钥了。

#### 存储池
存储池是用户存储数据的逻辑分区。在 Ceph 部署中，经常创建存储池作为逻辑分区、用以归类相似的数据。例如，用 Ceph 作为 OpenStack 的后端时，典型的部署通常会创建多个存储池，分别用于存储卷宗、映像、备份和虚拟机，以及用户（如 client.glance 、 client.cinder 等）。


#### 命名空间
池中的对象可以关联到命名空间——池中的一组逻辑对象。用户对池的访问可以与名称空间相关联，以便用户只能在名称空间内进行读写操作。写入到池中名称空间的对象只能被访问该名称空间的用户访问。
名称空间的基本原理是，为了授权单独的用户集，池可以是分离数据集的计算代价高昂的方法。例如，每个OSD池应该有大约100个放置组。一个拥有1000个osd的示例集群将为一个池提供10万个放置组。每个池将在示例集群中创建另外100,000个放置组。相比之下，将对象写入名称空间只会将名称空间与对象名称关联起来，而不会产生单独池的计算开销。您可以使用名称空间，而不是为一个用户或一组用户创建单独的池。
>注意:此时只能使用librados。

### 管理用户
用户管理功能为Ceph存储集群管理员提供了直接在Ceph存储集群中创建、更新和删除用户的能力。
当您在Ceph存储集群中创建或删除用户时，您可能需要将密钥分发给客户端，以便将它们添加到密匙环中。详情见密钥环管理。

#### 罗列用户

列举在cluster中的用户，使用如下操作
```
ceph auth list
```
Ceph 将会列举在clusterh中的所用的用户，在一个two-node 的cluster中，命令结果如下所示
```
installed auth entries:

osd.0
        key: AQCvCbtToC6MDhAATtuT70Sl+DymPCfDSsyV4w==
        caps: [mon] allow profile osd
        caps: [osd] allow *
osd.1
        key: AQC4CbtTCFJBChAAVq5spj0ff4eHZICxIOVZeA==
        caps: [mon] allow profile osd
        caps: [osd] allow *
client.admin
        key: AQBHCbtT6APDHhAA5W00cBchwkQjh3dkKsyPjw==
        caps: [mds] allow
        caps: [mon] allow *
        caps: [osd] allow *
client.bootstrap-mds
        key: AQBICbtTOK9uGBAAdbe5zcIGHZL3T/u2g6EBww==
        caps: [mon] allow profile bootstrap-mds
client.bootstrap-osd
        key: AQBHCbtT4GxqORAADE5u7RkpCN/oo4e5W0uBtw==
        caps: [mon] allow profile bootstrap-osd
```

使用TYPE.ID形式表示用户。osd.0 表示其用户类型为osd,其ID为0。client.admin其用户类型为client,ID 为admin。可以使用-o {filename}选项指定一个文件名，用于存储auth list 命令的输出

#### 获取用户
要检索特定的用户、密钥和功能，请执行以下操作:
```
ceph auth get {TYPE.ID}
```
例如
```
ceph auth get client.admin
```
同样可以执行-o {filename}
#### 新增用户

添加用户将 创建用户名、密钥和用于创建用户的命令中包含的任何功能。用户的密钥允许用户使用Ceph存储集群进行身份验证。用户的功能授权用户在Ceph监视器(mon)、Ceph osd或Ceph元数据服务器(mds)上读、写或执行。
有如下方式可以增加用户

* ceph auth add:这个命令是添加用户的标准方法。它将创建用户、生成密钥并添加任何指定的功能。

* ceph auth get-or-create:这个命令通常是创建用户最方便的方法，因为它返回一个带有用户名(在括号中)和密钥的密钥文件格式。如果用户已经存在，该命令只返回keyfile格式的用户名和密钥。您可以使用-o {filename}选项将输出保存到文件中。

* ceph auth get-or-create-key:该命令是创建用户并返回用户密钥(仅)的一种方便方法。这对于只需要密钥的客户端(例如libvirt)非常有用。如果用户已经存在，该命令只返回密钥。您可以使用-o {filename}选项将输出保存到文件中。

在创建客户端用户时，您可以创建一个没有功能的用户。除了身份验证之外，没有任何功能的用户是无用的，因为客户机无法从监视器检索集群映射。但是，如果您希望以后使用ceph auth caps命令延迟添加功能，那么可以创建没有功能的用户。
一个典型的用户至少在Ceph监视器上具有读取能力，在Ceph osd上具有读写能力。此外，用户的OSD权限通常仅限于访问特定的池。

```
ceph auth add client.john mon 'allow r' osd 'allow rw pool=liverpool'

ceph auth get-or-create client.paul mon 'allow r' osd 'allow rw pool=liverpool'

ceph auth get-or-create client.george mon 'allow r' osd 'allow rw pool=liverpool' -o george.keyring

ceph auth get-or-create-key client.ringo mon 'allow r' osd 'allow rw pool=liverpool' -o ringo.key
```

#### 修改用户能力
