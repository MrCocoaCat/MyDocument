#!bash/bin
basepath=$(cd `dirname $0`; pwd)

#sh install.sh xen

#sh install.sh xen

#sh install.sh xen

#sh install.sh ovs

#sh install.sh libvirt
#sh install.sh pip

#sh install.sh guestfs

mkdir $basepath/offlinepacket
tar -zxvf $basepath/offlinepacket.tar.gz -C  $basepath/offlinepacket
pip install -r $basepath/requirements.txt -f $basepath/offlinepacket
rm -rf $basepath/offlinepacket


tar -zxvf stomp.tar.gz 
cd $basepath/stomp
python setup.py install
cd $basepath
rm -rf $basepath/stomp


cd $basepath
tar -zxvf iiebcvir_xen.tar.gz 
#cd iiebcvir_xen
mkdir /etc/confpath/
cp $basepath/iiebcvir_xen/confpath/config.ini /etc/confpath/

# 修改数据库
#machine
#010kvm
#002是xen

# 挂载nfs 
mount -t nfs 192.168.125.50:/home/BCNFSRoot/ /mnt/FileServer/

# 制作二进制
#pyinstaller -F main.py 