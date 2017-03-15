---
title: 【nginx学习一】基本原理学习 
date: 2017-03-14 23:21:35
tags: 
- nginx
- 基本原理
---

> 由于性能问题，需要将 apache + php5.2 升级到 nginx + php7，对于nginx的性能和热加载早有耳闻，why nginx so diao，小拽通过nginx的线程管理，请求管理，事件管理等几个方面来做一个初步介绍

## 一、nginx现状
nginx 是否是当前的`使用最广泛的webserver ,支持http正向/反向代理，支持TCP/UDP层代理`，来看下netcraft的数据

[![webserver_all](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_all.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_all.png)
[![webserver_top](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_top.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_trend_top.png)

如上图所示：nginx在全部网站中占比达到18%，在top millon busest 达到28%，而且一直在增加
更全数据可以参考https://news.netcraft.com/archives/2017/01/12/january-2017-web-server-survey.html

## 二、nginx的特点
nginx的特点总结起来有四个主要方面
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

下面一张图是nginx apache 和lighttpd的一个对比
[![nginx对比图](http://cuihuan.net/wp_content/new/nginx1/nginx_compare.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_compare.png)

## 三、nginx的核心机制

### 3.1 基本框架
一句话简述：master-worker多进程模式，单线程/非阻塞。
[![nginx 基本框架](http://cuihuan.net/wp_content/new/nginx1/nginx_framework.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_framework.png)

### 3.2 进程管理
之所以nginx能够热加载的原因，
[![nginx 配置热加载](http://cuihuan.net/wp_content/new/nginx1/nginx_conf_reload.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_conf_reload.png)
[![nginx 线程热加载](http://cuihuan.net/wp_content/new/nginx1/nginx_bit_reload.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_bit_reload.png)

### 3.3 主要处理流程和模块
worker 处理请求
请求-》读取头部【post read】-> 请求配置关联【rewrite】-》 频率控制【pre-access 】->权限控制【access 】

->产生内容【content】->内容过滤【filter,包括压缩，过滤等等】->日志【log】
单个请求worker
[![nginx 主要流程和模块](http://cuihuan.net/wp_content/new/nginx1/nginx_flow.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_flow.png)

对应的主要状态机
http://www.nginxguts.com/2011/01/phases/

### 3.4 请求管理
> 官方阐述：It’s well known that NGINX uses `an asynchronous, event‑driven approach to handling connections`. This means that instead of creating another dedicated process or thread for each request (like servers with a traditional architecture), it handles multiple connections and requests in one worker process. To achieve this, NGINX works with sockets in a non‑blocking mode and uses efficient methods such as epoll and kqueue.
[![nginx 任务基本框架](http://cuihuan.net/wp_content/new/nginx1/nginx_task.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_task.png)

epoll 官网：http://man7.org/linux/man-pages/man7/epoll.7.html
http://yaocoder.blog.51cto.com/2668309/888374
线程池官网：
https://www.nginx.com/blog/thread-pools-boost-performance-9x/

原理的官方阐述
>Let’s return to our poor sales assistant who delivers goods from a faraway warehouse. But he has become smarter (or maybe he became smarter after being beaten by the crowd of angry clients?) and hired a delivery service. Now when somebody asks for something from the faraway warehouse, instead of going to the warehouse himself, he just drops an order to a delivery service and they will handle the order while our sales assistant will continue serving other customers. Thus only those clients whose goods aren’t in the store are waiting for delivery, while others can be served immediately.
官方原理解释：
每次都要去调用系统，和自身整理之后一次性给系统。
[![nginx 任务基本框架](http://cuihuan.net/wp_content/new/nginx1/nginx_task2.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_task2.png)

### 3.5 事件管理

[![nginx 事件](http://cuihuan.net/wp_content/new/nginx1/nginx_event.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_event.png)
[![nginx epoll](http://cuihuan.net/wp_content/new/nginx1/nginx_epoll.png)](http://cuihuan.net/wp_content/new/nginx1/nginx_epoll.png)

### 


## 参考文章
- netcraft：https://news.netcraft.com/archives/2017/01/12/january-2017-web-server-survey.html
- nginx的线程调度设计：https://www.nginx.com/blog/inside-nginx-how-we-designed-for-performance-scale/
- epoll详述：http://man7.org/linux/man-pages/man7/epoll.7.html
- http://yaocoder.blog.51cto.com/2668309/888374
- 线程池：https://www.nginx.com/blog/thread-pools-boost-performance-9x/



【转载请注明：[【redis学习三】简单高可用redis架构实践](http://cuihuan.net/2017/02/05/redis3/) | [靠谱崔小拽](http://cuihuan.net) 】