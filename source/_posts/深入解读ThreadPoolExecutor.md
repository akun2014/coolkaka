---
title: 深入解读ThreadPoolExecutor
date: 2019-08-15 14:21:36
tags: java
---
# 深入解读ThreadPoolExecutor

先来看看如何构造一个ThreadPoolExecutor

```java
private static final ThreadPoolExecutor threadPool = new ThreadPoolExecutor(50, 100, 10L,
            TimeUnit.SECONDS, new LinkedBlockingDeque<>(), 
            new ThreadFactoryBuilder()
            .setNameFormat("named-pool-%d").build(), new ThreadPoolExecutor.DiscardPolicy());
```

上面的构造函数的参数比较多，下面我们来一一解读

```java
public ThreadPoolExecutor(int corePoolSize,//核心线程数
                        int maximumPoolSize,//最大线程数
                         long keepAliveTime,//存活时间
                         TimeUnit unit,//存活时间单位
                         BlockingQueue<Runnable> workQueue,//工作队列
                         ThreadFactory threadFactory,//线程池工厂
                         RejectedExecutionHandler handler//拒绝执行Handler
                         ) {
        //省略部分参数
        this.corePoolSize = corePoolSize;
        this.maximumPoolSize = maximumPoolSize;
        this.workQueue = workQueue;
        this.keepAliveTime = unit.toNanos(keepAliveTime);
        this.threadFactory = threadFactory;
        this.handler = handler;
    }
```

jdk源码对这些参数的解释

* corePoolSize – the number of threads to keep in the pool, even if they are idle, unless allowCoreThreadTimeOut is set

> 在线程池内，即使线程是空闲也需要维持的线程数称为corePoolSize，除非allowCoreThreadTimeOut设置为true

* maximumPoolSize – the maximum number of threads to allow in the pool

> 线程池内允许的最大线程数

* keepAliveTime – when the number of threads is greater than the core, this is the maximum time that excess idle threads will wait for new tasks before terminating.

> 当前核心线程数设置corePoolSize=5,如果线程池内有6个线程，其中有一个线程空闲。keepAliveTime参数设置该空闲线程在等待新任务到被中断之前的存活时间。

* unit – the time unit for the keepAliveTime argument

> keepAliveTime的时间单位

* workQueue – the queue to use for holding tasks before they are executed. This queue will hold only the Runnable tasks submitted by the execute method.

> 当前核心线程没有空闲线程来处理新的任务时，新的任务会被保存在任务队列中，等待空闲线程来执行。Java中的BlockingQueue主要有两种实现，分别是ArrayBlockingQueue 和 LinkedBlockingQueue

* threadFactory – the factory to use when the executor creates a new thread

> 线程工厂，用来创建新的线程

* handler – the handler to use when execution is blocked because the thread bounds and queue capacities are reached

> 线程阻塞时的策略

Core and maximum pool sizes

    A ThreadPoolExecutor will automatically adjust the pool size according to the bounds set by corePoolSize and maximumPoolSize . 
    When a new task is submitted in method execute(Runnable), and fewer than corePoolSize threads are running, a new thread is created to handle the request, even if other worker threads are idle. If there are more than corePoolSize but less than maximumPoolSize threads running, a new thread will be created only if the queue is full. 
    By setting corePoolSize and maximumPoolSize the same, you create a fixed-size thread pool. By setting maximumPoolSize to an essentially unbounded value such as Integer.MAX_VALUE, you allow the pool to accommodate an arbitrary number of concurrent tasks.

   > 当新的task提交时：1、小于corePoolSize，创建新的线程处理task。2、大于corePoolSize小于maximumPoolSize，并且任务队列已满，创建新的线程。3、任务队列已满，并且等于maximumPoolSize，将会触发handler处理

On-demand construction

    By default, even core threads are initially created and started only when new tasks arrive, but this can be overridden dynamically using method prestartCoreThread or prestartAllCoreThreads. You probably want to prestart threads if you construct the pool with a non-empty queue.
    
   > 默认情况下，核心线程直到新的task达到时才会初始化。使用prestartCoreThread（初始化一个）/prestartAllCoreThreads(初始化所有核心线程)来达到在task到达之前初始化核心线程。
    
Creating new threads

    New threads are created using a ThreadFactory. If not otherwise specified, a Executors.defaultThreadFactory is used, that creates threads to all be in the same ThreadGroup and with the same NORM_PRIORITY priority and non-daemon status. By supplying a different ThreadFactory, you can alter the thread's name, thread group, priority, daemon status, etc. If a ThreadFactory fails to create a thread when asked by returning null from newThread, the executor will continue, but might not be able to execute any tasks. Threads should possess the "modifyThread" RuntimePermission. If worker threads or other threads using the pool do not possess this permission, service may be degraded: configuration changes may not take effect in a timely manner, and a shutdown pool may remain in a state in which termination is possible but not completed.

