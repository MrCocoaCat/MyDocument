### tools
tools为运行ryu提供相关适配脚本，install_venv.py提供虚拟环境的安装脚本,
intall_venv.py 的main函数如下

```
def main(argv):
    # 检查以来，是否已安装Virtualenv
    check_dependencies()
    # 创建虚拟环境
    create_virtualenv()
    # 安装依赖包
    install_dependencies()
    print_help()
```
1. 首先进行环境检查，环境检查函数的实现也比较简单
```
def check_dependencies():
    """Make sure virtualenv is in the path."""

    if not HAS_VIRTUALENV:
        raise Exception('Virtualenv not found. ' + \
                         'Try installing python-virtualenv')
    print 'check_dependencies done.'

```

其中
```
HAS_VIRTUALENV = bool(run_command(['which', 'virtualenv'],
                                    check_exit_code=False).strip())
```

2. 这里要注意一个run_command 函数，这个函数是执行系统shell 命令

```
ROOT = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

def run_command(cmd, redirect_output=True, check_exit_code=True):
    """
    Runs a command in an out-of-process shell, returning the
    output of that command.  Working directory is ROOT.
    执行命令，在一个程序外的shell进程,
    执行目录为ROOT
    """
    # subprocess模块用于产生子进程
    # 如果参数为redirect_output ，则创建PIPE
    if redirect_output:
        stdout = subprocess.PIPE
    else:
        stdout = None
    # cwd 参数指定子进程的执行目录为ROOT，执行cwd 函数
    proc = subprocess.Popen(cmd, cwd=ROOT, stdout=stdout)

    # 如果子进程输出了大量数据到stdout或者stderr的管道，
    # 并达到了系统pipe的缓存大小的话，
    # 子进程会等待父进程读取管道，而父进程此时正wait着的话，将会产生死锁。
    # Popen.communicate()这个方法会把输出放在内存，而不是管道里，
    # 所以这时候上限就和内存大小有关了，一般不会有问题

    output = proc.communicate()[0]
    if check_exit_code and proc.returncode != 0:
        # 程序不返回0，则失败
        raise Exception('Command "%s" failed.\n%s' % (' '.join(cmd), output))
    return output
```

3. create_virtualenv 用于创建 virtualenv 环境
```
virtualenv -q venv
```
