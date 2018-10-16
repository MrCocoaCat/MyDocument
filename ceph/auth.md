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

ceph auth caps 命令可以用来修改指定用户的能力。设置新能力时会覆盖当前能力。查看用户当前的能力可以用 ceph auth get USERTYPE.USERID ；增加能力时应该加上当前已经有的能力，命令格式如下：
```
ceph auth caps USERTYPE.USERID {daemon} 'allow [r|w|x|*|...] [pool={pool-name}] [namespace={namespace-name}]' [{daemon} 'allow [r|w|x|*|...] [pool={pool-name}] [namespace={namespace-name}]']
```
例如
```
ceph auth get client.john
ceph auth caps client.john mon 'allow r' osd 'allow rw pool=liverpool'
ceph auth caps client.paul mon 'allow rw' osd 'allow rwx pool=liverpool'
ceph auth caps client.brian-manager mon 'allow *' osd 'allow *'
```

#### 删除用户
要删除一用户，用 ceph auth del 命令：
```
ceph auth del {TYPE}.{ID}
```
其中 {TYPE} 是 client 、 osd 、 mon 或 mds 之一， {ID} 是用户名或守护进程的 ID 。

#### 查看用户秘钥

打印用户的 authentication key 例如
```
ceph auth print-key {TYPE}.{ID}
```
当您需要用用户密钥(例如libvirt)填充客户端软件时，打印用户密钥是非常有用的。

#### 导入用户
要导入一个或多个用户，请使用ceph auth导入并指定一个密匙环:
```
ceph auth import -i /path/to/keyring
```
例如
```
sudo ceph auth import -i /etc/ceph/ceph.keyring
```
>ceph存储集群将添加新用户、密钥和功能，并更新现有用户、密钥和功能。

### 密钥环管理
当您通过Ceph客户机访问Ceph时，Ceph客户机将查找一个本地密匙环。默认情况下，Ceph使用以下四个keyring名称预先设置keyring设置，这样您就不必在您的Ceph配置文件中设置它们，除非您想要覆盖缺省值(不推荐):

* /etc/ceph/$cluster.$name.keyring
* /etc/ceph/$cluster.keyring
* /etc/ceph/keyring
* /etc/ceph/keyring.bin

$cluster 变量是Ceph cluster 名字，由Ceph的configu file 定义，(例如ceph.conf 表示其cluster的名字是ceph ,即cep.keyring)
$name 变量是用户类型及ID(例如，client.admin，即其秘钥为ceph.client.admin.keyring)

创建用户之后，必须获得密钥并将其添加到Ceph客户机上的keyring，以便用户能够访问Ceph存储集群。

#### 创建密钥环
当你使用程序的管理用户部分创建用户,您需要提供用户密钥Ceph客户端(s),Ceph客户指定用户可以检索的关键和验证Ceph集群存储。
Ceph客户端访问密匙环以查找用户名并检索用户的密匙。
ceph-authtool实用工具允许您创建一个密匙环。要创建空密匙环，请使用——create-keyring或-C。例如:
```
ceph-authtool --create-keyring /path/to/keyring
```

在使用多个用户创建密匙环时，我们建议使用密匙环文件名的集群名称(e.g., $cluster.keyring) 。将其保存在/etc/ceph目录中，以便密匙环配置默认设置将提取文件名，而无需在Ceph配置文件的本地副本中指定它。例如，创建ceph。通过执行以下操作进行密匙环:
```
sudo ceph-authtool -C /etc/ceph/ceph.keyring
```
当使用单个用户创建密匙环时，我们建议使用集群名、用户类型和用户名并将其保存在/etc/ceph目录中。例如,ceph.client.admin--ceph.client.admin.keyring。

要在/etc/ceph中创建一个keyring，您必须以root身份这样做。这意味着该文件将仅对root用户具有rw权限，这在密匙环包含管理员密钥时是合适的。但是，如果您打算为特定用户或用户组使用密匙环，请确保您执行chown或chmod以建立适当的密匙环所有权和访问权限。

#### 把用户加入密钥环
当你在 Ceph 存储集群中创建用户后，你可以用获取用户里面的方法获取此用户、及其密钥、能力，并存入一个密钥环文件。
当你只想使用一个用户/密匙环,在获取用户程序使用- o选项将输出保存到keyring文件格式。例如，为客户机创建一个密匙环。管理员用户，执行以下操作:
```
sudo ceph auth get client.admin -o /etc/ceph/ceph.client.admin.keyring
```
请注意，我们为单个用户使用推荐的文件格式。
当需要将用户导入到密匙环时，可以使用ceph-authtool指定目标密匙环和源密匙环。例如:

