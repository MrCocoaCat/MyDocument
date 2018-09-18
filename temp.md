openstack server create --flavor m1.nano --image cirros \
  --nic net-id=3e6c7f51-609f-4fdb-b999-b013941ab46f\
  --security-group default \
  --key-name mykey provider-instance2



  openstack server create --flavor m1.nano --image cirros \
  --nic net-id=f30e91d1-a74c-4bc1-be7b-d3f7486eebd8 --security-group default \
  --key-name mykey selfservice-instance
