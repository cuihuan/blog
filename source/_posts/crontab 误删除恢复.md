---
title: crontab 误删除恢复 
date: 2015-12-03 17:21:35
tags: 
- crontab
- linux
---

> 操作过程中：crontab被全部干掉了，利用log恢复过程记录。

## 事故原因分析：
回忆自己操作过程中，未进行crontab的清空，网上查了下原因，并且复现了下。可能原因如下：

**如果在SSH远程终端中敲下“crontab”命令之后，远程连接被一些原因（比如 糟糕的网络，程序异常）意外终止了，那么Crontab计划任务就会被操作系统所清空。听起来很不可思议，但是经过在虚拟机上的多次测试，它确确实实的发生了。测试方式为 用SecureCRT开一个SSH窗口，然后敲下命令“crontab”，接着在“任务管理器”中直接杀掉SecureCRT进程，再通过另外一个SSH窗口执行“crontab -l”，就会发现，所有的计划任务都不存在了。在今天事故发生的时间点上，就有人在服务器上遇到了这样的情况。**

## 恢复操作

-  获取完整日志和cmd日志。
从日志中恢复出一份最近几天的完整crontab 运行日志和cmd日志，并存储，用于之后完善和核准例行时间。
```
cat /var/log/cron | grep -i "`which cron`" > ./all_temp
cat  ./all_temp | grep -v "<command>” > ./cmd_temp
```

-  获取所有crontab指令。
从日志中恢复一份去重的crontab log。【相当于所有的crontab命令】
```
awk -F'(' '/crond/{a[$3]=$0}END{for(i in a)print a[i]}' /var/log/cron* >crontab.txt
```
- 手工恢复：
从crontab.txt 中找出每一条指令，然后在cmd_temp 中匹配运行次数，重新编辑crontab 添加

## 反思工作
防止类似事件再次发生，写个简单shell脚本，每天对crontab进行备份，备份最近15天的数据。过期清楚
```
#!/bin/bash
# 每天对crontab 进行备份 ，同时删除最近15天的数据
DATE=$(date +%Y%m%d)

crontab -l > /home/work/bak/crontab_$DATE.bak
find /home/work/bak/ -mtime +15 -name '*.bak' -exec rm -rf {} \;
```
[ 本人小站原文链接 ](http://cuihuan.net/?p=282)