Keep-alive times

    If the pool currently has more than corePoolSize threads, excess threads will be terminated if they have been idle for more than the keepAliveTime. This provides a means of reducing resource consumption when the pool is not being actively used. If the pool becomes more active later, new threads will be constructed. This parameter can also be changed dynamically using method setKeepAliveTime(long, TimeUnit). Using a value of Long.MAX_VALUE TimeUnit.NANOSECONDS effectively disables idle threads from ever terminating prior to shut down. By default, the keep-alive policy applies only when there are more than corePoolSize threads. But method allowCoreThreadTimeOut(boolean) can be used to apply this time-out policy to core threads as well, so long as the keepAliveTime value is non-zero.
    
Queuing

    Any BlockingQueue may be used to transfer and hold submitted tasks. The use of this queue interacts with pool sizing:
    

* If fewer than corePoolSize threads are running, the Executor always prefers adding a new thread rather than queuing.

* If corePoolSize or more threads are running, the Executor always prefers queuing a request rather than adding a new thread.

* If a request cannot be queued, a new thread is created unless this would exceed maximumPoolSize, in which case, the task will be rejected.

There are three general strategies for queuing:

    Direct handoffs. A good default choice for a work queue is a SynchronousQueue that hands off tasks to threads without otherwise holding them. Here, an attempt to queue a task will fail if no threads are immediately available to run it, so a new thread will be constructed. This policy avoids lockups when handling sets of requests that might have internal dependencies. Direct handoffs generally require unbounded maximumPoolSizes to avoid rejection of new submitted tasks. This in turn admits the possibility of unbounded thread growth when commands continue to arrive on average faster than they can be processed.
    
    Unbounded queues. Using an unbounded queue (for example a LinkedBlockingQueue without a predefined capacity) will cause new tasks to wait in the queue when all corePoolSize threads are busy. Thus, no more than corePoolSize threads will ever be created. (And the value of the maximumPoolSize therefore doesn't have any effect.) This may be appropriate when each task is completely independent of others, so tasks cannot affect each others execution; for example, in a web page server. While this style of queuing can be useful in smoothing out transient bursts of requests, it admits the possibility of unbounded work queue growth when commands continue to arrive on average faster than they can be processed.
    
    Bounded queues. A bounded queue (for example, an ArrayBlockingQueue) helps prevent resource exhaustion when used with finite maximumPoolSizes, but can be more difficult to tune and control. Queue sizes and maximum pool sizes may be traded off for each other: Using large queues and small pools minimizes CPU usage, OS resources, and context-switching overhead, but can lead to artificially low throughput. If tasks frequently block (for example if they are I/O bound), a system may be able to schedule time for more threads than you otherwise allow. Use of small queues generally requires larger pool sizes, which keeps CPUs busier but may encounter unacceptable scheduling overhead, which also decreases throughput.

Rejected tasks

    New tasks submitted in method execute(Runnable) will be rejected when the Executor has been shut down, and also when the Executor uses finite bounds for both maximum threads and work queue capacity, and is saturated. In either case, the execute method invokes the RejectedExecutionHandler.rejectedExecution(Runnable, ThreadPoolExecutor) method of its RejectedExecutionHandler. Four predefined handler policies are provided:
    

1. In the default ThreadPoolExecutor.AbortPolicy, the handler throws a runtime RejectedExecutionException upon rejection.

2. In ThreadPoolExecutor.CallerRunsPolicy, the thread that invokes execute itself runs the task. This provides a simple feedback control mechanism that will slow down the rate that new tasks are submitted.

> 直接在 execute 方法的调用线程中运行无法加入到任务队列中的任务

1. In ThreadPoolExecutor.DiscardPolicy, a task that cannot be executed is simply dropped.

1. In ThreadPoolExecutor.DiscardOldestPolicy, if the executor is not shut down, the task at the head of the work queue is dropped, and then execution is retried (which can fail again, causing this to be repeated.)

Hook methods

    This class provides protected overridable beforeExecute(Thread, Runnable) and afterExecute(Runnable, Throwable) methods that are called before and after execution of each task. These can be used to manipulate the execution environment; for example, reinitializing ThreadLocals, gathering statistics, or adding log entries. Additionally, method terminated can be overridden to perform any special processing that needs to be done once the Executor has fully terminated.
    If hook or callback methods throw exceptions, internal worker threads may in turn fail and abruptly terminate.

Queue maintenance

    Method getQueue() allows access to the work queue for purposes of monitoring and debugging. Use of this method for any other purpose is strongly discouraged. Two supplied methods, remove(Runnable) and purge are available to assist in storage reclamation when large numbers of queued tasks become cancelled.

Finalization

   > A pool that is no longer referenced in a program AND has no remaining threads will be shutdown automatically. If you would like to ensure that unreferenced pools are reclaimed even if users forget to call shutdown, then you must arrange that unused threads eventually die, by setting appropriate keep-alive times, using a lower bound of zero core threads and/or setting allowCoreThreadTimeOut(boolean).
