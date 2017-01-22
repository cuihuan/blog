---
title: postMessage处理iframe 跨域问题 
date: 2016-02-29 17:21:35
tags: 
- iframe跨域
- iframe自适应高度
- iframe
- javascript
- html5
---

> 背景：由于同源策略存在，javascript的跨域一直都是一个棘手的问题。`父页面无法直接获取iframe内部的跨域资源；同时，iframe内部的跨域资源也无法将信息直接传递给父页面`。

## 一：传统的解决方式。
传统的iframe资源解决方式：主要通过通过中间页面代理，此处不再赘述，参考[中间页获取跨域iframe](http://www.cnblogs.com/snandy/p/3900016.html)

## 二：html5 postMessage的产生
随着HTML5的发展，html5工作组提供了两个重要的接口：`postMessage(send) 和 onmessage`。这两个接口有点类似于websocket，可以实现两个跨域站点页面之间的数据传递。

[postMessage API](https://www.w3.org/TR/websockets/?cm_mc_uid=62901929538214344332551&cm_mc_sid_50200000=1456119382)

下面是实践过程中两个小栗子：分别父页面传递信息给iframe，iframe传递信息给父页面。

## 三：iframe获取父页面信息
话不多说，直接上码：
参考demo：[父页面传给子页面demo](http://cuihuan.net:1015/demo_file/postmesage/demo.html)
### 父页面代码
```
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>崔涣 iframe postmessage 父页面</title>
    <script type="text/JavaScript">
        function sendIt() {
            // 通过 postMessage 向子窗口发送数据
            document.getElementById("otherPage").contentWindow
                    .postMessage(
                    document.getElementById("message").value,
                    "http://cuihuan.net:8003"
            );
        }
    </script>
</head>
<body>
<!-- 通过 iframe 嵌入子页面 -->
<iframe src="http://cuihuan.net:8003/test.html" id="otherPage"></iframe>
<br/>
<br/>
<input type="text" id="message"/>
<input type="button" value="Send to child.com" onclick="sendIt()"/>
</body>
</html>
```
### 子页面代码

```
<html> 
 <head> 
 <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"> 
 <title>崔涣测试子页面信息</title> 
 <script type="text/JavaScript"> 
	 //event 参数中有 data 属性，就是父窗口发送过来的数据
	 window.addEventListener("message", function( event ) { 
		 // 把父窗口发送过来的数据显示在子窗口中
	   document.getElementById("content").innerHTML+=event.data+"<br/>"; 
	 }, false ); 

 </script> 
 </head> 
 <body> 
	 this is the 8003 port for cuixiaozhuai 
	 <div id="content"></div> 
 </body> 
 </html>
```
demo 效果如下图：两个跨域页面之间，父页面给子页面传递数据。
[![16743333-E2AF-40E5-8DD2-0CBCE8919C66](http://cuihuan.net/wp-content/uploads/2016/02/16743333-E2AF-40E5-8DD2-0CBCE8919C66.png)](http://cuihuan.net/wp-content/uploads/2016/02/16743333-E2AF-40E5-8DD2-0CBCE8919C66.png) 

## 四：iframe传递信息给父页面

参考demo：[跨域子页面传给父页面demo](http://cuihuan.net:1015/demo_file/postmesage/son2Parent.html)
### 父页面代码
```
<html>
 <head>
 <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
 <title>崔涣测试父页面</title>
 <script type="text/JavaScript">
     //event 参数中有 data 属性，就是父窗口发送过来的数据
     window.addEventListener("message", function( event ) {
         // 把父窗口发送过来的数据显示在子窗口中
       document.getElementById("content").innerHTML+=event.data+"<br/>";
     }, false );

 </script>
 </head>
 <body>
     <iframe src="http://cuihuan.net:8003/iframeSon.html" id="otherPage"></iframe>
     <br/>
     this is the 1015 port for cuixiaozhuai。
     <div id="content"></div>
 </body>
 </html>
```
### 子页面代码
```
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>崔小涣iframe postmessage 测试页面</title>
    <script type="text/JavaScript">
        function sendIt() {
            // 子页面给父页面传输信息 
            parent.postMessage(
                document.getElementById("message").value,
                "http://cuihuan.net:1015"
            );
        }
    </script>
</head>
<body>
<br/>
this is the  port for cuixiaozhuai
<input type="text" id="message"/>
<input type="button" value="Send to child.com" onclick="sendIt()"/>
</body>
</html>
```
demo 效果如下图：两个跨域页面之间，子页面传递数据给父页面传递数据。
[![22433B4C-8836-4546-93DB-7A896F8B4B37](http://cuihuan.net/wp-content/uploads/2016/02/22433B4C-8836-4546-93DB-7A896F8B4B37.png)](http://cuihuan.net/wp-content/uploads/2016/02/22433B4C-8836-4546-93DB-7A896F8B4B37.png) 

## 五：postmessage简单分析和安全问题

postmessage 传送过来的信息如下图，
[![BABB5101-CD9D-448C-99EE-910334405D3D](http://cuihuan.net/wp-content/uploads/2016/02/BABB5101-CD9D-448C-99EE-910334405D3D.png)](http://cuihuan.net/wp-content/uploads/2016/02/BABB5101-CD9D-448C-99EE-910334405D3D.png)

几乎包含了所有应该有的信息。甚至data中可以包含object，出于安全考虑可以域的校验，数据规则的校验安全校验，如下代码
```

 window.addEventListener('message', function (event) {
        
        //校验函数是否合法
        var checkMessage = function () {
            // 只获取需要的域，并非所有都可以跨域
            if (event.origin != "need domain") {
                return false;
            }

            
            var message = event.data;
            // 传输数据类型校验
            if (typeof(message) !== 'object') {
                return false;
            }

            // message 的rule中包含xxx则为xxx需要字段。
            return message.rule === "xxx";
        };

        if (checkMessage()) {
            // 通过校验进行相关操作
            addDetailFunc(event);
        }
    });
```
【转载请注明：[postMessage处理iframe 跨域问题](http://cuihuan.net/article/postmessage%E5%A4%84%E7%90%86iframe-%E8%B7%A8%E5%9F%9F%E9%97%AE%E9%A2%98.html) | [靠谱崔小拽](http://cuihuan.net) 】
 


