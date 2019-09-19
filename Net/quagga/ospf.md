
```
/usr/local/sbin/zebra -d        // 启动zebra后台程序]
```


（6）、设置和查看访问控制列表
Router1# configure terminal 与方式 Router1# conf t 相同

Router1(config)# access-list private-only permit 192.168.0.0/24           只允许这四个网络进行转发，拒绝其他任何网络
Router1(config)# access-list private-only permit 192.168.1.0/24
Router1(config)# access-list private-only permit 192.168.2.0/24
Router1(config)# access-list private-only permit 192.168.3.0/24

Router1(config)# access-list private-only deny any
Router1(config)# exit


https://www.cnblogs.com/chinas/p/4563015.html
