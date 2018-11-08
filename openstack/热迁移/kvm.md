配置使用libvirt进行热迁移：

1. 修改文件/etc/libvirt/libvirtd.conf，将相应表项改为如下所示：

```
listen_tls = 0

listen_tcp = 1

auth_tcp = “none”
```
2. 修改文件Edit /etc/init/libvirt-bin.conf

```
env libvirtd_opts="-d -l"
```

3. 修改文件/etc/default/libvirt-bin

```
#options passed to libvirtd, add "-l" to listen on tcp
libvirtd_opts="-d-l"
```

4. 重启libvirt

```
sudo service libvirt-bin restart
```

5. 执行热迁移，使用virsh命令，或者使用下面的Python脚本。在shell命令中，假设192.168.137.138为目的物理机的IP。

```
sudo virsh migrate --live vm1 qemu+tcp://192.168.137.138/system 
```
