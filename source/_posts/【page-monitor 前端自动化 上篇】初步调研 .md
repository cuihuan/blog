---
title: 【page-monitor 前端自动化 上篇】初步调研  
date: 2016-08-07 17:21:35
tags: 
- 自动化测试
- javascript
---

> 前端自动化测试主要在于：`变化快，不稳定，兼容性复杂`；故而，想通过较低的成本维护较为通用的自动化case比较困难。本文旨在`通过page-monitor获取和分析dom结构，调研能否通过监控和分析核心dom，来进行前端自动化测试`。

## 一：page-monitor 介绍
page-monitor：通过xpath获取dom节点结构，之后可视化的渲染出页面的差异。
github地址：https://github.com/fouber/page-monitor
基本原理：`利用xpath获取页面的dom结构，存储为结构化的json，对比两次的json之间的差异，利用phantom渲染页面和差异页面`。

先上个初次试用的图

[![927EE33C-AD06-4EC3-9E5C-B8C3D2029AA3](http://cuihuan.net/wp-content/uploads/2016/08/927EE33C-AD06-4EC3-9E5C-B8C3D2029AA3-212x300.png)](http://cuihuan.net/wp-content/uploads/2016/08/927EE33C-AD06-4EC3-9E5C-B8C3D2029AA3.png)

## 二：初次试用
### 2.1 安装
```
# page-monitor 依赖于 phantomjs
npm install phantomjs
npm install page-monitor
```
注意：phantomJs较大，如果比较慢 可以用brew安装，并且`page-monitor最多兼容phantom1.98`
```
# 调整phantom为1.98 版本
MacBook-Pro:~ cuixiaohuan$ brew link phantomjs198
Linking /usr/local/Cellar/phantomjs198/1.9.8... 2 symlinks created
MacBook-Pro:~ cuixiaohuan$ phantomjs -v
1.9.8
```
2.2 初次运行：
写一个test.js 代码如下:
```
var Monitor = require('page-monitor');

var url = 'http://www.baidu.com';
var monitor = new Monitor(url);
monitor.capture(function(code){
        console.log(monitor.log); // from phantom
        console.log('done, exit [' + code + ']');
});
```
运行效果
```
MacBook-Pro:test cuixiaohuan$ node test.js
{ debug:
   [ 'mode: 11',
     'need diff',
     'loading: http://www.baidu.com',
     'page.viewportSize = {"width":320,"height":568}',
     'page.settings.resourceTimeout = 20000',
     'page.settings.userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X; en-us) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53"',
     'loaded: http://www.baidu.com',
     'delay before render: 0ms',
     'walk tree',
     'save capture [/Users/cuixiaohuan/Desktop/workspace/test/pagemonitor/test/www.baidu.com/Lw==/1461155680901]',
     'screenshot [/Users/cuixiaohuan/Desktop/workspace/test/pagemonitor/test/www.baidu.com/Lw==/1461155680901/screenshot.jpg]',
     'Unsafe JavaScript attempt to access frame with URL about:blank from frame with URL file:///Users/cuixiaohuan/Desktop/workspace/test/pagemonitor/test/node_modules/page-monitor/phantomjs/index.js. Domains, protocols and ports must match.' ],
  warning: [],
  info: [],
  error: [],
  notice: [] }
done, exit [0]
```
### 2.2 生成对比页面
 test.js code

```
monitor.diff(1408947323420, 1408947556898, function(code){
    console.log(monitor.log.info); // diff result
    console.log('[DONE] exit [' + code + ']');
});
```
运行
```
MacBook-Pro:test cuixiaohuan$ node test.js
[ '{"diff":{"left":"1461155680901","right":"1461163758667","screenshot":"/Users/cuixiaohuan/Desktop/workspace/test/pagemonitor/test/www.baidu.com/Lw==/diff/1461155680901-1461163758667.jpg","count":{"add":2,"remove":2,"style":0,"text":9}}}' ]
[DONE] exit [0]
```

### 2.3 对比页面效果如下图
[![927EE33C-AD06-4EC3-9E5C-B8C3D2029AA3](http://cuihuan.net/wp-content/uploads/2016/08/927EE33C-AD06-4EC3-9E5C-B8C3D2029AA3-212x300.png)](http://cuihuan.net/wp-content/uploads/2016/08/927EE33C-AD06-4EC3-9E5C-B8C3D2029AA3.png)

### 2.4 目录初步分析
通过目录和运行结果
1：每个时间利用phantom生成一张截图【保存现场】和一个dome的tree.json【对比dom】 【生成过程看下源码】
2：diff 调用tree.json 比较区中的区别【位置，内容生成和对比过程之后看下源码？】
3：利用当时保存的截图渲染生成的结果

[![F2838502-FF7E-4DC8-9C7F-01687F3DB3E9](http://cuihuan.net/wp-content/uploads/2016/08/F2838502-FF7E-4DC8-9C7F-01687F3DB3E9-300x151.png)](http://cuihuan.net/wp-content/uploads/2016/08/F2838502-FF7E-4DC8-9C7F-01687F3DB3E9.png)


## 三：dom diff工具page monitor 调研初步结论：

- 1：dom的diff 是可行的。
- 2：page monitor 现有主要功能：抽取不同时间段的页面做页面domdiff
使用过程中缺陷：
1：依赖太多，依赖node，依赖phantom，
2：接口太少，现在直接提供的就两个一个保存现场，一个diff。不方便dom定制和阈值定制。

## 四：应用价值思考和下一步
如果能对dom树的处理更完善一些，应用价值还是挺高的，例如`核心dom的diff，局部dom的diff，时效性dom(例如：时间tag必须变化，不变化则为bug)的变更检验，兼容性dom的check等等`

下一步调研：
看下源码中，分析dom生成tree过程，对比tree过程，展现tree过程。

相关文章：
[【page-monitor 前端自动化 中篇】 源码分析](http://cuihuan.net/?p=493)
[【page-monitor 前端自动化 下篇】 实践应用](http://cuihuan.net/?p=508)
