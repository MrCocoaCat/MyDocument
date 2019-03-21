### Apt Configure
### Apt Pipelining
### Apt Pipelining
### Byobu
### CA Certs
### Chef
### Debug
### Disable EC2 Metadata
### Disk Setup
### Emit Upstart
### Fan
### Final Message
### Foo
### Growpart
**summary**:增长分区

Growpart调整分区大小以填充可用磁盘空间。这对于具有比pristine映像使用的更大磁盘空间量的云实例非常有用，因为它允许实例自动使用额外空间。

运行growpart on的设备被指定为 devices key下的列表。devices 列表中的每个条目可以是文件系统中设备的挂载点的路径，也可以是/dev中块设备的路径。可以使用mode config键选择用于调整大小的实用程序。
如果mode key设置为auto，则将使用任何可用的实用程序（growpart或gpart）。如果两个实用程序都不可用，则不会引发错误。如果mode设置为growpart，则将使用growpart实用程序。 如果此实用程序在系统上不可用，则会导致错误。如果mode设置为off或false，则cc_growpart将不执行任何操作。

此模块与cloud-initramfs-tools的growroot功能之间存在一些功能重叠。
但是，在某些情况下，一个工具能够运行而另一个工具不能运行。
两者的默认配置应适用于大多数云实例。
要明确阻止cloud-initramfs-tools运行growroot，可以创建文件/etc/growroot-disabled。默认情况下，growroot和cc_growpart都会检查此文件是否存在，如果存在则不会运行。 但是，通过将ignore_growroot_disabled设置为true，可以忽略cc_growpart的此文件。 有关cloud-initramfs-tools的更多信息，请参阅 https://launchpad.net/cloud-initramfs-tools
默认情况下，根分区上会启用Growpart。 growpart的默认配置是：
```
growpart:
    mode: auto
    devices: ["/"]
    ignore_growroot_disabled: false
```

**Internal name**: cc_growpart
**Module frequency**: 永远
**支持的发行版**: 所有
**Config keys**:
```
growpart:
    mode: <auto/growpart/off/false>
    devices:
        - "/"
        - "/dev/vdb1"
    ignore_growroot_disabled: <true/false>
```

### Grub Dpkg
### Keys to Console
### Landscape
### Locale
### LXD
### Mcollective
### Migrator
### Mounts
### NTP
### Package Update Upgrade Install
### Phone Home
### Power State Change
### Puppet
### Resizefs
### Resolv Conf
### RedHat Subscription
### Rightscale Userdata
### Rsyslog
### Runcmd
### Salt Minion
### Scripts Per Boot
### Scripts Per Instance
### Scripts Per Once
### Scripts User
### Scripts Vendor
### Seed Random
### Set Hostname
**summary**:
**Internal name**:
**Module frequency**:
**支持的发行版**:
**Config keys**:
### Set Passwords
**summary**:设置用户密码
设置系统密码并启用或禁用ssh密码验证chpasswd配置密钥接受包含两个密钥中的一个密钥的字典，可以是expire或list。如果指定了expire并将其设置为false，则密码全局配置密钥将用作所有用户帐户的密码。如果指定了expire键并将其设置为true，则用户密码将过期，从而阻止使用默认系统密码。

如果提供了列表键，则可以指定用户名：密码对的列表。指定的用户名必须已存在于系统上，或者已使用cc_users_groups模块创建。可以使 用用户名：RANDOM或 用户名：R随机生成密码。可以使用用户名：$6$salt$ hash指定哈希密码。用户使用密码认证登陆ssh,可以使用ssh_pwauth启用，禁用 或 设置系统默认值。
**Internal name**:cc_set_passwords
**Module frequency**:一直
**支持的发行版**:所有
**Config keys**:
```
ssh_pwauth: <yes/no/unchanged>

password: password1
chpasswd:
    expire: <true/false>

chpasswd:
    list: |
        user1:password1
        user2:RANDOM
        user3:password3
        user4:R

##
# or as yaml list
##
chpasswd:
    list:
        - user1:password1
        - user2:RANDOM
        - user3:password3
        - user4:R
        - user4:$6$rL..$ej...
```
