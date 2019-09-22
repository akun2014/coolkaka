---
title: CGLIB
abbrlink: 1f5b1554
date: 2019-08-12 17:13:12
tags:
categories:
---
[github](https://github.com/cglib/cglib)



# CGLIB原理
动态生成一个要代理类的子类，子类重写要代理的类的所有不是final的方法。在子类中采用方法拦截的技术拦截所有父类方法的调用，顺势织入横切逻辑
# CGLIB底层
使用字节码处理框架ASM，来转换字节码并生成新的类。不鼓励直接使用ASM，因为它要求你必须对JVM内部结构包括class文件的格式和指令集都很熟悉。

# CGLIB包结构

> net.sf.cglib.core 底层字节码处理类，大部分与ASM有关系。

> net.sf.cglib.transform 编译期或运行期类和类文件的转换

> net.sf.cglib.proxy 实现创建代理和方法拦截器的类

> net.sf.cglib.reflect 实现快速反射和C#风格代理的类

> net.sf.cglib.util 集合排序等工具类

> net.sf.cglib.beans JavaBean相关的工具类


## net.sf.cglib.proxy包下常用类

* Callback 及其子类
    * MethodInterceptor 拦截器
    * LazyLoader
    * Dispatcher
    * InvocationHandler
    * FixedValue

    LazyLoader、Dispatcher都用于延迟加载对象。不同之处是，LazyLoader只在第一次访问延迟加载属性时触发代理类回调方法，而Dispatcher在每次访问延迟加载属性时都会触发代理类回调方法

* CallbackFilter 回调过滤器
  回调时可以设置对不同方法执行不同的回调逻辑，或者根本不执行回调

  [CgLibProxyTest](https://github.com/akun2014/TestJDK/tree/master/src/main/java/com/gk/proxy/cglib)
