使用本地源
### 安装软件包

```
# yum install quagga-0.99.15-7.el6_3.2.x86_64.rpm 或rpm

# ls /etc/quagga/
bgpd.conf.sample    ospfd.conf.sample   vtysh.conf         zebra.conf.sample
bgpd.conf.sample2   ripd.conf.sample    vtysh.conf.sample
ospf6d.conf.sample  ripngd.conf.sample  zebra.conf
```

### 服务器基本配置
1. 复制配置文件：

```
# cp /etc/quagga/zebra.conf.sample /etc/quagga/zebra.conf
cp：是否覆盖"/etc/quagga/zebra.conf"？ y
```
2. 启动zebra服务
```
[root@vn quagga]# service zebra start
```
3. 开机自启动zebra服务
```
[root@vn quagga]# chkconfig zebra on
[root@vn quagga]# chkconfig --list zebra
zebra          	0:关闭	1:关闭	2:启用	3:启用	4:启用	5:启用	6:关闭
```
4. 查看端口号
```
[root@vn quagga]# netstat -antu|grep 2601
tcp        0      0 127.0.0.1:2601              0.0.0.0:*                   LISTEN  
```
用127.0.0.1登陆

5. 路由器基本配置
（1）进入配置模式：
```
[root@vn quagga]# telnet 127.0.0.1 2601
Password:                               输入连接密码，默认为zebra
Router>                                  已经进入用户模式

Router> enable
Password:                               进入特权模式的密码默认为zebra
Router#                                  已经进入特权模式

Router# config terminal         进入配置模式
Router(config)#
```
（2）、设置系统网络名称
```
Router(config)# hostname Router1
Router1(config)#
```
（3）、配置密码
Router1(config)# password zebra                                 配置终端连接密码
Router1(config)# enable password zebra                    配置进入特权模式的密码
Router1(config)# service password-encryption           对口令进行加密
(4)、配置接口IP地址
Router1(config)# interface eth0                                    一定要进入接口模式
Router1(config-if)# ip add         按tab键自动补全
Router1(config-if)# ip address 192.168.0.2/24              设定IP地址，子网掩码
Router1(config-if)# no shutdown                                 激活网络接口
Router1(config-if)# exit                                                  退出
Router1(config)# interface eth1                                     添加第二个IP
Router1(config-if)# ip address 192.168.1.2/24               设置IP地址、子网掩码
Router1(config-if)# no shutdown                                   激活网络接口
Can't up interface                                                             这里需要添加一块虚拟网卡，
注意选择仅与主机共享一个网络（host only）
Router1(config-if)# no shutdown
Router1(config-if)# exit
Router1(config)# exit
Router1# show interface                                               查看接口信息
Interface eth0 is up, line protocol detection is disabled
  index 2 metric 1 mtu 1500
  flags: <UP,BROADCAST,RUNNING,MULTICAST>
  HWaddr: 00:0c:29:d1:b6:78
  inet 192.168.0.2/24 broadcast 192.168.0.255
  inet 192.168.121.171/24 broadcast 192.168.121.255
  inet6 fe80::20c:29ff:fed1:b678/64
Interface eth1 is up, line protocol detection is disabled
  index 3 metric 1 mtu 1500
  flags: <UP,BROADCAST,RUNNING,MULTICAST>
  inet 192.168.126.128/24 broadcast 192.168.126.255
  inet6 fe80::20c:29ff:fed1:b682/64
Interface lo is up, line protocol detection is disabled
  index 1 metric 1 mtu 16436
  flags: <UP,LOOPBACK,RUNNING>
  inet 127.0.0.1/8
  inet6 ::1/128

Router1# show interface eth0                   单独查看eth0的接口信息
Interface eth0 is up, line protocol detection is disabled
  index 2 metric 1 mtu 1500
  flags: <UP,BROADCAST,RUNNING,MULTICAST>
  HWaddr: 00:0c:29:d1:b6:78
  inet 192.168.0.2/24 broadcast 192.168.0.255
  inet 192.168.121.171/24 broadcast 192.168.121.255
  inet6 fe80::20c:29ff:fed1:b678/64

为eth1配置IP地址（重新打开一个terminal）：
[root@vn ~]# ifconfig eth1 192.168.1.2
Router1# show interface eth1
Interface eth1 is up, line protocol detection is disabled
  index 3 metric 1 mtu 1500
  flags: <UP,BROADCAST,RUNNING,MULTICAST>
  inet 192.168.1.2/24 broadcast 192.168.1.255
  inet6 fe80::20c:29ff:fed1:b682/64
（5）、显示IP路由表信息
Router1# show ip route  
Codes: K - kernel route, C - connected, S - static, R - RIP, O - OSPF,
       I - ISIS, B - BGP, > - selected route, * - FIB route

K>* 0.0.0.0/0 via 192.168.121.2, eth0             内核路由表
C>* 127.0.0.0/8 is directly connected, lo       回路   
K>* 169.254.0.0/16 is directly connected, eth0
C>* 192.168.0.0/24 is directly connected, eth0      直连网络
C>* 192.168.1.0/24 is directly connected, eth1
C>* 192.168.121.0/24 is directly connected, eth0
（6）、设置和查看访问控制列表
Router1# configure terminal 与方式 Router1# conf t 相同

Router1(config)# access-list private-only permit 192.168.0.0/24           只允许这四个网络进行转发，拒绝其他任何网络
Router1(config)# access-list private-only permit 192.168.1.0/24
Router1(config)# access-list private-only permit 192.168.2.0/24
Router1(config)# access-list private-only permit 192.168.3.0/24

Router1(config)# access-list private-only deny any
Router1(config)# exit
Router1# show ip access-list            查看访问控制列表
ZEBRA:
Zebra IP access list private-only
    permit 192.168.0.0/24
    permit 192.168.1.0/24
    permit 192.168.2.0/24
    permit 192.168.3.0/24
    deny   any
（7）、查看和保存路由器配置
Router1# show running-config  查看当前正在运行的路由配置
Router1# show startup-config    显示下一次启动的配置内容
Router1# copy running-config startup-config  保存到下一次启动的配置文件中
Configuration saved to /etc/quagga/zebra.conf
Router1# exit
Connection closed by foreign host.
[root@vn quagga]# cat /etc/quagga/zebra.conf             这里可以看到配置信息
注意：另一种方法是直接修改/etc/quagga/zebra.conf 配置文件，这是两种方式，根据实际情况自己选择。
