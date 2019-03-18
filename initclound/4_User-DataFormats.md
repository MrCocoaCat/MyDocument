### User-Data Formats
将由cloud-init执行的用户数据必须采用以下类型之一。

### Gzip 压缩的数据(Gzip Compressed Content)
发现压缩为gzip的内容将被解压缩。 然后将使用未压缩的数据，就好像它没有被压缩一样。这通常很有用，因为用户数据限制在~16384个字节。
### Mime多部件档案(Mime Multi Part Archive)
此规则列表适用于此多部分文件的每个部分。 使用mime-multi part文件，用户可以指定多种类型的数据。例如，可以指定用户数据脚本和cloud-config类型。支持的内容类型

* text/x-include-once-url
* text/x-include-url
* text/cloud-config-archive
* text/upstart-job
* text/cloud-config
* text/part-handler
* text/x-shellscript
* text/cloud-boothook

#### Helper script to generate mime messages
```
#!/usr/bin/python

import sys

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

if len(sys.argv) == 1:
    print("%s input-file:type ..." % (sys.argv[0]))
    sys.exit(1)

combined_message = MIMEMultipart()
for i in sys.argv[1:]:
    (filename, format_type) = i.split(":", 1)
    with open(filename) as fh:
        contents = fh.read()
    sub_message = MIMEText(contents, format_type, sys.getdefaultencoding())
    sub_message.add_header('Content-Disposition', 'attachment; filename="%s"' % (filename))
    combined_message.attach(sub_message)

print(combined_message)
```

### User-Data Script
通常由那些只想执行shell脚本的人使用。
```
$ cat myscript.sh

#!/bin/sh
echo "Hello World.  The time is now $(date -R)!" | tee /root/output.txt

$ euca-run-instances --key mykey --user-data-file myscript.sh ami-a07d95c9
```
以 #! 或者 Content-Type: text/x-shellscript 开头，when using a MIME archive

### Include File
此内容是包含文件。

该文件包含一个网址列表，每行一个。 将读取每个URL，并且它们的内容将通过同一组规则传递。 即，从URL读取的内容可以是gzip，mime-multi-part或纯文本。 如果读取文件时发生错误，则不会读取剩余文件。

以 #include 或者 Content-Type: text/x-include-url 开头，when using a MIME archive.

### Cloud Config Data
**重要**
Cloud-config是通过用户数据完成某些事情的最简单方法。 使用cloud-config语法，用户可以以人性化的格式指定某些内容。
这些东西包括：
* apt升级应该在首次启动时运行
* 应该使用不同的apt镜像
* 应该增加额外的资源
* 应导入某些ssh密钥
* 还有很多…

https://cloudinit.readthedocs.io/en/latest/topics/examples.html#yaml-examples

以 #cloud-config 或者 Content-Type: text/cloud-config开头， when using a MIME archive.

### Upstart Job
内容被放入/etc/init中的文件中，并且将被upstart用作任何其他upstart作业。

以 #upstart-job 或 Content-Type: text/upstart-job 开头，when using a MIME archive.


### Cloud Boothook
这个内容是boothook数据。
它存储在/var/lib/cloud下的文件中，然后立即执行。
这是最早的钩子。 请注意，没有提供仅运行一次的机制。
展位必须自己处理。 它在环境变量INSTANCE_ID中提供了实例id。
这可以用于提供“每实例一次”类型的功能。

以 #cloud-boothook 或  Content-Type: text/cloud-boothook 开头，when using a MIME archive.

### Part Handler

这是一个部分处理程序：它包含自定义代码，用于支持多部分用户数据中的新mime类型，或覆盖支持的mime类型的现有处理程序。
它将根据其文件名（生成）写入/var/lib/cloud/data中的文件。
这必须是包含list_types函数和handle_part函数的python代码。
读取该部分后，将调用list_types方法。 它必须返回此部分处理程序处理的mime类型列表。
因为mime部分是按顺序处理的，所以部分处理程序部分必须位于任何部分之前，并且mime类型应该在相同的用户数据中处理。

The handle_part function must be defined like:
```
def handle_part(data, ctype, filename, payload):
  # data = the cloudinit object
  # ctype = "__begin__", "__end__", or the mime-type of the part that is being handled.
  # filename = the filename of the part (or a generated filename if none is present in mime data)
  # payload = the parts' content
```

然后，Cloud-init将在处理任何部件之前调用handle_part函数一次，每个部件接收一次，并且在处理完所有部件之后调用一次。 '__begin__'和'__end__'标记允许零件处理程序在接收任何零件之前或之后进行初始化或拆卸。


```
#part-handler
# vi: syntax=python ts=4

def list_types():
    # return a list of mime-types that are handled by this module
    return(["text/plain", "text/go-cubs-go"])

def handle_part(data,ctype,filename,payload):
    # data: the cloudinit object
    # ctype: '__begin__', '__end__', or the specific mime-type of the part
    # filename: the filename for the part, or dynamically generated part if
    #           no filename is given attribute is present
    # payload: the content of the part (empty for begin or end)
    if ctype == "__begin__":
       print "my handler is beginning"
       return
    if ctype == "__end__":
       print "my handler is ending"
       return

    print "==== received ctype=%s filename=%s ====" % (ctype,filename)
    print payload
    print "==== end ctype=%s filename=%s" % (ctype, filename)
```
