### 以卷启动实例日志分析
第一次以此镜像启动实例，cinder,glance,nova 后端均配置为ceph。分别使用三个不同的ceph pools。

### controlr:nova-api.log

14:15:41.523 271154 INFO nova.api.openstack.compute.server_external_events  Creating event network-changed:97aec095-dfbf-47e7-b78e-76a48ddbd86d for instance 9afef808 on compute3


### compute3:nova-api.log


#### 尝试在compute3节点上创建实例，进行相关判断

14:15:36.622   INFO nova.compute.claims  [instance: 9afef808] Attempting claim on node compute3: memory 4096 MB, disk 10 GB, vcpus 4 CPU
14:15:36.623   INFO nova.compute.claims  [instance: 9afef808] Total memory: 65507 MB, used: 512.00 MB
14:15:36.623   INFO nova.compute.claims  [instance: 9afef808] memory limit not specified, defaulting to unlimited
14:15:36.623   INFO nova.compute.claims  [instance: 9afef808] Total disk: 5589 GB, used: 0.00 GB
14:15:36.624   INFO nova.compute.claims  [instance: 9afef808] disk limit not specified, defaulting to unlimited
14:15:36.624   INFO nova.compute.claims  [instance: 9afef808] Total vcpu: 24 VCPU, used: 0.00 VCPU
14:15:36.624   INFO nova.compute.claims  [instance: 9afef808] vcpu limit not specified, defaulting to unlimited
#### 判断成功，在compute3节点上创建实例

14:15:36.626   INFO nova.compute.claims  [instance: 9afef808] Claim successful on node compute3
14:15:36.930   WARNING nova.virt.libvirt.driver  [instance: 9afef808] Ignoring supplied device name: /dev/vda. Libvirt can't honour user-supplied dev names
14:15:37.062   INFO nova.virt.block_device  [instance: 9afef808] Booting with blank volume at /dev/vda
14:16:04.103   INFO nova.virt.libvirt.driver  [instance: 9afef808] Creating image
#### 网络

14:16:04.554   INFO os_vif [ ] Successfully plugged vif VIFBridge(active=False,address=fa:16:3e:1c:9c:3a,bridge_name='brqacad4e04-d7',has_traffic_filtering=True,id=97aec095-dfbf-47e7-b78e-76a48ddbd86d,network=Network(acad4e04-d7f5-478a-9ec2-1be696f81ed9),plugin='linux_bridge',port_profile=<?>,preserve_on_delete=False,vif_name='tap97aec095-df')
14:16:04.647   INFO nova.virt.libvirt.driver  [instance: 9afef808] Using config drive
14:16:04.811   INFO nova.virt.libvirt.driver  [instance: 9afef808] Creating config drive at /var/lib/nova/instances/9afef808/disk.config
14:16:05.063   INFO nova.virt.libvirt.driver  [instance: 9afef808] Deleting local config drive /var/lib/nova/instances/9afef808/disk.config because it was imported into RBD.
14:16:05.366   INFO nova.compute.manager  [instance: 9afef808] VM Resumed (Lifecycle Event)
14:16:05.379   INFO nova.virt.libvirt.driver  [instance: 9afef808] Instance spawned successfully.
14:16:05.380   INFO nova.compute.manager  [instance: 9afef808] Took 1.28 seconds to spawn the instance on the hypervisor.
14:16:05.464   INFO nova.compute.manager  [instance: 9afef808] During sync_power_state the instance has a pending task (spawning). Skip.
14:16:05.465   INFO nova.compute.manager  [instance: 9afef808] VM Started (Lifecycle Event)

#### 创建时间

14:16:05.520   INFO nova.compute.manager  [instance: 9afef808] Took 28.92 seconds to build instance.

14:16:08.047   WARNING nova.compute.manager   [instance: 9afef808] Received unexpected event network-vif-plugged-97aec095-dfbf-47e7-b78e-76a48ddbd86d for instance with vm_state active and task_state None.

### compute1：volume.log


#### 创建卷的信息

14:15:37.734  INFO cinder.volume.flows.manager.create_volume  Volume fb41e36f-2cb2-44eb-a905-732d0107a6ee: being created as image with specification: {'status': u'creating', 'image_location': (None, None), 'volume_size': 10, 'volume_name': u'volume-fb41e36f-2cb2-44eb-a905-732d0107a6ee', 'image_id': u'0ff8b675-7cc0-4252-a499-0f99a517350c', 'image_service': <cinder.image.glance.GlanceImageService object at 0x7921ed0>, 'image_meta': {u'status': u'active', u'name': u'xenial', u'tags': [], u'container_format': u'bare', u'created_at': datetime.datetime(2018, 10, 22, 1, 29, 10, tzinfo=<iso8601.Utc>), u'disk_format': u'qcow2', u'updated_at': datetime.datetime(2018, 10, 22, 1, 29, 16, tzinfo=<iso8601.Utc>), u'visibility': u'public', 'properties': {}, u'owner': u'871273cbfca841a49e6136e4d8ac7961', u'protected': False, u'id': u'0ff8b675-7cc0-4252-a499-0f99a517350c', u'file': u'/v2/images/0ff8b675-7cc0-4252-a499-0f99a517350c/file', u'checksum': u'c26409a3fbbfcf81eb6c6a8126015d68', u'min_disk': 0, u'virtual_size': None, u'min_ram': 0, u'size': 296812544}}

#### 下载镜像，速度为74.68 MB/s
14:15:41.525  INFO cinder.image.image_utils  Image download 283.00 MB at 74.68 MB/s
#### 转换镜像格式
14:15:48.188  INFO cinder.image.image_utils  Converted 2252.00 MB image at 466.98 MB/s
#### 创建卷
14:16:01.705  INFO cinder.volume.flows.manager.create_volume  Volume volume-fb41e36f-2cb2-44eb-a905-732d0107a6ee (fb41e36f-2cb2-44eb-a905-732d0107a6ee): created successfully
#### 创建10G 卷，花费不足1秒
14:16:01.721  INFO cinder.volume.manager  Created volume successfully.
14:16:02.887  INFO cinder.volume.manager  Initialize volume connection completed successfully.
#### 将卷链接至实例
14:16:03.063  INFO cinder.volume.manager  Attaching volume fb41e36f-2cb2-44eb-a905-732d0107a6ee to instance 9afef808 at mountpoint /dev/vda on host None.
14:16:03.156  INFO cinder.volume.manager  Attach volume completed successfully.
