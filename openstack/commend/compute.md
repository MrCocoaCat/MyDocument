https://docs.openstack.org/nova/queens/admin/index.html



#### [Manage Flavors](https://docs.openstack.org/nova/queens/admin/flavors.html)
Admin users 可以使用 openstack flavor 命令管理flavors.查看命令的详细信息使用
```
$ openstack flavor --help
```
##### Create a flavor
1. 列出用于显示ID和名称、内存数量、根分区和临时分区的磁盘空间数量、交换以及每种类型的虚拟cpu数量
```
openstack flavor list
```

2. 要创建flavor，请指定名称、ID、RAM大小、磁盘大小和该flavor的vcpu数量，如下所示:
```
$ openstack flavor create FLAVOR_NAME --id FLAVOR_ID \
    --ram RAM_IN_MB --disk ROOT_DISK_IN_GB --vcpus NUMBER_OF_VCPUS
```

3. 如果单个用户或用户组需要定制的flavor，而您不希望其他项目能够访问这种flavor，则可以创建私有flavor。
```
openstack flavor create --private m1.extra_tiny --id auto \
   --ram 256 --disk 0 --vcpus 1
```
创建一个味道之后，通过指定味道名称或ID和项目ID将其分配给项目
```
$ openstack flavor set --project PROJECT_ID m1.extra_tiny
```
4. 对于可选参数列表，运行以下命令:
```
openstack help flavor creates
```
