## 启动
/usr/local/share/openvswitch/scripts/ovn-ctl start_northd
/usr/local/share/openvswitch/scripts/ovn-ctl start_controller


### Centrol节点

```
# ovn-nbctl set-connection ptcp:6641:10.19.19.123
# ovn-sbctl set-connection ptcp:6642:10.19.19.123

# netstat -lntp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 10.19.19.123:6641          0.0.0.0:*               LISTEN      817/ovsdb-server
tcp        0      0 10.19.19.123:6642          0.0.0.0:*               LISTEN      857/ovsdb-server

# ovs-vsctl set open . external-ids:ovn-remote=tcp:10.19.19.123:6642
# ovs-vsctl set open . external-ids:ovn-encap-type=geneve
# ovs-vsctl set open . external-ids:ovn-encap-ip=10.19.19.123

# netstat -antp | grep ovn-controller
tcp        0      0 10.19.19.123:57350         10.19.19.123:6642          ESTABLISHED 815/ovn-controller
```
### Node节点

```
# ovs-vsctl set open . external-ids:ovn-remote=tcp:10.19.19.123:6642
# ovs-vsctl set open . external-ids:ovn-encap-type=vxlan
# ovs-vsctl set open . external-ids:ovn-encap-ip=10.19.19.113

# netstat -antp | grep ovn-controller
tcp        0      0 92.0.0.13:40096         10.19.19.123:6642          ESTABLISHED 807/ovn-controller
```
更正：
```
ovs-vsctl set Open_vSwitch . external-ids:system-id=$SYSTEM_ID
ovs-vsctl set Open_vSwitch . external_ids:ovn-nb="tcp:$CENTRAL_IP:6641"

ovs-vsctl set Open_vSwitch . external_ids:ovn-remote="tcp:$CENTRAL_IP:6642" \
ovs-vsctl set Open_vSwitch . external_ids:ovn-encap-ip=$LOCAL_IP
# 设置隧道类型
ovs-vsctl set Open_vSwitch . external_ids:ovn-encap-type="$ENCAP_TYPE"
```

设置连接ovn-controller 与ovsDB 的连接
```
ovs-vsctl set-manager "ptcp:6640"
ovn-controller tcp:127.0.0.1:6640
```


### 添加默认网桥

在Node节点上添加网桥  
```
ovs-vsctl add-br br-int -- set Bridge br-int fail-mode=secure
```

### 构建逻辑网络结构

1. 创建logical switch

```
ovn-nbctl ls-add ls1
```

2. 创建 logical port1

```
ovn-nbctl lsp-add ls1 s1-p1
ovn-nbctl lsp-set-addresses s1-p1 00:00:00:00:00:01
ovn-nbctl lsp-set-port-security s1-p1 00:00:00:00:00:01
```

3. 创建 logical port2

```
ovn-nbctl lsp-add ls1 ls1-port2
ovn-nbctl lsp-set-addresses ls1-port2 00:00:00:00:00:02
ovn-nbctl lsp-set-port-security ls1-port2 00:00:00:00:00:02
```

4. 显示状态

```
ovn-nbctl show
```
注意，虚拟端口的名称是唯一的，不能重复。虚拟端口同时也会生成一个很长的UUID。本文使用更加人性化的端口名称来代表这些端口。我们同时定义了这些虚拟端口的mac地址。在端口安全实验（逻辑端口只允许特定的源mac地址数据包通过）将用到这些mac地址。

5. 绑定external_ids

```
ovs-vsctl set Interface tap1 external_ids:iface-id=ls1-vm2

ovs-vsctl set Interface tap2 external_ids:attached-mac=00:00:00:00:00:02

ip link set tap1 address 00:00:00:00:00:01

```

6. 清理环境

```
ovn-nbctl ls-del ls1
```




### 参考

OVN是OVS 5倍的性能--性能测试报告
https://blog.csdn.net/zhengmx100/article/details/54949183
ML2+OVS 控制平面是基于Openstack 的。首先有大量由Python编写的agents 。 Neutron server与这些agents交互式使用基于AMQP的RPC机制（本文的案例用到了最广泛使用的RabbitMQ）。

OVN 的控制平面使用了分布式数据库驱动的方式. 配置和状态由这2个数据库管理: OVN northbound 和 southbound databases。这2个数据库都基于OVSDB。与通过RPC接收更新的方式不同, OVN中的组件监控数据库中相关表项的变化并将最新的表项应用于本地。这些组件的详细信息可以阅读the first release of OVN 和 ovn-architecture document 。

OVN 没有使用任何的Neutron agents。相反，所有功能都由ovn-controller 和 OVS 流实现。比如security groups, DHCP, L3 routing和 NAT功能等。
