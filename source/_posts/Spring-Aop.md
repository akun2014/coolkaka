---
title: Spring-Aop
tags:
  - spring
  - aop
abbrlink: 39dd5a04
date: 2019-08-12 17:13:12
---
# 几个重要类和接口

## Advice 通知

+ MethodBeforeAdvice

+ AfterReturningAdvice

+ ThrowsAdvice

## Pointcut  切面

+ AspectJExpressionPointcut
+ NameMatchMethodPointcut
+ AnnotationMatchingPointcut
+ ComposablePointcut

## Advisor  切面通知器

+ RegexpMethodPointcutAdvisor
+ AspectJExpressionPointcutAdvisor
+ NameMatchMethodPointcutAdvisor
+ DefaultBeanFactoryPointcutAdvisor

## MethodInterceptor 方法拦截器

+ AfterReturningAdviceInterceptor
+ MethodBeforeAdviceInterceptor
+ ThrowsAdviceInterceptor

## AopProxyFactory

+ DefaultAopProxyFactory

## AopProxy  完成对目标方法的代理

+ JdkDynamicAopProxy 

   > ReflectiveMethodInvocation  完成对拦截器链的调用

+ CglibAopProxy

   > CglibMethodInvocation 完成对拦截器链的调用

## AdvisorChainFactory

+ DefaultAdvisorChainFactory

## AdvisorAdapter

+ AfterReturningAdviceAdapter
+ MethodBeforeAdviceAdapter
+ ThrowsAdviceAdapter