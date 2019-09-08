### Open vSwitch on Linux, FreeBSD and NetBSD
This document describes how to build and install Open vSwitch on a generic Linux, FreeBSD, or NetBSD host. For specifics around installation on a specific platform, refer to one of the other installation guides listed in Installing Open vSwitch.

### Obtaining Open vSwitch Sources
The canonical location for Open vSwitch source code is its Git repository, which you can clone into a directory named “ovs” with:

```
$ git clone https://github.com/openvswitch/ovs.git
```

Cloning the repository leaves the “master” branch initially checked out. This is the right branch for general development. If, on the other hand, if you want to build a particular released version, you can check it out by running a command such as the following from the “ovs” directory:
```
$ git checkout v2.7.0
```
The repository also has a branch for each release series. For example, to obtain the latest fixes in the Open vSwitch 2.7.x release series, which might include bug fixes that have not yet been in any released version, you can check it out from the “ovs” directory with:

$ git checkout origin/branch-2.7
If you do not want to use Git, you can also obtain tarballs for Open vSwitch release versions via http://openvswitch.org/download/, or download a ZIP file for any snapshot from the web interface at https://github.com/openvswitch/ovs.

Build Requirements
To compile the userspace programs in the Open vSwitch distribution, you will need the following software:

GNU make

A C compiler, such as:

GCC 4.6 or later.
Clang 3.4 or later.
MSVC 2013. Refer to Open vSwitch on Windows for additional Windows build instructions.
While OVS may be compatible with other compilers, optimal support for atomic operations may be missing, making OVS very slow (see lib/ovs-atomic.h).

libssl, from OpenSSL, is optional but recommended if you plan to connect the Open vSwitch to an OpenFlow controller. libssl is required to establish confidentiality and authenticity in the connections from an Open vSwitch to an OpenFlow controller. If libssl is installed, then Open vSwitch will automatically build with support for it.

libcap-ng, written by Steve Grubb, is optional but recommended. It is required to run OVS daemons as a non-root user with dropped root privileges. If libcap-ng is installed, then Open vSwitch will automatically build with support for it.

Python 2.7. You must also have the Python six library version 1.4.0 or later.

Unbound library, from http://www.unbound.net, is optional but recommended if you want to enable ovs-vswitchd and other utilities to use DNS names when specifying OpenFlow and OVSDB remotes. If unbound library is already installed, then Open vSwitch will automatically build with support for it. The environment variable OVS_RESOLV_CONF can be used to specify DNS server configuration file (the default file on Linux is /etc/resolv.conf).

On Linux, you may choose to compile the kernel module that comes with the Open vSwitch distribution or to use the kernel module built into the Linux kernel (version 3.3 or later). See the Open vSwitch FAQ question “What features are not available in the Open vSwitch kernel datapath that ships as part of the upstream Linux kernel?” for more information on this trade-off. You may also use the userspace-only implementation, at some cost in features and performance. Refer to Open vSwitch without Kernel Support for details.

To compile the kernel module on Linux, you must also install the following:

A supported Linux kernel version.

For optional support of ingress policing, you must enable kernel configuration options NET_CLS_BASIC, NET_SCH_INGRESS, and NET_ACT_POLICE, either built-in or as modules. NET_CLS_POLICE is obsolete and not needed.)

On kernels before 3.11, the ip_gre module, for GRE tunnels over IP (NET_IPGRE), must not be loaded or compiled in.

To configure HTB or HFSC quality of service with Open vSwitch, you must enable the respective configuration options.

To use Open vSwitch support for TAP devices, you must enable CONFIG_TUN.

To build a kernel module, you need the same version of GCC that was used to build that kernel.

A kernel build directory corresponding to the Linux kernel image the module is to run on. Under Debian and Ubuntu, for example, each linux-image package containing a kernel binary has a corresponding linux-headers package with the required build infrastructure.

If you are working from a Git tree or snapshot (instead of from a distribution tarball), or if you modify the Open vSwitch build system or the database schema, you will also need the following software:

Autoconf version 2.63 or later.
Automake version 1.10 or later.
libtool version 2.4 or later. (Older versions might work too.)
The datapath tests for userspace and Linux datapaths also rely upon:

pyftpdlib. Version 1.2.0 is known to work. Earlier versions should also work.
GNU wget. Version 1.16 is known to work. Earlier versions should also work.
netcat. Several common implementations are known to work.
curl. Version 7.47.0 is known to work. Earlier versions should also work.
tftpy. Version 0.6.2 is known to work. Earlier versions should also work.
netstat. Available from various distro specific packages
The ovs-vswitchd.conf.db(5) manpage will include an E-R diagram, in formats other than plain text, only if you have the following:

