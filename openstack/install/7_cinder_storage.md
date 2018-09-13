https://docs.openstack.org/cinder/queens/install/cinder-storage-install-rdo.html

### Prerequisites

1. Install the supporting utility packages:
```
yum install lvm2 device-mapper-persistent-data
```

```
systemctl enable lvm2-lvmetad.service
# systemctl start lvm2-lvmetad.service

```

2. Create the LVM physical volume /dev/sdb:
```

```
