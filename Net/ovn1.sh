#https://www.cnblogs.com/YaoDD/p/7475728.html
ovn-nbctl ls-add inside
ovn-nbctl ls-add dmz

# add the router
ovn-nbctl lr-add tenant1

# create router port for the connection to dmz
ovn-nbctl lrp-add tenant1 tenant1-dmz 02:ac:10:ff:01:29 172.16.255.129/26

# create the dmz switch port for connection to tenant1
ovn-nbctl lsp-add dmz dmz-tenant1
ovn-nbctl lsp-set-type dmz-tenant1 router
ovn-nbctl lsp-set-addresses dmz-tenant1 02:ac:10:ff:01:29
ovn-nbctl lsp-set-options dmz-tenant1 router-port=tenant1-dmz

# create router port for the connection to inside
ovn-nbctl lrp-add tenant1 tenant1-inside 02:ac:10:ff:01:93 172.16.255.193/26

# create the inside switch port for connection to tenant1
ovn-nbctl lsp-add inside inside-tenant1
ovn-nbctl lsp-set-type inside-tenant1 router
ovn-nbctl lsp-set-addresses inside-tenant1 02:ac:10:ff:01:93
ovn-nbctl lsp-set-options inside-tenant1 router-port=tenant1-inside

ovn-nbctl show



ovn-nbctl lsp-add dmz dmz-vm1
ovn-nbctl lsp-set-addresses dmz-vm1 "02:ac:10:ff:01:30 172.16.255.130"
ovn-nbctl lsp-set-port-security dmz-vm1 "02:ac:10:ff:01:30 172.16.255.130"

ovn-nbctl lsp-add dmz dmz-vm2
ovn-nbctl lsp-set-addresses dmz-vm2 "02:ac:10:ff:01:31 172.16.255.131"
ovn-nbctl lsp-set-port-security dmz-vm2 "02:ac:10:ff:01:31 172.16.255.131"

ovn-nbctl lsp-add inside inside-vm3
ovn-nbctl lsp-set-addresses inside-vm3 "02:ac:10:ff:01:94 172.16.255.194"
ovn-nbctl lsp-set-port-security inside-vm3 "02:ac:10:ff:01:94 172.16.255.194"

ovn-nbctl lsp-add inside inside-vm4
ovn-nbctl lsp-set-addresses inside-vm4 "02:ac:10:ff:01:95 172.16.255.195"
ovn-nbctl lsp-set-port-security inside-vm4 "02:ac:10:ff:01:95 172.16.255.195"

ovn-nbctl show



dmzDhcp="$(ovn-nbctl create DHCP_Options cidr=172.16.255.128/26 \
options="\"server_id\"=\"172.16.255.129\" \"server_mac\"=\"02:ac:10:ff:01:29\" \
\"lease_time\"=\"3600\" \"router\"=\"172.16.255.129\"")"
echo $dmzDhcp

insideDhcp="$(ovn-nbctl create DHCP_Options cidr=172.16.255.192/26 \
options="\"server_id\"=\"172.16.255.193\" \"server_mac\"=\"02:ac:10:ff:01:93\" \
\"lease_time\"=\"3600\" \"router\"=\"172.16.255.193\"")"
echo $insideDhcp

ovn-nbctl dhcp-options-list



ovn-nbctl lsp-set-dhcpv4-options dmz-vm1 $dmzDhcp
ovn-nbctl lsp-get-dhcpv4-options dmz-vm1

ovn-nbctl lsp-set-dhcpv4-options dmz-vm2 $dmzDhcp
ovn-nbctl lsp-get-dhcpv4-options dmz-vm2

ovn-nbctl lsp-set-dhcpv4-options inside-vm3 $insideDhcp
ovn-nbctl lsp-get-dhcpv4-options inside-vm3

ovn-nbctl lsp-set-dhcpv4-options inside-vm4 $insideDhcp
ovn-nbctl lsp-get-dhcpv4-options inside-vm4



ip netns add vm1
ovs-vsctl add-port br-int vm1 -- set interface vm1 type=internal
ip link set vm1 address 02:ac:10:ff:01:30
ip link set vm1 netns vm1
ovs-vsctl set Interface vm1 external_ids:iface-id=dmz-vm1

ip netns exec vm1 dhclient vm1
ip netns exec vm1 ip addr show vm1
ip netns exec vm1 ip route show

ip netns add vm3
ovs-vsctl add-port br-int vm3 -- set interface vm3 type=internal
ip link set vm3 address 02:ac:10:ff:01:94

ip link set vm3 netns vm3
ovs-vsctl set Interface vm3 external_ids:iface-id=inside-vm3
ip netns exec vm3 dhclient vm3
ip netns exec vm3 ip addr show vm3
ip netns exec vm3 ip route show





## nat
# create router edge1
ovn-nbctl create Logical_Router name=edge1 options:chassis={chassis_uid}

# create a new logical switch for connecting the edge1 and tenant1 routers
ovn-nbctl ls-add transit


# edge1 to the transit switch
ovn-nbctl lrp-add edge1 edge1-transit 02:ac:10:ff:00:01 172.16.255.1/30
ovn-nbctl lsp-add transit transit-edge1
ovn-nbctl lsp-set-type transit-edge1 router
ovn-nbctl lsp-set-addresses transit-edge1 02:ac:10:ff:00:01
ovn-nbctl lsp-set-options transit-edge1 router-port=edge1-transit


# tenant1 to the transit switch
ovn-nbctl lrp-add tenant1 tenant1-transit 02:ac:10:ff:00:02 172.16.255.2/30
ovn-nbctl lsp-add transit transit-tenant1
ovn-nbctl lsp-set-type transit-tenant1 router
ovn-nbctl lsp-set-address transit-tenant1 02:ac:10:ff:00:02
ovn-nbctl lsp-set-options transit-tenant1 router-port=tenant1-transit
