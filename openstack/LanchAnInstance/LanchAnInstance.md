本节创建必要的虚拟网络以支持启动实例。网络选项1包括一个provider(external)网络和一个使用它的实例。网络选项2包括一个provider网络，以及一个self-service (private)网络和一个使用它的实例。
本节中的指令在控制(controller)节点上使用命令行接口(CLI)工具。但是，您可以按照安装工具的任何主机上的说明进行操作。
#### Create virtual networks
为配置Neutron时选择的网络选项创建虚拟网络。如果选择选项1，只创建提供者网络。如果选择选项2，创建提供者和自助服务网络。
[Provider_Network](./Provider_Network.md)
[Self-service_Network](./Self-service_Network.md)
为您的环境创建了适当的网络之后，您可以继续准备环境以启动实例。
