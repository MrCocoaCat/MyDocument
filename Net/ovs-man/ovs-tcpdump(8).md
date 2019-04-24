ovs-tcpdump(8)                Open vSwitch Manual               ovs-tcpdump(8)



NAME
       ovs-tcpdump - Dump traffic from an Open vSwitch port using tcpdump.

SYNOPSIS
       ovs-tcpdump -i port tcpdump options...

DESCRIPTION
       ovs-tcpdump在ovs-vswitchd守护进程中创建switch镜像端口，并执行tcpdump来侦听这些端口。 当tcpdump实例退出时，它会清除它创建的镜像端口。

       ovs-tcpdump不允许同一端口使用多个镜像。它有一些逻辑来解析当前配置并防止重复镜像。

       The -i option may not appear multiple times.

       值得注意的是，在基于Linux的内核中，除非应用程序打开了特定的tuntap设备，否则点击设备不会接收数据包。

       This requires CAP_NET_ADMIN privileges, so the ovs-
       tcpdump command must be run as a user with such  permissions  (this  is usually a super-user).

OPTIONS
       -h
       --help Prints a brief help message to the console.

       -V
       --version
              Prints version information to the console.

       --db-sock
              The  Open vSwitch database socket connection string.
              The default is unix:/var/run/openvswitch/db.sock

       --dump-cmd
              The command to run instead of tcpdump.

       -i
       --interface
              The interface for which a mirror port  should  be  created,  and  packets should be dumped.

       --mirror-to
              The name of the interface which should be the destination of the
              mirrored packets. The default is miINTERFACE

       --span If specified, mirror all ports (optional).

SEE ALSO
       ovs-appctl(8),  ovs-vswitchd(8),  ovs-pcap(1),  ovs-tcpundump(1),  tcp‐
       dump(8), wireshark(8).
