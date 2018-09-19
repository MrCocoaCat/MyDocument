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

#### Access the instance using the virtual console

1. Obtain a Virtual Network Computing (VNC) session URL for your instance and access it from a web browser:

```
$ openstack console url show provider-instance

+-------+---------------------------------------------------------------------------------+
| Field | Value                                                                           |
+-------+---------------------------------------------------------------------------------+
| type  | novnc                                                                           |
| url   | http://controller:6080/vnc_auto.html?token=5eeccb47-525c-4918-ac2a-3ad1e9f1f493 |
+-------+---------------------------------------------------------------------------------+
```
CirrOS映像包括传统的用户名/密码身份验证，并在登录提示符处提供这些凭据。在登录CirrOS之后，我们建议您使用ping来验证网络连接。

2. Verify access to the provider physical network gateway:
```
$ ping -c 4 203.0.113.1

PING 203.0.113.1 (203.0.113.1) 56(84) bytes of data.
64 bytes from 203.0.113.1: icmp_req=1 ttl=64 time=0.357 ms
64 bytes from 203.0.113.1: icmp_req=2 ttl=64 time=0.473 ms
64 bytes from 203.0.113.1: icmp_req=3 ttl=64 time=0.504 ms
64 bytes from 203.0.113.1: icmp_req=4 ttl=64 time=0.470 ms

--- 203.0.113.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2998ms
rtt min/avg/max/mdev = 0.357/0.451/0.504/0.055 ms
```
3. Verify access to the internet:
```
$ ping -c 4 openstack.org

PING openstack.org (174.143.194.225) 56(84) bytes of data.
64 bytes from 174.143.194.225: icmp_req=1 ttl=53 time=17.4 ms
64 bytes from 174.143.194.225: icmp_req=2 ttl=53 time=17.5 ms
64 bytes from 174.143.194.225: icmp_req=3 ttl=53 time=17.7 ms
64 bytes from 174.143.194.225: icmp_req=4 ttl=53 time=17.5 ms

--- openstack.org ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 17.431/17.575/17.734/0.143 ms
```

#### Access the instance remotely
1. Verify connectivity to the instance from the controller node or any host on the provider physical network:

```
$ ping -c 4 203.0.113.103

PING 203.0.113.103 (203.0.113.103) 56(84) bytes of data.
64 bytes from 203.0.113.103: icmp_req=1 ttl=63 time=3.18 ms
64 bytes from 203.0.113.103: icmp_req=2 ttl=63 time=0.981 ms
64 bytes from 203.0.113.103: icmp_req=3 ttl=63 time=1.06 ms
64 bytes from 203.0.113.103: icmp_req=4 ttl=63 time=0.929 ms

--- 203.0.113.103 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3002ms
rtt min/avg/max/mdev = 0.929/1.539/3.183/0.951 ms
```
2. Access your instance using SSH from the controller node
 or any host on the provider physical network:

 ```
 $ ssh cirros@203.0.113.103

The authenticity of host '203.0.113.102 (203.0.113.102)' can't be established.
RSA key fingerprint is ed:05:e9:e7:52:a0:ff:83:68:94:c7:d1:f2:f8:e2:e9.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '203.0.113.102' (RSA) to the list of known hosts.
 ```
