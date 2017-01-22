---
title: canvas 生成和合并图片 
date: 2015-11-23 17:21:35
tags: 
- 合成图片
- canvas
- javascript
---
> 先说背景：工作中遇到一个问题，file组件上传图片，file是可以上传n张图片；但是，后台逻辑历史原因，只能展现一张。因此：考虑到成本，决定在前端**将多张图片合并成一张给后端**。

### 先上代码
```
_mergeImage2Canvas:function() {
    // 获取file上传和展现的图片。一般file上传之后，有个小图标展现。
    var imgs = $(".img_files");
    if (!imgs) {
        return false;
    }

    // 创建原始图像
    // 原因：file上传之后，展现往往是个缩略图，无法取到真正大小
    for (var i = 0; i < imgs.length; i++) {
        var fbwImg   = document.createElement("img");
        var fbwImgID = "temp_img_id" + i;
        $("#" + fbwImgID).remove();
        fbwImg.src   = imgs[i].src;
        fbwImg.className     = "temp-img-class";
        // 不显示，仅供调用
        fbwImg.style.display = "none";

        // 临时区域扩展
        $("#temp_section").append(fbwImg);
    }

    // 合并原始图片，生成一个新的base64 图片
    var getOriginImgBase64 = function (oriImgs) {
        if (!oriImgs) {
            return false;
        }
        
        // 获取canvas的宽高
        // 原因：canvas需要首先指定宽高，所以需要提前获取最终的宽高
        var maxWidth = 0;
        var height = 0;
        for (var i = 0; i < oriImgs.length; i++) {
            var img = oriImgs[i];
            if (img.width > maxWidth) {
                maxWidth = img.width;
            }
            height += img.height;
        }

        // 设定canvas
        var canvas    = document.createElement("canvas");
        canvas.width  = maxWidth + 10;
        canvas.height = height + 10;
        var ctx       = canvas.getContext("2d");

        // 留5margin
        var dheight = 5;
        for (var j = 0; j < oriImgs.length; j++) {
            var img     = oriImgs[j];
            var cheight = img.height;
            var cwidth  = img.width;

            // 留5 margin
            ctx.drawImage(img, 5, dheight, cwidth, cheight);

            dheight = dheight + cheight + 5;
        }

        // 生成的base64 放在需要的一个全局变量中。
        fbw_img_data = canvas.toDataURL('image/png');
        
        // 清理
        $(".temp_img_class").remove();
    };

    // 之所以使用timer，考虑到dom树如果没有加载完成，会取到高度有误差
    var imgTimer = null;
    imgTimer = setTimeout(function () {
        getOriginImgBase64($(".temp_img_class"));

        if (imgTimer) {
            clearTimeout(imgTimer);
        }
    }, 300);
}
```
### 合成效果
图片一：小站logo

[![cuihuan_title (1)](http://cuihuan.net/wp-content/uploads/2015/11/cuihuan_title-1.jpg)](http://cuihuan.net/wp-content/uploads/2015/11/cuihuan_title-1.jpg) 

图片二：小图标：
[![del](http://cuihuan.net/wp-content/uploads/2015/11/del.png)](http://cuihuan.net/wp-content/uploads/2015/11/del.png)

合成效果：

 [![下载](http://cuihuan.net/wp-content/uploads/2015/11/下载.png)](http://cuihuan.net/wp-content/uploads/2015/11/下载.png)


### 原理简介
主要是通过canvas 获取多个图片的base64编码，之后通过drawImage 函数合并和toDataUrl的方式合成。

### 问题思考
- 问题一：必须支持canvas，否则还需要后台统一跑脚本处理。
- 问题二：性能消耗过大。append img 和base64代码对dom的消耗都挺大，尤其是在移动端，很容易造成崩溃。解决办法：设定最大宽度，将图片等比缩放，这样子就少了向dom扩展元素这部分的损耗。
- 问题三：base64 在传输上性能消耗也挺大，没有file原生的好。

因此：出了必须前端搞定，最好的方式，还是在后台跑脚本运行合并。

[ 个人小站原文链接 ](http://cuihuan.net/?p=253)
