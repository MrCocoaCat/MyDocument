#!bash/bin
basepath=$(cd `dirname $0`; pwd)

#sudo apt-get install xen-hypervisor-amd64

#rm -rf  $basepath/xen-deb
echo "begin setting xen-hypervisor-amd64"
sleep 1
#Modify GRUB to default to booting Xen:
sed -i 's/GRUB_DEFAULT=.*\+/GRUB_DEFAULT="Xen 4.1-amd64"/' /etc/default/grub
update-grub
#Set the default toolstack to xm (aka xend):
#sed -i 's/TOOLSTACK=.*\+/TOOLSTACK="xm"/' /etc/default/xen
#Now reboot:
#reboot
