ovn-nbctl(8)                  Open vSwitch

### NAME
ovn-nbctl - Open Virtual Network的北向数据库管理程序

### SYNOPSIS
ovn-nbctl [options] command [arg...]

### DESCRIPTION
这个程序可以用来管理OVN 的北向数据库

### GENERAL COMMANDS
  * init   
  如果数据库为空，则初始化数据库。 如果数据库已初始化，则此命令无效。

  * show [switch | router]       
  打印数据库内容的简要概述。如果提供了switch，则仅显示与该逻辑交换机相关的记录。
  如提供router，则仅显示与该逻辑路由器相关的记录。

#### LOGICAL SWITCH COMMANDS
  * ls-add       
  创建一个新的未命名的逻辑交换机，该交换机最初没有端口。
  交换机没有名称，其他命令必须通过其UUID引用此交换机。

  * [--may-exist | --add-duplicate] ls-add switch    
  创建一个名为switch的新逻辑交换机，该交换机最初没有端口。
  OVN北向数据库模式（schema）不要求逻辑交换机名称是唯一的, 但是，名称的重点是为人们提供一种
  简单的方式来引用交换机，使用重复的名称对此无益。因此，在没有任何选项的情况下，
  如果switch是重复名称，则此命令将其视为错误。
  使用--may-exist选项, 添加重复名称会成功，但不会创建新的逻辑交换机。
  使用--add-duplicate选项,  该命令实际上创建了一个具有重复名称的新逻辑交换机。
  指定两个选项都是错误的。 如果有多个具有重复名称的逻辑交换机，应使用UUID配置逻辑交换机，
  而不是交换机名称。

  * [--if-exists] ls-del switch   
  删除switch。如果switch不存在，则报错,除非指定了--if-exists 选项。

  * ls-list   
  在标准输出中列出所有存在的switches，每条一行.

### ACL COMMANDS
  These  commands  operates on ACL objects for a given entity. The entity
  can be either a logical switch or a port group. The entity can be spec‐
  ified  as  uuid  or  name. The --type option can be used to specify the
  type of the entity, in case both a logical switch and a port groups ex‐
  ist with the same name specified for entity. type must be either switch
  or port-group.

    [--type={switch | port-group}] [--log] [--meter=meter] [--sever‐
    ity=severity]  [--name=name] [--may-exist] acl-add entity direc‐
    tion priority match verdict
           Adds the specified ACL to entity. direction must  be  ei‐
           ther  from-lport  or to-lport. priority must be between 0
           and 32767, inclusive. A full description  of  the  fields
           are  in  ovn-nb(5). If --may-exist is specified, adding a
           duplicated ACL succeeds but the ACL is  not  really  cre‐
           ated.  Without  --may-exist,  adding a duplicated ACL re‐
           sults in error.
           The --log option enables packet logging for the ACL.  The
           options  --severity  and  --name  specify  a severity and
           name, respectively, for log entries (and also enable log‐
           ging).  The  severity  must be one of alert, warning, no‐
           tice, info, or debug. If a severity is not specified, the
           default  is  info.  The  --meter=meter  option is used to
           rate-limit packet logging. The meter argument names a me‐
           ter configured by meter-add.

    [--type={switch | port-group}] acl-del entity [direction [prior‐
    ity match]]
           Deletes ACLs from entity. If only entity is supplied, all
           the  ACLs  from  the  entity are deleted. If direction is
           also specified, then all the flows in that direction will
           be  deleted from the entity. If all the fields are given,
           then a single flow that matches all the  fields  will  be
           deleted.

    [--type={switch | port-group}] acl-list entity
           Lists the ACLs on entity.

### LOGICAL SWITCH QOS RULE COMMANDS
       [--may-exist]  qos-add  switch  direction  priority  match  [dscp=dscp]
       [rate=rate [burst=burst]]
              Adds QoS marking and metering rules to switch. direction must be
              either  from-lport  or  to-lport. priority must be between 0 and
              32767, inclusive.

              If dscp=dscp is specified, then matching packets will have  DSCP
              marking  applied.  dscp  must be between 0 and 63, inclusive. If
              rate=rate is specified then matching packets will have  metering
              applied   at   rate   kbps.  If  metering  is  configured,  then
              burst=burst specifies the burst rate  limit  in  kilobits.  dscp
              and/or rate are required arguments.

              If  --may-exist  is specified, adding a duplicated QoS rule suc‐
              ceeds but the QoS rule is not really created. Without  --may-ex‐
              ist, adding a duplicated QoS rule results in error.

       qos-del switch [direction [priority match]]
              Deletes  QoS  rules from switch. If only switch is supplied, all
              the QoS rules from the logical switch are deleted. If  direction
              is  also specified, then all the flows in that direction will be
              deleted from the logical switch. If all the fields are supplied,
              then  a  single  flow  that  matches  the  given  fields will be
              deleted.

       qos-list switch
              Lists the QoS rules on switch.

#### METER COMMANDS
       meter-add name action rate unit [burst]
              Adds the specified meter. name must be a unique name to identify
              this  meter.  The  action  argument specifies what should happen
              when this meter is exceeded. The only supported action is drop.

              The unit specifies the unit for the rate argument; valid  values
              are  kbps and pktps for kilobits per second and packets per sec‐
              ond, respectively. The burst option configures the maximum burst
              allowed for the band in kilobits or packets depending on whether
              the unit chosen was kbps or pktps, respectively. If a  burst  is
              not supplied, the switch is free to select some reasonable value
              depending on its configuration.

              ovn-nbctl only supports adding a meter with a single  band,  but
              the other commands support meters with multiple bands.

              Names  that  start  with "\__" (two underscores) are reserved for
              internal use by OVN, so ovn-nbctl does not allow adding them.

       meter-del [name]
              Deletes meters. By default, all meters are deleted. If  name  is
              supplied, only the meter with that name will be deleted.

       meter-list
              Lists all meters.

