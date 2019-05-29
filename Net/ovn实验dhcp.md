https://www.cnblogs.com/YaoDD/p/7475728.html

## 添加交换机
```
ovn-nbctl ls-add s1
ovn-nbctl ls-add s2
```

# 添加路由
ovn-nbctl lr-add r1

# create router port for the connection to s1
ovn-nbctl lrp-add r1 r1-s1 00:00:00:00:01:00 10.0.100.1/24

# create the s1 switch port for connection to r1
ovn-nbctl lsp-add s1 s1-r1
ovn-nbctl lsp-set-type s1-r1 router
ovn-nbctl lsp-set-addresses s1-r1 00:00:00:00:01:00
ovn-nbctl lsp-set-options s1-r1 router-port=r1-s1

# create router port for the connection to s2
ovn-nbctl lrp-add r1 r1-s2 00:00:00:00:02:00 10.0.200.1/24

# create the s2 switch port for connection to r1

ovn-nbctl lsp-add s2 s2-r1
ovn-nbctl lsp-set-type s2-r1 router
ovn-nbctl lsp-set-addresses s2-r1 00:00:00:00:02:00
ovn-nbctl lsp-set-options s2-r1 router-port=r1-s2

ovn-nbctl show


### 添加端口
```
ovn-nbctl lsp-add s1 s1-p1
ovn-nbctl lsp-set-addresses s1-p1 "00:00:00:00:00:01 10.0.100.11"
ovn-nbctl lsp-set-port-security s1-p1 "00:00:00:00:00:01 10.0.100.11"

ovn-nbctl lsp-add s1 s1-p2
ovn-nbctl lsp-set-addresses s1-p2 "00:00:00:00:00:02 10.0.100.12"
ovn-nbctl lsp-set-port-security s1-p2 "00:00:00:00:00:02 10.0.100.12"

ovn-nbctl lsp-add s2 s2-p3
ovn-nbctl lsp-set-addresses s2-p3 "00:00:00:00:00:03 10.0.200.13"
ovn-nbctl lsp-set-port-security s2-p3 "00:00:00:00:00:03 10.0.200.13"

ovn-nbctl lsp-add s2 s2-p4
ovn-nbctl lsp-set-addresses s2-p4 "00:00:00:00:00:04 10.0.200.14"
ovn-nbctl lsp-set-port-security s2-p4 "00:00:00:00:00:04 10.0.200.14"

# 显示
ovn-nbctl show

```
现在通过一条命令就能定义mac和IP地址。 IP地址定义实现了我们的2个目的：

1.它通过OVN在本地应答其知道的IP/MAC的ARP请求来实现ARP抑制。

2.从哪个端口收到DHCP请求，就会从哪个接口分配IP地址。通过这种方式来实现DHCP。

接下来，我们需要定义DHCP选项并将它们分配给逻辑端口。这里的处理将与我们以前看到的有点不同，因为我们将直接与OVN NB数据库进行交互。
用这种方式的原因是需要捕获DHCP_Options中的UUID，以便我们可以将UUID分配给交换机端口。 为此，我们将把捕获的ovn-nbctl命令的结果输出到一对bash变量中。

### 创建DHCP

1. 创建两个DHCP 并获取其UUID
```
s1Dhcp="$(\
  ovn-nbctl create DHCP_Options cidr=10.0.100.0/24 \
options="\
        \"server_id\"=\"10.0.100.1\"\
        \"server_mac\"=\"00:00:00:00:01:00\" \
        \"lease_time\"=\"3600\"\
        \"router\"=\"10.0.100.1\"\
        "
)"

echo $s1Dhcp


ovn-nbctl create DHCP_Options cidr=10.0.200.0/24
echo $s2Dhcp

```

2.  
ovn-nbctl dhcp-options-list


ovn-nbctl lsp-set-dhcpv4-options s1-p1 $s1Dhcp
ovn-nbctl lsp-get-dhcpv4-options s1-p1

ovn-nbctl lsp-set-dhcpv4-options s1-p2 $s1Dhcp
ovn-nbctl lsp-get-dhcpv4-options s1-p2

ovn-nbctl lsp-set-dhcpv4-options s2-p3 $s2Dhcp
ovn-nbctl lsp-get-dhcpv4-options s2-p3

ovn-nbctl lsp-set-dhcpv4-options s2-p4 $s2Dhcp
ovn-nbctl lsp-get-dhcpv4-options s2-p4

### 网卡匹配
ovs-vsctl set Interface tap1 external_ids:iface-id=s1-p1
ovs-vsctl set Interface tap2 external_ids:iface-id=s1-p2
ovs-vsctl set Interface tap3 external_ids:iface-id=s2-p3
ovs-vsctl set Interface tap4 external_ids:iface-id=s2-p4
