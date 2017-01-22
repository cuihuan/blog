---
title: 【page-monitor 前端自动化 中篇】 源码分析 
date: 2016-08-07 17:21:35
tags: 
- 自动化测试
- javascript
---
> 上篇中初探了page-monitor的一些功能和在前端自动化测试方面的可行性，本篇主要分析下page-monitor的实现方式和源码。

## mode-module简介
page-monitor的存在形式是node-module，依赖于node安装和运行，简单必须了解下node_modules

`node-module`是nodejs的模块，符合commonJs规范【具体规范可以参考：http://javascript.ruanyifeng.com/nodejs/module.html】

简单描述commonJs规范
1：文件即模块，作用域在文件内，不允许重复，不会污染。
2：`加载依赖出现顺序`，加载即运行，重复则利用缓存。
> 多说一句：这是amd 和cmd(commonJs)的本质区别，由于node多运行于服务端，加载比较快，因此比较适合cmd 规范，浏览器端的模块则更适用于cmd的规范，个人理解没有广义的好坏之分

方便看源码，贴出node_modole简单构成和主要函数module
node内部提供一了一个modle的构造函数，所有的模块都继承和依赖于此模块。
[![F4D61DF9-40DC-4DB6-A98E-6BED90406D5A](http://cuihuan.net/wp-content/uploads/2016/08/F4D61DF9-40DC-4DB6-A98E-6BED90406D5A.png)](http://cuihuan.net/wp-content/uploads/2016/08/F4D61DF9-40DC-4DB6-A98E-6BED90406D5A.png)
node module的引入 require命令。
其他加载规则，路径设定不在此赘述。

## page-monitor文件分析

完整文件目录：
[![B39BD2DF-7652-49F9-A8FB-F2F691688169](http://cuihuan.net/wp-content/uploads/2016/08/B39BD2DF-7652-49F9-A8FB-F2F691688169.png)](http://cuihuan.net/wp-content/uploads/2016/08/B39BD2DF-7652-49F9-A8FB-F2F691688169.png)  

运行生成目录分析：
[![B39BD2DF-7652-49F9-A8FB-F2F691688169](http://cuihuan.net/wp-content/uploads/2016/08/dom-%E5%88%86%E5%B8%83.jpg)](http://cuihuan.net/wp-content/uploads/2016/08/dom-%E5%88%86%E5%B8%83.jpg)  

出了node_module及其组件代码，可用和值的分析的文件index.js 和phantomjs 下面的五个文件。

## 分析index.js
代码中无非变量声明和引用，关键一句引用phantom的命令乳腺
```
// 多线程启动位置
var proc = spawn(binPath, arr);
```
通过上面多线程的启动node可以达到高效和并发处理测试任务的需求，分析下arr的内容如下图：看到了 窗口大小，延时，ua，存放地址，diff变量等等

[![E9B3CEA8-6B99-45CC-A52A-B8E9D90B267C](http://cuihuan.net/wp-content/uploads/2016/08/E9B3CEA8-6B99-45CC-A52A-B8E9D90B267C.png)](http://cuihuan.net/wp-content/uploads/2016/08/E9B3CEA8-6B99-45CC-A52A-B8E9D90B267C.png)

## 分析获取DOM源码
获取dom的源码主要利用了web api evalution，evalution传入一个xpath的参数，返回一个xpath的对象，之后通过遍历和xpath规则生成规则化的json。
贴一个evalution api
[![90E47065-DF3B-470E-996C-1900A2EAF354](http://cuihuan.net/wp-content/uploads/2016/08/90E47065-DF3B-470E-996C-1900A2EAF354.png)](http://cuihuan.net/wp-content/uploads/2016/08/90E47065-DF3B-470E-996C-1900A2EAF354.png) 

为了看懂page-monitor的代码举个栗子
```
# evalution example:

var headings = document.evaluate("/html/body//h2", document, null, XPathResult.ANY_TYPE, null);
/* 检索body中所有H2的所欲.
 * 结果存在于一个node的迭代器中 */
var thisHeading = headings.iterateNext();
var alertText = "Level 2 headings in this document are:\n";
while (thisHeading) {
  alertText += thisHeading.textContent + "\n";
  thisHeading = headings.iterateNext();
}
alert(alertText); // Alerts the text of all h2 elements
```
通过上面函数和page-monitor中walk.js函数最后一行，可以看出page-monitor 保存了四个元素：属性[name,id等等]，节点类型，位置[后期渲染]，样式的md5加密[样式仅需要对比是否变化即可]
具体内容和dom结构如下：
 [![30FA5132-7903-466A-B866-588311812C47](http://cuihuan.net/wp-content/uploads/2016/08/30FA5132-7903-466A-B866-588311812C47.png)](http://cuihuan.net/wp-content/uploads/2016/08/30FA5132-7903-466A-B866-588311812C47.png)
对应的具体dom结构
[![FBEE1F3F-7A81-4AF0-8E05-7E0BED5B5291](http://cuihuan.net/wp-content/uploads/2016/08/FBEE1F3F-7A81-4AF0-8E05-7E0BED5B5291.png)](http://cuihuan.net/wp-content/uploads/2016/08/FBEE1F3F-7A81-4AF0-8E05-7E0BED5B5291.png) 

## diff.js 代码
diff代码主要两个作用
- 1：获取差异
- 2：渲染差异
其中对比的策略：

历史完全每个对比现在：获取更新和删除的内容
现在完全每个对比历史：获取更新和新增的内容
具体可以参考代码

## 其他api和源码简单修改
必须了解的web api 还有一个是querySeletor 也就是检索的api，参考地址
[document.querySelector()](https://developer.mozilla.org/zh-CN/docs/Web/API/Document/querySelector)
了解了这个api就可以做一件事情：`不对全局dom diff，只对特别关心的dom进行diff`
实现方式：修改querySelector的根节点为Header
获取的dom结构如下：根节点为header
[![30FA5132-7903-466A-B866-588311812C47](http://cuihuan.net/wp-content/uploads/2016/08/30FA5132-7903-466A-B866-588311812C47.png)](http://cuihuan.net/wp-content/uploads/2016/08/30FA5132-7903-466A-B866-588311812C47.png)

获取的页面截图如下：
[![FDF6B258-5A69-47D1-B1FF-4EB38D7B8677](http://cuihuan.net/wp-content/uploads/2016/08/FDF6B258-5A69-47D1-B1FF-4EB38D7B8677.png)](http://cuihuan.net/wp-content/uploads/2016/08/FDF6B258-5A69-47D1-B1FF-4EB38D7B8677.png)


## 代码流程图
 [![page-diff 流程图](http://cuihuan.net/wp-content/uploads/2016/08/page-diff-%E6%B5%81%E7%A8%8B%E5%9B%BE.png)](http://cuihuan.net/wp-content/uploads/2016/08/page-diff-流程图.png)
## 总结
本次在调研page-monitor的基础上，对page-monitor的源码实现进行分析；同时利用相关api修改，来只对核心页面进行获取优化。下一篇将会进一步思考page-monitor的应用。

相关文章：
[【page-monitor 前端自动化 上篇】 初步调研](http://cuihuan.net/?p=485)
[【page-monitor 前端自动化 下篇】 实践应用](http://cuihuan.net/?p=508)





