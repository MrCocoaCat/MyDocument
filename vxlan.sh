#bin/bash
echo "start------ "$0
echo ""

a="10"
b="20"

function SetIp(){
 num=`ifconfig br-base|grep inet|awk '{print $2}'|awk -F '.' '{print $4}'`
 echo "seting IP with suffix:"$num
 if [ $num == "123" ];then
  remote_ip="10.19.15.119"
  ip="10.19.15.123"
 elif [ $num == "119" ];then
  remote_ip="10.19.15.123"
  ip="10.19.15.119"
 else
  echo "please set your own IP"
  exit
 fi
 echo "finish seting IP"
}

function addFlow1(){
 ovs-ofctl add-flow br-tun "priority=5,in_port=1,dl_vlan=10,actions=output:10"
 ovs-ofctl add-flow br-tun "priority=5,in_port=10,dl_vlan=10,actions=output:1"

 ovs-ofctl add-flow br-tun "priority=5,in_port=1,dl_vlan=20,actions=output:20"
 ovs-ofctl add-flow br-tun "priority=5,in_port=20,dl_vlan=20,actions=output:1"
}
function addFlow2(){
 ovs-ofctl add-flow br-tun "priority=5,in_port=1,dl_vlan=10,actions=strip_vlan,output:10"
 ovs-ofctl add-flow br-tun "priority=5,in_port=10,dl_vlan=0xffff,actions=mod_vlan_vid:10,output:1"

 ovs-ofctl add-flow br-tun "priority=5,in_port=1,dl_vlan=20,actions=strip_vlan,output:20"
 ovs-ofctl add-flow br-tun "priority=5,in_port=20,dl_vlan=0xffff,actions=mod_vlan_vid:20,output:1"
}

virsh shutdown ubuntu-server-61111
virsh shutdown ubuntu-server-61112
SetIp
ovs-vsctl --if-exists del-br br-int
ovs-vsctl --if-exists del-br br-tun

ovs-vsctl add-br br-int
ip link set  br-int up
ovs-vsctl add-br br-tun
ip link set  br-tun up

#ovs-vsctl add-port br-vxlan enp130s0f0
#ifconfig br-vxlan ${ip}/24
ifconfig enp130s0f0 ${ip}/24
#ifconfig enp130s0f0 0

ovs-vsctl add-port br-tun pt_peerA -- set interface pt_peerA type=patch option:peer=pt_peerB
ovs-vsctl add-port br-int pt_peerB -- set interface pt_peerB type=patch option:peer=pt_peerA

ovs-vsctl add-port br-tun vxlan-$a -- set interface vxlan-$a type=vxlan options:remote_ip=${remote_ip} options:key=1$a options:local_ip=${ip} options:df_default=true
ovs-vsctl add-port br-tun vxlan-$b -- set interface vxlan-$b type=vxlan options:remote_ip=${remote_ip} options:key=1$b options:local_ip=${ip} options:df_default=true

ovs-vsctl set interface pt_peerA ofport_request=1
ovs-vsctl set interface pt_peerA ofport_request=1
ovs-vsctl set interface vxlan-$a ofport_request=$a
ovs-vsctl set interface vxlan-$b ofport_request=$b
# 设置连接

#ovs-vsctl set interface pt_peerA type=patch option:peer=pt_peerB
#ovs-vsctl set interface pt_peerB type=patch

#ovs-vsctl set interface pt_peerB option:peer=pt_peerA
#ovs-vsctl set interface pt_peerA option:peer=pt_peerB



sleep 1
virsh destroy ubuntu-server-61111 2>/dev/null
virsh destroy ubuntu-server-61112 2>/dev/null
virsh create /root/liyubo/vxlan1/ubuntu.xml 
virsh create /root/liyubo/vxlan2/ubuntu.xml 

sleep 1
ovs-vsctl set port tap1 tag=$a
#ovs-vsctl set interface tap1 ofport_request=1
#ifconfig tap1 mtu 1450
ovs-vsctl set port tap2 tag=$b
#ovs-vsctl set interface tap2 ofport_request=2
#ifconfig tap2 mtu 1450

ovs-ofctl del-flows br-tun
addFlow2
ifconfig tap1 mtu 1600
ifconfig tap2 mtu 1600
ifconfig tap2 mtu 1600

