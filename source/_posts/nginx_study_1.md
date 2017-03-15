---
title: 【nginx学习一】基本原理学习 
date: 2017-03-14 23:21:35
tags: 
- nginx
- 基本原理
---
> 由于性能问题，需要将 apache + php5.2 升级到 nginx + php7，对于nginx的性能和热加载早有耳闻，why nginx so diao。小拽进行了初探，`有任何疑问或不准确的地方，欢迎直接开炮`！！！

## 一、nginx现状
nginx 是当前的`使用最广泛的webserver ,支持http正向/反向代理，支持TCP/UDP层代理`，来看下netcraft的数据


[![webserver_all](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_all.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_all.png)
[![webserver_top](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_top.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_top.png)

nginx在`全部网站中占比达到18%`，在`top millon busest 达到28%`，而且一直在增加。当下最时尚的webserver非nginx莫属
>更全数据可以参考：[【netcraft】](https://news.netcraft.com/archives/2017/01/12/january-2017-web-server-survey.html)

## 二、nginx的特点
深入了解nginx之前，先泛泛的了解下nginx的几个特点
- 性能好
 - 非阻塞IO/高并发,支持文件IO
 - 多worker，thread pool 
 - 基于rbtree的定时器
 - 系统特性的持续支持
- 功能强大
 - webserver/cache/keepalive/pipeline等等
 - 各种upstream的支持【fastcgi/http/...】
 - 输出灵活【chunk/zip/...】
 - 在不断的发展 http2,tcp,udp,proxy...
- 运维的友好【这个对于开发和部署很重要】
 - 配置非常规范【个人认为：约定及规范是最好的实践】
 - 热加载和热更新【后文会详细介绍，能在二进制的层面热更新】
 - 日志强大【真的很强的，很多变量支撑】
- 扩展强大

下图是nginx、apache和lighttpd的一个对比。系统压力，内存占用，upstream支持等多个方面都非常不错
[![nginx对比图](http://cuihuan.net/wp_content/new/nginx1/nginx_compare.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_compare.png)

## 三、nginx的核心机制

### 3.1 运行方式
一句话简述nginx的运行方式：`master-worker多进程模式运行，单线程/非阻塞执行`

如下官方图：nginx 启动后生成master，master会启动conf数量的`worker进程`，当用户的请求过来之后，由不同的worker调起`执行线程`，非阻塞的执行请求。这种运行方式相对于`apache的进程执行`相对轻量很多，支撑的并发性也会高很多。
[![nginx 基本框架](http://cuihuan.net/wp_content/new/nginx1/nginx_framework.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_framework.png)


### 3.2 进程管理
nginx是master-worker进程工作模式，那么nginx是如何管理master启程，怎么做到热加载的？
#### 3.2.1 配置热加载
官方图很赞，在`更换配置之后，master生成新的worker，直到原有的worker全部任务结束kill掉之后`。从现象上作证，也就是在relaod配置之后，短时间可能出现超过conf数量的进程，更新完成后，进程会完全改变。
> 不更新、直接替换，这种设计思路在代码部署中也很常见，包括mysql迁移，代码更新，服务尝试，很值的学习。
[![nginx 配置热加载](http://cuihuan.net/wp_content/new/nginx1/nginx_conf_reload.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_conf_reload.png)

#### 3.2.2 版本更新热加载
了解了worker的热加载之后，理解master就非常简单了，通过信号控制，同时存在两个master，逐步替代。
[![nginx 线程热加载](http://cuihuan.net/wp_content/new/nginx1/nginx_bit_reload.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_bit_reload.png)

关于replace过程中如何细节控制一致性，稳定性，信号控制，log控制等等，敬请期待小拽的进一步探索！

### 3.3 处理流程和模块
启动进程后，请求在nginx内部是如何流转的，nginx内部包括哪些模块？

#### 3.3.1 worker处理过程

 1. 【post header】请求到达后首先读取header，log中request time初始时间便从此开始。
 2. 【rewrite】请求相关的配置和参数
 3. 【pre-access】预处理阶段，频率控制，高频绝句
 4. 【acess】权限控制，白名单，403，access deny ，静态文件开放等均有这个模块产生
 5. 【content】这个模块会调用upstream产生内容，这个阶段最重要`此处调起了工作线程，调用fastcgi，http，以及各种操作产生内容均在此处`。性能优化可能需要确认程序执行时间，对应access log中的upstream time 由此产生，记录了nginx中程序运行的全量时间，而request - upstream 就是网络传输和预处理时间。
 6. 【filter】内容过滤，包括gzip压缩，返回等在此处
 7. 【log】日志的产生
 8. 【重定向】`没有这个模块，所有的进行智能单向走，有了这个，在任何阶段都可以产生返回`，例如client主动阶段产生499的log，过程可能就是1-》2-》8-》7 over

> 摘自某ppt的一个图，如侵权，请尽快联系小拽
[![nginx 主要流程和模块](http://cuihuan.net/wp_content/new/nginx1/nginx_flow.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_flow.png)

各个阶段的主要状态机可以参考:[【跳转】](http://www.nginxguts.com/2011/01/phases/)

### 3.4 请求管理
了解了worker的工作模式和worker的内部主要模块，那么worker是如何管理请求的？

#### 3.4.1 任务调度
> 官方阐述：It’s well known that NGINX uses `an asynchronous, event‑driven approach to handling connections`. This means that instead of creating another dedicated process or thread for each request (like servers with a traditional architecture), it handles multiple connections and requests in one worker process. To achieve this, NGINX works with sockets in a non‑blocking mode and uses efficient methods such as epoll and kqueue.
核心词：`异步，事件驱动，链接控制`

解释的很清楚，`nginx并不是通过每个请求都创建线程，而是通过内部管理的调度分配`。
如下图：此处不翻译了，大家直接看原版
epoll详解：[【跳转】](http://man7.org/linux/man-pages/man7/epoll.7.html)

[![nginx 任务基本框架](http://cuihuan.net/wp_content/new/nginx1/nginx_task.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_task.png)

#### 3.4.2 线程池

官方说明
>Let’s return to our poor sales assistant who delivers goods from a faraway warehouse. But he has become smarter (or maybe he became smarter after being beaten by the crowd of angry clients?) and hired a delivery service. Now when somebody asks for something from the faraway warehouse, instead of going to the warehouse himself, he just drops an order to a delivery service and they will handle the order while our sales assistant will continue serving other customers. Thus only those clients whose goods aren’t in the store are waiting for delivery, while others can be served immediately.

小拽认为简而言之：`结合实际情况，除了空闲被动给，更多的通过事件驱动主动要`，通过这种方式在执行资源紧缺的情况下，达到一个执行资源的优化部署，如下图。
[![nginx 任务基本框架](http://cuihuan.net/wp_content/new/nginx1/nginx_task2.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_task2.png)
线程池官网详解：[【跳转】](https://www.nginx.com/blog/thread-pools-boost-performance-9x/)
#### 3.4.3 事件调度

请求的具体调度基于事件，例如网络IO,磁盘IO,定时器等均可以对事件进行阻塞，当阻塞的事件空闲时，发出调度请求，完成处理。
需要额外提一下，`nginx的定时器基于rbtree，红黑树的快速插入和查询保证了nginx事件调度的高效性`
事件框架的处理模型
[![nginx 事件](http://cuihuan.net/wp_content/new/nginx1/nginx_event_.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_event_.png)
[![nginx epoll](http://cuihuan.net/wp_content/new/nginx1/nginx_epoll.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_epoll.png)

## 简单总结
- 性能：nginx 工作模式是master-worker进程方式，执行请求是有更轻量线程完成。
- 热加载：nginx 替换非更新的方式是nginx热加载的本质
- 功能强大：nginx upstream是在线程层面调度，兼容多种，所以可以扩展很多功能强大
- 处理流程：主要的流程过程和模块分离清晰。
- 请求处理：通过自身的管理，线程池，异步事件驱动等当来完成任务调度

再次强调：初探nginx，有疑问或不准确的地方，请直接开炮！！！

## 参考文章
- netcraft：https://news.netcraft.com/archives/2017/01/12/january-2017-web-server-survey.html
- nginx的线程调度设计：https://www.nginx.com/blog/inside-nginx-how-we-designed-for-performance-scale/
- epoll详述：http://man7.org/linux/man-pages/man7/epoll.7.html
- http://yaocoder.blog.51cto.com/2668309/888374
- 线程池：https://www.nginx.com/blog/thread-pools-boost-performance-9x/


【转载请注明：[【【nginx学习一】基本原理学习 ](http://localhost:4000/2017/03/14/nginx_study_1/) | [靠谱崔小拽](http://cuihuan.net) 】
