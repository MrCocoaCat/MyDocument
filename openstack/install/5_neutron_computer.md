https://docs.openstack.org/neutron/queens/install/compute-install-rdo.html
计算节点处理实例的连接和安全组。
#### 安装组件
```
yum install openstack-neutron-linuxbridge ebtables ipset
```

#### Configure the common component

网络公共组件配置包括身份验证机制、消息队列和插件。

* vim /etc/neutron/neutron.conf

  * In the [database] section, 注释掉所有的选项，因为计算节点不需要连接数据库
  。
  * 在[DEFAULT]字段, 仅开启compute和metadata的APIs
  ```
  [DEFAULT]
  # ...
  enabled_apis = osapi_compute,metadata
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
  * 在Default 字段配置my_ip选项
  ```
  [DEFAULT]
  # ...
  my_ip = MANAGEMENT_INTERFACE_IP_ADDRESS

  ```
  >MANAGEMENT_INTERFACE_IP_ADDRESS 为计算节点的管理IP

  * 在Default 字段，开启网络支持
  ```
  use_neutron = True
  firewall_driver = nova.virt.firewall.NoopFirewallDriver
  ```
  >需要关闭网络防火墙，使用命令 nova.virt.firewall.NoopFirewallDriver

  * 在vnc字段设置远程控制台的接入点
  ```
  [vnc]
  # ...
  enabled = True
  server_listen = 0.0.0.0
  server_proxyclient_address = $my_ip
  novncproxy_base_url = http://controller:6080/vnc_auto.html
  ```

  服务器组件监听所有IP地址，代理组件只监听计算节点的管理接口IP地址。基本URL指示可以使用web浏览器访问此计算节点上实例的远程控制台的位置。

  * 在 [glance] 字段, 设置 Image service API的服务地址:

  ```
  [glance]
  # ...
  api_servers = http://controller:9292
  ```

  * In the [oslo_concurrency] section, configure the lock path:
  ```
  [oslo_concurrency]
  # ...
  lock_path = /var/lib/neutron/tmp

  ```  
  * 在[placement] 字段, 设置Placement API
  ```
  [placement]
  # ...
  os_region_name = RegionOne
  project_domain_name = Default
  project_name = service
  auth_type = password
  user_domain_name = Default
  auth_url = http://controller:5000/v3
  username = placement
  password = PLACEMENT_PASS

  ```

#### 结束安装
1. 确定计算节点是否支持虚拟机
```
egrep -c '(vmx|svm)' /proc/cpuinfo
```
如果该命令返回1或大于1，则计算节点支持硬件加速，这通常不需要额外的配置。
如果该命令返回值为0，则计算节点不支持硬件加速，必须配置libvirt以使用QEMU而不是KVM。

2. 启动计算服务，包括其依赖项，并配置它们在系统启动时自动启动
```
# systemctl enable libvirtd.service openstack-nova-compute.service
# systemctl start libvirtd.service openstack-nova-compute.service
```

### Add the compute node to the cell database
以下操作在控制节点上完成
