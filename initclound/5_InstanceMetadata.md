### What is a instance data?
实例数据是cloud-init进程配置实例的所有配置数据的集合。
此配置通常来自任意数量的来源：

* 云提供的元数据服务（又称元数据）
* 附加到实例的config-drive
* 已启动的云镜像或分发中的cloud-config seed文件
* 文件或cloud metadata services提供的vendordata
* 在实例创建时提供的userdata

每个云提供商都以不同的格式向实例提供唯一的配置元数据。Cloud-init provides a cache of any crawled metadata as well as a versioned set of standardized instance data keys which it makes available on all platforms.

Cloud-init在/run/cloud-init/instance-data.json中生成一个简单的json对象，其表示 初始引导期间使用的元数据的 标准化和版本化。目的是为使用cloud-init部署的任何系统上的用户或脚本提供以下好处：

* 要查询的简单静态对象以获取实例的元数据
* 避免对已经缓存在文件系统上的元数据进行昂贵的网络事务
* 减少重新抓取已缓存的静态元数据的元数据服务的需要
* 利用cloud-init的最佳实践来抓取云元数据服务
* 避免在每个云平台上滚动唯一的元数据爬虫以获取元数据配置值

Cloud-init存储在以下文件中处理的所有实例数据：

* /run/cloud-init/instance-data.json: 世界可读的json包含标准化密钥，敏感密钥
* /run/cloud-init/instance-data-sensitive.json: root-readable unredacted json blob
* /var/lib/cloud/instance/user-data.txt: root-readable 敏感的原始用户数据
* /var/lib/cloud/instance/vendor-data.txt: root-readable
敏感的原始vendordata

Cloud-init从instance-data.json编辑任何安全敏感内容，将/run/cloud-init/instance-data.json存储为世界可读的json文件。
因为用户数据和供应商数据可以包含密码，所以这两个文件也只是root用户。root用户还可以读取/run/cloud-init/instance-data-sensitive.json，它是来自instance-data.json的所有实例数据以及未经过编辑的敏感内容。


### Format of instance-data.json

instance-data.json和instance-data-sensitive.json文件是格式良好的JSON，并记录由cloud-init处理的任何元数据的键和值集。 Cloud-init标准化了此内容的格式，以便可以跨不同的云平台进行通用化。

有三个基本的顶级键

* base64_encoded_keys：进入instance-data.json对象的正斜杠分隔键路径列表，其值为base64encoded以实现json兼容性。应解码这些路径上的值以获得原始值。
* sensitive_keys：进入instance-data.json对象的正斜杠分隔键路径列表，其值被数据源视为“安全敏感”。对于非root用户，只会从instance-data.json中编辑此处列出的密钥。
* ds：针对特定云平台爬网的特定于数据源的元数据。它应该密切代表已爬网的云元数据的结构。提供的内容和细节的结构完全依赖于云。里程将根据云暴露的内容而有所不同。在'ds'键下公开的内容目前是实验性的，并且预计会在即将发布的cloud-init版本中略有变化。
* v1：标准化的cloud-init元数据密钥，这些密钥保证存在于所有云平台上。即使cloud-init引入了带有v2的新版标准化密钥，它们也将保留其当前的行为和格式，并将继续推进。

存在标准化密钥

| Key path | Description | Examples |
| ------ | ------ | ------ |
| v1._beta_keys | 标准密钥列表仍在'beta'中。 这些密钥的格式，意图或存在可能会发生变化。 不要认为它们是生产就绪的。 | [subplatform] |
| v1.cloud_name | 在可能的情况下，这将指示此系统正在运行的云的“名称”。 这与下面的“平台”明显不同。 例如，Amazon Web Services的名称为'aws'，而平台为'ec2'。如果在元数据中没有确定或提供特定名称，则此字段可能包含与“平台”相同的内容。 | aws, openstack, azure, configdrive, nocloud, ovf, etc. |
|v1.instance_id|云分配的唯一instance_id|	i-<somehash>|
|v1.local_hostname|系统的内部或本地主机名|ip-10-41-41-70, <user-provided-hostname>|
|v1.platform|尝试识别实例正在运行的云平台。|ec2, openstack, lxd, gce nocloud, ovf|
|v1.subplatform|其他平台详细信息描述了所使用的元数据的特定来源或类型 子平台的格式为：<subplatform_type>（<url_file_or_dev_path>）|metadata (http://168.254.169.254), seed-dir (/path/to/seed-dir/), config-disk (/dev/cd0), configdrive (/dev/sr0)|
|v1.public_ssh_keys|由数据源元数据提供给实例的ssh密钥列表。|[‘ssh-rsa AA…’, …]|
|v1.region|部署实例的物理区域/数据中心|us-east-2|
|v1.availability_zone|部署实例的物理可用区域|us-east-2b, nova, null|

### Using instance-data

从cloud-init v.18.4开始，/run/cloud_init/instance-data.json中的任何变量都可用于：

* User-data scripts 用户数据脚本
* Cloud config data 云配置数据
* 命令行界面通过cloud-init查询或cloud-init devel渲染

许多云允许用户在实例启动时向实例提供用户数据。 Cloud-init支持许多用户数据格式。用户数据脚本和 ＃cloud-config数据都支持jinja模板渲染。
当提供的用户数据的第一行开头时，## template：jinja cloud-init将使用jinja呈现该文件。 任何instance-data-sensitive.json变量都表示为点分隔的jinja模板变量，因为cloud-config模块作为“root”用户运行。

以下是提供这些类型的用户数据的一些示例

* 云配置使用ec2公共主机名和可用区调
```
## template: jinja

#cloud-config
runcmd:
    - echo 'EC2 public hostname allocated to instance: {{
      ds.meta_data.public_hostname }}' > /tmp/instance_metadata
    - echo 'EC2 avaiability zone: {{ v1.availability_zone }}' >>
      /tmp/instance_metadata
    - curl -X POST -d '{"hostname": "{{ds.meta_data.public_hostname }}",
      "availability-zone": "{{ v1.availability_zone }}"}'
      https://example.com
```

* 自定义用户数据脚本根据区域执行不同的操作

```
## template: jinja
#!/bin/bash
{% if v1.region == 'us-east-2' -%}
echo 'Installing custom proxies for {{ v1.region }}
sudo apt-get install my-xtra-fast-stack
{%- endif %}
...
```

Cloud-init还提供了一个命令行工具cloud-init查询，可以帮助开发人员或脚本轻松获取实例元数据。 有关更多信息，请参阅cloud-init查询。

To cut down on keystrokes on the command line, cloud-init also provides top-level key aliases for any standardized v# keys present. The preceding v1 is not required of v1.var_name These aliases will represent the value of the highest versioned standard key. For example, cloud_name value will be v2.cloud_name if both v1 and v2 keys are present in instance-data.json. The query command also publishes userdata and vendordata keys to the root user which will contain the decoded user and vendor data provided to this instance. Non-root users referencing userdata or vendordata keys will see only redacted values.

```
# List all top-level instance-data keys available
% cloud-init query --list-keys

# Find your EC2 ami-id
% cloud-init query ds.metadata.ami_id

# Format your cloud_name and region using jinja template syntax
% cloud-init query --format 'cloud: {{ v1.cloud_name }} myregion: {{
% v1.region }}'
```
