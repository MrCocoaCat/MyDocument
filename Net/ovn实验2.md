### 理解路由

在本次实验中，我们将创建一个OVN路由器，即“分布式逻辑路由器”（DLR）。 DLR不同于传统路由器，因为它不是物理的设备，而是一种逻辑架构（与逻辑交换机不同）。 DLR仅作为OVS中的一个功能而存在：换句话说，每个OVS实例能够在overlay网络转发流量之前先在本地模拟出一个三层路由器。

创建逻辑交换机和逻辑路由器
在ubuntu1上定义逻辑交换机:

```
ovn-nbctl ls-add s1
ovn-nbctl ls-add s2
```

添加逻辑路由器及其关联的路由器和交换机端口:

添加路由器r1
```
ovn-nbctl lr-add r1
```

1. 为路由器r1创建一个连接到s2交换机的端口

```
ovn-nbctl lrp-add r1 r1-s2 00:00:00:00:01:00 172.16.255.129/26
```


为s2 交换机创建用于连接到路由器r1的端口 s2-r1

```
ovn-nbctl lsp-add s2 s2-r1

ovn-nbctl lsp-set-type s2-r1 router

ovn-nbctl lsp-set-addresses s2-r1 00:00:00:00:01:00

ovn-nbctl lsp-set-options s2-r1 router-port=r1-s2
```


2. 为路由器r1创建一个连接到s1交换机的端口
```
ovn-nbctl lrp-add r1 r1-s1  00:00:00:00:02:00 172.16.255.193/26
```

为s1交换机创建用于连接到路由器r1的端口s1-r1
```
ovn-nbctl lsp-add s1 s1-r1
ovn-nbctl lsp-set-type s1-r1 router
ovn-nbctl lsp-set-addresses s1-r1  00:00:00:00:02:00
ovn-nbctl lsp-set-options s1-r1 router-port=r1-s1
```

ovn-nbctl show



### 添加 DHCP
OVN中的DHCP与大多数的解决方案有点不同。 大多数人的想法是管理员将：

1.给定子网定义一组DHCP选项
2.创建逻辑交换机端口，给该端口定义MAC地址和IP地址
3.为该端口分配DHCP选项。
4.将端口安全设置为仅允许分配的地址

下面，我们将要给4台虚拟机配置逻辑端口。

在ubuntu1上:
```
ovn-nbctl lsp-add s1 s1-vm1
ovn-nbctl lsp-set-addresses s1-vm1 " 00:00:00:00:00:01 172.16.255.130"
ovn-nbctl lsp-set-port-security s1-vm1 " 00:00:00:00:00:01 172.16.255.130"

ovn-nbctl lsp-add s1 s1-vm2
ovn-nbctl lsp-set-addresses s1-vm1 " 00:00:00:00:00:02 172.16.255.131"
ovn-nbctl lsp-set-port-security s1-vm1 " 00:00:00:00:00:02 172.16.255.131"

ovn-nbctl lsp-add s1 s2-vm3
ovn-nbctl lsp-set-addresses s2-vm3 " 00:00:00:00:00:03 172.16.255.194"
ovn-nbctl lsp-set-port-security s2-vm3 " 00:00:00:00:00:03 172.16.255.194"

ovn-nbctl lsp-add s1 s2-vm4
ovn-nbctl lsp-set-addresses s2-vm4 " 00:00:00:00:00:04 172.16.255.195"
ovn-nbctl lsp-set-port-security s2-vm4 " 00:00:00:00:00:04 172.16.255.195"

ovn-nbctl show
```

您可能已经注意到，与上一个实验不同，现在通过一条命令就能定义mac和IP地址。 IP地址定义实现了我们的2个目的：

1.它通过OVN在本地应答其知道的IP/MAC的ARP请求来实现ARP抑制。

2.从哪个端口收到DHCP请求，就会从哪个接口分配IP地址。通过这种方式来实现DHCP。

接下来，我们需要定义DHCP选项并将它们分配给逻辑端口。这里的处理将与我们以前看到的有点不同，因为我们将直接与OVN NB数据库进行交互。 用这种方式的原因是需要捕获DHCP_Options中的UUID，以便我们可以将UUID分配给交换机端口。 为此，我们将把捕获的ovn-nbctl命令的结果输出到一对bash变量中。

```
s2Dhcp="$(ovn-nbctl create DHCP_Options cidr=172.16.255.128/26
options=""server_id"="172.16.255.129" "server_mac"="02:ac:10:ff:01:29"
"lease_time"="3600" "router"="172.16.255.129"")"

echo $s2Dhcp

s1Dhcp="$(ovn-nbctl create DHCP_Options cidr=172.16.255.192/26
options=""server_id"="172.16.255.193" "server_mac"=" 00:00:00:00:02:00"
"lease_time"="3600" "router"="172.16.255.193"")"

echo $s1Dhcp

ovn-nbctl dhcp-options-list


s2Dhcp="$(ovn-nbctl create DHCP_Options cidr=172.16.255.128/26
options=""server_id"="172.16.255.129" "server_mac"="02:ac:10:ff:01:29"
"lease_time"="3600" "router"="172.16.255.129"")"
echo $s2Dhcp

s1Dhcp="
$(ovn-nbctl create DHCP_Options cidr=172.16.255.192/26
options=" "server_id"="172.16.255.193" "server_mac"=" 00:00:00:00:02:00"
"lease_time"="3600" "router"="172.16.255.193" ")
"

echo $s1Dhcp

ovn-nbctl dhcp-options-list
```

