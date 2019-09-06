---
title: JVM
date: 2019-08-12 17:13:12
tags: [java,jvm]
categories: JVM
---
* 内存结构
  
  1. 程序计数器
  2. Java虚拟机栈
  3. 本地方法栈
  4. Java堆
  5. 方法区
  6. 运行时常量池
  7. 直接内存

* 内存分配
* 垃圾回收算法
   
  如何判断对象已死
  1. 引用计数算法
  2. 可达性分析算法

  垃圾搜集算法
  1. 标记清除算法
  2. 复制算法
  3. 标记-整理算法
  4. 分代收集算法
* 垃圾回收器
  
  ParNew CMS
* 类加载机制

  * classLoader、类加载过程、双亲委派（破坏双亲委派）、模块化（osgi）
* javac 前期编译优化

  * 解语法糖、解析与填充符号表、语义分析与字节码生成
  * 类加载步骤：加载-> 验证 -> 准备 -> 解析 -> 初始化

  > 验证：验证class文件合法性

  > 准备：class的初始化

  > 解析：符号应用转为直接引用

  > 初始化：对象实例化
* JIT运行时编译优化
* class文件结构
* Java内存模型
* jvm常用参数已经调优
* jvm性能监控与故障处理工具

  * jps, jstack, jmap、jstat, jconsole, jinfo, jhat, javap, btrace、TProfiler