#### LOGICAL SWITCH PORT COMMANDS
  * [--may-exist] lsp-add switch port   
  在lswitch上创建一个新的逻辑switch port名为port。如果已存在名为port的逻辑端口，则会出错，除非指定了--may-exist选项。
  如果现有端口位于交换机以外的某个逻辑交换机中，或者如果它具有父端口，无论是否使--may-exist都会报错。

  * [--may-exist] lsp-add switch port parent tag_request   
  Creates on switch a logical switch port named  port  that  is  a child  of  parent  that  is identified with VLAN ID tag_request,which must be between 0 and 4095, inclusive. If  tag_request  is 0,  ovn-northd  generates  a  tag that is unique in the scope of parent. This is useful in cases such  as  virtualized  container environments  where  Open vSwitch does not have a direct connection to the container’s port and it must be shared with the virtual machine’s port.

  It  is an error if a logical port named port already exists, unless --may-exist is specified. Regardless of --may-exist, it  is an error if the existing port is not in switch or if it does not have the specified parent and tag_request.

  * [--if-exists] lsp-del port   
  删除端口.当端口不存在时则报错,unless --if-exists is specified.

  * lsp-list switch   
  列举switch中所有的logical switch ports在标准输出中，每一行

  * lsp-get-parent port   
  如果设置了parent port ，则显示。否则不显示

  * lsp-get-tag port   
    如果设置了，则获取端口流量的tag。如未设置则不显示。

  * lsp-set-addresses port [address]...   
    设置与端口地址关联的地址。每个地址应为以下之一
        * 一个以太网地址, 可选地，后跟空格及一个或多个IP地址
               OVN将该以太网地址的数据包传送到此端口。
        * unknown
               OVN将目的MAC地址不在任何逻辑端口地址列中的单播以太网数据包
               传送到unknown端口。
        * dynamic
              使用此关键字可使ovn-northd生成全局唯一的MAC地址，并在逻辑端口的子网中选择未使用的IPv4地址，并将其存储在端口的dynamic_addresses列中。

        * router
                仅当逻辑交换机端口的类型是路由器时，才可以设置此选项。
                这表示此逻辑交换机端口的以太网，IPv4和IPv6地址应从连接的逻辑路由器端口获取，如lsp-set-options中的router-port所指定
  可以设置多个地址。 如果没有给出地址参数，port将没有与之关联的地址。

  * lsp-get-addresses port   
    在标准输出上列出与端口关联的所有地址，每行一个。

  * lsp-set-port-security port [addrs]...  
    将与端口关联的端口安全地址设置为addrs。
    可以使用多个addrs参数设置多组地址。
    如果没有给出addrs参数，则端口没有启用端口安全性。
    Port security limits the addresses from which a logical port may
    send packets and to  which  it  may  receive  packets.
    有关详细信息，请参阅Logical_Switch_Port表中port_security列的ovn-nb（5）文档。

  * lsp-get-port-security port   
    在标准输出上列出与端口关联的所有端口安全地址，每个一行

  * lsp-get-up port   
    显示端口状态，开启或关闭

  * lsp-set-enabled port state   
    设置端口的administrative状态, 启用或禁用。当端口禁用时，流量禁止流入或流出端口

  * lsp-get-enabled port   
    显示端口的administrative状态, 启用或禁用

  * lsp-set-type port type   
        设置逻辑端口的类型。 类型必须是以下之一:
        * (empty string)
               A VM (or VIF) interface.
        * router
               与逻辑路由器的连接
        * localnet
               从每个ovn控制器实例连接到本地可访问的网络。
               逻辑交换机只能连接一个localnet端口。 这用于建立与现有网络直接连接的模型。
        * localport
               A connection to a local VIF. Traffic that  arrives  on  a  localport  is  never  forwarded  over a tunnel to another
               chassis. These ports are present  on  every  chassis  and
               have  the  same  address  in all of them. This is used to
               model connectivity to local services that  run  on  every
               hypervisor.
        * l2gateway
               与物理网络的连接
        * vtep  
               A port to a logical switch on a VTEP gateway.

  * lsp-get-type port     
    获取逻辑端口的类型

  * lsp-set-options port [key=value]...   
    为逻辑端口设置type-specific key-value选项

  * lsp-get-options port     
    获取逻辑端口的type-specific选项

  * lsp-set-dhcpv4-options port dhcp_options   
    为逻辑 *port* 设置DHCPv4选项。*dhcp_options* 是一个UUID，指的是DHCP_Options表中的一组DHCP选项。

  * lsp-get-dhcpv4-optoins port  
    获取逻辑端口的DHCPv4选项配置

  * lsp−set−dhcpv6−options port dhcp_options  
    为logical port 设置DHCPv6选项。*dhcp_options* 是一个UUID，指的是DHCP_Options表中的一组DHCP选项。


  * lsp-get-dhcpv6-optoins port   
    获取逻辑端口的DHCPv6选项配置

#### LOGICAL ROUTER COMMANDS
  lr-add创建一个新的，未命名的逻辑路由器，它最初没有端口。 路由器没有名称，其他命令必须通过其UUID引用此路由器。

   * [--may-exist | --add-duplicate] lr-add router   
  新创建一个名为 *router* 的路由，初始化后没有端口。OVN的北向数据集模型（schema）并不要求逻辑路由名称唯一，路由的提供一个简单的
  路由器名称是唯一的，但名称的重点是为人们提供一种简单的方法来引用路由器，使用重复的名称对此无益。因此，如果没有任何选项，如果路由器是重复的名称，则此命令将其视为错误。
  使用--may-exist时，添加重复名称会成功，但不会创建新的逻辑路由器。
  使用--add-duplicate，该命令实际上会创建一个具有重复名称的新逻辑路由器。
  同时制定两个选项是错误的。如果有多个具有重复名称的逻辑路由器，请使用UUID而不是路由器名称配置逻辑路由器。

  * [--if-exists] lr-del router
  删除路由器。 如果路由器不存在则出错，除非指定了--if-exists。

  * lr-list  
  在标准输出中，列出所有存在的路由，每个一行

