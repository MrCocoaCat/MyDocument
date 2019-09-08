ip netns exec ubuntu /usr/sbin/dnsmasq --conf-file=/home/zjl/ubuntu.conf






1. 添加网卡
os.popen("ovs-vsctl add-br ubuntu")
os.popen("ifconfig ubuntu up")

2. 添加命名空间ubuntu
os.popen("ip netns add ubuntu")

3. 添加设备对 ubuntu_nsp 及 ubuntu_br
os.popen("ip link add ubuntu_nsp type veth peer name ubuntu_br")

4. 将ubuntu_nsp设备放入命名空间
os.popen("ip link set ubuntu_nsp netns ubuntu")
os.popen("ifconfig ubuntu_br up")

5. 将ubuntu_br添加至网桥
os.popen("ovs-vsctl add-port ubuntu ubuntu_br")

os.popen("ip netns exec ubuntu ip link set dev lo up")
os.popen("ip netns exec ubuntu ip link set dev ubuntu_nsp up")


6. /etc/dnsmasq.conf 配置文件

```
no-hosts
no-resolv
# 限制 Dnsmasq 监听的网络接口
interface=ubuntu_nsp
# 最大限制
dhcp-lease-max=4096
leasefile-ro
except-interface=lo
bind-interfaces                                                   
log-facility=/tmp/dnsmasq.log
log-async=10
# 分配DNS
dhcp-option=6,114.114.114.114

# dhcp动态分配的地址范围
dhcp-range=set:tag0,5.6.0.1,5.6.0.1,255.255.0.0,infinite
# 服务的静态绑定
#  dhcp-host的配置方式有很多种，这里使用的是：[client端MAC地址] + [分配的IP]+ [主机名]
dhcp-host=12:34:56:78:00:00,5.6.0.1


dhcp-range=set:tag1,5.6.0.2,5.6.0.2,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:01,5.6.0.2


dhcp-range=set:tag2,5.6.0.3,5.6.0.3,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:02,5.6.0.3


dhcp-range=set:tag3,5.6.0.4,5.6.0.4,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:03,5.6.0.4


dhcp-range=set:tag4,5.6.0.5,5.6.0.5,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:04,5.6.0.5


dhcp-range=set:tag5,5.6.0.6,5.6.0.6,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:05,5.6.0.6


dhcp-range=set:tag6,5.6.0.7,5.6.0.7,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:06,5.6.0.7


dhcp-range=set:tag7,5.6.0.8,5.6.0.8,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:07,5.6.0.8


dhcp-range=set:tag8,5.6.0.9,5.6.0.9,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:08,5.6.0.9


dhcp-range=set:tag9,5.6.0.10,5.6.0.10,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:09,5.6.0.10


dhcp-range=set:tag10,5.6.0.11,5.6.0.11,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:0a,5.6.0.11


dhcp-range=set:tag11,5.6.0.12,5.6.0.12,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:0b,5.6.0.12


dhcp-range=set:tag12,5.6.0.13,5.6.0.13,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:0c,5.6.0.13


dhcp-range=set:tag13,5.6.0.14,5.6.0.14,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:0d,5.6.0.14


dhcp-range=set:tag14,5.6.0.15,5.6.0.15,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:0e,5.6.0.15


dhcp-range=set:tag15,5.6.0.16,5.6.0.16,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:0f,5.6.0.16


dhcp-range=set:tag16,5.6.0.17,5.6.0.17,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:10,5.6.0.17


dhcp-range=set:tag17,5.6.0.18,5.6.0.18,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:11,5.6.0.18


dhcp-range=set:tag18,5.6.0.19,5.6.0.19,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:12,5.6.0.19


dhcp-range=set:tag19,5.6.0.20,5.6.0.20,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:13,5.6.0.20


dhcp-range=set:tag20,5.6.0.21,5.6.0.21,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:14,5.6.0.21


dhcp-range=set:tag21,5.6.0.22,5.6.0.22,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:15,5.6.0.22


dhcp-range=set:tag22,5.6.0.23,5.6.0.23,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:16,5.6.0.23


dhcp-range=set:tag23,5.6.0.24,5.6.0.24,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:17,5.6.0.24


dhcp-range=set:tag24,5.6.0.25,5.6.0.25,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:18,5.6.0.25


dhcp-range=set:tag25,5.6.0.26,5.6.0.26,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:19,5.6.0.26


dhcp-range=set:tag26,5.6.0.27,5.6.0.27,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:1a,5.6.0.27


dhcp-range=set:tag27,5.6.0.28,5.6.0.28,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:1b,5.6.0.28


dhcp-range=set:tag28,5.6.0.29,5.6.0.29,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:1c,5.6.0.29


dhcp-range=set:tag29,5.6.0.30,5.6.0.30,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:1d,5.6.0.30


dhcp-range=set:tag30,5.6.0.31,5.6.0.31,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:1e,5.6.0.31


dhcp-range=set:tag31,5.6.0.32,5.6.0.32,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:1f,5.6.0.32


dhcp-range=set:tag32,5.6.0.33,5.6.0.33,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:20,5.6.0.33


dhcp-range=set:tag33,5.6.0.34,5.6.0.34,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:21,5.6.0.34


dhcp-range=set:tag34,5.6.0.35,5.6.0.35,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:22,5.6.0.35


dhcp-range=set:tag35,5.6.0.36,5.6.0.36,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:23,5.6.0.36


dhcp-range=set:tag36,5.6.0.37,5.6.0.37,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:24,5.6.0.37


dhcp-range=set:tag37,5.6.0.38,5.6.0.38,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:25,5.6.0.38


dhcp-range=set:tag38,5.6.0.39,5.6.0.39,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:26,5.6.0.39


dhcp-range=set:tag39,5.6.0.40,5.6.0.40,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:27,5.6.0.40


dhcp-range=set:tag40,5.6.0.41,5.6.0.41,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:28,5.6.0.41


dhcp-range=set:tag41,5.6.0.42,5.6.0.42,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:29,5.6.0.42


dhcp-range=set:tag42,5.6.0.43,5.6.0.43,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:2a,5.6.0.43


dhcp-range=set:tag43,5.6.0.44,5.6.0.44,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:2b,5.6.0.44


dhcp-range=set:tag44,5.6.0.45,5.6.0.45,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:2c,5.6.0.45


dhcp-range=set:tag45,5.6.0.46,5.6.0.46,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:2d,5.6.0.46


dhcp-range=set:tag46,5.6.0.47,5.6.0.47,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:2e,5.6.0.47


dhcp-range=set:tag47,5.6.0.48,5.6.0.48,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:2f,5.6.0.48


dhcp-range=set:tag48,5.6.0.49,5.6.0.49,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:30,5.6.0.49


dhcp-range=set:tag49,5.6.0.50,5.6.0.50,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:31,5.6.0.50


dhcp-range=set:tag50,5.6.0.51,5.6.0.51,255.255.0.0,infinite
dhcp-host=12:34:56:78:00:32,5.6.0.51

```


 ip netns exec ubuntu /usr/sbin/dnsmasq --conf-file=/home/zjl/ubuntu.con


https://www.cnblogs.com/CasonChan/p/4604871.html






在“GRUB_CMDLINE_LINUX”位置处不改变之前原有信息，在其基础上进行追加信息“net.ifnames=0 biosdevname=0”
