### window 安装Cloudbase-Init

window 下的初始化由Cloudbase-Init 提供， 其官方地址为 https://cloudbase.it/ 。在虚拟机中安装该软件，过程十分简单。

官方文档： https://cloudbase-init.readthedocs.io/en/latest/plugins.html

###  配置
 软件的配置文件为
```
 C:\Program Files (x86)\Cloudbase Solutions\Cloudbase-Ini\cloudbase-init.conf
```
metadata_services 选项设置元数据获取服务，ConfigDriveService 表示openstack 本地模式
```
metadata_services=cloudbaseinit.metadata.services.configdrive.ConfigDriveService,
```
plugins 选项设置需要执行的插件
SetHostNamePlugin 更改主机名
etUserPasswordPlugin 更改主机密码
ExtendVolumesPlugin 自动扩展磁盘空间(每次重启均执行)

```
# What plugins to execute.
plugins=cloudbaseinit.plugins.common.mtu.MTUPlugin,
        cloudbaseinit.plugins.common.sethostname.SetHostNamePlugin
        cloudbaseinit.plugins.windows.setuserpassword.SetUserPasswordPlugin
        cloudbaseinit.plugins.windows.extendvolumes.ExtendVolumesPlugin
```
此外还需要设置允许重启，允许使用cdrom
```
allow_reboot = true
```
###  元数据制作

ConfigDriveService 会识别lable 为 config-2 的光盘
并读取其中 openstack/latest/meta_data.json 文件的数据

穿件seed 文件夹 ，并写入数据
```
$ vim seed/openstack/latest/meta_data.json

{
    "hostname": "test5",
    "meta": {
        "admin_pass": "6"
    },
    "uuid": "local-2"
}


```
* hostname： 设置的主机名称
* admin_pass： 设置的用户密码
* uuid ：即在uuid 不同时，才会执行初始化工作，故每次需要更改


使用genisoimage 指令封装seed目录下的数据为seed.iso
```
genisoimage -output seed.iso -volid config-2 -joliet -rock seed/
```
###  启动虚拟机
挂载制作好的磁盘为
```
<disk type='file' device='cdrom'>
    <driver name='qemu' type='raw' cache='none'/>
    <source file='./seed.iso'/>
    <target dev='hdc' bus='ide'/>
</disk>
```
参考window
https://cwiki.apache.org/confluence/display/CLOUDSTACK/Using+ConfigDrive+for+Metadata,+Userdata+and+Password#UsingConfigDriveforMetadata,UserdataandPassword-Contentofmeta_data.json(jsonencoded):
openstack 中使用metadata 的方式
https://docs.openstack.org/nova/latest/user/config-drive.html
http://www.voidcn.com/article/p-pqsebuws-pk.html
