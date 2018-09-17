#### Self-service network

如果选择networking选项2，还可以创建一个self-service (private) 网络，通过NAT连接到物理网络基础设施。 这个网络包括一个DHCP服务器，它为实例提供IP地址。这个网络上的实例可以自动访问外部网络，如Internet。但是，从外部网络(如Internet)访问此网络上的实例需要一个浮动IP地址。
demo或其他非特权用户可以创建这个网络，因为它只提供对demo项目中的实例的连接。
![](assets/markdown-img-paste-20180917155036996.png)

*Networking Option 2: Self-service networks - Overview*

***

![](assets/markdown-img-paste-20180917155119846.png)
*Networking Option 2: Self-service networks - Connectivity*

#### Create the self-service network

1. 在controller节点上, 使demo获取user-only CLI 命令权限
```
$ . demo-openrc
```
2. 创建网络

```
$ openstack network create selfservice

Created a new network:
+-------------------------+--------------------------------------+
| Field                   | Value                                |
+-------------------------+--------------------------------------+
| admin_state_up          | UP                                   |
| availability_zone_hints |                                      |
| availability_zones      |                                      |
| created_at              | 2016-11-04T18:20:59Z                 |
| description             |                                      |
| headers                 |                                      |
| id                      | 7c6f9b37-76b4-463e-98d8-27e5686ed083 |
| ipv4_address_scope      | None                                 |
| ipv6_address_scope      | None                                 |
| mtu                     | 1450                                 |
| name                    | selfservice                          |
| port_security_enabled   | True                                 |
| project_id              | 3828e7c22c5546e585f27b9eb5453788     |
| project_id              | 3828e7c22c5546e585f27b9eb5453788     |
| revision_number         | 3                                    |
| router:external         | Internal                             |
| shared                  | False                                |
| status                  | ACTIVE                               |
| subnets                 |                                      |
| tags                    | []                                   |
| updated_at              | 2016-11-04T18:20:59Z                 |
+-------------------------+--------------------------------------+
```
