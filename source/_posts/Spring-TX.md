---
title: Spring-TX
date: 2019-08-12 17:13:12
tags:
---
# Spring的事务实现原理

## **关于事务的一些概念**

## 事务的四大特性 ACID

+ 原子性 atomicity
+ 一致性 consistency
+ 隔离性 isolation
+ 持久性 durability

## 事务属性

+ 隔离性

> 定义了一个事务可能受其他并发事务影响的程度

+ 传播行为

> 为了解决业务层方法之间互相调用的事务问题

+ 回滚规则

> 这些规则定义了哪些异常会导致事务回滚而哪些不会

+ 是否只读属性
+ 事务超时

### 事务属性之隔离级别

+ READ_UNCOMMITTED

> A constant indicating that dirty reads, non-repeatable reads and phantom reads can occur. This level allows a row changed by one transaction to be read by another transaction before any changes in that row have been committed (a "dirty read"). If any of the changes are rolled back, the second transaction will have retrieved an invalid row.

+ READ_COMMITTED

> A constant indicating that dirty reads are prevented; non-repeatable reads and phantom reads can occur. This level only prohibits a transaction from reading a row with uncommitted changes in it.

+ REPEATABLE_READ

> A constant indicating that dirty reads and non-repeatable reads are prevented; phantom reads can occur. This level prohibits a transaction from reading a row with uncommitted changes in it, and it also prohibits the situation where one transaction reads a row, a second transaction alters the row, and the first transaction rereads the row, getting different values the second time (a "non-repeatable read")

+ SERIALIZABLE

> A constant indicating that dirty reads, non-repeatable reads and phantom reads are prevented. This level includes the prohibitions in TRANSACTION_REPEATABLE_READ and further prohibits the situation where one transaction reads all rows that satisfy a WHERE condition, a second transaction inserts a row that satisfies that WHERE condition, and the first transaction rereads for the same condition, retrieving the additional "phantom" row in the second read.

### 事务属性之事务传播行为

#### 支持当前事务的情况：

+ PROPAGATION_REQUIRED

> 如果当前存在事务，则加入该事务。如果当前不存在事务，则创建一个事务。

+ PROPAGATION_SUPPORTS

> 如果当前存在事务，则加入该事务。如果当前不存在事务，则以非事务的方式继续运行。

+ PROPAGATION_MANDATORY（mandatory：强制性）

> 如果当前存在事务，则加入该事务。如果当前不在事务，则抛出异常。

#### 不支持当前事务：

+ PROPAGATION_REQUIRES_NEW

> 如果当前存在事务，则挂起当前事务。如果当前不存在事务，这创建一个新事务。

+ PROPAGATION_NOT_SUPPORTED

> 如果当前存在事务，则挂起当前事务。如果当前不存在事务，则以非事务运行。

+ PROPAGATION_NEVER

以非事务的方式运行，如果当前存在事务，则抛出异常。

#### 其他情况：

+ PROPAGATION_NESTED

> 如果当前存在事务，则创建一个新事务作为当前事务的嵌套事务来运行。如果当前没有事务，这该值等价于PROPAGATION_REQUIRED

--------

## **spring事务抽象中重要的类**

1.PlatformTransactionManager

事务管理器. 常用的事务管理器

+ DataSourceTransactionManager

```(java)
public interface PlatformTransactionManager {
    //根据当前指定的事务传播行为，返回当前事务或者开启一个新事务
    TransactionStatus getTransaction(TransactionDefinition definition);
    void commit(TransactionStatus status);
    void rollback(TransactionStatus status);
}
```

+ HibernateTransactionManager
+ JtaTransactionManager

2.TransactionDefinition

定义事务属性，例如隔离级别、传播行为、是否只读、超时时间等

 ```(java)

public interface TransactionDefinition {
    // 返回事务的传播行为
    int getPropagationBehavior();
    // 返回事务的隔离级别，事务管理器根据它来控制另外一个事务可以看到本事务内的哪些数据
    int getIsolationLevel();
    // 返回事务必须在多少秒内完成
    int getTimeout();
    //返回事务的名字
    String getName();
    // 返回是否优化为只读事务。
    boolean isReadOnly();
}
```

3.TransactionStatus

当前事务状态抽象

```(java)

public interface TransactionStatus{
    //是否是新事务
    boolean isNewTransaction();
    //是否有恢复点
    boolean hasSavepoint();
    //设置为只回滚
    void setRollbackOnly();
    //是否为只回滚
    boolean isRollbackOnly();
    //是否已经完成
    boolean isCompleted;
}
```