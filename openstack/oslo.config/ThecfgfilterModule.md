### The cfgfilter Module
ConfigFilter类有三个用例:
1. 帮助强制指定的模块不访问其他模块注册的选项，而不首先使用import_opt()声明那些跨模块的依赖项。
2. 防止私有配置选项对注册它的模块以外的模块可见。
3. 限制可以访问的Cfg对象的选项。
