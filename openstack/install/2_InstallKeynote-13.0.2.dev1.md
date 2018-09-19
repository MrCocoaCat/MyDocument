### Identity service overview
OpenStack标识服务提供了一个集成点，用于管理身份验证、授权和服务目录。标识服务通常是用户与之交互的第一个服务。经过身份验证后，最终用户可以使用其身份访问其他OpenStack服务。

同样，其他OpenStack服务利用身份服务来确保用户是他们所说的自己，并发现部署中的其他服务在哪里。标识服务还可以与一些外部用户管理系统(如LDAP)集成。

用户和服务可以通过使用服务目录定位其他服务，是由Identity service提供服务。顾名思义，服务目录是OpenStack部署中可用服务的集合。每个服务可以有一个或多个端点，每个端点可以是三种类型之一:admin、internal或public。在生产环境中，出于安全原因，不同的端点类型可能驻留在单独的网络上，这些网络公开给不同类型的用户。

例如，公共API(public API)网络可能从Internet上可见，以便客户可以管理他们的云。

管理API(admin API )网络可能仅限于管理云基础设施的组织内的运营商。

内部API( internal API )网络可能仅限于包含OpenStack服务的主机。
此外，OpenStack支持多个区域的可伸缩性。
为了简单起见，本指南对所有端点类型和默认的RegionOne区域使用管理网络。
在标识服务中创建的区域、服务和端点一起构成部署的服务目录。部署中的每个OpenStack服务都需要一个服务条目，其中包含存储在标识服务中的相应端点。
这可以在安装和配置标识服务之后完成。
在标识服务中创建的区域、服务和端点一起构成部署的服务目录。部署中的每个OpenStack服务都需要一个服务条目，其中包含存储在标识服务中的相应端点。
这可以在安装和配置标识服务之后完成。
### 安装keysnote（Identity service）

#### 在安装和配置认证服务之前，首先确保已创建数据库

1. 使用root帐号连接数据库

```
mysql -u root -p
```

2. 创建keystone数据库


```
MariaDB [(none)]> CREATE DATABASE keystone;
```

3. 进行授权

>grant 权限1,权限2,…权限n on 数据库名称.表名称 to 用户名@用户地址 identified by ‘连接口令’;

```
MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'KEYSTONE_DBPASS';

MariaDB [(none)]> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%'
IDENTIFIED BY 'KEYSTONE_DBPASS';

```

即为keystone用户添加所有权限，其密码为KEYSTONE_DBPASS
使用如下命令可以查看数据库状态

>密码为KEYSTONE_DBPASS

```
MariaDB [(none)]> show databases;
```

##### 安装和配置组件
1. 安装包
```
yum install openstack-keystone httpd mod_wsgi
```
2.  vim /etc/keystone/keystone.conf

```
[database]
# 在[database]字段中, 设置数据库权限:
connection = mysql+pymysql://keystone:KEYSTONE_DBPASS@controller/keystone

[token]
# 在 [token]字段中, 配置令牌提供者:
provider = fernet
```
>
将KEYSTONE_DBPASS 换成自己的database密码

3. 填充标识服务数据库

```
su -s /bin/sh -c "keystone-manage db_sync" keystone
```
该命令执行之后，keystone数据库建立的相应的表，可以使用
```
show tables
```
进行查看
+-----------------------------+
| Tables_in_keystone          |
+-----------------------------+
| access_token                |
| application_credential      |
| application_credential_role |
| assignment                  |
| config_register             |
| consumer                    |
| credential                  |
| endpoint                    |
| endpoint_group              |
| federated_user              |
| federation_protocol         |
| group                       |
| id_mapping                  |
| identity_provider           |
| idp_remote_ids              |
| implied_role                |
| limit                       |
| local_user                  |
| mapping                     |
| migrate_version             |
| nonlocal_user               |
| password                    |
| policy                      |
| policy_association          |
| project                     |
| project_endpoint            |
| project_endpoint_group      |
| project_tag                 |
| region                      |
| registered_limit            |
| request_token               |
| revocation_event            |
| role                        |
| sensitive_config            |
| service                     |
| service_provider            |
| system_assignment           |
| token                       |
| trust                       |
| trust_role                  |
| user                        |
| user_group_membership       |
| user_option                 |
| whitelisted_config          |
+-----------------------------+


>su -s 指定执行的shell 即指定为/bin/sh
keystone-manage db_sync　为同步数据库命令


4. 初始化Fernet密钥存储库

```
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
```

```
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
```
>keystone-manage fernet_setup 设置用于令牌（token）加密的Fernet密钥存储库

>eystone-manage credential_setup 设置用于凭证（credential，用户密码）加密的Fernet密钥存储库。

5. 引导标识服务

```

keystone-manage bootstrap \
  --bootstrap-password ADMIN_PASS \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne

```

将ADMIN_PASS替换为合适的密码,此密码为环境变量中的密码。填充数据库

>keystone-manage bootstrap 执行基本的引导过程

--bootstrap-region-id RegionOne，在表region 中生成以下内容
+-----------+-------------+------------------+-------+
| id        | description | parent_region_id | extra |
+-----------+-------------+------------------+-------+
| RegionOne |             | NULL             | {}    |
+-----------+-------------+------------------+-------+

在表endpoint表中生成

