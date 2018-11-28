

网络文件地址为：/etc/sysconfig/network-scripts

### 配置网卡
编辑ifcfg-ens3:
```
 # 网卡类型：为以太网
TYPE=Ethernet  

# 代理方式：关闭状态            
PROXY_METHOD=none  

# 只是浏览器：否       
BROWSER_ONLY=no    

# 网卡的引导协议：DHCP[中文名称: 动态主机配置协议]       
BOOTPROTO=dhcp   

# 默认路由：是, 不明白的可以百度关键词 `默认路由`
DEFROUTE=yes   

# 是不开启IPV4致命错误检测：否     
IPV4_FAILURE_FATAL=no   

# IPV6是否自动初始化: 是[不会有任何影响, 现在还没用到IPV6]
IPV6INIT=yes

 # IPV6是否自动配置：是[不会有任何影响, 现在还没用到IPV6]              
IPV6_AUTOCONF=yes  

# IPV6是否可以为默认路由：是[不会有任何影响, 现在还没用到IPV6]        
IPV6_DEFROUTE=yes    

 # 是不开启IPV6致命错误检测：否     
IPV6_FAILURE_FATAL=no      

# IPV6地址生成模型：stable-privacy [这只一种生成IPV6的策略]
IPV6_ADDR_GEN_MODE=stable-privacy    

 # 网络接口名称，即配置文件名后半部分。     
NAME=eno16777736    

 vi /etc/resolv.conf=f47bde51-fa78-4f79-b68f-d5dd90cfc698   # 通用唯一识别码, 每一个网卡都会有, 不能重复, 否两台linux只有一台网卡可用

 # 网卡设备名称
DEVICE=ens33     

# 是否开机启动， 要想网卡开机就启动或通过 `systemctl restart network`控制网卡,必须设置为 `yes`        
ONBOOT=no                   

```


### 重启网卡

service network restart

### DNS

配置文件 /etc/resolv.conf

nameserver 8.8.8.8
nameserver 159.226.8.7







#
/etc/network/

sudo /etc/init.d/networking restart
