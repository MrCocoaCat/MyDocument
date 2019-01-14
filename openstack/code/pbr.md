https://docs.openstack.org/pbr/latest/user/features.html
### pbr - Python Build Reasonableness

用于以一致的方式管理setuptools打包需求的库。
pbr读取然后通过setup钩子过滤setup.cfg数据以填充默认值并提供更合理的行为，然后将结果作为调用setup.py的参数 - 因此处理Python包装的繁重工作依旧由setuptools完成。
请注意，我们不支持setuptools的easy_install功能：虽然我们依赖setup_requires，但对于任何install_requires，我们建议在运行setup.py install之前安装它们 - 手动或使用安装工具（如pip）。

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

#### Features
要了解pbr能为您做些什么，最好看两个项目：一个使用纯setuptools，另一个使用pbr。 首先，我们来看看setuptools项目。
```
$ tree -L 1
.
├── AUTHORS
├── CHANGES
├── LICENSE
├── MANIFEST.in
├── README.rst
├── requirements.txt
├── setup.cfg
├── setup.py
└── somepackage

$ cat setup.py
setuptools.setup(
    name='mypackage',
    version='1.0.0',
    description='A short description',
    long_description="""A much longer description...""",
    author="John Doe",
    author_email='john.doe@example.com',
    license='BSD',
)
```
这是一个使用pbr的类似包：
```
$ tree -L 1
.
├── LICENSE
├── README.rst
├── setup.cfg
├── setup.py
└── somepackage

$ cat setup.py
setuptools.setup(
    pbr=True
)

$ cat setup.cfg
[metadata]
name = mypackage
description = A short description
description-file = README.rst
author = John Doe
author-email = john.doe@example.com
license = BSD
```

由此，我们注意到pbr的几个主要特征：

* 广泛使用setup.cfg进行配置
* 自动包元数据生成（版本）
* 自动生成元数据文件（AUTHOR，ChangeLog，MANIFEST.in，RELEASENOTES.txt）
此外，还有其他一些你在这里看不到的东西，但是pbr会帮助你完成的功能：
* setuptools命令的有用扩展

#### setup.cfg
distutils2的一个主要特性是使用了setup.cfg INI风格的配置文件。 这用于定义包的元数据和通常提供给setup（）函数的其他选项。

#### Package Metadata
