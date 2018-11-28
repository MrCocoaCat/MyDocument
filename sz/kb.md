### 装系统

选择：
1. Software selection选项

2. infrastructure server

3. virtualation Hy

配置网卡
```
vi /etc/sysconfig/network-scripts/ifcfg-eth0
service network restart
```


### 挂在


1. fdisk -l
显示所有磁盘


2. 挂载

```
mount /dev/sdb2 /mnt/yum/
```

3. 安装http 服务
```
yum -y install
```

3. 创建软连接

```
ln -s /mnt/yum/Rhel_yum/centos7.5 /var/www/html/html
```


2. 更新配置源

```
cp /mnt/yum/Rhel_yum/yum/local* /etc/yum.repos.d/
```

修改
localHttpepel.repo
localHttp.repo

3. 关闭防火墙

```
setenforce 0

```
更改后为permissive

```
systemctl stop firewalled
```
