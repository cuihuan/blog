---
title: php进程通信
date: 2017-06-21 23:21:35
tags: 
- php
- ipc
---
> PHP间进程如何通信，PHP相关的服务的IPC是实现方式，IPC的思想如何用到项目中。

# 一、linux进程间通信

理解php间进程通信机制，先了解下linux进程间有哪些通讯机制

## 1.1 历史发展
linux ipc 按照历史来源主要有两大块

- AT&T的system v IPc:管道，FIFO，信号
- BSD的socket Ipc :消息队列，共享内存，信号灯。

![进程发展](https://www.ibm.com/developerworks/cn/linux/l-ipc/1.gif)

## 1.2 主要方式
总结起来主要有以下六种方式
- 1：管道【pipe】：主要是`有关系的进程之间`的通讯，例如ls xx |grep xx。
- 2：信号【signal】：通过`中间进程`来管理进程之间的通讯，属于比较复杂的进程间通讯方式。
- 3：消息队列【message】：消息的链接表，进程生产和消费消费消息队列。
 - 优势：克服了信号量承载的消息少，管道只能用规定的字节流，同时受到缓冲区大小的约束的问题 （而且读写是有队列的，有一个写，就只有一个能读到，比较简单，不需要同步和互斥）
 - 缺点：太过简单，处理复杂情况可能会造成饥饿现象
  
- 4：共享内存。多个进程访问同一个内存区。`最快的IPC方式`，但是需要处理进程间的`同步和互斥`。 同时也是`当下使用最广泛的IPC`，例如nginx，框架通讯，配置中心都是该原理。
- 5：信号量【semaphore】：主要作为`进程间，以及进程内部线程之间`的通讯手段。nginx早起的channel机制就类似于信号量
- 6：套接字【socket】：`不同机器之间`的通讯手段。处于tcp-》socket-》http之间的一个协议。

# 二、php进程通讯有哪些方式
最好的语言php有哪些IPC的方式

- pcntl扩展：主要的进程扩展，完成进程的创建，子进程的创建，也是当前使用比较广的多进程。
- posix扩展：完成posix兼容机通用api,如获取进程id,杀死进程等。主要依赖 IEEE 1003.1 (POSIX.1) ，兼容posix
- sysvmsg扩展：实现system v方式的进程间通信之消息队列。
- sysvsem扩展：实现system v方式的信号量。
- sysvshm扩展：实现system v方式的共享内存。
- sockets扩展：实现socket通信，跨机器，跨平台。

php也有一些封装好的异步进程处理框架：例如swoole,workman等

# 三、与php相关的IPC

## 3.1 nginx的IPC

nginx的ipc主要有两种：
- 早期：channel 机制：类似于信号，标示不同进程以及进程与子进程之间的套接字，同时具有继承关系。
缺点：过于复杂，也产生了过多的套接字，造成存储浪费。

- 当前主流：共享内存方式：快，写入数据少，方便。


> 具体可以参见这篇文章：写的非常好 https://rocfang.gitbooks.io/dev-notes/content/nginxzhong_de_jin_cheng_jian_tong_xin.html

## 3.2 apache的IPC
apache：https://arrow.apache.org/docs/ipc.html

# 四、实际应用中的IPC

在平时的项目中，类似于php和linux的IPC的思想大量存在，深入理解。

- socket方式：不同项目间通讯，跨机微服务等等，也是使用最广泛的IPC。

- 共享内存方式：配置中心，公共数据库，甚至git都可以看做共享内存的衍生；`共享内存就必须要注意同步和互斥。
- cache ：是共享内存和管道结合的思想
- 项目流式架构：管道的方式，可以大量的节省空间和时间的通讯方式。

【转载请注明：[php进程通信](http://cuihuan.net/2017/06/21/php进程通信/) | [靠谱崔小拽](http://cuihuan.net) 】