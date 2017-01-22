---
title: fsck修复linux文件损坏 
date: 2016-08-20 17:21:35
tags: 
- git修复
- linux
---

>`数据一定要备份，最好多机备份，代码一定要ci`。

## 背景和损失
背景：机房事故，突然关机，硬盘年老失修，造成很多文件不可用。如图


[![11441496-18D2-4576-8F5F-C2BF7B84F458](http://cuihuan.net/wp-content/uploads/2016/08/11441496-18D2-4576-8F5F-C2BF7B84F458-300x84.png)](http://cuihuan.net/wp-content/uploads/2016/08/11441496-18D2-4576-8F5F-C2BF7B84F458.png)


面临损失：
作为一名靠谱程序员，数据库单机多机备份，程序版本控制这些都是有的【如果没有，一定要加上】；但这次有一个重要影响，就是git中commit之后，没有push的文件全损坏了，损坏了，坏了，了。。。。

## 分析原因
op给出的说法是网络波动，造成机房故障，机器重启。但从结果看，文件系统乱掉了，而且乱掉的文件主要分两类：
- 1：当时正在写入和操作的文件。例如运行的脚本，正在写的文件，samba建立网络映射的文件，git实时文件。
- 2：内存里的数据，例如memcache里的数据等等



## 处理：fsck修复。
###1：查看硬盘挂载：
df查看下磁盘的挂载位置。

[![F60D7BE5-D89D-4C74-9927-6EE2DD6157DF](http://cuihuan.net/wp-content/uploads/2016/08/F60D7BE5-D89D-4C74-9927-6EE2DD6157DF-300x51.png)](http://cuihuan.net/wp-content/uploads/2016/08/F60D7BE5-D89D-4C74-9927-6EE2DD6157DF.png)
### 2：操作挂起：`不挂起可能会出现数据恢复中断`。
报错：直接挂起会出现 dev is busy，如下图
[![59423A93-F29C-4A30-AB92-17408E9E6556](http://cuihuan.net/wp-content/uploads/2016/08/59423A93-F29C-4A30-AB92-17408E9E6556-300x40.png)](http://cuihuan.net/wp-content/uploads/2016/08/59423A93-F29C-4A30-AB92-17408E9E6556.png)
用：umout -l /dev/sda3
[![3C64703C-CF4A-47EB-9FE3-91CD7542E8FA](http://cuihuan.net/wp-content/uploads/2016/08/3C64703C-CF4A-47EB-9FE3-91CD7542E8FA-300x46.png)](http://cuihuan.net/wp-content/uploads/2016/08/3C64703C-CF4A-47EB-9FE3-91CD7542E8FA.png)
```
#umount -l <挂载点|设备>

此命令将会断开设备并关闭打开该设备的全部句柄。
通常，您可以使用 eject <挂载点|设备>命令弹出碟片
```
### 3：fsck 扫盘
```
fsck -f /dev/sda3
```
注意ext2 还会进行e2fsck 再扫一遍，此为正常操作
[![C9347418-9644-4841-9A2C-3FFB1157E5D8](http://cuihuan.net/wp-content/uploads/2016/08/C9347418-9644-4841-9A2C-3FFB1157E5D8-300x83.png)](http://cuihuan.net/wp-content/uploads/2016/08/C9347418-9644-4841-9A2C-3FFB1157E5D8.png)
### 4：扫盘结束后，挂载驱动盘


### 5：寻找和恢复文件
把.git 内的文件全部整理，导出，一个一个寻找自己需要的文件，找到了久违的文件。
[![3B14EF17-2C86-411F-BF16-4FFC15637C4D](http://cuihuan.net/wp-content/uploads/2016/08/3B14EF17-2C86-411F-BF16-4FFC15637C4D-300x109.png)](http://cuihuan.net/wp-content/uploads/2016/08/3B14EF17-2C86-411F-BF16-4FFC15637C4D.png)

## 后续
一句话：`代码一定要ci，数据一定要容灾`

【转载请注明：[fsck修复linux文件损坏](http://cuihuan.net/?p=474) | [靠谱崔小拽](http://cuihuan.net) 】







