ovn-ctl(8)                               Open vSwitch Manual                              ovn-ctl(8)

NAME
       ovn-ctl - Open Virtual Network northbound daemon lifecycle utility

SYNOPSYS
       ovn-ctl [options] command

DESCRIPTION
       This  program  is  intended to be invoked internally by Open Virtual Network startup scripts.
       System administrators should not normally invoke it directly.

COMMANDS
              start_northd
              start_controller
              stop_northd
              stop_controller
              restart_northd
              restart_controller

OPTIONS
       --ovn-northd-priority=NICE

       --ovn-northd-wrapper=WRAPPER

       --ovn-controller-priority=NICE

       --ovn-controller-wrapper=WRAPPER

       -h | --help

FILE LOCATION OPTIONS
       --db-sock==SOCKET

       --db-nb-file==FILE

       --db-sb-file==FILE

       --db-nb-schema==FILE

       --db-sb-schema==FILE

EXAMPLE USAGE
   Run ovn-controller on a host already running OVS
       # ovn-ctl start_controller

   Run ovn-northd on a host already running OVS
       # ovn-ctl start_northd

   All-in-one OVS+OVN for testing
       # ovs-ctl start --system-id="random"

       # ovn-ctl start_northd

       # ovn-ctl start_controller
