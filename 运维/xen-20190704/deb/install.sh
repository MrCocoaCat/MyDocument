#!bash/bin
basepath=$(cd `dirname $0`; pwd)
echo $1
tar -zxvf $basepath/$1.tar.gz -C $basepath/
dpkg -i $basepath/$1/*.deb
rm -rf  $basepath/$1
