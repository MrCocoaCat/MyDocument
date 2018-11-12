### 部署整体流程
1. 安装git
```
yum install -y git
```
2. 使用git下载DevStack源码
```
git clone https://git.openstack.org/openstack-dev/devstack
```
3. 使用创建用户脚本创建用户
```
cd devstack/tools/
./create-stack-user.sh
```
4. 设置用户权限，并移动devstack文件夹至stack 用户下
```
mv devstack/ /opt/stack/
chown -R stack:stack /opt/stack/devstack
```
5. 切换到stack用户
```
su - stack
cd devstack
```
6. 在devstack目录下编写local.conf文件，写入以下内容
```
[[local|localrc]]
ADMIN_PASSWORD=secret
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
```

7. 通过执行自动化脚本进行部署
```
./stack.sh
```
### stack.sh脚本
stack.sh是Openstack 的安装脚本，其可以安装并且配置变量。包括Cinder,Glance,Horizon,Keystone,Nova, Neutron,Swift等模块。通过设置环境变量可以改变脚本的执行方式，默认的设置在 "stackrc" 文件中。在多个节点上运行stack.sh 脚本，可以进行多节点的部署。



###问题总结

**1. 安装devstack时会出错：env: ‘/opt/stack/requirements/.venv/bin/pip’: No such file or directory**
在 ~/devstack/local.conf 添加内容：
```
    enable_service placement-api
    enable_service placement-client
```
```
[stack@kuber-node1 devstack]$ virtualenv ../requirements/.venv/
```




[opendev官方地址](https://docs.openstack.org/devstack/latest/)