#### LOGICAL ROUTER PORT COMMANDS
  * [--may-exist] lrp-add router port mac network... [peer=peer]
  在路由器上创建一个名为 *port* 的新逻辑路由器端口，其中包含Ethernet地址mac
  和每个网络的一个或多个IP地址/网络掩码。  
  可选参数 *peer* 标识连接到此端口的逻辑路由器端口。
   以下示例，添加一个路由端口，带有IPv4 地址和IPv6 地址，并含有peer lr1
  ```
  lrp-add lr0 lrp0 00:11:22:33:44:55 192.168.0.1/24 2001:db8::1/64
  peer=lr1
  ```
  如果指定了名为port的逻辑路由器端口，则会出错，除非指定了--may-exist。
  --may-exist，如果现有路由器端口位于路由器以外的某个逻辑路由器中，则会出错

   * [--if-exists] lrp-del port
   删除端口，如果端口不存在则报错，除非指定--if-exists

   * lrp-list router
  在标准输出中列出逻辑路由中的所有端口，每个一行

  * lrp-set-enabled port state
  设置端口administrative状态，开启或禁用。如果端口为禁用模式，流量禁止流入或流出该端口。

  * lrp-get-enabled port
    打印端口的administrative状态，开启或禁用

  * lrp-set-gateway-chassis port chassis [priority]
    Set gateway chassis for port. *chassis* is the name of  the  chas‐
    sis. This creates a gateway chassis entry in Gateway_Chassis ta‐
    ble. It won’t check if chassis really exists  in  OVN_Southbound
    database.  Priority will be set to 0 if priority is not provided
    by user. priority must be between 0 and 32767, inclusive.

   * lrp-del-gateway-chassis port chassis
    Deletes gateway chassis from port. It is  an  error  if  gateway
    chassis with chassis for port does not exist.

   * lrp-get-gateway-chassis port
    Lists all the gateway chassis with priority within port on stan‐
    dard output, one per line, ordered based on priority.

#### LOGICAL ROUTER STATIC ROUTE COMMANDS
 * [--may-exist]  [--policy=POLICY]  lr-route-add  router  prefix  nexthop
 [port]
  为路由器添加指定的路由规则。 *prefix* 描述该路由的IPv4或
  IPv6 前缀, 例如192.168.100.0/24.  *nexthop* 指定该路由所使用的网关，该网关是逻辑路由的逻辑端口的IP 地址or 逻辑端口的IP地址。
  如果指定了 *port*，则匹配此路由的包通过此端口发送出去，当 *port* 省略时，通过 *nexthup* 判断输出端口
  --policy 描述用于制定路由策略的规则，这应该是“dst-ip”或“src-ip”。 如果未指定，则默认为“dst-ip”。
  如果带有相同前缀的路由已经存在，则报错。除非指定了--may-exist is specified.

 * [--if-exists] lr-route-del router [prefix]
  删除路由器的路由规则。如果仅仅提供 *router*, 则逻辑路由器的所有路由规则均被删除。
  如果 *prefix* 也被指定，则逻辑路由器中匹配 *prefix* 的所有路由规则将被删除。
  如果指定的 *prefix* 无相应匹配的路由规则，则报错。除非制定了 --if-exists

 * lr-route-list router
   列出路由器上的路由规则

