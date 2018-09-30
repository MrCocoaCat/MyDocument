### Introduction to the Block Storage service
块存储服务提供计算实例可以使用的持久块存储资源。这包括类似于Amazon Elastic Block storage (EBS)的二级附加存储。此外，还可以将图像写入块存储设备，以便计算将其用作可引导的持久实例。
块存储服务与Amazon EBS服务略有不同。块存储服务不提供像NFS那样的共享存储解决方案。使用块存储服务，您只能将设备附加到一个实例。
**块存储服务提供:**
* cinder-api
一个WSGI应用程序，它在整个块存储服务中验证和路由请求。它只支持OpenStack api，尽管有一种转换可以通过计算的EC2接口完成，该接口调用块存储客户端。
* cinder-schedule
调度程序将请求路由到适当的卷服务。根据您的配置，这可能是对正在运行的卷服务的简单轮询调度，也可能通过使用Filter Scheduler而变得更加复杂。Filter Scheduler是默认值，它支持对容量、可用性区域、卷类型和功能以及自定义过滤器等内容进行筛选。
* cinder-volume
管理块存储设备，特别是后端设备本身
* cinder-backup
提供一种将块存储卷备份到OpenStack对象存储(swift)的方法。
**块存储服务包含以下组件:**
* 
