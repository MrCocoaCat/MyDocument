
1. local network
 不会与宿主机的任何物理网卡连接，流量只被限制在宿主机内，同时也不关联任何的 VLAN ID。
2. flat network
是不带 tag 的网络，宿主机的物理网卡通过网桥与 flat network 连接，每个 flat network 都会占用一个物理网卡
3. vlan network
是带 tag 的网络。


ovs-dpctl 用来配置switch内核模块。

ovs-vsctl 查询和更新ovs-vswitchd的配置。

ovs-appctl 发送命令消息，运行相关daemon。

ovs-ofctl 查询和控制OpenFlow交换机和控制器。



### [open vSwitch]查看OVS端口ofport编号及对应虚拟机MAC
[参考](https://www.cnblogs.com/azyet/p/3580255.html)


在用open vSwitch做实验时，我们经常需要知道OVS port对应的ofport编号，这个比较容易，用

```
ovs-ofctl show [bridge]
```

就能得到。如

```
root@vaio:~# ovs-ofctl show br-int
OFPT_FEATURES_REPLY (xid=0x2): dpid:0000da9142cdfb44
n_tables:254, n_buffers:256
capabilities: FLOW_STATS TABLE_STATS PORT_STATS QUEUE_STATS ARP_MATCH_IP
actions: OUTPUT SET_VLAN_VID SET_VLAN_PCP STRIP_VLAN SET_DL_SRC SET_DL_DST SET_NW_SRC SET_NW_DST SET_NW_TOS SET_TP_SRC SET_TP_DST ENQUEUE
 1(patch-tun): addr:6e:4b:44:8e:f8:d7
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
 18(tap0): addr:ea:58:d5:f8:26:4e
     config:     0
     state:      0
     current:    10MB-FD COPPER
     speed: 10 Mbps now, 0 Mbps max
 19(tap1): addr:96:fc:5d:b6:43:d6
     config:     0
     state:      0
     current:    10MB-FD COPPER
     speed: 10 Mbps now, 0 Mbps max
 LOCAL(br-int): addr:da:91:42:cd:fb:44
     config:     0
     state:      0
     speed: 0 Mbps now, 0 Mbps max
OFPT_GET_CONFIG_REPLY (xid=0x4): frags=normal miss_send_len=0
```

### 查看MAC 地址表
当一个bridge上连接有多台虚拟机（或VM有多个IF）时，我们还常常需要知道VM的IF与bridge  port的对应，这时候可以使用：
```
ovs-appctl fdb/show [bridge]
```
例如：
```
root@vaio:~# ovs-appctl fdb/show br-int
 port  VLAN  MAC                Age
LOCAL     0  da:91:42:cd:fb:44   18
   18     0  52:54:00:a9:b8:b0    0
   19     0  52:54:00:a9:b8:b1    0
```
可以看到18号ofport连接的是MAC为52:54:00:a9:b8:b0的虚拟网卡。可结合上一个命令，知18号ofport的port name为tap0。
需要注意的是，该网卡必须要有数据的收发，才能够得到上述的结果，所以使用该命令之前不妨先执行一下类似ping的动作。






### 删除内部端口VLAN配置

ovs-vsctl remove port tap100 tag 100

### 设置peer
ovs-vsctl add-port br-eth patch-eth -- set interface patch-eth type=patch options:peer=patch-tap

 ovs-vsctl add-port br-tap patch-tap -- set interface patch-tap type=patch options:peer=patch-eth

#### 添加vxlan

ovs-vsctl del-port gre0
ovs-vsctl add-port br0 vxlan0 -- set interface vxlan0 type=vxlan options:remote_ip=10.0.2.12 options:key=100


#### tag

 VLAN Configuration
Port的一个重要的方面就是VLAN Configuration，有两种模式：

trunk port，这个port不配置tag，配置trunks，如果trunks为空，则所有的VLAN都trunk，也就意味着对于所有的VLAN的包，本身带什么VLAN ID，就是携带者什么VLAN ID，如果没有设置VLAN，就属于VLAN 0，全部允许通过。如果trunks不为空，则仅仅带着这些VLAN ID的包通过。
access port，这个port配置tag，从这个port进来的包会被打上这个tag，如果从其他的trunk port中进来的本身就带有VLAN ID的包，如果VLAN ID等于tag，则会从这个port发出，从其他的access port上来的包，如果tag相同，也会被forward到这个port。从access port发出的包不带VLAN ID。如果一个本身带VLAN ID的包到达access port，即便VLAN ID等于tag，也会被抛弃。










cookie=0xaaa0e760a7848ec3, duration=76543.287s, table=20, n_packets=28, n_bytes=3180, idle_age=33324, hard_age=65534, priority=2,dl_vlan=1,dl_dst=fa:16:3e:fd:8a:ed actions=strip_vlan,set_tunnel:0x64,output:2






ovs-ofctl add-flow br-int ’in_port=1 actions=set_tunnel:5001,set_field:192.168.1.1->gt;>gt;tun_dst,3’
ovs-ofctl add-flow br-int ’in_port=3,tun_src=192.168.1.1,tun_id=5001 actions=1’


NXM_OF_VLAN_TCI[0..11],NXM_OF_ETH_DST[]=NXM_OF_ETH_SRC[],load:0->NXM_OF_VLAN_TCI[],load:NXM_NX_TUN_ID[]->NXM_NX_TUN_ID[],output:NXM_OF_IN_PORT[]
