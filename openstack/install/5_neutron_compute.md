https://docs.openstack.org/neutron/queens/install/compute-install-rdo.html
计算节点处理实例的连接和安全组。
#### 安装组件
```
yum install openstack-neutron-linuxbridge ebtables ipset
```

#### Configure the common component

网络公共组件配置包括身份验证机制、消息队列和插件。

* vim /etc/neutron/neutron.conf

  ```
  * In the [DEFAULT] section, 配置 RabbitMQ消息队列的接入

  ```
  [DEFAULT]
  # ...
  transport_url = rabbit://openstack:RABBIT_PASS@controller

  ```

  * In the [DEFAULT] and [keystone_authtoken] sections, configure Identity service access:
  ```
  [DEFAULT]
  # ...
  auth_strategy = keystone

  [keystone_authtoken]

  auth_uri = http://controller:5000
  auth_url = http://controller:35357
  memcached_servers = controller:11211
  auth_type = password
  project_domain_name = default
  user_domain_name = default
  project_name = service
  username = neutron
  password = NEUTRON_PASS
  ```
  * 在[oslo_concurrency]字段, configure the lock path:

  ```

  ```
