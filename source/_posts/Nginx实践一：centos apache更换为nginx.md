---
title: Nginx实践一：centos apache更换为nginx 
date: 2015-11-18 17:21:35
tags: 
- nginx
- apache
- php
---

> 背景介绍： 阿里云，512M内存（最屌丝配置），搭建lamp 环境，除去 mysql分配了100M左右（这个不能再少了），http竟然占用了200多M，太庞大，决定换为较轻量级，高并发的nginx。

### 背景数据

如下图所示：系统也就500M ,出了mysql占用的100M, httpd 占了1/2 还多（经常达到十几个进程），剩余50M，有时更少不能忍，经常造成数据库崩掉，写了个自动重启脚本，但觉的不是治本之策
     
    # 统计apache 进程个数
    ps aux|grep httpd | wc –l
    
[![ngnix 服务器占用](http://cuihuan.net/wp-content/uploads/2015/11/8C2E5AE4-0A5E-479E-8C20-1CFF0C35F6D7-1024x621.png)](http://cuihuan.net/wp-content/uploads/2015/11/8C2E5AE4-0A5E-479E-8C20-1CFF0C35F6D7.png)

### 解决策略

* 1：针对Apache进行优化。包括优化worker运行方式等等。可以参考[ apache优化 ](https://linux.cn/article-5294-2.html)
* 2 :更换轻量级服务器。采用nginx 或者lighthttpd等更轻量的服务器。传说中Nginx大法负载均衡和高并发略胜一筹，决定实践一把。

### apache替换为nginx

* 1： 停掉apache
    sudo service httpd stop
    
 注意：以防万一，最好不好提前卸掉。
* 2：安装nginx
    yum install nginx
    
* 3：启动nginx
    sudo nginx
    
 安装成功之后，启动成功如下图 [![CB5A50FB-8B68-4F21-A6F4-BDC7AF6C93B2](http://cuihuan.net/wp-content/uploads/2015/11/CB5A50FB-8B68-4F21-A6F4-BDC7AF6C93B2-1024x302.png)](http://cuihuan.net/wp-content/uploads/2015/11/CB5A50FB-8B68-4F21-A6F4-BDC7AF6C93B2.png)
* 4：简单配置nginx
 主要是简单修改下log【方便追查问题】 和 web_root 对应文件【快速启用网站】
* 5：重启nginx
    [root@iZ25xlozdf2Z nginx]# nginx -s quit
    [root@iZ25xlozdf2Z nginx]# nginx
    
 如下图，配置web目录成功！ [![BAEF603F-CA9C-436E-B870-3E70C11542D0](http://cuihuan.net/wp-content/uploads/2015/11/BAEF603F-CA9C-436E-B870-3E70C11542D0.png)](http://cuihuan.net/wp-content/uploads/2015/11/BAEF603F-CA9C-436E-B870-3E70C11542D0.png)
* 6：添加php 支持
 安装php-fpm
    yum install php-fpm
    
 nginx.conf设置
    location ~ \.php$ {
        root /var/www/html;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME         /var/www/html$fastcgi_script_name;
        include fastcgi_params;
    }
    
* 7：重新启动服务，网站回复。
 [![A8D2AD14-7AB9-4421-AF40-B1BE0A5355C3](http://cuihuan.net/wp-content/uploads/2015/11/A8D2AD14-7AB9-4421-AF40-B1BE0A5355C3-1024x718.png)](http://cuihuan.net/wp-content/uploads/2015/11/A8D2AD14-7AB9-4421-AF40-B1BE0A5355C3.png)
* 8：耗存简单对比 如下图：基本上节省了200M，虽然这个可能是运行初期数据；但是，还是确实轻了不少，每个服务占存基本上1/4，线程也少了不少。内存占用方面表现，感觉尚可，接下就看性能了 [![E773D2EE-2F51-4113-AAE1-939CD88DCAEE](http://cuihuan.net/wp-content/uploads/2015/11/E773D2EE-2F51-4113-AAE1-939CD88DCAEE-1024x667.png)](http://cuihuan.net/wp-content/uploads/2015/11/E773D2EE-2F51-4113-AAE1-939CD88DCAEE.png)

### 后续

初次接触nginx，整体感觉还不错。后续，进行基本的防攻击，多端口设置，和性能配置。

[ 个人小站原文链接 ](http://cuihuan.net/?p=225)