```
sudo ceph-authtool /etc/ceph/ceph.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
```

#### 创建用户

Ceph提供了创建用户函数来创建一个用户直接在Ceph集群存储。但是，您也可以直接在Ceph客户端keyring上创建用户、键和功能。然后，您可以将用户导入Ceph存储集群。例如:

```
sudo ceph-authtool -n client.ringo --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.keyring
```

您还可以同时创建一个密匙环并向密匙环添加一个新用户。例如:
```
sudo ceph-authtool -C /etc/ceph/ceph.keyring -n client.ringo --cap osd 'allow rwx' --cap mon 'allow rwx' --gen-key
```

#### 修改用户属性
要修改密匙环中的用户记录的功能，请指定密匙环，以及后面跟着功能的用户。例如:
```
sudo ceph-authtool /etc/ceph/ceph.keyring -n client.ringo --cap osd 'allow rwx' --cap mon 'allow rwx'
```
要将用户更新到Ceph存储集群，必须将keyring中的用户更新到Ceph存储集群中的用户条目。
```
sudo ceph auth import -i /etc/ceph/ceph.keyring
```
### 命令行用法
Ceph 支持用户名和密钥的下列用法：

* --id | --user

描述:
Ceph 用一个类型和 ID（ 如 TYPE.ID 或 client.admin 、 client.user1 ）来标识用户， id 、 name 、和 -n 选项可用于指定用户名（如 admin 、 user1 、 foo 等）的 ID 部分，你可以用 --id 指定用户并忽略类型，例如可用下列命令指定 client.foo 用户：
```
ceph --id foo --keyring /path/to/keyring health
ceph --user foo --keyring /path/to/keyring health
```
* --name | -n

描述:
Ceph 用一个类型和 ID （如 TYPE.ID 或 client.admin 、 client.user1 ）来标识用户， --name 和 -n 选项可用于指定完整的用户名，但必须指定用户类型（一般是 client ）和用户 ID ，例如：

```
ceph --name client.foo --keyring /path/to/keyring health
ceph -n client.foo --keyring /path/to/keyring health
```

* --keyring

描述:
包含一或多个用户名、密钥的密钥环路径。 --secret 选项提供了相同功能，但它不能用于 RADOS 网关，其 --secret 另有用途。你可以用 ceph auth get-or-create 获取密钥环并保存在本地，然后您就可以改用其他用户而无需重指定密钥环路径了。
```
sudo rbd map --id foo --keyring /path/to/keyring mypool/myimage
```

### 局限性
cephx 协议提供 Ceph 客户端和服务器间的相互认证，并没打算认证人类用户或者应用程序。如果有访问控制需求，那必须用另外一种机制，它对于前端用户访问Ceph对象存储可能是特定的，其任务是确保只有此机器上可接受的用户和程序才能访问 Ceph 的对象存储。
用于认证 Ceph 客户端和服务器的密钥通常以纯文本存储在权限合适的文件里，并保存于可信主机上。

>Important 密钥存储为纯文本文件有安全缺陷，但很难避免，它给了 Ceph 可用的基本认证方法，设置 Ceph 时应该注意这些缺陷。

尤其是任意用户、特别是移动机器不应该和 Ceph 直接交互，因为这种用法要求把明文认证密钥存储在不安全的机器上，这些机器的丢失、或盗用将泄露可访问 Ceph 集群的密钥。
相比于允许潜在的欠安全机器直接访问 Ceph 对象存储，应该要求用户先登录安全有保障的可信机器，这台可信机器会给人们存储明文密钥。未来的 Ceph 版本也许会更彻底地解决这些特殊认证问题。
当前，没有任何 Ceph 认证协议保证传送中消息的私密性。所以，即使物理线路窃听者不能创建用户或修改它们，但可以听到、并理解客户端和服务器间发送过的所有数据。此外，Ceph 没有可加密用户数据的选项，当然，用户可以手动加密、然后把它们存在对象库里，但 Ceph 没有自己加密对象的功能。在 Ceph 里存储敏感数据的用户
