local network 不会与宿主机的任何物理网卡连接，流量只被限制在宿主机内，同时也不关联任何的 VLAN ID。

flat network 是不带 tag 的网络，宿主机的物理网卡通过网桥与 flat network 连接，每个 flat network 都会占用一个物理网卡
vlan network 是带 tag 的网络。


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

# 为网桥设置控制器
ovs-vsctl set-controller br0 tcp:192.168.6.246:6653