#### NAT COMMANDS
 * [--may-exist] lr-nat-add  router  type  external_ip  logical_ip  [logi‐
 cal_port external_mac]   
 为路由器器添加特定的NAT。*type* 必须为 snat,dnat,或dnat_and_snat。The *external_ip* 是一个IPv4地址. *logical_ip* 是一个IPv4网络 (e.g 192.168.1.0/24) 或IPv4 地址。
 仅当路由器是分布式路由器（distributed  router），而不是网关路由器(gateway  router）且类型为dnat_and_snat时，才接受 *logical_port* 和 *external_mac*。
 *logical_port* 是logical_ip所在的现有逻辑交换机端口名称， *external_mac* 是Ethernet地址.
 当type是 *dnat* 时，外部可见的IP地址 *external_ip* 被DNAT到逻辑空间中的IP地址 *logical_ip*
 当type为 *snat* 时，其源IP地址与 *logical_ip* 中的IP地址匹配或者在
 *logical_ip* 提供的网络中的IP数据包被SNAT到 *external_ip* 中的IP地址。
 当type为 *dnat_and_snat* 时，外部可见的IP地址 *external_ip* 被DNAT化为logcal空间中的IP地址 *logical_ip*。
 此外，源IP地址与 *logical_ip* 匹配的IP数据包被SNAT到 *external_ip* 中的IP地址。

 指定logical_port和external_mac时，NAT规则将在logical_port所在的chassis上编程。
 这包括对 *external_ip* 的ARP回复，返回 *external_mac* 的值。
 使用 *external_mac* 发送源IP地址等于 *external_ip* 的所有数据包。

 如果已存在具有相同值的router，type，external_ip和logical_ip的NAT，则会出错，除非指定了--may-exist。如果指定了--may-exist，logical_port和external_mac，则会覆盖logical_port和external_mac的现有值。

 * [--if-exists] lr-nat-del router [type [ip]]
 从路由器删除NAT。 如果仅提供路由器，则会删除逻辑路由器中的所有NAT。 如果还指定了type，则将从逻辑路由器中删除与该类型匹配的所有NAT。 如果给出了所有字段，则将删除与所有字段匹配的单个NAT规则。
 当type是snat时，ip应该是logical_ip。 当type是dnat或dnat_and_snat时，ip应该是external_ip。
 如果指定了ip并且没有匹配的NAT条目，则会出错，除非指定了--if-exists。

 * lr-nat-list router
 显示路由器上的所有NATs

#### LOAD BALANCER COMMANDS
     [--may-exist | --add-duplicate] lb-add lb vip ips [protocol]
            Creates a new load balancer named lb with the provided  vip  and
            ips  or  adds the vip to an existing lb. vip should be a virtual
            IP address (or an IP address and a port number with : as a sepa‐
            rator).   Examples   for   vip  are  192.168.1.4,  fd0f::1,  and
            192.168.1.5:8080. ips should be comma separated IP endpoints (or
            comma  separated IP addresses and port numbers with : as a sepa‐
            rator). ips must be the same address family as vip. Examples for
            ips are 10.0.0.1,10.0.0.2or [fdef::1]:8800,[fdef::2]:8800.

            The  optional  argument protocol must be either tcp or udp. This
            argument is useful when a port number is provided as part of the
            vip.  If  the  protocol is unspecified and a port number is pro‐
            vided as part of the vip, OVN assumes the protocol to be tcp.

            It is an error if the vip already exists in  the  load  balancer
            named lb, unless --may-exist is specified. With --add-duplicate,
            the command really creates a new load balancer with a  duplicate
            name.

            The following example adds a load balancer.

            lb-add                      lb0                     30.0.0.10:80
            192.168.10.10:80,192.168.10.20:80,192.168.10.30:80 udp

     [--if-exists] lb-del lb [vip]
            Deletes lb or the vip from lb. If vip is supplied, only the  vip
            will  be deleted from the lb. If only the lb is supplied, the lb
            will be deleted. It is an error if vip does not already exist in
            lb, unless --if-exists is specified.

     lb-list [lb]
            Lists  the LBs. If lb is also specified, then only the specified
            lb will be listed.

     [--may-exist] ls-lb-add switch lb
            Adds the specified lb to switch. It is an error if a  load  bal‐
            ancer  named lb already exists in the switch, unless --may-exist
            is specified.

     [--if-exists] ls-lb-del switch [lb]
            Removes lb from switch. If only switch is supplied, all the  LBs
            from  the  logical  switch are removed. If lb is also specified,
            then only the lb will be removed from the logical switch. It  is
            an  error if lb does not exist in the switch, unless --if-exists
            is specified.

     ls-lb-list switch
            Lists the LBs for the given switch.

     [--may-exist] lr-lb-add router lb
            Adds the specified lb to router. It is an error if a  load  bal‐
            ancer  named lb already exists in the router, unless --may-exist
            is specified.

     [--if-exists] lr-lb-del router [lb]
            Removes lb from router. If only router is supplied, all the  LBs
            from  the  logical  router are removed. If lb is also specified,
            then only the lb will be removed from the logical router. It  is
            an  error if lb does not exist in the router, unless --if-exists
            is specified.

     lr-lb-list router
            Lists the LBs for the given router.

#### DHCP OPTIONS COMMANDS
  * dhcp-options-create cidr [key=value]  
  使用指定的 *cidr* 和可选的 *external-id* 在DHCP_Options表中创建新的DHCP选项条目。

  * dhcp-options-list  
  列出DHCP选项条目。

  * dhcp-options-del dhcp-option  
  删除 *dhcp-option* UUID所引用的DHCP Options条目。

  * dhcp-options-set-options dhcp-option [key=value]...  
  设置dhcp-option UUID的DHCP选项。

  * dhcp-options-get-options dhcp-option  
  列出dhcp-option UUID的DHCP选项。    

#### PORT GROUP COMMANDS
       pg-add group [port]...
              Creates  a  new  port  group in the Port_Group table named group
              with optional ports added to the group.

       pg-set-ports group port...
              Sets ports on the port group named group.  It  is  an  error  if
              group does not exist.

       pg-del group
              Deletes  port  group group. It is an error if group does not ex‐
              ist.

#### DATABASE COMMANDS

   这些命令查询和修改ovsdb表的内容。
   它们是ovsdb接口的略微抽象，因此它们的运行级别低于其他ovn-nbctl命令。
   *Identifying Tables, Records, and Columns*
   这些命令中的每一个都有一个 *table* 参数来标识数据库中的表。
   其中许多还采用 *record* 参数来标识表中的特定记录。

   *record* 参数可以是记录的UUID，可以缩写为其前4个（或更多）十六进制数字，只要它是唯一的。
   许多表提供了识别记录的其他方法。 Some commands also take *column* parameters
   that identify a particular field within the records in a table.

   For a list of tables and their columns, see ovn-nb(5) or see the  table
   listing from the --help option.

   Record names must be specified in full and with correct capitalization,
   except that UUIDs may be abbreviated to their first  4  (or  more)  hex
   digits, as long as that is unique within the table. Names of tables and
   columns are not case-sensitive, and - and _  are  treated  interchange‐
   ably.  Unique  abbreviations  of table and column names are acceptable,
   e.g. d or dhcp is sufficient to identify the DHCP_Options table.

       Database Values

       Each column in the database accepts a fixed type of data. The currently
       defined basic types, and their representations, are:

              integer
                     A  decimal integer in the range -2**63 to 2**63-1, inclu‐
                     sive.

              real   A floating-point number.

              Boolean
                     True or false, written true or false, respectively.

              string An arbitrary Unicode string, except that null  bytes  are
                     not  allowed.  Quotes  are optional for most strings that
                     begin with an English letter or  underscore  and  consist
                     only  of letters, underscores, hyphens, and periods. How‐
                     ever, true and false and strings that match the syntax of
                     UUIDs  (see  below)  must be enclosed in double quotes to
                     distinguish them from  other  basic  types.  When  double
                     quotes  are  used, the syntax is that of strings in JSON,
                     e.g. backslashes may be used to  escape  special  charac‐
                     ters.  The  empty string must be represented as a pair of
                     double quotes ("").

              UUID   Either a universally unique identifier in  the  style  of
                     RFC  4122,  e.g. f81d4fae-7dec-11d0-a765-00a0c91e6bf6, or
                     an @name defined by a get or create  command  within  the
                     same ovn-nbctl invocation.

       Multiple values in a single column may be separated by spaces or a sin‐
       gle comma. When multiple values are present,  duplicates  are  not  al‐
       lowed,  and  order  is not important. Conversely, some database columns
       can have an empty set of values, represented as [], and square brackets
       may optionally enclose other non-empty sets or single values as well.

       A  few  database columns are "maps" of key-value pairs, where the key
       and the value are each some fixed database type. These are specified in
       the  form key=value, where key and value follow the syntax for the col‐
       umn’s key type and value type, respectively. When  multiple  pairs  are
       present  (separated  by  spaces or a comma), duplicate keys are not al‐
       lowed, and again the order is not important. Duplicate values  are  al‐
       lowed.  An  empty map is represented as {}. Curly braces may optionally
       enclose non-empty maps as well (but use quotes  to  prevent  the  shell
       from  expanding other-config={0=x,1=y} into other-config=0=x other-con‐
       fig=1=y, which may not have the desired effect).

       Database Command Syntax

              [--if-exists]    [--columns=column[,column]...]    list    table
              [record]...
                     Lists  the  data  in each specified record. If no records
                     are specified, lists all the records in table.

                     If --columns is specified, only the requested columns are
                     listed,  in  the  specified order. Otherwise, all columns
                     are listed, in alphabetical order by column name.

                     Without --if-exists, it is  an  error  if  any  specified
                     record  does not exist. With --if-exists, the command ig‐
                     nores any record that does not exist,  without  producing
                     any output.

              [--columns=column[,column]...]       find       table      [col‐
              umn[:key]=value]...
                     Lists the data in  each  record  in  table  whose  column
                     equals  value  or, if key is specified, whose column con‐
                     tains a key with the specified value. The following oper‐
                     ators  may  be used where = is written in the syntax sum‐
                     mary:

                     = != gt;>gt; = >gt;>gt;=
                            Selects records in which column[:key] equals, does
                            not  equal, is less than, is greater than, is less
                            than or equal to, or is greater than or  equal  to
                            value, respectively.

                            Consider  column[:key]  and  value as sets of ele‐
                            ments. Identical sets are considered equal. Other‐
                            wise,  if  the sets have different numbers of ele‐
                            ments, then the set with more elements is  consid‐
                            ered  to  be larger. Otherwise, consider a element
                            from each set pairwise, in increasing order within
                            each  set.  The first pair that differs determines
                            the result. (For a column that contains  key-value
                            pairs, first all the keys are compared, and values
                            are considered only if the two sets contain  iden‐
                            tical keys.)

                     {=} {!=}
                            Test for set equality or inequality, respectively.

                     {=}   Selects  records in which column[:key] is a subset
                            of value. For example, flood-vlans{=}1,2  selects
                            records  in  which  the  flood-vlans column is the
                            empty set or contains 1 or 2 or both.

                     {}    Selects records in which column[:key] is a  proper
                            subset  of  value.  For example, flood-vlans{}1,2
                            selects records in which the flood-vlans column is
                            the empty set or contains 1 or 2 but not both.

                     {>gt;>gt;=} {>gt;>gt;}
                            Same  as  {=}  and {}, respectively, except that
                            the  relationship  is   reversed.   For   example,
                            flood-vlans{>gt;>gt;=}1,2  selects  records  
                            in which the
                            flood-vlans column contains both 1 and 2.

                     For arithmetic operators (= != gt;>gt; = >gt;>gt;=),
                      when  key  is
                     specified  but a particular record’s column does not con‐
                     tain key, the record is always omitted from the  results.
                     Thus,   the   condition   other-config:mtu!=1500  matches
                     records that have a mtu key whose value is not 1500,  but
                     not those that lack an mtu key.

                     For  the  set operators, when key is specified but a par‐
                     ticular record’s column does not contain key, the compar‐
                     ison  is  done  against an empty set. Thus, the condition
                     other-config:mtu{!=}1500 matches records that have a  mtu
                     key  whose  value  is not 1500 and those that lack an mtu
                     key.

                     Don’t forget to escape gt;>gt; from interpretation by  the
                     shell.

                     If --columns is specified, only the requested columns are
                     listed, in the specified order. Otherwise all columns are
                     listed, in alphabetical order by column name.

                     The  UUIDs  shown  for rows created in the same ovn-nbctl
                     invocation will be wrong.

              [--if-exists] [--id=@name] get table record [column[:key]]...
                     Prints the value of each specified column  in  the  given
                     record in table. For map columns, a key may optionally be
                     specified, in which case the value associated with key in
                     the column is printed, instead of the entire map.

                     Without  --if-exists,  it  is an error if record does not
                     exist or key is specified,  if  key  does  not  exist  in
                     record. With --if-exists, a missing record yields no out‐
                     put and a missing key prints a blank line.

                     If @name is specified, then the UUID for  record  may  be
                     referred  to by that name later in the same ovn-nbctl in‐
                     vocation in contexts where a UUID is expected.

                     Both --id and the column arguments are optional, but usu‐
                     ally  at  least  one or the other should be specified. If
                     both are omitted, then get has no effect except to verify
                     that record exists in table.

                     --id and --if-exists cannot be used together.

              [--if-exists] set table record column[:key]=value...
                     Sets  the  value  of  each  specified column in the given
                     record in table to value. For map columns, a key may  op‐
                     tionally be specified, in which case the value associated
                     with key in that column is changed (or added, if none ex‐
                     ists), instead of the entire map.

                     Without  --if-exists,  it  is an error if record does not
                     exist. With --if-exists, this  command  does  nothing  if
                     record does not exist.

              [--if-exists] add table record column [key=]value...
                     Adds  the  specified value or key-value pair to column in
                     record in table. If column is a  map,  then  key  is  re‐
                     quired, otherwise it is prohibited. If key already exists
                     in a map column, then the current value is  not  replaced
                     (use the set command to replace an existing value).

                     Without  --if-exists,  it  is an error if record does not
                     exist. With --if-exists, this  command  does  nothing  if
                     record does not exist.

              [--if-exists] remove table record column value...

                     [--if-exists] remove table record column key...

                     [--if-exists]  remove  table  record  column key=value...
                     Removes the specified values or key-value pairs from col‐
                     umn in record in table. The first form applies to columns
                     that are not maps: each specified value is  removed  from
                     the  column. The second and third forms apply to map col‐
                     umns: if only a key is specified, then any key-value pair
                     with  the  given key is removed, regardless of its value;
                     if a value is given then a pair is removed only  if  both
                     key and value match.

                     It  is  not  an  error if the column does not contain the
                     specified key or value or pair.

                     Without --if-exists, it is an error if  record  does  not
                     exist.  With  --if-exists,  this  command does nothing if
                     record does not exist.

              [--if-exists] clear table record column...
                     Sets each column in record in table to the empty  set  or
                     empty  map,  as appropriate. This command applies only to
                     columns that are allowed to be empty.

                     Without --if-exists, it is an error if  record  does  not
                     exist.  With  --if-exists,  this  command does nothing if
                     record does not exist.

              [--id=@name] create table column[:key]=value...
                     Creates a new record in table and sets the initial values
                     of  each  column. Columns not explicitly set will receive
                     their default values. Outputs the UUID of the new row.

                     If @name is specified, then the UUID for the new row  may
                     be  referred  to by that name elsewhere in the same \*(PN
                     invocation in contexts where a  UUID  is  expected.  Such
                     references may precede or follow the create command.

                     Caution (ovs-vsctl as example)
                            Records  in the Open vSwitch database are signifi‐
                            cant only when they can be reached directly or in‐
                            directly  from  the Open_vSwitch table. Except for
                            records in the QoS or Queue tables,  records  that
                            are  not reachable from the Open_vSwitch table are
                            automatically  deleted  from  the  database.  This
                            deletion  happens immediately, without waiting for
                            additional ovs-vsctl commands  or  other  database
                            activity. Thus, a create command must generally be
                            accompanied by additional commands within the same
                            ovs-vsctl  invocation to add a chain of references
                            to the newly created  record  from  the  top-level
                            Open_vSwitch  record.  The  EXAMPLES section gives
                            some examples that show how to do this.

              [--if-exists] destroy table record...
                     Deletes each specified record from table. Unless --if-ex‐
                     ists is specified, each records must exist.

              --all destroy table
                     Deletes all records from the table.

                     Caution (ovs-vsctl as example)
                            The  destroy command is only useful for records in
                            the QoS or Queue tables. Records in  other  tables
                            are  automatically  deleted from the database when
                            they become unreachable from the Open_vSwitch  ta‐
                            ble.  This  means that deleting the last reference
                            to a record is sufficient for deleting the  record
                            itself.  For  records  in these tables, destroy is
                            silently ignored. See the EXAMPLES  section  below
                            for more information.

              wait-until table record [column[:key]=value]...
                     Waits  until  table  contains a record named record whose
                     column equals value or, if key is specified, whose column
                     contains a key with the specified value. Any of the oper‐
                     ators !=, gt;>gt;, =, or >gt;>gt;= may be  substituted  for  =  to
                     test  for  inequality, less than, greater than, less than
                     or equal to, or greater than or equal  to,  respectively.
                     (Don’t forget to escape gt;>gt; from interpretation by the
                     shell.)

                     If no column[:key]=value arguments are given,  this  com‐
                     mand  waits  only  until  record exists. If more than one
                     such argument is given, the command waits  until  all  of
                     them are satisfied.

                     Caution (ovs-vsctl as example)
                            Usually  wait-until should be placed at the begin‐
                            ning of a set of ovs-vsctl commands. For  example,
                            wait-until  bridge  br0  --  get  bridge br0 data‐
                            path_id waits until a bridge named br0 is created,
                            then  prints  its  datapath_id column, whereas get
                            bridge br0 datapath_id --  wait-until  bridge  br0
                            will  abort  if  no  bridge  named br0 exists when
                            ovs-vsctl initially connects to the database.

                     Consider specifying --timeout=0 along with  --wait-until,
                     to  prevent ovn-nbctl from terminating after waiting only
                     at most 5 seconds.

              comment [arg]...
                     This command has no effect on behavior, but any  database
                     log  record  created by the command will include the com‐
                     mand and its arguments.

#### SYNCHRONIZATION COMMANDS
       sync   Ordinarily, --wait=sb or --wait=hv only waits for changes by the
              current ovn-nbctl invocation to take effect. This means that, if
              none of the commands supplied to ovn-nbctl change the  database,
              then  the  command  does not wait at all. With the sync command,
              however, ovn-nbctl waits even for earlier changes to  the  data‐
              base  to propagate down to the southbound database or all of the
              OVN chassis, according to the argument to --wait.

#### REMOTE CONNECTIVITY COMMANDS
       get-connection
              Prints the configured connection(s).

       del-connection
              Deletes the configured connection(s).

       [--inactivity-probe=msecs] set-connection target...
              Sets the configured manager target or  targets.  Use  --inactiv‐
              ity-probe=msecs to override the default idle connection inactiv‐
              ity probe time. Use 0 to disable inactivity probes.

#### SSL CONFIGURATION COMMANDS
       get-ssl
              Prints the SSL configuration.

       del-ssl
              Deletes the current SSL configuration.

       [--bootstrap] set-ssl private-key  certificate  ca-cert  [ssl-protocol-
       list [ssl-cipher-list]]
              Sets the SSL configuration.

#### DAEMON MODE
       When  it  is invoked in the most ordinary way, ovn-nbctl connects to an
       OVSDB server that hosts the northbound database,  retrieves  a  partial
       copy  of  the  database that is complete enough to do its work, sends a
       transaction request to the  server,  and  receives  and  processes  the
       server’s  reply.  In  common  interactive use, this is fine, but if the
       database is large, the step in which ovn-nbctl retrieves a partial copy
       of  the  database  can  take a long time, which yields poor performance
       overall.

       To improve performance in such  a  case,  ovn-nbctl  offers  a  "daemon
       mode,"  in  which  the user first starts ovn-nbctl running in the back‐
       ground and afterward uses the daemon to execute operations.  Over  sev‐
       eral  ovn-nbctl  command  invocations, this performs better overall be‐
       cause it retrieves a copy of the database only once at  the  beginning,
       not once per program run.

       Use the --detach option to start an ovn-nbctl daemon. With this option,
       ovn-nbctl prints the name of a control socket  to  stdout.  The  client
       should  save this name in environment variable OVN_NB_DAEMON. Under the
       Bourne shell this might be done like this:

             export OVN_NB_DAEMON=$(ovn-nbctl --pidfile --detach)


       When OVN_NB_DAEMON is set, ovn-nbctl  automatically  and  transparently
       uses the daemon to execute its commands.

       When  the daemon is no longer needed, kill it and unset the environment
       variable, e.g.:

             kill $(cat /var/run/ovn-nbctl.pid)
             unset OVN_NB_DAEMON


       Daemon mode is experimental.

   Daemon Commands
       Daemon mode is internally implemented using the same mechanism used  by
       ovs-appctl.  One  may  also  use ovs-appctl directly with the following
       commands:

              run [options] command [arg...] [--  [options]  command  [arg...]
              ...]
                     Instructs the daemon process to run one or more ovn-nbctl
                     commands described above and reply with  the  results  of
                     running  these  commands.  Accepts the --no-wait, --wait,
                     --timeout, --dry-run,  --oneline,  and  the  options  de‐
                     scribed under Table Formatting Options in addition to the
                     the command-specific options.

              exit   Causes ovn-nbctl to gracefully terminate.

#### OPTIONS
       --no-wait | --wait=none
       --wait=sb
       --wait=hv
            These options control whether and how ovn-nbctl waits for the  OVN
            system  to become up-to-date with changes made in an ovn-nbctl in‐
            vocation.

            By default, or if --no-wait or --wait=none, ovn-nbctl exits  imme‐
            diately  after  confirming that changes have been committed to the
            northbound database, without waiting.

            With --wait=sb, before ovn-nbctl exits, it waits for ovn-northd to
            bring the southbound database up-to-date with the northbound data‐
            base updates.

            With --wait=hv, before ovn-nbctl exits, it additionally waits  for
            all  OVN  chassis  (hypervisors and gateways) to become up-to-date
            with the northbound database updates. (This can become an  indefi‐
            nite wait if any chassis is malfunctioning.)

            Ordinarily,  --wait=sb  or --wait=hv only waits for changes by the
            current ovn-nbctl invocation to take effect. This means  that,  if
            none  of  the  commands supplied to ovn-nbctl change the database,
            then the command does not wait at all. Use  the  sync  command  to
            override this behavior.

       --db database
            The OVSDB database remote to contact. If the OVN_NB_DB environment
            variable is set, its value is used as the default. Otherwise,  the
            default  is  unix:/var/run/openvswitch/ovnnb_db.sock, but this de‐
            fault is unlikely to be useful outside of single-machine OVN  test
            environments.

       --leader-only
       --no-leader-only
            By  default,  or with --leader-only, when the database server is a
            clustered database, ovn-nbctl will avoid servers  other  than  the
            cluster  leader.  This  ensures that any data that ovn-nbctl reads
            and reports is up-to-date. With --no-leader-only,  ovn-nbctl  will
            use  any  server  in  the  cluster, which means that for read-only
            transactions it can report and act  on  stale  data  (transactions
            that   modify   the  database  are  always  serialized  even  with
            --no-leader-only). Refer to Understanding Cluster  Consistency  in
            ovsdb(7) for more information.

   Daemon Options
       --pidfile[=pidfile]
              Causes a file (by default, program.pid) to be created indicating
              the PID of the running process. If the pidfile argument  is  not
              specified, or if it does not begin with /, then it is created in
              /var/run/openvswitch.

              If --pidfile is not specified, no pidfile is created.

       --overwrite-pidfile
              By default, when --pidfile is specified and the  specified  pid‐
              file already exists and is locked by a running process, the dae‐
              mon refuses to start. Specify --overwrite-pidfile to cause it to
              instead overwrite the pidfile.

              When --pidfile is not specified, this option has no effect.

       --detach
              Runs  this  program  as a background process. The process forks,
              and in the child it starts a new session,  closes  the  standard
              file descriptors (which has the side effect of disabling logging
              to the console), and changes its current directory to  the  root
              (unless  --no-chdir is specified). After the child completes its
              initialization, the parent exits.

       --monitor
              Creates an additional process to monitor  this  program.  If  it
              dies  due  to a signal that indicates a programming error (SIGA‐
              BRT, SIGALRM, SIGBUS, SIGFPE, SIGILL, SIGPIPE, SIGSEGV, SIGXCPU,
              or SIGXFSZ) then the monitor process starts a new copy of it. If
              the daemon dies or exits for another reason, the monitor process
              exits.

              This  option  is  normally used with --detach, but it also func‐
              tions without it.

       --no-chdir
              By default, when --detach is specified, the daemon  changes  its
              current  working  directory  to  the root directory after it de‐
              taches. Otherwise, invoking the daemon from a carelessly  chosen
              directory  would  prevent  the administrator from unmounting the
              file system that holds that directory.

              Specifying --no-chdir suppresses this behavior,  preventing  the
              daemon  from changing its current working directory. This may be
              useful for collecting core files, since it is common behavior to
              write core dumps into the current working directory and the root
              directory is not a good directory to use.

              This option has no effect when --detach is not specified.

       --no-self-confinement
              By default this daemon will try to self-confine itself  to  work
              with  files  under  well-known  directories whitelisted at build
              time. It is better to stick with this default behavior  and  not
              to  use  this  flag  unless some other Access Control is used to
              confine daemon. Note that in contrast to  other  access  control
              implementations  that  are  typically enforced from kernel-space
              (e.g. DAC or MAC), self-confinement is imposed  from  the  user-
              space daemon itself and hence should not be considered as a full
              confinement strategy, but instead should be viewed as  an  addi‐
              tional layer of security.

       --user=user:group
              Causes  this  program  to  run  as a different user specified in
              user:group, thus dropping most of  the  root  privileges.  Short
              forms  user  and  :group  are also allowed, with current user or
              group assumed, respectively. Only daemons started  by  the  root
              user accepts this argument.

              On   Linux,   daemons   will   be   granted   CAP_IPC_LOCK   and
              CAP_NET_BIND_SERVICES before dropping root  privileges.  Daemons
              that  interact  with  a  datapath, such as ovs-vswitchd, will be
              granted three  additional  capabilities,  namely  CAP_NET_ADMIN,
              CAP_NET_BROADCAST  and  CAP_NET_RAW.  The capability change will
              apply even if the new user is root.

              On Windows, this option is not currently supported. For security
              reasons,  specifying  this  option will cause the daemon process
              not to start.

#### LOGGING OPTIONS
       -v[spec]
       --verbose=[spec]
            Sets logging levels. Without any spec, sets the log level for  ev‐
            ery  module  and  destination to dbg. Otherwise, spec is a list of
            words separated by spaces or commas or colons, up to one from each
            category below:

            •      A  valid module name, as displayed by the vlog/list command
                   on ovs-appctl(8), limits the log level change to the speci‐
                   fied module.

            •      syslog,  console, or file, to limit the log level change to
                   only to the system log, to the console, or to a  file,  re‐
                   spectively.  (If  --detach  is specified, the daemon closes
                   its standard file descriptors, so logging  to  the  console
                   will have no effect.)

                   On  Windows  platform,  syslog is accepted as a word and is
                   only useful along with the --syslog-target option (the word
                   has no effect otherwise).

            •      off,  emer,  err,  warn,  info,  or dbg, to control the log
                   level. Messages of the given severity  or  higher  will  be
                   logged,  and  messages  of  lower severity will be filtered
                   out. off filters out all messages. See ovs-appctl(8) for  a
                   definition of each log level.

            Case is not significant within spec.

            Regardless  of the log levels set for file, logging to a file will
            not take place unless --log-file is also specified (see below).

            For compatibility with older versions of OVS, any is accepted as a
            word but has no effect.

       -v
       --verbose
            Sets  the  maximum  logging  verbosity level, equivalent to --ver‐
            bose=dbg.

       -vPATTERN:destination:pattern
       --verbose=PATTERN:destination:pattern
            Sets the log pattern for destination to pattern. Refer to  ovs-ap‐
            pctl(8) for a description of the valid syntax for pattern.

       -vFACILITY:facility
       --verbose=FACILITY:facility
            Sets  the RFC5424 facility of the log message. facility can be one
            of kern, user, mail, daemon, auth, syslog, lpr, news, uucp, clock,
            ftp,  ntp,  audit,  alert, clock2, local0, local1, local2, local3,
            local4, local5, local6 or local7. If this option is not specified,
            daemon  is used as the default for the local system syslog and lo‐
            cal0 is used while sending a message to the  target  provided  via
            the --syslog-target option.

       --log-file[=file]
            Enables  logging  to a file. If file is specified, then it is used
            as the exact name for the log file. The default log file name used
            if file is omitted is /var/log/openvswitch/program.log.

       --syslog-target=host:port
            Send  syslog messages to UDP port on host, in addition to the sys‐
            tem syslog. The host must be a numerical IP address, not  a  host‐
            name.

       --syslog-method=method
            Specify  method  as  how  syslog messages should be sent to syslog
            daemon. The following forms are supported:

            •      libc, to use the libc syslog() function. Downside of  using
                   this  options  is that libc adds fixed prefix to every mes‐
                   sage before it is actually sent to the syslog  daemon  over
                   /dev/log UNIX domain socket.

            •      unix:file, to use a UNIX domain socket directly. It is pos‐
                   sible to specify arbitrary message format with this option.
                   However,  rsyslogd  8.9  and  older versions use hard coded
                   parser function anyway that limits UNIX domain socket  use.
                   If  you  want  to  use  arbitrary message format with older
                   rsyslogd versions, then use UDP socket to localhost IP  ad‐
                   dress instead.

            •      udp:ip:port,  to  use  a UDP socket. With this method it is
                   possible to use arbitrary message format  also  with  older
                   rsyslogd.  When sending syslog messages over UDP socket ex‐
                   tra precaution needs to be taken into account, for example,
                   syslog daemon needs to be configured to listen on the spec‐
                   ified UDP port, accidental iptables rules could  be  inter‐
                   fering  with  local syslog traffic and there are some secu‐
                   rity considerations that apply to UDP sockets, but  do  not
                   apply to UNIX domain sockets.

            •      null, to discard all messages logged to syslog.

            The  default is taken from the OVS_SYSLOG_METHOD environment vari‐
            able; if it is unset, the default is libc.

#### TABLE FORMATTING OPTIONS
       These options control the format of output from the list and find  com‐
       mands.

              -f format
              --format=format
                   Sets  the  type of table formatting. The following types of
                   format are available:

                   table  2-D text tables with aligned columns.

                   list (default)
                          A list with one column per line and  rows  separated
                          by a blank line.

                   html   HTML tables.

                   csv    Comma-separated values as defined in RFC 4180.

                   json   JSON  format as defined in RFC 4627. The output is a
                          sequence of JSON objects, each of which  corresponds
                          to  one  table.  Each  JSON object has the following
                          members with the noted values:

                          caption
                                 The table’s caption. This member  is  omitted
                                 if the table has no caption.

                          headings
                                 An  array  with one element per table column.
                                 Each array element is  a  string  giving  the
                                 corresponding column’s heading.

                          data   An array with one element per table row. Each
                                 element is also an array with one element per
                                 table  column.  The  elements of this second-
                                 level array are the cells that constitute the
                                 table.  Cells  that  represent  OVSDB data or
                                 data types are expressed in  the  format  de‐
                                 scribed  in  the  OVSDB  specification; other
                                 cells are simply expressed as text strings.

              -d format
              --data=format
                   Sets the formatting for cells within output  tables  unless
                   the table format is set to json, in which case json format‐
                   ting is always used when formatting  cells.  The  following
                   types of format are available:

                   string (default)
                          The  simple  format described in the Database Values
                          section of ovs-vsctl(8).

                   bare   The simple format with punctuation stripped off:  []
                          and {} are omitted around sets, maps, and empty col‐
                          umns, items within sets  and  maps  are  space-sepa‐
                          rated, and strings are never quoted. This format may
                          be easier for scripts to parse.

                   json   The RFC 4627 JSON format as described above.

              --no-headings
                   This option suppresses the heading row that  otherwise  ap‐
                   pears in the first row of table output.

              --pretty
                   By  default, JSON in output is printed as compactly as pos‐
                   sible. This option causes JSON in output to be printed in a
                   more  readable  fashion. Members of objects and elements of
                   arrays are printed one per line, with indentation.

                   This option does not affect JSON in tables, which is always
                   printed compactly.

              --bare
                   Equivalent to --format=list --data=bare --no-headings.

   PKI Options
       PKI  configuration  is  required  to  use SSL for the connection to the
       database.

              -p privkey.pem
              --private-key=privkey.pem
                   Specifies a PEM file containing the  private  key  used  as
                   identity for outgoing SSL connections.

              -c cert.pem
              --certificate=cert.pem
                   Specifies  a  PEM file containing a certificate that certi‐
                   fies the private key specified on -p or --private-key to be
                   trustworthy. The certificate must be signed by the certifi‐
                   cate authority (CA) that the peer in SSL  connections  will
                   use to verify it.

              -C cacert.pem
              --ca-cert=cacert.pem
                   Specifies a PEM file containing the CA certificate for ver‐
                   ifying certificates presented to this program by SSL peers.
                   (This  may  be  the  same certificate that SSL peers use to
                   verify the certificate specified on -c or --certificate, or
                   it  may  be a different one, depending on the PKI design in
                   use.)

              -C none
              --ca-cert=none
                   Disables verification  of  certificates  presented  by  SSL
                   peers.  This  introduces  a security risk, because it means
                   that certificates cannot be verified to be those  of  known
                   trusted hosts.

              --bootstrap-ca-cert=cacert.pem
                     When  cacert.pem  exists, this option has the same effect
                     as -C or --ca-cert. If it does not exist, then  the  exe‐
                     cutable  will  attempt  to obtain the CA certificate from
                     the SSL peer on its first SSL connection and save  it  to
                     the  named PEM file. If it is successful, it will immedi‐
                     ately drop the connection and reconnect, and from then on
                     all  SSL  connections must be authenticated by a certifi‐
                     cate signed by the CA certificate thus obtained.

                     This option exposes the SSL connection to  a  man-in-the-
                     middle  attack  obtaining the initial CA certificate, but
                     it may be useful for bootstrapping.

                     This option is only useful if the SSL peer sends  its  CA
                     certificate as part of the SSL certificate chain. The SSL
                     protocol does not require the server to send the CA  cer‐
                     tificate.

                     This option is mutually exclusive with -C and --ca-cert.

   Other Options
       -h
       --help
            Prints a brief help message to the console.

       -V
       --version
            Prints version information to the console.



Open vSwitch 2.10.90               ovn-nbctl                      ovn-nbctl(8)
