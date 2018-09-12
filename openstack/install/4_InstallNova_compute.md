本节介绍如何在计算节点上为Ubuntu、openSUSE和SUSE Linux Enterprise以及Red Hat Enterprise Linux和CentOS安装和配置计算服务。
该服务支持多个虚拟机监控程序来部署实例或虚拟机.为了简单起见，此配置使用了Quick EMUlator (QEMU)管理程序，在支持虚拟机硬件加速的计算节点上使用基于内核的VM (KVM)扩展。在遗留硬件上，此配置使用通用QEMU管理程序。您可以按照这些说明进行一些小的修改，以使用额外的计算节点水平缩放您的环境。


https://docs.openstack.org/nova/queens/install/compute-install-rdo.htmls

1. 安装软件包
```
 yum install openstack-nova-compute
```
2. vim /etc/nova/nova.conf

```
[DEFAULT]
# ...
enabled_apis = osapi_compute,metadata

transport_url = rabbit://openstack:RABBIT_PASS@controller


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
*
```
[DEFAULT]
# ...
my_ip = MANAGEMENT_INTERFACE_IP_ADDRESS

```
MANAGEMENT_INTERFACE_IP_ADDRESS  = 192.168.125.208

#### Add the compute node to the cell database
