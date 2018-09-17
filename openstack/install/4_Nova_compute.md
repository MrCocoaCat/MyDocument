本节介绍如何在计算节点上为Ubuntu、openSUSE和SUSE Linux Enterprise以及Red Hat Enterprise Linux和CentOS安装和配置计算服务。
该服务支持多个虚拟机监控程序来部署实例或虚拟机.为了简单起见，此配置使用了Quick EMUlator (QEMU)管理程序，在支持虚拟机硬件加速的计算节点上使用基于内核的VM (KVM)扩展。在遗留硬件上，此配置使用通用QEMU管理程序。您可以按照这些说明进行一些小的修改，以使用额外的计算节点水平缩放您的环境。


https://docs.openstack.org/nova/queens/install/compute-install-rdo.htmls

1. 安装软件包
```
 yum install openstack-nova-compute
```
2. vim /etc/nova/nova.conf

 * 开启compute和metadata服务
```
[DEFAULT]
# ...
enabled_apis = osapi_compute,metadata
```
  * 设置RABBIT_PASS
```
[DEFAULT]
transport_url = rabbit://openstack:RABBIT_PASS@controller
```
* 设置服务接入点
```
[api]
# ...
auth_strategy = keystone

[keystone_authtoken]
# ...
auth_url = http://controller:5000/v3
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = NOVA_PASS

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
>需要关闭网络防火墙，以使用nova.virt.firewall.NoopFirewallDriver

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
# ...、
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


#### Finalize installation
1. 确定计算节点是否支持硬件加速
```
egrep -c '(vmx|svm)' /proc/cpuinfo

```
如果结果为1或大于1，则支持硬件加速，
如果结果为0，则其不支持硬件加速，需要设置libvirt 使用 QEMU 替代 KVM

2. 启动服务并设置为开机启动

```
# systemctl enable libvirtd.service openstack-nova-compute.service
# systemctl start libvirtd.service openstack-nova-compute.service

```


#### Add the compute node to the cell database
