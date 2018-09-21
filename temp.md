openstack server create --flavor m1.nano --image cirros \
  --nic net-id=3e6c7f51-609f-4fdb-b999-b013941ab46f\
  --security-group default \
  --key-name mykey provider-instance2



  openstack server create --flavor m1.nano --image cirros \
  --nic net-id=f30e91d1-a74c-4bc1-be7b-d3f7486eebd8 --security-group default \
  --key-name mykey selfservice-instance


sudo virt-install --virt-type kvm --name ubuntu --ram 2048 --disk ubuntu-18.04-desktop.qcow2,format=qcow2 --network network=default --graphics vnc,listen=0.0.0.0 --noautoconsole --os-type=linux --os-variant=rhel7 --cdrom=`pwd`/ubuntu-18.04.1-desktop-amd64.iso









# By default, Ceph makes 3 replicas of objects. If you want to make four
# copies of an object the default value--a primary copy and three replica
# copies--reset the default values as shown in 'osd pool default size'.
# If you want to allow Ceph to write a lesser number of copies in a degraded
# state, set 'osd pool default min size' to a number less than the
# 'osd pool default size' value.

osd pool default size = 3  # Write an object 3 times.
osd pool default min size = 2 # Allow writing two copies in a degraded state.

# Ensure you have a realistic number of placement groups(PG). We recommend
# approximately 100 per OSD. E.g., total number of OSDs multiplied by 100
# divided by the number of replicas (i.e., osd pool default size). So for
# 10 OSDs and osd pool default size = 4, we'd recommend approximately
# (100 * 10) / 4 = 250.

osd pool default pg num = 250
osd pool default pgp num = 250



ceph auth get-or-create client.glance | ssh 10.19.19.23 sudo tee /etc/ceph/ceph.client.glance.keyring

ssh {your-glance-api-server} sudo chown glance:glance /etc/ceph/ceph.client.glance.keyring

ceph auth get-or-create client.cinder | ssh {your-volume-server} sudo tee /etc/ceph/ceph.client.cinder.keyring

ssh {your-cinder-volume-server} sudo chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring

ceph auth get-or-create client.cinder-backup | ssh {your-cinder-backup-server} sudo tee /etc/ceph/ceph.client.cinder-backup.keyring

ssh {your-cinder-backup-server} sudo chown cinder:cinder /etc/ceph/ceph.client.cinder-backup.keyring
