https://docs.openstack.org/neutron/queens/install/compute-install-rdo.html
计算节点处理实例的连接和安全组。
#### 安装组件
```
yum install openstack-neutron-linuxbridge ebtables ipset
```
#### Configure the common component
网络公共组件配置包括身份验证机制、消息队列和插件。

* vim /etc/neutron/neutron.conf

  * In the [database] section, comment out any connection options because compute nodes do not directly access the database.
  * In the [DEFAULT] section, configure RabbitMQ message queue access:
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
# ...
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

* In the [oslo_concurrency] section, configure the lock path:
```
[oslo_concurrency]
# ...
lock_path = /var/lib/neutron/tmp

```  


vim /etc/nova/nova.conf
```
[neutron]
# ...
url = http://controller:9696
auth_url = http://controller:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = NEUTRON_PASS
```
