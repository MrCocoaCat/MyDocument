#!bin/bash
sudo rm -rf /var/cache/apt/archives/*
cp -r /var/cache/apt/archives  ~/
chmod 777 -R ./archives
scp -r ./archives root@192.168.83.150:~/






basepath = /root



# 安装pip包
#rpm -i python2-pip-8.1.2-8.el7.noarch.rpm 
yum install python2-pip
tar -zxvf offlinepacket.tar.gz
pip install -r ./requirements.txt -f ./offlinepacket/
rm -rm $basepath/offlinepacket/
cd $basepath

# 单独安装stomp 包
tar -zxvf stomp.tar.gz
cd $basepath/stomp/
python setup.py install
cd $basepath
rm -rf stomp/

#
yum install openvswitch
service openvswitch start

#
yum -y install libvirt-python
yum -y install python-libguestfs

# 解压包
cd $basepath
tar -zxvf iiebcvir.tar.gz

# 配置程序配置文件
mkdir /etc/confpath/
cp iiebcvir/confpath/config.ini /etc/confpath/

cd ./iiebcvir
python main.py


# 磁盘放置目录
#/home/iievirimg/attempt



#### Xen 
sudo apt-get install xen-hypervisor-amd64
#Modify GRUB to default to booting Xen:
sudo sed -i 's/GRUB_DEFAULT=.*\+/GRUB_DEFAULT="Xen 4.1-amd64"/' /etc/default/grub
sudo update-grub
#Set the default toolstack to xm (aka xend):
sudo sed -i 's/TOOLSTACK=.*\+/TOOLSTACK="xm"/' /etc/default/xen
#Now reboot:
sudo reboot

#sudo apt-get install virtinst


apt-get install openvswitch-switch
apt-get install libvirt-bin

# qemu binary /etc/default/qemu-kvm is not excutable permission

apt-get install python-pip

apt-get install python-libguestfs


pip install -r ./requirements.txt -f ./offlinepacket/

# 数据库
# 修改


18663511203 清晨
15624980719 陈宇

# 修改数据库
machine
010kvm
002是xen

# 挂载nfs 
mount -t nfs 192.168.125.50:/home/BCNFSRoot/ /mnt/FileServer/

# 制作二进制
pyinstaller -F main.py 

# 配置文件 
 /etc/confpath/



dkpg-scanpackges packs /dev/null | gzip > packs/Packages.gz -r
deb file:///media/ packs/

/root/iiebcvir_xen/excutor/xenhostdeploy.py

cp -r /var/cache/apt/archives  /yout-path



nohup /usr/local/node/bin/node /www/im/chat.js >> /usr/local/node/output.log 2>&1 &



offlinepacket 那个是pip的包
stomp.rar
是离线的python 包
1.解压stomp.tar  tar -xvf stomp.rar 进入目录 执行 python setup.py install
2.解压offlinepacket  tar -xvf offlinepacket.tar, 执行 pip install -r ./requirements.txt -f ./offlinepacket/
3.利用源安装 python-libguestfs
4.挂载nfs，mount -t nfs ip:/home/BCNFSRoot /mnt/FileServer/
5.更改配置目录 /etc/confpath/config.ini
6.启动程序 nohup python main.py &
你看这几步方便理解不
