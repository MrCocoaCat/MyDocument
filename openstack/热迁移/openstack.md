https://www.cnblogs.com/pinganzi/p/6556446.html


修改libvirt配置

配置versh免密码连接，修改/etc/libvirt/libvirtd.conf

添加如下配置

```
listen_tls = 0

listen_tcp = 1

tcp_port = "16509"

listen_addr = "172.16.201.8"   #根据自己的计算节点IP改写

auth_tcp = "none"

```

修改/etc/sysconfig/libvirtd 添加如下参数

```
LIBVIRTD_CONFIG=/etc/libvirt/libvirtd.conf

LIBVIRTD_ARGS="--listen"
```


重启libvirt


systemctl restart libvirtd.service
查看监听端口：


```
[root@compute1 ~]# netstat -lnpt | grep libvirtd

tcp        0      0 172.16.206.6:16509      0.0.0.0:*               LISTEN      9852/libvirtd
```
测试：


在compute1节点上：
```
virsh -c qemu+tcp://compute2/system
```

在compute2节点上
```
virsh -c qemu+tcp://compute1/system
```
如果能无密码连接上去，表示配置没问题
