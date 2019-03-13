设置区域
```
interface range name liyubo2 interface GigabitEthernet 1/0/10 to GigabitEthernet 1/0/20
```

设置vlan
```
# 设置其类型为access
port link-type access

# 设置其为vlan 600
port access vlan 600
```

配置openflow
```

1) 进入系统视图。
system-view

(2) 进入OpenFlow 实例视图。
openflow instance instance-id

(3) 配置OpenFlow 实例的类型。
classification vlan vlan-id [ mask vlan-mask ] [ loosen ]
缺省情况下，未配置 OpenFlow 实例的类型。

(4) （可选）配置带内管理VLAN。
in-band management vlan { vlan-id [ to vlan-id ] } &<1-10>
缺省情况下，未配置带内管理 VLAN。

```
