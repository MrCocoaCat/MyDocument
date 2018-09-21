mysql> show status like 'Threads%';
+-------------------+-------+
| Variable_name     | Value |
+-------------------+-------+
| Threads_cached    | 58    |
| Threads_connected | 57    |   ###这个数值指的是打开的连接数
| Threads_created   | 3676  |
| Threads_running   | 4     |   ###这个数值指的是激活的连接数，这个数值一般远低于connected数值
+-------------------+-------+

Threads_connected 跟show processlist结果相同，表示当前连接数。准确的来说，Threads_running是代表当前并发数

这是是查询数据库当前设置的最大连接数
mysql> show variables like '%max_connections%';
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 1000  |
+-----------------+-------+

可以在/etc/my.cnf里面设置数据库的最大连接数
[mysqld]
max_connections = 1000




[转载于](https://www.cnblogs.com/baby123/p/5710787.html)
#### 显示哪些线程正在运行

```
show full processlist;
```

状态：
1. SLEEP
线程正在等待客户端发送新的请求。
2. QUERY
线程正在执行查询或者正在将结果发送给客户端。　
3. LOCKED
在MYSQL服务层，该线程正在等待表锁。在存储引擎级别实现的锁，如INNODB的行锁，并不会体现在线程状态中。　对于MYISAM来说这是一个比较典型的状态。但在其他没有行锁的引擎中也经常会出现。　
4. ANALYZING　AND STATISTICS
线程正在收集存储引擎的统计信息，　并生成查询的执行计划。
5. COPYING TO TMP TABLE （ON DISK）
线程正在执行查询，　并且将其结果集都复制到一个临时文件中，　这种状态一般要么是在做GROUP BY操作，要么是文件排序操作，　或者是UNION操作。　如果这个状态后面还有ON DISK的标　，　那表示MYSQL正在将一个内存临时表放到磁盘上。

6. SORTING RESULT
线程正在对结果集进行排序。

7. SENDING DATA
线程可能在多个状态之间传送数据，或者生成结果集，或者在向客户端返回数据。

　　

#### 连接数设置多少是合理的?

查看mysql的最大连接数：
```
　show variables like '%max_connections%';
```
查看服务器响应的最大连接数:
```
 show global status like 'Max_used_connections';
```

服务器响应的最大连接数为3，远低于mysql服务器允许的最大连接数值

对于mysql服务器最大连接数值的设置范围比较理想的是：服务器响应的最大连接数值占服务器上限连接数值的比例值在10%以上，如果在10%以下，说明mysql服务器最大连接上限值设置过高。

Max_used_connections / max_connections * 100% = 3/512 * 100% ≈ 6%

#### wait_timeout

wait_timeout — 指的是mysql在关闭一个非交互的连接之前所要等待的秒数

如果你没有修改过MySQL的配置，wait_timeout的初始值是28800

wait_timeout 过大有弊端，其体现就是MySQL里大量的SLEEP进程无法及时释放，拖累系统性能，不过也不能把这个指设置的过小，否则你可能会遭遇到“MySQL has gone away”之类的问题

查看
```
 show global variables like 'wait_timeout';  
```

设置
```
set global wait_timeout=100;  

```
#### interactive_time
 指的是mysql在关闭一个交互的连接之前所要等待的秒数

```
set global  interactive_timeout=300;
```

mysql终端查看timeout的设置

```
show global variables like '%timeout%';
```

总结

MySQL服务器所支持的最大连接数是有上限的，因为每个连接的建立都会消耗内存，因此客户端在连接到MySQL Server处理完相应的操作后，应该断开连接并释放占用的内存。

如果MySQL Server有大量的闲置连接，不仅会白白消耗内存，而且如果连接一直在累加而不断开，最终肯定会达到MySQL Server的连接上限数，这会报'too many connections'的错误。

对于wait_timeout的值设定，应该根据系统的运行情况来判断。在系统运行一段时间后，可以通过show processlist命令查看当前系统的连接状态，如果发现有大量的sleep状态的连接进程，则说明该参数设置的过大，可以进行适当的调整小些。
