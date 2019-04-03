### 安装init-cloud
使用 apt-get 即可进行安装
```
sudo apt-get install init-cloud
```
官方文档：https://cloudinit.readthedocs.io/en/latest/

默认的配置文件为/etc/cloud/cloud.cfg

其中 /etc/cloud/cloud.cfg.d/90_dpkg.cfg为配置元数据选项,使用命令
```
dkpg-reconfigure cloud-init
```
可以更改此文件，使用空格更改选项，仅保留“NoCloud” 一项

### 制作Nocloud 数据源
1. 编辑元数据

创建 **my-meta-data** 文件，并写入一下内容
```
instance-id: iid-local03
local-hostname: ubuntu-server
```
instance-id为实例标号，只有其发生变化的时候，才会运行init-cloud


创建 **my-user-data** 文件，并写入以下内容

```
#cloud-config
chpasswd:
 list: |
   ubuntu:123456
expire: false
```
即使用cloud-config 配置模式，使用chpasswd 模块进行修改密码：将ubuntu的密码修改为123456

自动扩展磁盘空间使用growpart 模块，

```
growpart:
    mode: growpart
    devices: ["/"]
    ignore_growroot_disabled: true
```
* mode ：使用的模式，设置为 growpart
* devices ： 需要扩展的目录
* ignore_growroot_disabled ： 忽略ignore_growroot_disabled 的影响

2. 生成镜像
将my-user-data及my-meta-data文件生成为my-seed.img 数据
```
cloud-localds my-seed.img my-user-data my-meta-data
```

### 启动虚拟机
在虚拟机启动xml文件中挂载/my-seed.img镜像
```
<disk type='file' device='disk' cache='none'>
               <driver name='qemu' type='raw'/>
               <source file='/my-seed.img'/>
               <target dev='hdc' bus='virtio'/>
               <readonly/>
</disk>
```
