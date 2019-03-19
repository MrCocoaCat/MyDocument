## Datasources
### What is a datasource?
数据源是cloud-init的配置数据源，通常来自用户（也称为userdata）或来自创建配置驱动器的堆栈（也称为元数据）。典型的用户数据包括文件，yaml和shell脚本，而典型的元数据包括服务器名称，实例ID，显示名称和其他特定于云的详细信息。 由于提供此数据的方式有多种（每个云解决方案似乎更喜欢自己的方式），因此在内部创建了一个数据源抽象类，以允许单一方式访问不同的云系统方法，通过子类的典型用法提供此数据。

由cloud-init的数据源处理的任何元数据都保存为/run/cloud-init/instance-data.json。 Cloud-init提供工具以快速内省部分数据。 有关更多信息，请参阅实例元数据。

### Adding a new Datasource
数据源对象与cloud-init有一些touch point。 如果您有兴趣为您的云平台添加新数据源，则需要注意以下事项：

* 确定一种积极识别平台的机制：云平台向客户肯定地识别自己是一种很好的做法。
这允许访客根据其运行的平台做出明智的决策。在x86和arm64架构上，许多云通过DMI数据识别自己。 例如，Oracle的公共云在DMI机箱资产字段中提供字符串“OracleCloud.com”。

cloud-init的镜像会生成一个包含平台详细信息的日志文件。/run/cloud-init/ds-identify.log日志文件也可能会提供唯一识别平台的标识。如果没有日志，可以通过 source ./tools/ds-identify 生成，或安装/usr/lib/cloud-init/ds-identify

下面的ds-identify和datasource模块部分将需要用于标识平台的机制。

* Add datasource module ：``cloudinit/sources/DataSource<CloudPlatform>.py``建议您首先复制一个更简单的数据源，如DataSource Hetzner。

* Add tests for datasource module： Add a new file with some tests for the module to cloudinit/sources/test_<yourplatform>.py. For example see cloudinit/sources/tests/test_oracle.py

* Update ds-identify: 在systemd系统中，ds-identify用于检测应该启用哪个数据源，或者是否应该运行cloud-init。您需要对tools/ds-identify进行更改

* Add tests for ds-identify：将新类中的相关测试添加到tests/unittests/test_ds_identify.py中。 您可以使用TestOracle作为示例。

* Add your datasource name to the builtin list of datasources：将数据源模块名称添加到cloudinit/ settings.py中datasource_list条目的末尾。

* 将您的云平台添加到 apport集合提示：更新cloudinit / apport.py中的云平台列表。
此列表将提供给调用ubuntu-bug cloud-init的用户。

### Datasource Documentation
以下是已实现的数据源列表。 请关注以获取更多信息

NoCloud
https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
#### NoCloud

数据源NoCloud允许用户在不运行网络服务的情况下（甚至根本没有网络）向用户提供用户数据和元数据。

您可以通过vfat或iso9660文件系统上的文件向本地vm引导提供meta-data和 user-data。 文件系统卷标签必须是cidata。

或者，您可以通过内核命令行或SMBIOS“序列号”选项提供元数据。 数据必须以字符串的形式传递：

```
ds=nocloud[;key=val;key=val]
```
或者

```
ds=nocloud-net[;key=val;key=val]
```

允许的密钥是：
h or local-hostname
i or instance-id
s or seedfrom

```
## create user-data and meta-data files that will be used
## to modify image on first boot

$ { echo instance-id: iid-local01; echo local-hostname: cloudimg; } > meta-data

$ printf "#cloud-config\npassword: passw0rd\nchpasswd: { expire: False }\nssh_pwauth: True\n" > user-data

## create a disk to attach with some user-data and meta-data

$ genisoimage  -output seed.iso -volid cidata -joliet -rock user-data meta-data


## alternatively, create a vfat filesystem with same files
## $ truncate --size 2M seed.img
## $ mkfs.vfat -n cidata seed.img
## $ mcopy -oi seed.img user-data meta-data ::

## create a new qcow image to boot, backed by your original image
$ qemu-img create -f qcow2 -b disk.img boot-disk.img

## boot the image and login as 'ubuntu' with password 'passw0rd'
## note, passw0rd was set as password through the user-data above,
## there is no password set on these images.
$ qemu-kvm -m 256 \
   -net nic -net user,hostfwd=tcp::2222-:22 \
   -drive file=boot-disk.img,if=virtio \
   -drive file=seed.iso,if=virtio
```
