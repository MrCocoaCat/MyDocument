(官方文档地址)[http://docs.ceph.com/docs/master/rados/operations/pools/#createpool]

1. 列举pools
```
ceph osd lspools
```

2. 创建pool


[ Pool, PG and CRUSH Config Reference.](http://docs.ceph.com/docs/master/rados/configuration/pool-pg-config-ref/)

[PG 设置详细介绍](http://docs.ceph.com/docs/master/rados/operations/placement-groups/)

3. 查看集群的使用情况
(ceph 状态查看)[https://www.cnblogs.com/zhongguiyao/p/7992729.html]

```
ceph df
```

SIZE: 集群的总容量；
AVAIL: 集群的空闲空间总量；
RAW USED: 已用存储空间总量；
% RAW USED: 已用存储空间比率。用此值参照 full ratio 和 near full \ ratio 来确保不会用尽集群空间。
详情见存储容量。
输出的 POOLS 段展示了存储池列表及各存储池的大致使用率。没有副本、克隆品和快照占用情况。例如，如果你把 1MB 的数据存储为对象，
理论使用率将是 1MB ，但考虑到副本数、克隆数、和快照数，实际使用率可能是 2MB 或更多。
NAME: 存储池名字；
ID: 存储池唯一标识符；
USED: 大概数据量，单位为 KB 、 MB 或 GB ；
%USED: 各存储池的大概使用率；
Objects: 各存储池内的大概对象数。
