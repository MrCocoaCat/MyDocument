### 安装glance
glance为虚拟机提供虚拟机的镜像服务，其本身不负责实际的存储。
OpenStack 的镜像服务 (glance) 允许用户发现、注册和恢复虚拟机镜像。它提供了一个 REST API，允许您查询虚拟机镜像的 metadata 并恢复一个实际的镜像。您可以存储虚拟机镜像通过不同位置的镜像服务使其可用，就像 OpenStack 对象存储那样从简单的文件系统到对象存储系统。
>为了简单起见，本指南描述了如何配置映像服务以使用文件后端，该文件后端将上传并存储在承载映像服务的控制器节点上。默认情况下，这个目录是/var/lib/glance/images/。在继续之前，确保controller节点在这个目录中至少有几GB的可用空间。由于文件后端通常是控制器节点的本地端，因此它通常不适合多节点部署。有关其他后端需求的信息，请参阅配置参考资

OpenStack映像服务是基础设施即服务(IaaS)的核心。它接受对磁盘或服务器映像的API请求，以及来自最终用户或OpenStack计算组件的元数据定义。它还支持在各种存储库类型(包括OpenStack对象存储)上存储磁盘或服务器映像。它接受对磁盘或服务器映像的API请求，以及来自最终用户或OpenStack计算组件的元数据定义。它还支持在各种存储库类型(包括OpenStack对象存储)上存储磁盘或服务器映像。在OpenStack映像服务上运行许多周期性的进程以支持缓存。复制服务通过集群确保一致性和可用性。其他周期性过程包括 auditors, updaters, 及 reapers。
OpenStack镜像服务包括以下组件:

* glance-api
    接受镜像发现、检索和存储的API调用。
* glance-registry
    存储、处理和检索关于映像的元数据。元数据包括大小和类型等项。
>registry是用于OpenStack映像服务的私有内部服务。不要向用户公开此服务。

* Database
    存储图像元数据，您可以根据自己的喜好选择数据库。大多数部署都使用MySQL或SQLite。
* Storage repository for image files
    支持各种存储库类型，包括普通文件系统(或安装在gles -api控制器节点上的任何文件系统)、对象存储、RADOS块设备、VMware数据存储和HTTP。注意，有些存储库只支持只读使用。
* Metadata definition service
    A common API for vendors, admins, services, and users to meaningfully define their own custom metadata. This metadata can be used on different types of resources like images, artifacts, volumes, flavors, and aggregates. A definition includes the new property’s key, description, constraints, and the resource types which it can be associated with.

#####　安装必备条件

1. 创建数据库
使用root帐号登录数据库
```
mysql -u root -p
```

创建glance数据库

```
MariaDB [(none)]> CREATE DATABASE glance;
```

为glance数据库赋予权限
```
MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'GLANCE_DBPASS';
MariaDB [(none)]> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%'   IDENTIFIED BY 'GLANCE_DBPASS';

```
2. 获取admin用户的环境变量，并创建服务认证

```
. admin-openrc
```

3. 要创建服务凭据

* 创建glance用户

```
$ openstack user create --domain default --password-prompt glance

User Password: GLANCE_PASS
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | default                          |
| enabled             | True                             |
| id                  | 3f4e777c4062483ab8d9edd7dff829df |
| name                | glance                           |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

```


* 把admin角色添加到glance用户和service项目中
```
openstack role add --project service --user glance admin
```
> 此命令无返回值

* 创建glance服务
```
$ openstack service create --name glance \
  --description "OpenStack Image" image

+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Image                  |
| enabled     | True                             |
| id          | 8c2c7f1b9b5049ea9e63757b5533e6d2 |
| name        | glance                           |
| type        | image                            |
+-------------+----------------------------------+
```

4. 创建glance服务的端点

```
$ openstack endpoint create --region RegionOne \
  image public http://controller:9292

+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 340be3625e9b4239a6415d034e98aace |
| interface    | public                           |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 8c2c7f1b9b5049ea9e63757b5533e6d2 |
| service_name | glance                           |
| service_type | image                            |
| url          | http://controller:9292           |
+--------------+----------------------------------+

$ openstack endpoint create --region RegionOne \
  image internal http://controller:9292

+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | a6e4b153c2ae4c919eccfdbb7dceb5d2 |
| interface    | internal                         |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 8c2c7f1b9b5049ea9e63757b5533e6d2 |
| service_name | glance                           |
| service_type | image                            |
| url          | http://controller:9292           |
+--------------+----------------------------------+

$ openstack endpoint create --region RegionOne \
  image admin http://controller:9292

+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 0c37ed58103f4300a84ff125a539032d |
| interface    | admin                            |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 8c2c7f1b9b5049ea9e63757b5533e6d2 |
| service_name | glance                           |
| service_type | image                            |
| url          | http://controller:9292           |
+--------------+----------------------------------+

```

