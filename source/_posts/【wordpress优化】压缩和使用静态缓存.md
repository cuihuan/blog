---
title: 【wordpress优化】压缩和使用静态缓存 
date: 2015-12-06 17:21:35
tags: 
- 缓存
- wordpress
- php
---
> 先说背景：wordpress个人网站，整体性能挺不错；但是，由于采用php动态获取数据，构成页面的方式，势必会影响页面加载速度。对于一些最常用的页面[例如首页]等等，完全可以采用生成伪静态页面缓存的方式加载。

> 针对现有的缓存方式调研了一下：本文使用`wp super cache`进行了优化，提升加载速度200%以上。

## 无图无真想，先看效果
针对相同页面在chrome下做了个加载时间，大小的对比，如下图

优化前数据：23ms感知页面；3.62s加载完成；页面大小：419k；请求个数：25个；
[![原始加载时间](http://cuihuan.net/wp-content/uploads/2015/12/E6B50C39-73D4-4397-9A79-794C58FC8A6A-1024x490.png)](http://cuihuan.net/wp-content/uploads/2015/12/E6B50C39-73D4-4397-9A79-794C58FC8A6A.png)

优化后数据：106ms感知页面；`1.81s`加载完成；页面大小`13.9k`；请求个数24个；
![原始加载时间](http://cuihuan.net/wp-content/uploads/2015/12/1FDB64C3-369A-47E4-8CF7-FE2E7676FC4C1-1024x482.png)

效果不错，后文做个详细分析。

## 了解 wp super cache
[ wp super cache ](http://z9.io/wp-super-cache/) 是wordpress的一种缓存优化插件，本质是利用缓存机制提升页面加载速度。
**实现原理:** php最终在前端展现时需要转换为html，然后获取响应的数据；wp super cache 则提前将php文件转换为的html伪静态文件进行存储，一旦发生请求，直接返回生成的页面；减少了数据库取数据，转换等过程，来增加加载速度。
**优 点:** 增加了加载速度。
**缺 点:** 增加了存储成本，而且要不断的更新，如果用户量大，个人感觉存储和离线成本增加会挺多。

## 安装 wp super cache

官网下载地址：[ http://z9.io/wp-super-cache/ ](http://z9.io/wp-super-cache/) 
【无法翻墙可参考小拽博文：[ 不翻墙，下载wordpress官方主题和插件小技巧 ](http://cuihuan.net/article/%E4%B8%8D%E7%BF%BB%E5%A2%99%EF%BC%8C%E4%B8%8B%E8%BD%BDwordpress%E5%AE%98%E6%96%B9%E6%8F%92%E4%BB%B6%E5%B0%8F%E6%8A%80%E5%B7%A7.html)】

注意：安装wp super cache 需要设定固定连接 如下图
推荐采用【自定义结果】：http://cuihuan.net/article/%postname%.html 
原因在于其他包含字母或者日期不太容易表意，也不利于阅读和seo等等。
[![修改链接格式](http://cuihuan.net/wp-content/uploads/2015/12/BEA1E968-7B4D-4CED-AC56-8E3F4A5A6F2C-1024x546.png)](http://cuihuan.net/wp-content/uploads/2015/12/BEA1E968-7B4D-4CED-AC56-8E3F4A5A6F2C.png)

如果最初采用的是http://xxx/?p=xxx的方式，需要对服务器进行相关设置，否则会一直出现404。解决和设置办法，在另一篇文章中，此处不赘述（[wp super cache 安装和问题解决](http://cuihuan.net/article/wp%20super%20cache%20%E5%AE%89%E8%A3%85%E5%92%8C%E9%97%AE%E9%A2%98%E8%A7%A3%E5%86%B3.html)）。

安装成功后，后台设置中会出现wp super cache

## 配置 wp super cache
安装成功后的简单个人推荐设置。

通用-》启用cache：开启
高级-》启用缓存：开启
高级-》模式选择：推荐mode_rewrite 这个需要apache或者nginx进行相关设置，这个速度最快；如果不想设置，可以选择php缓存模式。
高级-》压缩页面：必选。
高级-》页面更新清除，评论更新清楚：推荐。作用是更新文章，评论之后触发缓存更新。
高级-》移动支持：推荐。
其他一些设置根据个人需求增加。

配置，更新之后，进入网站cache目录下会出现缓存的html文件和gzip的压缩文件（前提是设置了giz压缩）。

```
[root@cuixiaohuan cuihuan.net]# pwd
xxx/wp-content/cache/supercache/cuihuan.net
[root@cuixiaohuan cuihuan.net]# ls -lh
total 52K
-rw-r--r-- 1 apache apache 40K Dec 5 11:33 index.html
-rw-r--r-- 1 apache apache 9.5K Dec 5 11:33 index.html.gz
```

## 效果分析

优化前数据：23ms感知页面；3.62s加载完成；页面大小：419k；请求个数：25个；
优化后数据：106ms感知页面；`1.81s`加载完成；页面大小`13.9k`；请求个数24个；

感知页面变慢：原因在于，原始php页面相对较小，传输也相对较快，传输基本框架之后，才进行页面dom绘制，js渲染，数据获取和再次渲染，所以感知时间原始的快。但是对于750ms以下的对于用户几乎都是无感知。

加载完成变快：最主要达到的效果，节省最多的时间在于数据库获取数据的时间。

页面大小变小：`这块小的有点出乎意外`，小是应该的，但是小这么多就有点🐂了；之后分析了下页面，可能和文章异步获取，存储的html只获取了部分页面的文章，同时，对jquery等等组件肯定是利用缓存，不计入数据大小了。

请求数目变化不大。

> 整体效果：加载快了，页面小了。

【转载请注明：[【wordpress优化】压缩和使用静态缓存 ](http://cuihuan.net/article/%E3%80%90wordpress%E4%BC%98%E5%8C%96%E3%80%91wp-super-cache-%E9%9D%99%E6%80%81%E7%BC%93%E5%AD%98.html) | [ 靠谱崔小拽 ](http://cuihuan.net)】



