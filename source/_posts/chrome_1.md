---
title: 【chrome 插件一】开发一个简单chrome浏览器插件 
date: 2016-04-26 17:21:35
tags: 
- chrome-extension
- chrome
- javascript
---
> chrome 之所以越来越好用，很大一部分原因归功于功能丰富的插件；对于chrome忠实用户来说，了解和开发一款适合自己的chrome插件，确实是一件很cool的事情。

## 了解chrome 插件
chrome 插件个人理解：`就是一个html + js +css + image的一个web应用`；不同于普通的web应用，`chrome插件除了兼容普通的js，json，h5等api，还可以调用一些浏览器级别的api，例如收藏夹，历史记录等。`

推荐两个网站了解和入门
谷歌官方API：https://developer.chrome.com/extensions/getstarted
360的文档：http://open.chrome.360.cn/extension_dev/overview.html

## 开始写第一个插件
### 文件结构
一个简单的demo，文件目录如下
[![7A980C32-7D7B-44F6-AC5D-C0CC02F79ACA](http://cuihuan.net/wp-content/uploads/2016/04/7A980C32-7D7B-44F6-AC5D-C0CC02F79ACA.png)](http://cuihuan.net/wp-content/uploads/2016/04/7A980C32-7D7B-44F6-AC5D-C0CC02F79ACA.png)
和普通的web文件没有什么区别，简单介绍下
- html:存放html页面
- js :存放js
- locales ：存放了一个多语言的兼容【可无】
- image ：放了两张图片【初期图标】
- manifest ：核心入口文件

### 写一个manifest
api参考文档 :http://open.chrome.360.cn/extension_dev/manifest.html

直接上代码：
```
{
  "name": "hijack analyse plug",
  "version": "0.0.1",
  "manifest_version": 2,

  // 简单描述
  "description": "chrome plug analyse and guard the http hijack",
  "icons": {
    "16": "image/icon16.png",
    "48": "image/icon48.png"
  },
  // 选择默认语言
  "default_locale": "en",

  // 浏览器小图表部分
  "browser_action": {
    "default_title": "反劫持",
    "default_icon": "image/icon16.png",
    "default_popup": "html/test.html"
  },

  // 引入一个脚本
  "content_scripts": [
    {
      "js": ["script/test.js"],
      // 在什么情况下使用该脚本
      "matches": [
        "http://*/*",
        "https://*/*"
      ],
      // 什么情况下运行【文档加载开始】
      "run_at": "document_start"
    }
  ],
  // 应用协议页面
  "permissions": [
    "http://*/*",
    "https://*/*"
  ]
}
```

test.js 文件
```
/**
 * @author: cuixiaohuan
 * Date: 16/4/13
 * Time: 下午8:41
 */
(function(){
    /**
     * just test for run by self
     */
    console.log('begin');
})();
```

test.html 文件
```
<!DOCTYPE html>
<html>
<head lang="en">
    <meta charset="UTF-8">
    <title>just for test</title>
</head>
<body>
<h3>test</h3>
</body>
</html>
```
### 运行插件
chrome 中输入：chrome://extensions
选择加载已解压的插件-》选择文件根目录即可。
效果如下：

[![生效插件](http://cuihuan.net/wp-content/uploads/2016/04/475BA7E7-29F3-48AF-9990-2B73FF1B4B56.png)](http://cuihuan.net/wp-content/uploads/2016/04/475BA7E7-29F3-48AF-9990-2B73FF1B4B56.png)
一个基本的插件变完成了，勾选已启用，随便打开一个网页，会看到log中输出如下

[![运行效果](http://cuihuan.net/wp-content/uploads/2016/04/50F1039A-71C0-463F-A60D-C95527985C7E.png)](http://cuihuan.net/wp-content/uploads/2016/04/50F1039A-71C0-463F-A60D-C95527985C7E.png)

点击页面上面的小图标如下图：
[![右侧展示](http://cuihuan.net/wp-content/uploads/2016/04/25CF59DD-0666-4A6F-ACA3-683D1FEEA346.png)](http://cuihuan.net/wp-content/uploads/2016/04/25CF59DD-0666-4A6F-ACA3-683D1FEEA346.png)

## 优化建议
一个小的插件已经完成，但是还有更多的api和有趣的事情可以去做。下面是360文档中给出一些优化建议，共勉。
- 确认 Browser actions 只使用在大多数网站都有功能需求的场景下。确认 Browser actions 没有使用在少数网页才有功能的场景， 此场景请使用page actions。
- 确认你的图标尺寸尽量占满19x19的像素空间。 Browser action 的图标应该看起来比page action的图标更大更重。
- 尽量使用alpha通道并且柔滑你的图标边缘，因为很多用户使用themes，你的图标应该在在各种背景下都表现不错。不要不停的闪动你的图标，这很惹人反感。

【转载请注明：[【chrome 插件一】开发一个简单chrome浏览器插件](http://cuihuan.net/article/postmessage%E5%A4%84%E7%90%86iframe-%E8%B7%A8%E5%9F%9F%E9%97%AE%E9%A2%98.html) | [靠谱崔小拽](http://cuihuan.net) 】