+----------------------------------+--------------------+-----------+----------------------------------+----------------------------+-------+---------+-----------+
| id                               | legacy_endpoint_id | interface | service_id                       | url                        | extra | enabled | region_id |
+----------------------------------+--------------------+-----------+----------------------------------+----------------------------+-------+---------+-----------+
| 541f63f2daf645fc92d24285664adef4 | NULL               | public    | d43ed3733922488e9a5dd14396ba1194 | http://controller:5000/v3/ | {}    |       1 | RegionOne |
| 74512328e9044b5a8691c64a7305d6eb | NULL               | admin     | d43ed3733922488e9a5dd14396ba1194 | http://controller:5000/v3/ | {}    |       1 | RegionOne |
| dd8b5b7bcab445f4beaee0f5527a4704 | NULL               | internal  | d43ed3733922488e9a5dd14396ba1194 | http://controller:5000/v3/ | {}    |       1 | RegionOne |
+----------------------------------+--------------------+-----------+----------------------------------+----------------------------+-------+---------+-----------+



##### 配置Apache HTTP 服务

1. vim /etc/httpd/conf/httpd.conf 文件并且配置ServerName

```
ServerName controller
```

2. 为 /usr/share/keystone/wsgi-keystone.conf 文件创建链接

```
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

```

##### 安装完成启动服务
1. 启动 Apache HTTP 服务并设置为开机启动

```
systemctl enable httpd.service
systemctl start httpd.service
```

2. 配置管理账户

```
$ export OS_USERNAME=admin
$ export OS_PASSWORD=ADMIN_PASS
$ export OS_PROJECT_NAME=admin

$ export OS_USER_DOMAIN_NAME=Default
$ export OS_PROJECT_DOMAIN_NAME=Default

$ export OS_AUTH_URL=http://controller:35357/v3
$ export OS_IDENTITY_API_VERSION=3

```

####　创建用户

身份服务为每个OpenStack服务提供身份验证服务。

1. 创建默认域(domain)，在‘keystone-manage bootstrap’步骤中已经存在“default”域。
创建example域作为演示


```
$ openstack domain create --description "An Example Domain" example

+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | An Example Domain                |
| enabled     | True                             |
| id          | 2f4f80574fd84fe6ba9067228ae0a50c |
| name        | example                          |
+-------------+----------------------------------+
```

>domain 名为example

2. 创建一个server项目(project)，添加到环境中的每个服务包含一个惟一的用户。

```
$ openstack project create --domain default \
  --description "Service Project" service

+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Service Project                  |
| domain_id   | default                          |
| enabled     | True                             |
| id          | 24ac7f19cd944f4cba1d77469b2a73ed |
| is_domain   | False                            |
| name        | service                          |
| parent_id   | default                          |
+-------------+----------------------------------+
```

>项目名为service
>在project 数据库中生成相关数据

3. 常规(非管理)任务应该使用常规权限的项目和用户。作为示例，创建demo项目用户

* 创建demo项目:

```
$ openstack project create --domain default \
  --description "Demo Project" demo

+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Demo Project                     |
| domain_id   | default                          |
| enabled     | True                             |
| id          | 231ad6e7ebba47d6a1e57e1cc07ae446 |
| is_domain   | False                            |
| name        | demo                             |
| parent_id   | default                          |
+-------------+----------------------------------+
```
>项目名为demo

* 创建 demo 用户:

```
$ openstack user create --domain default \
  --password-prompt demo

User Password: DEMO_PASS
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | default                          |
| enabled             | True                             |
| id                  | aeda23aa78f44e859900e22c24817832 |
| name                | demo                             |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

```
> --domain default 域名为default
> 其用户名为demo

* 创建用户(user)角色(role):

```
$ openstack role create user

+-----------+----------------------------------+
| Field     | Value                            |
+-----------+----------------------------------+
| domain_id | None                             |
| id        | 997ce8d05fc143ac97d83fdfb5998552 |
| name      | user                             |
+-----------+----------------------------------+
```
>

* 为demo项目和用户添加用户角色（user role）

```
 openstack role add --project demo --user demo user

```
>--project demo 指定项目
>--user demo  指定用户
> 添加的角色为user

#### 验证操作 Verify operation

在安装其他服务之前，验证身份服务的操作。

1. 卸载临时OS_AUTH_URL和OS_PASSWORD环境变量:

```
unset OS_AUTH_URL OS_PASSWORD
```

2. 作为admin用户，请求一个authentication令牌。这个命令使用admin user的密码

```
$ openstack \
  --os-auth-url http://controller:35357/v3 \
  --os-project-domain-name Default \
  --os-user-domain-name Default \
  --os-project-name admin \
  --os-username admin\
   token issue

Password: ADMIN_PASS

+------------+-----------------------------------------------------------------+
| Field      | Value                                                           |
+------------+-----------------------------------------------------------------+
| expires    | 2016-02-12T20:14:07.056119Z                                     |
| id         | gAAAAABWvi7_B8kKQD9wdXac8MoZiQldmjEO643d-e_j-XXq9AmIegIbA7UHGPv |
| project_id | 343d245e850143a096806dfaefa9afdc                                |
| user_id    | ac3377633149401296f6c0d92d79dc16                                |
+------------+-----------------------------------------------------------------+
```

>密码为： ADMIN_PASS

>--os-auth-url http://controller:35357/v3 设置url
--os-project-domain-name Default
--os-user-domain-name Default
--os-project-name admin
--os-username admin
token issue 为命令，即发行一个新的令牌

#### 创建脚本
前面的部分使用了环境变量和命令选项的组合，通过openstack客户机与标识服务交互。为了提高客户端操作的效率，OpenStack支持简单的客户端环境脚本，也称为OpenRC文件。这些脚本通常包含所有客户机的通用选项，但也支持惟一选项。有关更多信息，请参阅OpenStack终端用户指南。

1. 创建admin-openrc文件，添加以下内容:

```
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=ADMIN_PASS
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

2. 创建demo-openrc

```
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=DEMO_PASS
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```
