https://www.jianshu.com/p/c31068cc0e5a

1. 安装vlan(vconfig)和加载8021q模块
```
#aptitude install vlan
#modprobe 8021q
```
或：
```
#yum install vconfig
#modprobe 8021q
#lsmod |grep -i 8021q
```
2. 使用linux vconfig命令配置vlan
```
#vconfig add eth0 100
#vconfig add eth0 200
```
在eth0接口上配置两个VLAN
```
#vconfig set_flag eth0.100 1 1
#vconfig set_flag eth0.200 1 1
```
设置VLAN的REORDER_HDR参数，默认就行了。
可以使用cat /proc/net/vlan/eth0.100查看eth0.100参数
配置网络信息
```
#ifconfig eth0 0.0.0.0
#ifconfig eth0.100 192.168.100.50 netmask 255.255.255.0 up
#ifconfig eth0.200 192.168.200.50 netmask 255.255.255.0 up
```
删除VLAN命令
```
#vconfig rem eth0.100
#vconfig rem eth0.200  
```
3.将VLAN信息写入配置文件
#echo "modprobe 8021q">>/etc/rc.local
开机加载8021q模块，或者使用

echo "8021q">>/etc/modules
#cp /etc/network/interfaces /etc/network/interfaces.default
#vim /etc/network/interfaces

auto lo eth0
iface lo inet loopback
iface eth0.100 inet static
    address 192.168.100.50
    netmask 255.255.255.0
iface eth0.200 inet static
    address 192.168.200.50
    netmask 255.255.255.0


### ovs vlan

vlan_mode 可选trunk, access, native-tagged, native-untagged之一。


```
ovs-vsctl set port <port name> vlan_mode=trunk|access|native-tagged|native-untagged
```
trunk
trunk 类似交换机配置的trunk模式。trunk 端口传递指定vlan（通过trunks指定）的包。如果trunks为空，则所有的VLAN都可以通过，即通过trunk port的包带任何vlan tag都不动的通过，如果没有不带vlan tag，就属于vlan 0通过。如果trunks不为空，则仅仅带着这些vlanid的包通过，其他vlan tag的包全部丢弃。

access
access 端口只允许tag指定vlan的包通过。从access port发出的包不带vlan tag。不带vlantag的包进入端口会打上tag，如果一个本身带vlan tag的包进入access port，即便vlan tag等于tag，也会被抛弃。

native-tagged
native-tagged端口与trunk端口类似，只有一点例外：不带802.1Q header的包进入端口会进入“native vlan”（通过tag指定）

native-untagged
native-untagged端口类似native-tagged端口，不同点是：从native-untagged端口发出的包进入native vlan会去掉802.1Q header
