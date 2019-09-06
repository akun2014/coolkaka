
---
title: Spring-IOC
date: 2019-08-12 17:13:12
tags:
---
# Spring IOC

## Spring IOC容器初始化

1. 资源定位

   由ResourceLoader通过统一的Resource接口来完成。常用的Resource实现 [ResourceTest](https://github.com/akun2014/TestJDK/blob/master/src/main/java/com/gk/spring/ioc/ResourceTest.java)

2. 资源载入、解析

   这个过程是把用户定义的Bean表示成IOC容器内部的数据结构，而这个容器内部的数据结构就是BeanDefinition
   具体实现见 BeanDefinitionDocumentReader、XMLBeanDefinitionReader、
ClassPathBeanDefinitionScanner用于处理注解Bean定义
   [BeanDefinitionReaderTest](https://github.com/akun2014/TestJDK/blob/master/src/main/java/com/gk/spring/ioc/BeanDefinitionReaderTest.java) [BeanDefinitionTest](https://github.com/akun2014/TestJDK/blob/master/src/main/java/com/gk/spring/ioc/BeanDefinitionTest.java)

3. BeanDefinition注册

   把载入过程中解析得到的BeanDefinition向IOC容器支持
   具体实现见 BeanDefinitionRegistry DefaultListableBeanFactory

## Spring IOC容器的依赖注入

1. 依赖注入  BeanWrapper

   + bean的实例化
   + 参数解析
   + 依赖关系处理

![applicationContext类继承](https://github.com/akun2014/TestJDK/blob/master/docs/spring/ioc/SpringIoc.png)

![关键类](https://github.com/akun2014/TestJDK/blob/master/docs/spring/ioc/Spring_IOC%E6%80%9D%E7%BB%B4%E5%AF%BC%E5%9B%BE.png)