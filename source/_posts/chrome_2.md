---
title: 【chrome 插件二】添加菜单和添加消息提醒 
date: 2016-04-20 17:21:35
tags: 
- chrome-extension
- chrome
- javascript
---
> 上一篇中简单的接触了chrome插件，并且草草的制作一个chrome 插件（-_-只中看，不能用）；这次主要学习，`browse action api制作菜单制作和调用系统提醒`。

## browse action
browse action 包括四部分：一个图标，一个tooltip，一个badge和一个pophtml
先上代码和效果
```
 "browser_action": {
    "default_title": "反劫持工具",
    "default_icon": "image/icon_19.png",
    "default_popup": "html/popup.html"
  },
```
[![red](http://cuihuan.net/wp-content/uploads/2016/04/9E62D576-098D-4B4A-8C4C-1E845D23E094.png)](http://cuihuan.net/wp-content/uploads/2016/04/9E62D576-098D-4B4A-8C4C-1E845D23E094.png)
### 图标
图标优化：`最好是19px，这样基本占满`，可以直接使用图标也可以用h5 canvas element，同时，`图片一定要是背景透明的`。

ps处理后页面效果如下：

[![title](http://cuihuan.net/wp-content/uploads/2016/04/C84884DF-38DB-4402-8BEF-181795A51FAF.png)](http://cuihuan.net/wp-content/uploads/2016/04/C84884DF-38DB-4402-8BEF-181795A51FAF.png)

### tooltip
直接设置default_title 效果是鼠标经过显示标题效果

### badge:
这个相当于设置图片文字和背景色：提供了两个方法：设置badge文字和颜色可以分别使用setBadgeText()andsetBadgeBackgroundColor()。

### pophtml：创建菜单
上码：`能用代码说话的，不用文字`
js
```
/**
 * @author: cuixiaohuan
 * Date: 16/4/19
 * Time: 下午9:41
 */

/**
 * 点击菜单的事件
 *
 * @param e
 */
function click(e) {
    chrome.tabs.executeScript(null,
        {
            // 更改背景色
            code: "document.body.style.backgroundColor='" + e.target.id + "'"
        }
    );

    window.close();
}

/**
 * 页面加载完成后，监听事件
 */
document.addEventListener('DOMContentLoaded', function () {
    var divs = document.querySelectorAll('div');
    for (var i = 0; i < divs.length; i++) {
        divs[i].addEventListener('click', click);
    }
});


```
html
```
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Set Page Color Popup</title>
    <style>
        body {
            overflow: hidden;
            margin: 0px;
            padding: 0px;
            background: white;
        }

        div:first-child {
            margin-top: 0px;
        }

        div {
            cursor: pointer;
            text-align: center;
            padding: 1px 3px;
            font-family: sans-serif;
            font-size: 0.8em;
            width: 100px;
            margin-top: 1px;
            background: #cccccc;
        }

        div:hover {
            background: #aaaaaa;
        }

        #red {
            border: 1px solid red;
            color: red;
        }

        #blue {
            border: 1px solid blue;
            color: blue;
        }

        #green {
            border: 1px solid green;
            color: green;
        }

        #yellow {
            border: 1px solid yellow;
            color: yellow;
        }
    </style>
    <script src="../script/changeBackgroud.js"></script>
</head>
<body>
    <div id="red">红色小拽</div>
    <div id="blue">绿色小拽</div>
    <div id="green">蓝色小拽</div>
    <div id="yellow">换色小拽</div>
  </body>
</html>
```
效果图
[![blue](http://cuihuan.net/wp-content/uploads/2016/04/4AA82B9D-759E-434E-A0B5-8F2F0376F16D.png)](http://cuihuan.net/wp-content/uploads/2016/04/4AA82B9D-759E-434E-A0B5-8F2F0376F16D.png)

## 调用系统提醒
notification api 官方文档:https://developer.chrome.com/extensions/notifications
注意
- chrome32 之前的预警接口不太一样，文档中已经说明。
- 使用预警一定要加上权限统一
```
  "permissions": [
    "notifications"
  ],
```
调用系统提醒代码
```

// 用户授权
if (Notification.permission == "granted") {
    Notification.requestPermission();
}

/**
 * 调用系统提醒
 * 
 * 第一次进入页面需要授权，之后弹出提醒
 */
function notifyMe() {
    if (!Notification) {
        alert('Desktop notifications not available in your browser. Try Chromium.');
        return;
    }

    if (Notification.permission !== "granted"){
        Notification.requestPermission();

    } else {
        var notification = new Notification('小拽提醒', {
            icon: 'http://cuihuan.net/wp-content/themes/quench-master/images/cuihuan_title.jpg',
            body: "别点击，点击跳转'靠谱崔小拽'"
        });

        notification.onclick = function () {
            window.open("http://cuihuan.net");
        };

    }
}

```
初次进去提醒，授权
[![notify_allow](http://cuihuan.net/wp-content/uploads/2016/04/8971AFAA-2C56-4A2F-962B-BBA0A8E0E7A4.png)](http://cuihuan.net/wp-content/uploads/2016/04/8971AFAA-2C56-4A2F-962B-BBA0A8E0E7A4.png)

提醒效果如右上角所示
[![notify](http://cuihuan.net/wp-content/uploads/2016/04/04A3AF6D-69FA-423A-8447-F5984F32762C.png)](http://cuihuan.net/wp-content/uploads/2016/04/04A3AF6D-69FA-423A-8447-F5984F32762C.png)

通过菜单和提醒，我们基本就可以完成一个简单的闹钟提醒，每隔30分钟提醒，码农扭扭脑袋，伸伸懒腰，小心肩周炎-_-!


【转载请注明：[【chrome 插件二】弹出菜单和系统提醒学习](http://cuihuan.net/?p=454) | [靠谱崔小拽](http://cuihuan.net) 】