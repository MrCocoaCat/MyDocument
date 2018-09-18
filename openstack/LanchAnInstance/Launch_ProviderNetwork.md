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

#### Launch the instance¶

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
