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
