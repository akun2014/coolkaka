
---
title: spring容器中重要数据结构BeanDefinition
date: 2019-08-12 17:13:12
tags:
---
# BeanDefinition

A BeanDefinition describes a bean instance

+ GenericBeanDefinition

> 使用xml格式声明的bean会被解析为此实现

+ ScannedGenericBeanDefinition

> 通过注解形式（例如@Service @Component @Repository @Controller）会被解析为此实现

+ AnnotatedGenericBeanDefinition

> 通过@Bean注解会被解析为此实现

# BeanDefinitionRegistry

hold bean definitions

+ DefaultListableBeanFactory

+ GenericApplicationContext