dot from graphviz (http://www.graphviz.org/).
If you are going to extensively modify Open vSwitch, consider installing the following to obtain better warnings:

“sparse” version 0.5.1 or later (https://git.kernel.org/pub/scm/devel/sparse/sparse.git/).
GNU make.
clang, version 3.4 or later
flake8 along with the hacking flake8 plugin (for Python code). The automatic flake8 check that runs against Python code has some warnings enabled that come from the “hacking” flake8 plugin. If it’s not installed, the warnings just won’t occur until it’s run on a system with “hacking” installed.
You may find the ovs-dev script found in utilities/ovs-dev.py useful.

### Installation Requirements
The machine you build Open vSwitch on may not be the one you run it on. To simply install and run Open vSwitch you require the following software:

Shared libraries compatible with those used for the build.
On Linux, if you want to use the kernel-based datapath (which is the most common use case), then a kernel with a compatible kernel module. This can be a kernel module built with Open vSwitch (e.g. in the previous step), or the kernel module that accompanies Linux 3.3 and later. Open vSwitch features and performance can vary based on the module and the kernel. Refer to Releases for more information.
For optional support of ingress policing on Linux, the “tc” program from iproute2 (part of all major distributions and available at https://wiki.linuxfoundation.org/networking/iproute2).
Python 2.7. You must also have the Python six library version 1.4.0 or later.
On Linux you should ensure that /dev/urandom exists. To support TAP devices, you must also ensure that /dev/net/tun exists.

### Bootstrapping
This step is not needed if you have downloaded a released tarball. If you pulled the sources directly from an Open vSwitch Git tree or got a Git tree snapshot, then run boot.sh in the top source directory to build the “configure” script:
```
$ ./boot.sh
```
### Configuring
Configure the package by running the configure script. You can usually invoke configure without any arguments. For example:

```
$ ./configure
```
By default all files are installed under /usr/local. Open vSwitch also expects to find its database in /usr/local/etc/openvswitch by default. If you want to install all files into, e.g., /usr and /var instead of /usr/local and /usr/local/var and expect to use /etc/openvswitch as the default database directory, add options as shown here:

```
$ ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc
```
>Note
Open vSwitch installed with packages like .rpm (e.g. via yum install or rpm -ivh) and .deb (e.g. via apt-get install or dpkg -i) use the above configure options.

By default, static libraries are built and linked against. If you want to use shared libraries instead:

$ ./configure --enable-shared
To use a specific C compiler for compiling Open vSwitch user programs, also specify it on the configure command line, like so:

$ ./configure CC=gcc-4.2
To use ‘clang’ compiler:

$ ./configure CC=clang
To supply special flags to the C compiler, specify them as CFLAGS on the configure command line. If you want the default CFLAGS, which include -g to build debug symbols and -O2 to enable optimizations, you must include them yourself. For example, to build with the default CFLAGS plus -mssse3, you might run configure as follows:

$ ./configure CFLAGS="-g -O2 -mssse3"
For efficient hash computation special flags can be passed to leverage built-in intrinsics. For example on X86_64 with SSE4.2 instruction set support, CRC32 intrinsics can be used by passing -msse4.2:

$ ./configure CFLAGS="-g -O2 -msse4.2"`
Also builtin popcnt instruction can be used to speedup the counting of the bits set in an integer. For example on X86_64 with POPCNT support, it can be enabled by passing -mpopcnt:

$ ./configure CFLAGS="-g -O2 -mpopcnt"`
If you are on a different processor and don’t know what flags to choose, it is recommended to use -march=native settings:

$ ./configure CFLAGS="-g -O2 -march=native"
With this, GCC will detect the processor and automatically set appropriate flags for it. This should not be used if you are compiling OVS outside the target machine.

>Note
CFLAGS are not applied when building the Linux kernel module.

Custom CFLAGS for the kernel module are supplied using the EXTRA_CFLAGS variable when running make. For example:

```
$ make EXTRA_CFLAGS="-Wno-error=date-time"
```

If you are a developer and want to enable Address Sanitizer for debugging purposes, at about a 2x runtime cost, you can add -fsanitize=address -fno-omit-frame-pointer -fno-common to CFLAGS. For example:

```
$ ./configure CFLAGS="-g -O2 -fsanitize=address -fno-omit-frame-pointer -fno-common"
```

**构建Linux kernel module**, so that you can run the kernel-based switch, pass the location of the kernel build directory on --with-linux. For example, to build for a running instance of Linux:

```
$ ./configure --with-linux=/lib/modules/$(uname -r)/build
```

>Note
If --with-linux requests building for an unsupported version of Linux, then configure will fail with an error message. Refer to the Open vSwitch FAQ for advice in that case.

If you wish to build the kernel module for an architecture other than the architecture of the machine used for the build, you may specify the kernel architecture string using the KARCH variable when invoking the configure script. For example, to build for MIPS with Linux:

$ ./configure --with-linux=/path/to/linux KARCH=mips
If you plan to do much Open vSwitch development, you might want to add --enable-Werror, which adds the -Werror option to the compiler command line, turning warnings into errors. That makes it impossible to miss warnings generated by the build. For example:

$ ./configure --enable-Werror
If you’re building with GCC, then, for improved warnings, install sparse (see “Prerequisites”) and enable it for the build by adding --enable-sparse. Use this with --enable-Werror to avoid missing both compiler and sparse warnings, e.g.:

$ ./configure --enable-Werror --enable-sparse
To build with gcov code coverage support, add --enable-coverage:

$ ./configure --enable-coverage
The configure script accepts a number of other options and honors additional environment variables. For a full list, invoke configure with the --help option:

$ ./configure --help
You can also run configure from a separate build directory. This is helpful if you want to build Open vSwitch in more than one way from a single source directory, e.g. to try out both GCC and Clang builds, or to build kernel modules for more than one Linux version. For example:

```
$ mkdir _gcc && (cd _gcc && ./configure CC=gcc)
$ mkdir _clang && (cd _clang && ./configure CC=clang)
```
Under certain loads the ovsdb-server and other components perform better when using the jemalloc memory allocator, instead of the glibc memory allocator. If you wish to link with jemalloc add it to LIBS:

$ ./configure LIBS=-ljemalloc

### Building
Run GNU make in the build directory, e.g.:

```
$ make
```
or if GNU make is installed as “gmake”:
```
$ gmake
```
If you used a separate build directory, run make or gmake from that directory, e.g.:
```
$ make -C _gcc
$ make -C _clang
```
Note

Some versions of Clang and ccache are not completely compatible. If you see unusual warnings when you use both together, consider disabling ccache.

Consider running the testsuite. Refer to Testing for instructions.

Run make install to install the executables and manpages into the running system, by default under /usr/local:
```
$ make install
```

If you built kernel modules, you may install them, e.g.:
```
$ make modules_install
```
It is possible that you already had a Open vSwitch kernel module installed on your machine that came from upstream Linux (in a different directory). To make sure that you load the Open vSwitch kernel module you built from this repository, you should create a depmod.d file that prefers your newly installed kernel modules over the kernel modules from upstream Linux. The following snippet of code achieves the same:

```
$ config_file="/etc/depmod.d/openvswitch.conf"
$ for module in datapath/linux/*.ko; do
  modname="$(basename ${module})"
  echo "override ${modname%.ko} * extra" >> "$config_file"
  echo "override ${modname%.ko} * weak-updates" >> "$config_file"
  done
$ depmod -a
```

Finally, load the kernel modules that you need. e.g.:

```
$ /sbin/modprobe openvswitch
```
To verify that the modules have been loaded, run /sbin/lsmod and check that openvswitch is listed:
```
$ /sbin/lsmod | grep openvswitch
```
>Note
If the modprobe operation fails, look at the last few kernel log messages (e.g. with dmesg | tail). Generally, issues like this occur when Open vSwitch is built for a kernel different from the one into which you are trying to load it. Run modinfo on openvswitch.ko and on a module built for the running kernel, e.g.:
$ /sbin/modinfo openvswitch.ko
$ /sbin/modinfo /lib/modules/$(uname -r)/kernel/net/bridge/bridge.ko


Compare the “vermagic” lines output by the two commands. If they differ, then Open vSwitch was built for the wrong kernel.

If you decide to report a bug or ask a question related to module loading, include the output from the dmesg and modinfo commands mentioned above.

### Starting
On Unix-alike systems, such as BSDs and Linux, starting the Open vSwitch suite of daemons is a simple process. Open vSwitch includes a shell script, and helpers, called ovs-ctl which automates much of the tasks for starting and stopping ovsdb-server, and ovs-vswitchd. After installation, the daemons can be started by using the ovs-ctl utility. This will take care to setup initial conditions, and start the daemons in the correct order. The ovs-ctl utility is located in ‘$(pkgdatadir)/scripts’, and defaults to ‘/usr/local/share/openvswitch/scripts’. An example after install might be:
```
$ export PATH=$PATH:/usr/local/share/openvswitch/scripts
$ ovs-ctl start
```
Additionally, the ovs-ctl script allows starting / stopping the daemons individually using specific options. To start just the ovsdb-server:
```
$ export PATH=$PATH:/usr/local/share/openvswitch/scripts
$ ovs-ctl --no-ovs-vswitchd start
```

Likewise, to start just the ovs-vswitchd:
```
$ export PATH=$PATH:/usr/local/share/openvswitch/scripts
$ ovs-ctl --no-ovsdb-server start
```

Refer to ovs-ctl(8) for more information on ovs-ctl.

In addition to using the automated script to start Open vSwitch, you may wish to manually start the various daemons. Before starting ovs-vswitchd itself, you need to start its configuration database, ovsdb-server. Each machine on which Open vSwitch is installed should run its own copy of ovsdb-server.
Before ovsdb-server itself can be started, configure a database that it can use:

```
$ mkdir -p /usr/local/etc/openvswitch
$ ovsdb-tool create /usr/local/etc/openvswitch/conf.db \
    vswitchd/vswitch.ovsschema
```
Configure ovsdb-server to use database created above, to listen on a Unix domain socket, to connect to any managers specified in the database itself, and to use the SSL configuration in the database:
```
$ mkdir -p /usr/local/var/run/openvswitch
$ ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
    --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
    --private-key=db:Open_vSwitch,SSL,private_key \
    --certificate=db:Open_vSwitch,SSL,certificate \
    --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
    --pidfile --detach --log-file
```
>Note
If you built Open vSwitch without SSL support, then omit --private-key, --certificate, and --bootstrap-ca-cert.)

Initialize the database using ovs-vsctl. This is only necessary the first time after you create the database with ovsdb-tool, though running it at any time is harmless:
```
$ ovs-vsctl --no-wait init
```
Start the main Open vSwitch daemon, telling it to connect to the same Unix domain socket:
```
$ ovs-vswitchd --pidfile --detach --log-file
```

### Validating
At this point you can use ovs-vsctl to set up bridges and other Open vSwitch features. For example, to create a bridge named br0 and add ports eth0 and vif1.0 to it:
```
$ ovs-vsctl add-br br0
$ ovs-vsctl add-port br0 eth0
$ ovs-vsctl add-port br0 vif1.0
```
Refer to ovs-vsctl(8) for more details. You may also wish to refer to Testing for information on more generic testing of OVS.

### Upgrading
When you upgrade Open vSwitch from one version to another you should also upgrade the database schema:

Note

The following manual steps may also be accomplished by using ovs-ctl to stop and start the daemons after upgrade. The ovs-ctl script will automatically upgrade the schema.

Stop the Open vSwitch daemons, e.g.:

$ kill `cd /usr/local/var/run/openvswitch && cat ovsdb-server.pid ovs-vswitchd.pid`
Install the new Open vSwitch release by using the same configure options as was used for installing the previous version. If you do not use the same configure options, you can end up with two different versions of Open vSwitch executables installed in different locations.

Upgrade the database, in one of the following two ways:

If there is no important data in your database, then you may delete the database file and recreate it with ovsdb-tool, following the instructions under “Building and Installing Open vSwitch for Linux, FreeBSD or NetBSD”.

If you want to preserve the contents of your database, back it up first, then use ovsdb-tool convert to upgrade it, e.g.:

$ ovsdb-tool convert /usr/local/etc/openvswitch/conf.db \
    vswitchd/vswitch.ovsschema
Start the Open vSwitch daemons as described under Starting above.

### Hot Upgrading
Upgrading Open vSwitch from one version to the next version with minimum disruption of traffic going through the system that is using that Open vSwitch needs some considerations:

If the upgrade only involves upgrading the userspace utilities and daemons of Open vSwitch, make sure that the new userspace version is compatible with the previously loaded kernel module.
An upgrade of userspace daemons means that they have to be restarted. Restarting the daemons means that the OpenFlow flows in the ovs-vswitchd daemon will be lost. One way to restore the flows is to let the controller re-populate it. Another way is to save the previous flows using a utility like ovs-ofctl and then re-add them after the restart. Restoring the old flows is accurate only if the new Open vSwitch interfaces retain the old ‘ofport’ values.
When the new userspace daemons get restarted, they automatically flush the old flows setup in the kernel. This can be expensive if there are hundreds of new flows that are entering the kernel but userspace daemons are busy setting up new userspace flows from either the controller or an utility like ovs-ofctl. Open vSwitch database provides an option to solve this problem through the other_config:flow-restore-wait column of the Open_vSwitch table. Refer to the ovs-vswitchd.conf.db(5) manpage for details.
If the upgrade also involves upgrading the kernel module, the old kernel module needs to be unloaded and the new kernel module should be loaded. This means that the kernel network devices belonging to Open vSwitch is recreated and the kernel flows are lost. The downtime of the traffic can be reduced if the userspace daemons are restarted immediately and the userspace flows are restored as soon as possible.
The ovs-ctl utility’s restart function only restarts the userspace daemons, makes sure that the ‘ofport’ values remain consistent across restarts, restores userspace flows using the ovs-ofctl utility and also uses the other_config:flow-restore-wait column to keep the traffic downtime to the minimum. The ovs-ctl utility’s force-reload-kmod function does all of the above, but also replaces the old kernel module with the new one. Open vSwitch startup scripts for Debian, XenServer and RHEL use ovs-ctl’s functions and it is recommended that these functions be used for other software platforms too.




***
https://www.cnblogs.com/gaozhengwei/p/7100140.html

OVN 作为OpenVSwitch的功能模块，每次OVN与OpenVSwitch一起发布，OVN与OpenVSwitch源代码放在ovs代码库：https://github.com/openvswitch/ovs.git

Build OpenVSwitch and OVN
复制代码
 1 # *Linux Environment： CentOS 7 （3.10.0-327.18.2.el7.x86_64）
 2   
 3 # Install depen package
 4 yum install gcc make python-devel openssl-devel kernel-devel graphviz \
 5     kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
 6     libtool checkpolicy selinux-policy-devel
 7   
 8 # Download code
 9 git clone https://github.com/openvswitch/ovs.git
10   
11 # Start build
12 cd $OVS_DIR
13 # Bootstrapping
14 ./boot.sh
15 # Configuring (special --prefix and --with-linux  e.g  ./configure  --with-linux=/lib/modules/$(uname -r)/build)
16 ./configure
17 #Build
18 make
19   
20 # 安装方式一 源代码安装
21  make install
22 ## Install kernel modules
23  make modules_install
24 ## Start service
25 ### Start openvswitch service
26 /usr/local/share/openvswitch/scripts/ovs-ctl start --system-id=random
27 ### Start ovn-northd
28 /usr/local/share/openvswitch/scripts/ovn-ctl start_northd
29 ### Start ovn-controller
30 /usr/local/share/openvswitch/scripts/ovn-ctl start_controller
31   
32 # 安装方式二 RPM包安装
33 ## Package RPM openvswitch and ovn
34 make rpm-fedora RPMBUILD_OPT="--without check"
35 ## Build kernel OVS Tree Datapath (specila kernal version, e.g  make rpm-fedora-kmod RPMBUILD_OPT='-D "kversion 4.3.4-300.fc23.x86_64"')
36 make rpm-fedora-kmod
37 ## Look for rpm from $OVS_DIR/rpm/rpmbuild/RPMS/x86_64
38 ### Install kernel OVS Tree Datapath
39 yum localinstall openvswitch-kmod-2.6.90-1.el7.centos.x86_64.rpm
40 ### Install OVS
41 yum localinstall openvswitch-2.6.90-1.el7.centos.x86_64.rpm
42 ### Install OVN
43 #### Install ovn common package
44 yum localinstall openvswitch-ovn-common-2.6.90-1.el7.centos.x86_64.rpm
45 #### Install ovn northd service
46 yum localinstall openvswitch-ovn-central-2.6.90-1.el7.centos.x86_64.rpm
47 #### Install ovn controller service
48 yum localinstall openvswitch-ovn-host-2.6.90-1.el7.centos.x86_64.rpm
49 ## Start service
50 ### Start openvswitch service
51 systemctl start openvswitch.service
52 ### Start ovn-northd
53 systemctl start ovn-northd
54 ### Start ovn-controller
55 systemctl start ovn-controller










####
# ovs-ctl stop 停止ovs服务

# ovs-dpctl show查看内核，会有一个ovs-system的datapath

# ovs-dpctl del-dp ovs-system 删除上一步出现的datapath（不进行这一步，rmmod可能会报错）

# rmmod  openvswitch 卸载openvswitch内核模块，使用lsmod | grep openvswitch 没有openvswitch

# 进入ovs源代码目录，按照前述编译步骤重新编译安装














***

### Distributions packaging Open vSwitch¶

You can use apt-get or aptitude to install the .deb packages and must be superuser.

1. Debian has openvswitch-switch and openvswitch-common .deb packages that includes the core userspace components of the switch.

2. For kernel datapath, openvswitch-datapath-dkms can be installed to automatically build and install Open vSwitch kernel module for your running kernel.

3. For DPDK datapath, Open vSwitch with DPDK support is bundled in the package openvswitch-switch-dpdk.