#####　安装和配置组件
1. 安装软件包
```
yum install openstack-glance
```
2. 配置 *glance-api.conf* 文件

glance-api 负责接受镜像发现、检索和存储的API调用。
 vim /etc/glance/glance-api.conf 文件进行如下操作：

* 在[database]字段, 设置数据库权限:
```
[database]
# ...
connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
```
可将GLANCE_DBPASS更改为合适密码,与授权密码相同

* 在 [keystone_authtoken] 和[paste_deploy]字段,配置身份服务访问:
```
[keystone_authtoken]
# ...
auth_uri = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = GLANCE_PASS

[paste_deploy]
# ...
flavor = keystone
```

* 在 [glance_store] 字段, 设置本地文件系统及镜像存储位置
```
[glance_store]

stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
```



3. 配 *glance-registry.conf*
glance-registry.conf 负责存储、处理和检索关于映像的元数据。元数据包括大小和类型等项。

vim /etc/glance/glance-registry.conf 文件并完成以下操作

* 在 [database]字段, 设置数据库接入

```
[database]
# ...
connection = mysql+pymysql://glance:GLANCE_DBPASS@controller/glance
```

* 在 [keystone_authtoken] 及[paste_deploy] 字段, 设置用户服务

```
[keystone_authtoken]
# ...
auth_uri = http://controller:5000
auth_url = http://controller:5000
memcached_servers = controller:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = GLANCE_PASS

[paste_deploy]
# ...
flavor = keystone
```

4. 填充image服务 数据库

```
su -s /bin/sh -c "glance-manage db_sync" glance
```

#####　结束安装并配置

```
# systemctl enable openstack-glance-api.service \
  openstack-glance-registry.service
# systemctl start openstack-glance-api.service \
  openstack-glance-registry.service
```


### Verify operation

[参考地址](https://docs.openstack.org/glance/queens/install/verify.html)
使用CirrOS验证映像服务的操作，CirrOS是一个小型Linux映像，可以帮助您测试OpenStack部署。
有关如何下载和构建映像的更多信息，请参阅OpenStack虚拟机映像指南。有关如何管理映像的信息，请参阅OpenStack终端用户指南。

1. 同步环境变量
```
$ . admin-openrc
```

2. 下载源镜像
```
wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
```

3. 使用QCOW2磁盘格式、bare容器格式和公共可见性将镜像上传到镜像服务，以便所有项目都可以访问:
```
openstack image create "cirros" \
  --file cirros-0.4.0-x86_64-disk.img \
  --disk-format qcow2 \
  --container-format bare \
  --public

+------------------+------------------------------------------------------+
| Field            | Value                                                |
+------------------+------------------------------------------------------+
| checksum         | 133eae9fb1c98f45894a4e60d8736619                     |
| container_format | bare                                                 |
| created_at       | 2015-03-26T16:52:10Z                                 |
| disk_format      | qcow2                                                |
| file             | /v2/images/cc5c6982-4910-471e-b864-1098015901b5/file |
| id               | cc5c6982-4910-471e-b864-1098015901b5                 |
| min_disk         | 0                                                    |
| min_ram          | 0                                                    |
| name             | cirros                                               |
| owner            | ae7a98326b9c455588edd2656d723b9d                     |
| protected        | False                                                |
| schema           | /v2/schemas/image                                    |
| size             | 13200896                                             |
| status           | active                                               |
| tags             |                                                      |
| updated_at       | 2015-03-26T16:52:10Z                                 |
| virtual_size     | None                                                 |
| visibility       | public                                               |
+------------------+------------------------------------------------------+

```

>--file cirros-0.4.0-x86_64-disk.img 指定镜像文件
--disk-format qcow2 指定镜像格式
--container-format bare 指定容器类型
--public 指定访问类型

4. 验证镜像是否可用
```
$ openstack image list

+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 38047887-61a7-41ea-9b49-27987d5e8bb9 | cirros | active |
+--------------------------------------+--------+--------+

```
