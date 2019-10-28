---
title: MySQL数据库知识点
abbrlink: 1d5d1d67
tags:
  - 数据库
  - MySQL
date: 2019-08-12 17:13:12
---

> MySQL基础知识点罗列，作为一个字典查看

# MySQL数据类型
1. 数字类型  
     * 整型  
   TINYINT  
   1Btyes  符号值：-128~127 无符号：0~255   
   SMALLINT  
   2Btyes 符号值：-32768~32767 无符号：0~65535  
   MEDIUMINT   
   3Btyes 符号值：-8388608~8388607 无符号：0~16777215   
   INT   
   4Btyes 符号值：-12147483648~2147483674 无符号：0~4294967295    
   BIGINT   
   8Btyes  符号值：-2^64~-2^64-1 无符号：0~2^64  
   * 浮点型  
   FLOAT 4Bytes  
   DOUBLE 8Bytes  
   DECIMAL   
   用法DECIMAL(M,D) M取值：[1-65] D取值：[0-30] 且M > D
2. 字符串类型  
  TEXT 适合存文本、BLOB适合存二进制数据  
TINYTEXT,TINYBLOB 2^8-1 Bytes  
TEXT, BLOB 2^16-1Bytes  
MEDIUMTEXT,MEDIUMBLOB 2^24-1Bytes  
LONGTEXT,LONGBLOB 2^32-1Bytes  
  1. 日期和时间类型  
DATE 1000-01-01 ~ 9999-12-31  
TIME -838:58:59 ~ 838:59:59  
DATETIME  1000-01-01 00:00:00 ~ 9999-12-31 23:59:59  
TIMESTAMP 1970-07-01 00:00:00  
YEAR 1901~2155
# MySQL运算符

`+, -, *, /, % ,=, >, <, !=, <> ,>=, <= ,` `IS NULL, IS NOT NULL ,BETWEEN AND , IN,NOT IN, LIKE ,NOT LIKE,REGEXP` `&& , AND , ! , NOT , || ,OR ,XOR`

# 常用关键字
`CREATE DATABASE,SHOW DATABASES,USE DATABASE,DROP DATABASE,CREATE TABLE,DESCRIBE,ALTER TABLE,RENAME TABLE,DROP TABLE,INSERT , UPDATE ,DELETE ,SELECT,DISTINCT , ORDER BY ,GROUP BY ,LIMIT,EXISTS,NOT EXISTS `  

# MySQL连接查询 
 内连接：INNER JOIN  
 外连接查询：LEFT JOIN,RIGHT JOIN  
 联合查询：UNION,UNION ALL  

 # MySQL函数
 
 数学函数  
 ABX(x),CELL(x),FLOOR(x),RAND(x),RAND(),TURNCATE(x,y),ROUND(x),ROUND(x,y)  
 字符串函数 
 UPPER(s),LOWER(s),LEFT(s),LTRIM(s),RIGHT(s),RTRIM(s),SUBSTRING(s,n,len),REVERSER(s) ,CONCAT(s1,s2,...)  
 日期函数  
 CURDATE(),CURTIME(),NOW(),DATEDIFF(d1,d2),ADDDATE(d,INTERVAL expr type)
 SUBDATE(d,n)


# 连接器
管理连接，权限认证。每个客户端连接都会在服务器进程中拥有一个线程，这个连接的查询只会在这个单独的线程中执行。服务器会缓存线程，因此不需要为每一个连接创建或者销毁线程。客户端连接到服务器时，服务器需要对其进行认证。
# 查询缓存
缓存数据。服务器会把查询到的数据缓存起来，下一个请求如果在缓存中能拿到数据，就直接返回给客户端。
# 分析器
词法分析、语法分析。服务器会解析查询，并生成解析树
# 优化器
执行计划生成、索引选择。服务器生成解析树后，会对其进行各种优化，包括重写查询，决定表的读取顺序，以及选择合适的索引等。
# 执行器
操作引擎，返回结果
# 存储引擎
存储数据，提供读写接口

# 多版本并发控制 Multiversion Concurrency Control

# 事务
4大特性：原子性、一致性、隔离性、持久性  
隔离级别:读未提交、读提交、可从复读、可串行化
# 锁
读锁、写锁、表锁、行级锁
# 存储引擎 
InnoDB MyISAM
