---
title: linux 查找清理大文件 
date: 2015-12-08 17:21:35
tags: 
- linux
---
> linux 经常硬盘空间不足，往往是由于一些大文件造成；之前寻找大文件总是很头疼，速度特别慢。
经学弟介绍使用：`du -sh * |grep G` 查找和清理速度不错，分享一下清理过程。

## 查看系统存储状态
```
[cuihuan:~ cuixiaohuan]$ df -h
Filesystem Size Used Avail Use% Mounted on
/dev/sda2 8.2G 6.7G 1.6G 82% /
/dev/sda3 1.4T 1.3T 50G 97% /home
```
1.5T的硬盘占用了97%，确实不够用了，必须着手清理一下

## 查找大文件

主要使用查找命令：`du -sh * |grep G`
从根文件开始查找
```
[cuihuan:~]$ du -sh * | grep G
。。。
73G mongodb
103G mxm
2.1G online
613G thirdparty [binggo!!!]
。。。
```
bingo 613g，看来这个主要矛盾了，进一步分析该文件

```
[cuihuan:~ mysql5]$ du -sh *
116M bin
904K include
13M lib
17M libexec
458G log [-__]
8.0K my.cnf
76M mysql-test
13M share
2.9M sql-bench
4.0K test
4.0K tmp
101G var [-_-]
[cuihuan:~ mysql5]$ cd log
[cuihuan:~ log]$ ls -lh
total 458G
-rw-rw---- 1 work work 870K Dec 2 17:42 mysql.err
-rw-rw---- 1 work work 3.9K Mar 24 2015 mysql.err-old
-rw-rw---- 1 work work 446G Dec 3 15:19 mysql.log 【-__】
-rw-rw---- 1 work work 11G Dec 3 15:10 slow.log
```
经过分析看到mysql.log的日志占了446G,着手清理下。【mysql log 好的保存方式是：天级导出，清理n天之前的log，此处不再赘述】

## 清理之后效果
清理 mysql.log 和var  之后
清理了大约`500g`的空间
```
[cuihuan:~ var]$ df -h   
Filesystem Size Used Avail Use% Mounted on
/dev/sda2 8.2G 6.7G 1.6G 82% /
/dev/sda3 1.4T 757G 584G 57% /home
```
【转载请注明：[linux 查找清理大文件](http://cuihuan.net/article/linux-%E6%9F%A5%E6%89%BE%E6%B8%85%E7%90%86%E5%A4%A7%E6%96%87%E4%BB%B6.html) | [靠谱崔小拽](http://cuihuan.net) 】

