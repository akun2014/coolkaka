---
title: jvm类加载机制
date: 2019-08-12 17:13:12
tags: [jvm]
categories: jvm
---
![](https://myblog-coolkaka.oss-cn-shanghai.aliyuncs.com/network/jvm%E7%B1%BB%E5%8A%A0%E8%BD%BD.png)

## 类的加载
1. 加载
把.class文件加载到内存中(以byte[]表示一个class文件)
1. 验证
验证class文件的合法性
1. 准备
为类变量分配内存，并赋予该基本类型的初始值（如int类型赋予0）。类变量就是被static修饰的变量。如果类变量还被final修饰，那在准备阶段就会赋予开发人员指定的初始值。
1. 解析
把符号引用替换为直接引用。即把符号引用转换为内存中的地址，使得方法调用更高效
1. 初始化
调用<clinit>方法，完成类的初始化工作。相当于执行代码中static代码块。

## Java虚拟机在何时加载类？

* 遇到new,getstatic,putstatic,invokestatic这4条字节码指令。即使用new关键字创建对象；访问或者赋值某个类或者接口的静态变量，调用类的静态方法
* 通过反射创建类
* 初始化一个类的子类
* Java虚拟机启动时被表明为启动类的类
* java.lang.invoke.MethodHandle的解析结果REF_getStatic,REF_putStatic,REF_invokeStatic，它们的方法句柄所对应的类没有进行过初始化

## 类的加载机制

Java通过类加载器加载类，并且jvm中存在多个类加载器，他们通过组合的方式，保持着一种层级关系，这些类加载器通过如下机制来加载类:

The Java platform uses a delegation model for loading classes. The basic idea is that every class loader has a "parent" class loader. When loading a class, a class loader first "delegates" the search for the class to its parent class loader before attempting to find the class itself.

> java平台采用委托模式来加载类。每一个类加载器都有一个称之为"parent"的加载器。当加载类的时候，类加载器在尝试加载类之前，会先委托给他的父加载器加载。当父加载无法完成类加载时，才会自己来加载类。

Here are some highlights of the class-loading API:

* Constructors in java.lang.ClassLoader and its subclasses allow you to specify a parent when you instantiate a new class loader. If you don't explicitly specify a parent, the virtual machine's system class loader will be assigned as the default parent.

> 通过构造方法，可以指定一个类加载器的父加载器。如果没有特别指定，jvm虚拟机的系统加载器会被指定为默认的父加载器。（一般是AppClassLoader）

* The loadClass method in ClassLoader performs these tasks, in order, when called to load a class:

     1. If a class has already been loaded, it returns it.

> 当class已经被加载过，直接返回

     1. Otherwise, it delegates the search for the new class to the parent class loader.
     
> 否则，委托给父加载器去加载

    1. If the parent class loader does not find the class, loadClass calls the method findClass to find and load the class.
    
> 如果父加载器无法加载该class，加载器会调用findClass去加载该class

* The findClass method of ClassLoader searches for the class in the current class loader if the class wasn't found by the parent class loader. You will probably want to override this method when you instantiate a class loader subclass in your application.

> 如果你想实现自己的类加载器，你应该重写ClassLoader的findClass方法


* The class java.net.URLClassLoader serves as the basic class loader for extensions and other JAR files, overriding the findClass method of java.lang.ClassLoader to search one or more specified URLs for classes and resources.

## tomcat中的类加载器

![](https://myblog-coolkaka.oss-cn-shanghai.aliyuncs.com/network/Java%E7%B1%BB%E5%8A%A0%E8%BD%BD%E6%9C%BA%E5%88%B6.png)

tomcat为什么需要实现自己的类加载器？先从tomcat在设计时需要考虑的问题着手。

1. tomcat可以允许多个Web应用程序同时运行，如果不同Web应用中存在同名的类，但是它们的功能一样，Tomcat需要加载和管理这两个同名类，保证它们不冲突，因此Web应用之间的需要隔离

1. 假如Web应用都依赖相同的第三方jar包，比如Spring。如果所有的Web应用都加载相同的第三方jar包，那将会使jvm内存膨胀，所以Tomcat需要保证相同的第三方jar包可以在不同的Web应用程序之间共享

1. Tomcat本身也是一个应用程序，Tomcat本身的类也需要和web应用的类隔离

要解决如上几个问题，Tomcat实现了自己的类加载器

1. 第一个问题：我们知道每一个Web应用都是一个独立的Context容器，而Context容器会负责创建和维护一个WebAppClassLoader实例。这背后的原理是，不同的类加载器实例加载的类会被jvm认为是不同的类，即使他们的类名相同。这相当于在jvm内部创建了一个个相互隔离的Java类空间，每个Web应用都有自己的类空间，Web应用中间通过各自的类加载器互相隔离。
2. 第二个问题：为了达到共享，让共享的类都由相同的类加载器去加载这些类即可。因此Tomcat设计者加了一个Shared ClassLoader，作为WebAppClassLoader的父加载器，专门用来加载Web应用中间共享的类。
3. 第三个问题：要共享可以通过父子关系，要隔离就需要兄弟关系。因此Tomcat设计者加入了和Shared ClassLoader平级的Server ClassLoader，专门用来加载Tomcat自身的类。

现在，Web应用之间有WebAppClassLoader做类隔离，有Shared ClassLoader做类共享；Tomcat和应用之间有Server ClassLoader和Shared ClassLoader做类隔离，那Tomcat和Web应用之间如何做类共享呢？Tomcat增加了一个Common ClassLoader作为Server ClassLoader和Shared ClassLoader的父加载器，Common ClassLoader加载的类都可以被Server ClassLoader和Shared ClassLoader使用。这样就做到了Tomcat和Web应用之间共享类。

## 线程上下文加载器
最后还要说一下线程上下文加载器。为什么会有线程上下文加载器，它用来解决什么样的实际问题呢？