如果您想了解有关OVN NB数据库的更多信息，请参阅ovn-nb的手册（译者注：http://openvswitch.org/support/dist-docs/ovn-nb.5.pdf）。

现在，我们将使用存储在变量中的UUID为逻辑交换机端口分配DHCP_Options。

```
ovn-nbctl lsp-set-dhcpv4-options s2-vm1 $s2Dhcp
ovn-nbctl lsp-get-dhcpv4-options s2-vm1

ovn-nbctl lsp-set-dhcpv4-options s2-vm2 $s2Dhcp
ovn-nbctl lsp-get-dhcpv4-options s2-vm2

ovn-nbctl lsp-set-dhcpv4-options s1-vm3 $s1Dhcp
ovn-nbctl lsp-get-dhcpv4-options s1-vm3

ovn-nbctl lsp-set-dhcpv4-options s1-vm4 $s1Dhcp
ovn-nbctl lsp-get-dhcpv4-options s1-vm4
```


配置虚拟机
与上一个实验一样，我们将使用OVS内部端口和网络命名空间构建的“伪虚拟机”。 现在的区别是，我们将使用DHCP进行地址分配。

接下来我们将设置虚拟机。
在ubuntu2上:


ip netns add vm1
ovs-vsctl add-port br-int vm1 -- set interface vm1 type=internal
ip link set vm1 address  00:00:00:00:00:01
ip link set vm1 netns vm1

ovs-vsctl set Interface vm1 external_ids:iface-id=s2-vm1
ip netns exec vm1 dhclient vm1
ip netns exec vm1 ip addr show vm1
ip netns exec vm1 ip route show

ip netns add vm3
ovs-vsctl add-port br-int vm3 -- set interface vm3 type=internal
ip link set vm3 address  00:00:00:00:00:03
ip link set vm3 netns vm3
ovs-vsctl set Interface vm3 external_ids:iface-id=s1-vm3
ip netns exec vm3 dhclient vm3
ip netns exec vm3 ip addr show vm3
ip netns exec vm3 ip route show

ip netns add vm1
ovs-vsctl add-port br-int vm1 -- set interface vm1 type=internal
ip link set vm1 address  00:00:00:00:00:01
ip link set vm1 netns vm1

ovs-vsctl set Interface vm1 external_ids:iface-id=s2-vm1
ip netns exec vm1 dhclient vm1
ip netns exec vm1 ip addr show vm1
ip netns exec vm1 ip route show

ip netns add vm3
ovs-vsctl add-port br-int vm3 -- set interface vm3 type=internal
ip link set vm3 address  00:00:00:00:00:03
ip link set vm3 netns vm3
ovs-vsctl set Interface vm3 external_ids:iface-id=s1-vm3
ip netns exec vm3 dhclient vm3
ip netns exec vm3 ip addr show vm3
ip netns exec vm3 ip route show

在 ubuntu3上:

Java
ip netns add vm2
ovs-vsctl add-port br-int vm2 -- set interface vm2 type=internal
ip link set vm2 address  00:00:00:00:00:02
ip link set vm2 netns vm2
ovs-vsctl set Interface vm2 external_ids:iface-id=s2-vm2
ip netns exec vm2 dhclient vm2
ip netns exec vm2 ip addr show vm2
ip netns exec vm2 ip route show

ip netns add vm4
ovs-vsctl add-port br-int vm4 -- set interface vm4 type=internal
ip link set vm4 address  00:00:00:00:00:04
ip link set vm4 netns vm4
ovs-vsctl set Interface vm4 external_ids:iface-id=s1-vm4
ip netns exec vm4 dhclient vm4
ip netns exec vm4 ip addr show vm4
ip netns exec vm4 ip route show

ip netns add vm2
ovs-vsctl add-port br-int vm2 -- set interface vm2 type=internal
ip link set vm2 address  00:00:00:00:00:02
ip link set vm2 netns vm2
ovs-vsctl set Interface vm2 external_ids:iface-id=s2-vm2
ip netns exec vm2 dhclient vm2
ip netns exec vm2 ip addr show vm2
ip netns exec vm2 ip route show

ip netns add vm4
ovs-vsctl add-port br-int vm4 -- set interface vm4 type=internal
ip link set vm4 address  00:00:00:00:00:04
ip link set vm4 netns vm4
ovs-vsctl set Interface vm4 external_ids:iface-id=s1-vm4
ip netns exec vm4 dhclient vm4
ip netns exec vm4 ip addr show vm4
ip netns exec vm4 ip route show
测试网络连通性
在ubuntu2上，从vm1测试网络连通性:


