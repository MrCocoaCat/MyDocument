
### RYU简介
Ryu是一个基于组件的软件定义网络框架。Ryu为软件组件提供定义良好的API，使开发人员可以轻松创建新的网络管理和控制应用程序。Ryu支持各种用于管理网络设备的协议，例如OpenFlow，Netconf，OF-config等。关于OpenFlow，Ryu支持完全支持1.0,1.2,1.3,1.4,1.5和Nicira Extensions。 所有代码都可以在Apache 2.0许可下免费获得。

使用Ryu 是非常简便的，可以通过pip 直接安装
```
pip install ryu
```
同时，也可以通过源码进行安装
```
git clone git://github.com/osrg/ryu.git
cd ryu; pip install .
```
Ryu 的项目文档完善，重要的是其官方提供台湾地区繁体版文档。虽然技术术语略有不同，但对于英文不好的同学，帮助还是很大的。

繁体版Ryubook:https://osrg.github.io/ryu-book/zh_tw/Ryubook.pdf
繁体版官方文档：https://ryu-zhdoc.readthedocs.io/

### 文件结构

使用git clone git://github.com/osrg/ryu.git下载源码后，查看目录结构如下
```
$ tree -L 1

.
├── bin  可执行程序
├── CONTRIBUTING.rst
├── debian
├── doc 文档
├── etc 配置文件
├── LICENSE
├── MANIFEST.in
├── README.rst
├── run_tests.sh
├── ryu 程序
├── setup.cfg
├── setup.py
├── tools 安装虚拟环境工具
└── tox.ini
```

相比openstack而言，Ryu的代码量并不多，目录结构也比较简单。与大多数项目一样，bin/目录放置执行文件，其中仅含有ryu、ryu-manager两个文件。我们看下ryu-manager文件
```
#!/usr/bin/env python
from ryu.cmd.manager import main
main()
```

\#!/usr/bin/env python 的含义是在#!/usr/bin/env中找到python的安装路径，然后去执行它。
含有这段话，就可以使用./ryu-manager语句执行，而不必使用python ryu-manager。主程序即执行ryu.cmd.manager中的main函数。可以看出ryu.cmd.manager即为ryu程序的入口点。

### setup.py
Ryu使用setup.py 进行打包分发，即使用setup.py就可以进行pip install 等pip 操作。通过setup.py文件可以总览整个项目，可视为整个项目的“源码地图”。
```
ryu.hooks.save_orig()
setuptools.setup(name='ryu',
                 setup_requires=['pbr'],
                 pbr=True)

```
ryu.hooks.save_orig() 保存现有环境变量，暂不做具体分析。setuptools指定引用pbr作为其解析工具，pbr是openstack推出的解析工具，其官方文档位置为：https://docs.openstack.org/pbr/latest/user/features.html
pbr 提供一下功能
* 版本：根据git revisions及tag管理版本号
* 作者：从git log生成AUTHORS文件
* ChangeLog：从git log生成ChangeLog
* 清单：从git文件和一些标准文件生成合理的清单
* 发行说明：使用reno生成发行说明文件
* Requirements：文件中存储依赖
* long_description：将您的README文件用作long_description
* Smart find_packages：在root包下智能查找包
* Sphinx Autodoc：为整个模块生成autodoc存根文件
注意，其不支持setuptools的easy_install功能：虽然其依赖setup_requires，但对于任何install_requires，我们建议在运行setup.py install之前安装它们 - 手动或使用安装工具（如pip）。

pbr 所解析的文件为setup.cfg，其内容如下
```
[metadata]
name = ryu
summary = Component-based Software-defined Networking Framework
license = Apache License 2.0
author = Ryu project team
author-email = ryu-devel@lists.sourceforge.net
home-page = http://osrg.github.io/ryu/
description-file = README.rst
platform = any
classifier =
    Development Status :: 5 - Production/Stable
    License :: OSI Approved :: Apache Software License
    Topic :: System :: Networking
    Natural Language :: English
    Programming Language :: Python
    Programming Language :: Python :: 2.7
    Programming Language :: Python :: 3
    Programming Language :: Python :: 3.4
    Programming Language :: Python :: 3.5
    Programming Language :: Python :: 3.6
    Programming Language :: Python :: 3.7
    Operating System :: Unix
keywords =
    openflow
    openvswitch
    openstack

[files]
packages =
    ryu
data_files =
    etc/ryu =
        etc/ryu/ryu.conf

[build_sphinx]
all_files = 1
build-dir = doc/build
source-dir = doc/source

[bdist_rpm]
Release = 1
Group = Applications/Accessories
Requires = python-eventlet, python-routes, python-webob, python-paramiko, python-netaddr, python-lxml, python-oslo-config, python-msgpack
doc_files = LICENSE
            MANIFEST.in
            README.rst
            CONTRIBUTING.rst
            doc/

[global]
setup-hooks =
    ryu.hooks.setup_hook

[entry_points]
console_scripts =
    ryu-manager = ryu.cmd.manager:main
    ryu = ryu.cmd.ryu_base:main

```
其中[entry_points]项，指定其程序入口，安装后可使用ryu-manager命令，即执行ryu.cmd.manager中的main函数。
