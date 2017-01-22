---
title: php 处理unicode解码 
date: 2015-11-28 17:21:35
tags: 
- unicode
- php
---
>备忘：这个算是解码比较靠谱的，亲测。参考自stackoverflow，mark 分享

```
// change unicode to unt-8
function replace_unicode_escape_sequence($match) {
    return mb_convert_encoding(pack('H*', $match[1]), 'UTF-8', 'UCS-2BE');
}

function unicode_decode($str) {
 return preg_replace_callback('/u([0-9a-f]{4})/i', 'replace_unicode_escape_sequence', $str); 
}

$str = unicode_decode('{"u5173u952eu8bcd":[{"","key":"u767eu5ea6"}]}');
```
问题：使用过程中，遇到一个问题：就是当多次调用改函数的时候，出现错误。原因在于函数名方式调用问题。

如果编码是 \u5173\u952e\u8bcd 正则改为/\u([0-9a-f]{4})/i 即可
[ 个人小站原文链接 ](http://cuihuan.net/?p=194)