# ping vm1的默认网关
root@ubuntu2:~# ip netns exec vm1 ping 172.16.255.129
PING 172.16.255.129 (172.16.255.129) 56(84) bytes of data.
64 bytes from 172.16.255.129: icmp_seq=1 ttl=254 time=0.689 ms
64 bytes from 172.16.255.129: icmp_seq=2 ttl=254 time=0.393 ms
64 bytes from 172.16.255.129: icmp_seq=3 ttl=254 time=0.483 ms

# 从 overlay网络ping vm2（跨越整个 r1）
root@ubuntu2:~# ip netns exec vm1  ping 172.16.255.131
PING 172.16.255.131 (172.16.255.131) 56(84) bytes of data.
64 bytes from 172.16.255.131: icmp_seq=1 ttl=64 time=2.16 ms
64 bytes from 172.16.255.131: icmp_seq=2 ttl=64 time=0.573 ms
64 bytes from 172.16.255.131: icmp_seq=3 ttl=64 time=0.446 ms

# 经过 router ping通 vm3（跨越整个 overlay网络）
root@ubuntu2:~# ip netns exec vm1  ping 172.16.255.194
PING 172.16.255.194 (172.16.255.194) 56(84) bytes of data.
64 bytes from 172.16.255.194: icmp_seq=1 ttl=63 time=1.37 ms
64 bytes from 172.16.255.194: icmp_seq=2 ttl=63 time=0.077 ms
64 bytes from 172.16.255.194: icmp_seq=3 ttl=63 time=0.076 ms

#经过 router ping 通vm4（跨越整个 overlay网络）
root@ubuntu2:~# ip netns exec vm1  ping 172.16.255.195
PING 172.16.255.195 (172.16.255.195) 56(84) bytes of data.
64 bytes from 172.16.255.195: icmp_seq=1 ttl=63 time=1.79 ms
64 bytes from 172.16.255.195: icmp_seq=2 ttl=63 time=0.605 ms
64 bytes from 172.16.255.195: icmp_seq=3 ttl=63 time=0.503 ms

# ping vm1的默认网关
root@ubuntu2:~# ip netns exec vm1 ping 172.16.255.129
PING 172.16.255.129 (172.16.255.129) 56(84) bytes of data.
64 bytes from 172.16.255.129: icmp_seq=1 ttl=254 time=0.689 ms
64 bytes from 172.16.255.129: icmp_seq=2 ttl=254 time=0.393 ms
64 bytes from 172.16.255.129: icmp_seq=3 ttl=254 time=0.483 ms

# 从 overlay网络ping vm2（跨越整个 r1）
root@ubuntu2:~# ip netns exec vm1  ping 172.16.255.131
PING 172.16.255.131 (172.16.255.131) 56(84) bytes of data.
64 bytes from 172.16.255.131: icmp_seq=1 ttl=64 time=2.16 ms
64 bytes from 172.16.255.131: icmp_seq=2 ttl=64 time=0.573 ms
64 bytes from 172.16.255.131: icmp_seq=3 ttl=64 time=0.446 ms

# 经过 router ping通 vm3（跨越整个 overlay网络）
root@ubuntu2:~# ip netns exec vm1  ping 172.16.255.194
PING 172.16.255.194 (172.16.255.194) 56(84) bytes of data.
64 bytes from 172.16.255.194: icmp_seq=1 ttl=63 time=1.37 ms
64 bytes from 172.16.255.194: icmp_seq=2 ttl=63 time=0.077 ms
64 bytes from 172.16.255.194: icmp_seq=3 ttl=63 time=0.076 ms

#经过 router ping 通vm4（跨越整个 overlay网络）
root@ubuntu2:~# ip netns exec vm1  ping 172.16.255.195
PING 172.16.255.195 (172.16.255.195) 56(84) bytes of data.
64 bytes from 172.16.255.195: icmp_seq=1 ttl=63 time=1.79 ms
64 bytes from 172.16.255.195: icmp_seq=2 ttl=63 time=0.605 ms
64 bytes from 172.16.255.195: icmp_seq=3 ttl=63 time=0.503 ms

### 结语
OVN使得第三层overlay网络易于部署和管理。 另外像DHCP的服务直接构建到系统中的方式，有助于减少构建有效的SDN解决方案所需的外部组件的数量。 在下一篇文章中，将讨论如何将我们（当前隔离的）overlay网络连接到外部世界。




本站原创文章仅代表作者观点，不代表SDNLAB立场。所有原创内容版权均属SDNLAB，欢迎大家转发分享。但未经授权，严禁任何媒体（平面媒体、网络媒体、自媒体等）以及微信公众号复制、转载、摘编或以其他方式进行使用，转载须注明来自 SDNLAB并附上本文链接。 本站中所有编译类文章仅用于学习和交流目的，编译工作遵照 CC 协议，如果有侵犯到您权益的地方，请及时联系我们。

s2Dhcp="$(ovn-nbctl create DHCP_Options cidr=10.0.200.0/24
options=""server_id"="172.16.255.129" "server_mac"="02:ac:10:ff:01:29"
"lease_time"="3600" "router"="172.16.255.129"")"
