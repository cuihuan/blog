---
title: jsonp + php 跨域实例 
date: 2015-12-02 17:21:35
tags: 
- cors
- 跨域
- jsonp
- javascript
---
> 由于跨域的存在，使资源交互在不同域名间变的复杂和安全。对于跨域数据传输，当数据长度较小(**get的长度内**)，jsonp是一种较好的解决方案。

> 分享一个自己在jsonp使用过程中的demo。
关于跨域可以参考：[跨域总结与解决办法]( http://www.cnblogs.com/rainman/archive/2011/02/20/1959325.html)

## jsonp的js端调用
主要功能：通过jsonp向服务器，调用相应接口，获应数据；根据获取数据结果做出相应回调。

```
/**
 * jsonp demo
 * 通过回调函数，进行获取之后的事件加载
 *
 * @author:cuihuan
 * @private
 */
_jsonpDemo:function(callback){
    $.ajax({
        url: "http://your_site_url",
        type: 'GET',
        dataType: 'JSONP',
        success: function (data) {
            if (data && data.status) {
                if (data.status == "0") {
                    // failure solve
                    ...
                } else if (data.status == 500) {
                    // server error log
                    _sendInternalLog(data.info);
                } else if (data.status == 1) {
                    //success solve 
                    ...
                }
                
                // callback func
               (callback && typeof(callback) === "function" ) && callback(); 
            }

        },
        error: function () {
            _sendFailLog();
        }
    })

}

```

## jsonp 服务器端 (php)
```

/**
 * 接口返回相应数据
 *
 * status: 0 标示失败，1标示成功,500发生错误
 * return: jsonp 
 */
public function actionGetJsonPInfo()
{
    try {
        $data = getNeedData()
        if ($data['status'] == "success") {
            $res = array("status" => "1", 'info' => $data['info']);
        }else{
            $res = array("status" => "0", 'info' => '0');
        }
    }catch (Exception $e){
        $res = array("status" => "500", 'info'=> $e);
    }

    // jsonp 通过get请求的返回数据形式
    if (isset ($_GET['callback'])) {
        header("Content-Type: application/json");
        echo $_GET['callback']."(".json_encode($res).")";
    }
}

```

## 总结
- 目前来说，数据量小的跨域传输，jsonp是一种很好的解决方案。
- jsonp在data中可以自动识别，res.status，res.info等状态位，比较方便。
- php端的接受代码最好不要采用 Access-Control-Allow-Origin:* 风险太大。

[ 本人小站原文 ](http://cuihuan.net/?p=278)

