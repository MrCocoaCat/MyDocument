### Launch an instance on the provider network

#### Determine instance options
要启动实例，您至少必须指定样式、映像名称、网络、安全组、密钥和实例名称( flavor, image name, network, security group, key, and instance name.)。
1.  在controller节点上, source demo的验证脚本以获取权限admin-only CLI commands:

```
. demo-openrc
```

2. flavor指定一个虚拟资源分配配置文件，其中包括处理器、内存和存储。
列举可用的flavor

```
$ openstack flavor list

+----+---------+-----+------+-----------+-------+-----------+
| ID | Name    | RAM | Disk | Ephemeral | VCPUs | Is Public |
+----+---------+-----+------+-----------+-------+-----------+
| 0  | m1.nano |  64 |    1 |         0 |     1 | True      |
+----+---------+-----+------+-----------+-------+-----------+
```
3. 列举可用的镜像

```
$ openstack image list

+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 390eb5f7-8d49-41ec-95b7-68c0d5d54b34 | cirros | active |
+--------------------------------------+--------+--------+
```

4. 列举可用的网络

```
$ openstack network list

+--------------------------------------+--------------+---------- -+
| ID                                   | Name         | Subnets    |
+--------------------------------------+--------------+------------+
| 4716ddfe-6e60-40e7-b2a8-42e57bf3c31c | selfservice  |            |
| b5b6993c-ddf9-40e7-91d0-86806a42edb8 | provider     |            |
+--------------------------------------+--------------+------------+
```
5. 列举可用的安全组

```
$ openstack security group list

+--------------------------------------+---------+------------------------+----------------------------------+
| ID                                   | Name    | Description            | Project                          |
+--------------------------------------+---------+------------------------+----------------------------------+
| dd2b614c-3dad-48ed-958b-b155a3b38515 | default | Default security group | a516b957032844328896baa01e0f906c |
+--------------------------------------+---------+------------------------+----------------------------------+
```

#### Launch the instance

1. 启动一个实例:
Replace PROVIDER_NET_ID with the ID of the provider provider network.

```
$ openstack server create --flavor m1.nano --image cirros \
  --nic net-id=PROVIDER_NET_ID --security-group default \
  --key-name mykey provider-instance


+-----------------------------+-----------------------------------------------+
| Field                       | Value                                         |
+-----------------------------+-----------------------------------------------+
| OS-DCF:diskConfig           | MANUAL                                        |
| OS-EXT-AZ:availability_zone |                                               |
| OS-EXT-STS:power_state      | NOSTATE                                       |
| OS-EXT-STS:task_state       | scheduling                                    |
| OS-EXT-STS:vm_state         | building                                      |
| OS-SRV-USG:launched_at      | None                                          |
| OS-SRV-USG:terminated_at    | None                                          |
| accessIPv4                  |                                               |
| accessIPv6                  |                                               |
| addresses                   |                                               |
| adminPass                   | PwkfyQ42K72h                                  |
| config_drive                |                                               |
| created                     | 2017-03-30T00:59:44Z                          |
| flavor                      | m1.nano (0)                                   |
| hostId                      |                                               |
| id                          | 36f3130e-cf1b-42f8-a80b-ebd63968940e          |
| image                       | cirros (97e06b44-e9ed-4db4-ba67-6e9fc5d0a203) |
| key_name                    | mykey                                         |
| name                        | provider-instance                             |
| progress                    | 0                                             |
| project_id                  | 3f714c72aed7442681cbfa895f4a68d3              |
| properties                  |                                               |
| security_groups             | name='default'                                |
| status                      | BUILD                                         |
| updated                     | 2017-03-30T00:59:44Z                          |
| user_id                     | 1a421c69342348248c7696e3fd6d4366              |
| volumes_attached            |                                               |
+-----------------------------+-----------------------------------------------+

```
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
