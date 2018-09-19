本节创建必要的虚拟网络以支持启动实例。网络选项1包括一个provider(external)网络和一个使用它的实例。网络选项2包括一个provider网络，以及一个self-service (private)网络和一个使用它的实例。
本节中的指令在控制(controller)节点上使用命令行接口(CLI)工具。但是，您可以按照安装工具的任何主机上的说明进行操作。
#### Create virtual networks
为配置Neutron时选择的网络选项创建虚拟网络。如果选择选项1，只创建提供者网络。如果选择选项2，创建提供者和自助服务网络。
[Provider_Network](./Provider_Network.md)
[Self-service_Network](./Self-service_Network.md)
为您的环境创建了适当的网络之后，您可以继续准备环境以启动实例。

#### Create m1.nano flavor
最小的默认样式每个实例消耗512mb内存。对于计算节点小于4 GB内存的环境，我们建议创建m1.namo flavor，每个实例只需要64MB。仅使用此类flavor 作为测试目的。
```
$ openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

+----------------------------+---------+
| Field                      | Value   |
+----------------------------+---------+
| OS-FLV-DISABLED:disabled   | False   |
| OS-FLV-EXT-DATA:ephemeral  | 0       |
| disk                       | 1       |
| id                         | 0       |
| name                       | m1.nano |
| os-flavor-access:is_public | True    |
| properties                 |         |
| ram                        | 64      |
| rxtx_factor                | 1.0     |
| swap                       |         |
| vcpus                      | 1       |
+----------------------------+---------+
```
#### Generate a key pair
大多数云映像支持公钥身份验证，而不是传统的密码身份验证。在启动实例之前，必须向计算服务添加公钥。
1. 同步环境变量
```
$ . demo-openrc
```

2. 生成一个key pair并且添加public key
```
$ ssh-keygen -q -N ""
$ openstack keypair create --public-key ~/.ssh/id_rsa.pub mykey

+-------------+-------------------------------------------------+
| Field       | Value                                           |
+-------------+-------------------------------------------------+
| fingerprint | ee:3d:2e:97:d4:e2:6a:54:6d:0d:ce:43:39:2c:ba:4d |
| name        | mykey                                           |
| user_id     | 58126687cbcc4888bfa9ab73a2256f27                |
+-------------+-------------------------------------------------+
```

> ssh-keygen 为生成秘钥的命令
-q   安静模式。用于在 /etc/rc 中创建新密钥的时候
-N [new_passphrase] ,提供一个新的密语。

3. 验证密钥对的添加

```
$ openstack keypair list

+-------+-------------------------------------------------+
| Name  | Fingerprint                                     |
+-------+-------------------------------------------------+
| mykey | ee:3d:2e:97:d4:e2:6a:54:6d:0d:ce:43:39:2c:ba:4d |
+-------+-------------------------------------------------+
```

#### Add security group rules

默认情况下，default 安全组应用于所有实例，并包含拒绝远程访问实例的防火墙规则。对于CirrOS等Linux映像，我们建议至少允许ICMP(ping)和secure shell(SSH)。

* Add rules to the default security group:
 * Permit ICMP (ping)

```
$ openstack security group rule create --proto icmp default

+-------------------+--------------------------------------+
| Field             | Value                                |
+-------------------+--------------------------------------+
| created_at        | 2017-03-30T00:46:43Z                 |
| description       |                                      |
| direction         | ingress                              |
| ether_type        | IPv4                                 |
| id                | 1946be19-54ab-4056-90fb-4ba606f19e66 |
| name              | None                                 |
| port_range_max    | None                                 |
| port_range_min    | None                                 |
| project_id        | 3f714c72aed7442681cbfa895f4a68d3     |
| protocol          | icmp                                 |
| remote_group_id   | None                                 |
| remote_ip_prefix  | 0.0.0.0/0                            |
| revision_number   | 1                                    |
| security_group_id | 89ff5c84-e3d1-46bb-b149-e621689f0696 |
| updated_at        | 2017-03-30T00:46:43Z                 |
+-------------------+--------------------------------------+
```
    * Permit secure shell (SSH) access:
    ```
    $ openstack security group rule create --proto tcp --dst-port 22 default

+-------------------+--------------------------------------+
| Field             | Value                                |
+-------------------+--------------------------------------+
| created_at        | 2017-03-30T00:43:35Z                 |
| description       |                                      |
| direction         | ingress                              |
| ether_type        | IPv4                                 |
| id                | 42bc2388-ae1a-4208-919b-10cf0f92bc1c |
| name              | None                                 |
| port_range_max    | 22                                   |
| port_range_min    | 22                                   |
| project_id        | 3f714c72aed7442681cbfa895f4a68d3     |
| protocol          | tcp                                  |
| remote_group_id   | None                                 |
| remote_ip_prefix  | 0.0.0.0/0                            |
| revision_number   | 1                                    |
| security_group_id | 89ff5c84-e3d1-46bb-b149-e621689f0696 |
| updated_at        | 2017-03-30T00:43:35Z                 |
+-------------------+--------------------------------------+
    ```
#### Launch an instance
如果选择网络选项1，则只能在provider网络上启动实例。如果选择networking选项2，可以在provider网络和 self-service 网络上启动实例。
