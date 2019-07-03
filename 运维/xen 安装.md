https://help.ubuntu.com/community/XenProposed

1. Install a 64-bit hypervisor.

```
sudo apt-get install xen-hypervisor-amd64
```

2. Modify GRUB to default to booting Xen:
```
sudo sed -i 's/GRUB_DEFAULT=.*\+/GRUB_DEFAULT="Xen 4.1-amd64"/' /etc/default/grub

sudo update-grub
```

3. Set the default toolstack to xm (aka xend):
```
sudo sed -i 's/TOOLSTACK=.*\+/TOOLSTACK="xm"/' /etc/default/xen
```

4.  reboot

```
sudo reboot
```

## 安装libvirt

```
apt-get install libvirt-bin
```

ubuntu 16.04.6
xen 4.6.5
libvirt 1.3.1



sudo virt-install --connect=xen:/// --name u14.04 --ram 1024 --disk u14.04.img,size=4 --graphics vnc,listen=0.0.0.0,port=5930 --location http://ftp.ubuntu.com/ubuntu/dists/trusty/main/installer-amd64/

virt-install --connect=xen:///    --name ubuntu16     --ram 512 --cdrom ./ubuntu-16.04.6-server-amd64.iso --disk path=./ub16.img,size=20,format=qcow2,bus=virtio --network bridge=br5 --os-type=linux  --graphics vnc,listen=0.0.0.0,port=5920



sudo virt-install --connect=xen:/// --name u18.04 --ram 1024 --disk  ./vm1.raw --graphics vnc,listen=0.0.0.0,port=5921  --cdrom ./ubuntu-18.04.2-desktop-amd64.iso


### 参考
libvirt xen参考
https://libvirt.org/drvxen.html

ubuntu xen 参考
https://help.ubuntu.com/community/Xen#Introduction
