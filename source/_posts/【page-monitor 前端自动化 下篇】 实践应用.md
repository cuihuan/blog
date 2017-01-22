---
title: 【page-monitor 前端自动化 下篇】 实践应用 
date: 2016-08-20 17:21:35
tags: 
- 自动化测试
- javascript
- 前端
---
> 通过page-diff的初步调研和源码分析，确定page-diff在前端自动化测试和监控方面做一些事情。本篇主要介绍下，page-diff在具体的实践中的一些应用

## 核心dom校验
前端的快速发展，造成前端dom无论结构还是命名经常变化，每次都尽可能关注每个dom的变化，不可能也没有必要。但是`核心dom是相对变化较小，但是比较重要`，因此可以利用page-monitor 修改关注结构中的核心代码，核心架构的变化。

上图是未修改的代码，下图是忽略footer内部变化
[![F1AE4B80-CFC6-4A94-AB24-86297DCDD759](http://cuihuan.net/wp-content/uploads/2016/08/F1AE4B80-CFC6-4A94-AB24-86297DCDD759.png)](http://cuihuan.net/wp-content/uploads/2016/08/F1AE4B80-CFC6-4A94-AB24-86297DCDD759.png)
[![0141A2E8-9B5E-439A-9FEC-1147ACF982DF](http://cuihuan.net/wp-content/uploads/2016/08/0141A2E8-9B5E-439A-9FEC-1147ACF982DF.png)](http://cuihuan.net/wp-content/uploads/2016/08/0141A2E8-9B5E-439A-9FEC-1147ACF982DF.png)
实践中可以针对自身的核心dom进行进一步优化

## 局部dom校验
项目中，往往在某一时期特别关心某些板块，或者某些板块相对容易出错；因此，可以利用page-monitor 进行局部dom的细节diff。中篇中对只针对header进行对比diff做了详细介绍，此处不赘述，上图。

[![FDF6B258-5A69-47D1-B1FF-4EB38D7B8677](http://cuihuan.net/wp-content/uploads/2016/08/FDF6B258-5A69-47D1-B1FF-4EB38D7B8677.png)](http://cuihuan.net/wp-content/uploads/2016/08/FDF6B258-5A69-47D1-B1FF-4EB38D7B8677.png)

## 算法优化
由于获取了完整了dom的json，因此可以通过相关阈值的设定或者算法的优化；来对比结果，进行更加优化的分级预警和分析；作者一般对非核心预警超过15%变化会做出预警，超过更高阈值会进一步的预警等等。
贴一个dom 细节图
 [![dom](http://cuihuan.net/wp-content/uploads/2016/08/dom.jpg)](http://cuihuan.net/wp-content/uploads/2016/08/dom.jpg)


## 其他分析
小拽通过上面的举例，旨在抛砖引玉，希望page-monitor或者dom结构在前端的自动化测试有一定应用，提升产品质量。

最终再上一张流程图，便于分析
[![page-diff 流程图](http://cuihuan.net/wp-content/uploads/2016/08/page-diff-%E6%B5%81%E7%A8%8B%E5%9B%BE.png)](http://cuihuan.net/wp-content/uploads/2016/08/page-diff-%E6%B5%81%E7%A8%8B%E5%9B%BE.png)

相关文章：
[【page-monitor 前端自动化 上篇】 初步调研](http://cuihuan.net/?p=485)
[【page-monitor 前端自动化 中篇】 源码分析](http://cuihuan.net/?p=493)





