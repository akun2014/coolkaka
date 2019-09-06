---
title: Spring-IOC-循环依赖
date: 2019-08-12 17:13:12
tags:
---
# ioc中循环依赖的处理

## spring处理循环依赖的数据基础

   > spring ioc只能处理singleton类型bean的循环依赖，无法处理prototype以及构造器循环依赖


```(java)
    /** Cache of singleton objects: bean name to bean instance. */
	private final Map<String, Object> singletonObjects = new ConcurrentHashMap<>(256);

	/** Cache of singleton factories: bean name to ObjectFactory. */
	private final Map<String, ObjectFactory<?>> singletonFactories = new HashMap<>(16);

    /** Cache of early singleton objects: bean name to bean instance. */
    private final Map<String, Object> earlySingletonObjects = new HashMap<>(16);

```

+ singletonObjects

  一级缓存
  
+ singletonFactories

  二级缓存

+ earlySingletonObjects

  三级缓存