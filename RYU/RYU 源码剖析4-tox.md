https://www.jianshu.com/p/20fdae9f8ab1


Tox - 使用介绍

###  概述
tox是通用的虚拟环境管理和测试命令行工具。tox能够让我们在同一个Host上自定义出多套相互独立且隔离的python环境（tox是openstack社区最基本的测试工具，比如python程序的兼容性、UT等）。它的目标是提供最先进的自动化打包、测试和发布功能。

作为持续集成服务器的前端，大大减少测试工作所需时间；
检查软件包能否在不同的python版本或解释器下正常安装；
在不同的环境中运行测试代码。
### 使用介绍
1. 安装
$ pip install tox

2. 创建tox测试项目
项目目录
$ tree .
.
├── requirements.txt
├── src
│   ├── app.py
│   ├── app.pyc
│   ├── __init__.py
│   └── __init__.pyc
├── tests
│   ├── __init__.py
│   ├── __init__.pyc
│   └── test_app.py
└── tox.ini

2 directories, 9 files

**src/app.py**
```
from math import fabs, ceil

def math_fabs(x):
    return fabs(x)

def math_ceil(x):
    return ceil(x)

if __name__ == '__main__':
    print math_fabs(-1.2)
    print math_ceil(-2.3)
```

**tests/test_app.py**
```
# -*- coding:utf-8 -*-

import pytest
from src.app import math_fabs, math_ceil

def test_math_fabs():
    assert math_fabs(-1.2) == 1.2
    assert math_fabs(0) == 0
    assert math_fabs(2.4) == 2.4

def test_math_ceil():
    assert math_ceil(-1.2) == -1
    assert math_ceil(0) == 0
    assert math_ceil(2.4) == 3
```

**tox.ini**
```
[tox]
envlist = py27
skipsdist = True
indexserver =
    default = https://pypi.doubanio.com/simple


[testenv]
install_command = pip install -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com {opts} {packages}
deps =
    -rrequirements.txt
commands = coverage erase
           py.test --cov={toxinidir}/src -sx tests
           coverage html
setenv =
    PYTHONPATH = {toxinidir}/py27

[testenv:dev]
deps = pytest
commands = {posargs:py.test}
```

* skipsdist，tox默认会使用sdist构建包，对于测试来说没有必要，而且构建还会要求存在README、setup.py等文件，并且保证setup.py的格式符合要求等，所以跳过此步
* [testenv]，默认的集成方案
* [testenv:dev]，非默认的集成方案，需要使用tox -e dev才能invoke
* deps = pytest，集成需要的依赖
* commands = {posargs:py.test}，可以把调用的命令的参数通过posargs传给tox来使用
* commands = coverage erase
py.test --cov={toxinidir}/src -sx tests
coverage html
相当于执行三步
* install_command = pip install -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com {opts} {packages}
安装需要的依赖包，替换原有的安装命令
* setenv =
PYTHONPATH = {toxinidir}/py27
设置python程序运行的环境变量

requirements.txt
```
pytest==3.0.0
mock==2.0.0
coverage==4.1
pytest-cov==2.0
pytest-randomly==1.0.0
pytest-mock==1.2
```
2.3. 测试执行

$ tox
```
py27 installed: bumpversion==0.5.3,click==6.7,coverage==4.1,Flask==0.12.2,funcsigs==1.0.2,itsdangerous==0.24,Jinja2==2.10,MarkupSafe==1.0,mock==2.0.0,pbr==4.0.1,py==1.5.3,pytest==3.0.0,pytest-cov==2.0.0,pytest-mock==1.2,pytest-randomly==1.0.0,six==1.11.0,Werkzeug==0.14.1
py27 runtests: PYTHONHASHSEED='1191855235'
py27 runtests: commands[0] | coverage erase
py27 runtests: commands[1] | py.test --cov=/home/kevin/learn/python-web/tox/src -sx tests
============================================================================== test session starts ===============================================================================
platform linux2 -- Python 2.7.12, pytest-3.0.0, py-1.5.3, pluggy-0.3.1
Using --randomly-seed=1522848244
rootdir: /home/kevin/learn/python-web/tox, inifile:
plugins: randomly-1.0.0, mock-1.2, cov-2.0.0
collected 2 items

tests/test_app.py ..
---------------------------------------------------------------- coverage: platform linux2, python 2.7.12-final-0 ----------------------------------------------------------------
Name              Stmts   Miss  Cover
-------------------------------------
src/__init__.py       0      0   100%
src/app.py            8      2    75%
-------------------------------------
TOTAL                 8      2    75%

============================================================================= pytest-warning summary =============================================================================
WC1 None pytest_funcarg__cov: declaring fixtures using "pytest_funcarg__" prefix is deprecated and scheduled to be removed in pytest 4.0.  Please remove the prefix and use the @pytest.fixture decorator instead.
================================================================== 2 passed, 1 pytest-warnings in 0.02 seconds ===================================================================
py27 runtests: commands[2] | coverage html
____________________________________________________________________________________ summary _____________________________________________________________________________________
  py27: commands succeeded
  congratulations :)
```

备注：
在tox.ini配置[testenv:dev]，可以执行tox -e dev，完成指定虚拟环境dev的test。

$ tox -e dev
```
dev recreate: /home/kevin/learn/python-web/tox/.tox/dev
dev installdeps: pytest
dev installed: attrs==17.4.0,funcsigs==1.0.2,more-itertools==4.1.0,pluggy==0.6.0,py==1.5.3,pytest==3.5.0,six==1.11.0
dev runtests: PYTHONHASHSEED='487614162'
dev runtests: commands[0] | py.test
============================================================================== test session starts ===============================================================================
platform linux2 -- Python 2.7.12, pytest-3.5.0, py-1.5.3, pluggy-0.6.0
rootdir: /home/kevin/learn/python-web/tox, inifile:
collected 2 items

tests/test_app.py ..                                                                                                                                                       [100%]

============================================================================ 2 passed in 0.01 seconds ============================================================================
____________________________________________________________________________________ summary _____________________________________________________________________________________
  dev: commands succeeded
  congratulations :)
```
