---
title: JavaCore-HashMap源码解析
date: 2019-08-25 18:40:30
tags: [collection]
categories: [java,java-core]
---

# HashMap

> 基于jdk1.8.0_77

The default initial capacity - MUST be a power of two.
默认的初始化容量，并且必须是2的幂

```
 static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16  
```

The load factor used when none specified in constructor.
默认负载英子

```
    static final float DEFAULT_LOAD_FACTOR = 0.75f;
```

The next size value at which to resize (capacity * load factor).
扩容阀值=容量 * 负载因子
```
    int threshold;
```
 
The load factor for the hash table.
当前负载因子
 ```
    final float loadFactor;
 ```
 
The bin count threshold for using a tree rather than list for a bin. Bins are converted to trees when adding an element to a bin with at least this many nodes. The value must be greater than 2 and should be at least 8 to mesh with assumptions in tree removal about conversion back to plain bins upon shrinkage.
 ```
static final int TREEIFY_THRESHOLD = 8;
 ```
 The bin count threshold for untreeifying a (split) bin during a resize operation. Should be less than TREEIFY_THRESHOLD, and at most 6 to mesh with shrinkage detection under removal.
  ```
 static final int UNTREEIFY_THRESHOLD = 6;
  ```
  The smallest table capacity for which bins may be treeified. (Otherwise the table is resized if too many nodes in a bin.) Should be at least 4 * TREEIFY_THRESHOLD to avoid conflicts between resizing and treeification thresholds.
  ```
   static final int MIN_TREEIFY_CAPACITY = 64;
  ```
  
  * 链表转红黑树
  * 多线程情况下出现死循环
  * put/get/remove方法
  * 1.7版本与1.8版本实现上的区别
