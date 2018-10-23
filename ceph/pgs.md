[](https://www.cnblogs.com/kuku0223/p/8214412.html)
#### ceph PG数量调整/PG的状态说明


优化:　　

##### PG Number

PG和PGP数量一定要根据OSD的数量进行调整，计算公式如下，但是最后算出的结果一定要接近或者等于一个2的指数。调整PGP不会引起PG内的对象的分裂，但是会引起PG的分布的变动三、总结PG是指定存储池存储对象的目录有多少个，PGP是存储池PG的OSD分布组合个数PG的增加会引起PG内的数据进行分裂，分裂到相同的OSD上新生成的PG当中PGP的增加会引起部分PG的分布进行变化，但是不会引起PG内对象的变动

Total PGs = (Total_number_of_OSD * 100) / max_replication_count

结算的结果往上取靠近2的N次方的值。比如总共OSD数量是160，复制份数3，pool数量也是3，那么按上述公式计算出的结果是1777.7。取跟它接近的2的N次方是2048，那么每个pool分配的PG数量就是2048。

在更改pool的PG数量时，需同时更改PGP的数量。PGP是为了管理placement而存在的专门的PG，它和PG的数量应该保持一致。如果你增加pool的pg_num，就需要同时增加pgp_num，保持它们大小一致，这样集群才能正常rebalancing。下面介绍如何修改pg_num和pgp_num。

1. 检查rbd这个pool里已存在的PG和PGP数量：

```
$ ceph osd pool get rbd pg_num
pg_num: 128

$ ceph osd pool get rbd pgp_num
pgp_num: 128
```
2. 检查pool的复制size，执行如下命令：

$ ceph osd dump |grep size|grep rbd
pool 2 'rbd' replicated size 3 min_size 2 crush_ruleset 0 object_hash rjenkins pg_num 128 pgp_num 128 last_change 45 flags hashpspool stripe_width 0

3. 使用上述公式，根据OSD数量、复制size、pool的数量，计算出新的PG数量，假设是256.

4. 变更rbd的pg_num和pgp_num为256：

```
$ ceph osd pool set rbd pg_num 256
$ ceph osd pool set rbd pgp_num 256
```

5. 如果有其他pool，同步调整它们的pg_num和pgp_num，以使负载更加均衡。


ceph - pg 常见状态
pg ( placement group ) 是数据存储的重要单位
在使用 ceph 的时候, pg 会经常发生状态的变化, 参考下面例子



当创建池的时候, 将会创建相应的 pg, 那么可以看到 pg creating 状态
当部分 pg 创建成功后, 将会发现 pg 会进入 peering 状态
当所有 pg peering 完成后,  将可见到状态变成 active+clean


常见的 pg 状态
* creating (创建中)
PG 正在被创建, 通常当存储池正在卑创建或增加一个存储池的 PG 数量时, PG 会呈现这个状态
* Down (失效)
PG 处于失效状态, PG 应该处于离线状态
* repair(修复)
PG 正在被检查, 被发现的任何不一致都将尽可能被修复.
* peering (等待互联)
当 ceph peering pg, ceph 将会把 pg 副本协定导入 osd, 当 ceph 完成 peering, 意味着 osd 同意当前 PG 状态, 并允许写入
PG 处于 peering 过程中, peering 由主 osd 发起的使存放 PG 副本的所有 OSD 就 PG 的所有对象和元素数据的状态达成一致的过程,  peering 过程完成后, 主 OSD 就可以接受客户端写请求.
* Active (活动)
当 ceph 完成 peering 过程, pg 将会变成 active, active 状态意味着 pg 中的数据变得可用, 主 pg 将可执行读写操作
PG 是活动的, 意味着 PG 中的数据可以被读写, 对该 PG 的操作请求都讲会被处理.
* Clean (干净)
当 pg 显示 clean 状态, 主 osd 与副本 osd 成功同步并且没有异步复制, ceph 在 pg 中所有对象具有正确的副本数量
PG 中的所有对象都已经卑复制了规定的副本数量.
* Replay (重做)
某 OSD 崩溃后, PG 正在等待客户端重新发起操作
* Degraded (降级)
当客户端写对象到主 osd, 主 OSD 会把数据写复制到对应复制 OSD, 在主 OSD 把对象写入存储后, PG 会显示为 degraded 状态, 直到主 osd 从复制 OSD 中接收到创建副本对象完成信息
PG 处于 active+degraded 原因是因为 OSD 是处于活跃, 但并没有完成所有的对象副本写入, 假如 OSD DOWN, CEPH 标记每个 PG 分配到这个相关 OSD 的
状态为 degraded, 当 OSD 重新上线, OSD 将会重新恢复,
假如 OSD DOWN 并且 degraded 状态持续, CEPH 会标记 DOWN OSD, 并会对集群迁移相关 OSD 的数据, 对应时间由 mon osd down out interval 参数决定
PG 可以被北极为 degraded, 因为 ceph 在对应 PG 中无法找到一个或者多个相关的对象, 你不可以读写 unfound 对象, 你仍然可以访问标记为 degraded PG 的其他数据
PG 中部分对象的副本数量未达到规定的数量
* Inconsistent (不一致)
PG副本出现不一致, 对象大小不正确或者恢复借宿后某个副本出现对象丢失现象
* recoverying (恢复中)
ceph 设备故障容忍在一定范围的软件与硬件问题, 当 OSD 变 DOWN, 那么包含该 OSD 的 PG 副本都会有问题, 当 OSD 恢复, OSD 对应的 PG 将会更新
并反映出当前状态, 在一段时间周期后, OSD 将会恢复 recoverying 状态

recovery 并非永远都有效, 因为硬件故障可能会导致多个 OSD 故障, 例如, 网络交换机故障, 可以导致集群中的多个主机及主机包含的 OSD 故障
当网络恢复之后, 每个 OSD 都必须执行恢复

CEPH 提供一定数量的设定在新服务请求与恢复 PG 中数据对象时的资源平衡,  
osd recovery delay start 设定允许 osd 重启, re-peer 并在启动 恢复之前处理一些回应请求,  
osd recovery threads 设定了恢复过程中线程限制 (默认 1 )
osd recovery thread timeout 设定线程超时, 因为可能出现多个 osd 故障, 重启后在 re-peer 过程中可能出现污染
osd recovery max active 设定限制对一个 osd 从故障后, 恢复请求并发数量
osd recovery max chunk 限制恢复时的数据 chunk 大小, 预防网络堵塞

PG 正在迁移或者同步对象及其副本, 一个 OSD 停止服务(DOWN), 其内容将会落后与 PG 内的其他副本, 这时 PG 将会进入 recoverying 状态, 该 OSD 上的对象将从其他副本同步过来
* BACK FILLING (回填)
当新 OSD 加入集群, CRUSH 将会为集群新添加的 OSD 重新分配 PG, 强制新的 OSD 接受重新分配的 PG 并把一定数量的负载转移到新 OSD 中
back filling OSD 会在后台处理, 当 backfilling 完成, 新的 OSD 完成后, 将开始对请求进行服务

在 backfill 操作期间, 你可以看到多种状态,
backfill_wait 表示 backfill 操作挂起, 但 backfill 操作还没有开始 ( PG 正在等待开始回填操作 )
backfill 表示 backfill 操作正在执行
backfill_too_full 表示在请求 backfill 操作, 由于存储能力问题, 但不可以完成,

ceph 提供设定管理装载重新分配 PG 关联到新的 OSD
osd_max_backfills 设定最大数量并发 backfills 到一个 OSD, 默认 10
osd backfill full ratio  当 osd 达到负载, 允许 OSD 拒绝 backfill 请求, 默认 85%,
假如 OSD 拒绝 backfill 请求,  osd backfill retry interval 将会生效, 默认 10 秒后重试
osd backfill scan min ,  osd backfill scan max 管理检测时间间隔

一个新 OSD 加入集群后, CRUSH 会把集群先有的一部分 PG 分配给他, 该过程称为回填, 回填进程完成后, 新 OSD 准备好了就可以对外提供服务
REMAPPED (重映射)
当 pg 改变, 数据从旧的 osd 迁移到新的 osd, 新的主 osd 应该请求将会花费一段时间, 在这段时间内, 将会继续向旧主 osd 请求服务, 直到
PG 迁移完成, 当数据迁移完成,  mapping 将会使用新的 OSD 响应主 OSD 服务

当 PG 的 action set 变化后, 数据将会从旧 acting set 迁移到新 action set, 新主 OSD 需要过一段时间后才能提供服务, 因此它会让老的主 OSD 继续提供服务, 知道 PG 迁移完成, 数据迁移完成后, PG map 将会使用新 acting set 中的主 OSD
* STALE (旧)
当 ceph 使用 heartbeat 确认主机与进程是否运行,  ceph osd daemon 可能由于网络临时故障, 获得一个卡住状态 (stuck state) 没有得到心跳回应
默认, osd daemon 会每 0.5 秒报告 PG, up 状态, 启动与故障分析,
假如 PG 中主 OSD 因为故障没有回应 monitor 或者其他 OSD 报告 主 osd down, 那么 monitor 将会标记 PG stale,
当你重启集群, 通常会看到 stale 状态, 直到 peering 处理完成,
在集群运行一段时候, 看到 stale 状态, 表示主 osd PG DOWN 或者没有主 osd 没有报告 PG 信息到 monitor 中

PG 处于未知状态, monitors 在 PG map 改变后还没有收到过 PG 的更新, 启用一个集群后, 常常会看到主 peering 过程结束前 PG 处于该状态
Scrubbing (清理中)
PG 在做不一至性校验
有问题的 PG:
inactive:
PG 很长时间没有显示为 acitve 状态, (不可执行读写请求), PG 不可以执行读写, 因为等待 OSD 更新数据到最新的备份状态

unclean:
PG 很长时间都不是 clean 状态 (不可以完成之前恢复的操作), PG 包含对象没有完成相应的复制副本数量, 通常都要执行恢复操作

stale:
PG 状态很长时间没有被 ceph-osd 更新过, 标识存储在该 GP 中的节点显示为 DOWN, PG 处于 unknown 状态, 因为 OSD 没有报告 monitor 由 mon osd report timeout 定义超时时间


###

重启服务
systemctl restart ceph-mon.target

---------------------

本文来自 styshoo 的CSDN 博客 ，全文地址请点击：https://blog.csdn.net/styshoo/article/details/62722679?utm_source=copy
