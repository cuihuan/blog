---
title: mysql数据导库常用操作 
date: 2016-03-08 17:21:35
tags: 
- mysql
---
> 工作中经常遇到：一个数据库导入新的数据库实例中，或者一个数据库中的某些表导入新的数据库中，常用操作，总结一下。

## 部分数据表导入新库
- 单表导入新库的sql为
```
# CREATE TABLE 新表 SELECT * FROM 旧表
create table `dashboard`.`xx` (select * from dashboard_stb.xxx);
```
- 多表导入新库（将所有的stability_* 导入新库）
多表的时候，只需选出需要的表即可。

```
# 拼接处所有的导出sql
mysql> select concat ('create table `dashboard`.',table_name,'(select * from `dashboard_stb`.',table_name,');') from information_schema.tables where table_name like "stability_%";
+--------------------------------------------------------------------------------------------------------+
| concat ('create table `dashboard`.',table_name,'(select * from `dashboard_stb`.',table_name,');')      |
+--------------------------------------------------------------------------------------------------------+
| create table `dashboard`.stability_capacity(select * from `dashboard_stb`.stability_capacity);         |
| create table `dashboard`.stability_dailymaxflow(select * from `dashboard_stb`.stability_dailymaxflow); |
| create table `dashboard`.stability_indextype(select * from `dashboard_stb`.stability_indextype);       |
| create table `dashboard`.stability_ktraceagent(select * from `dashboard_stb`.stability_ktraceagent);   
# 此处省略N行
+--------------------------------------------------------------------------------------------------------+
```
粘贴进去直接运行即可
```
mysql>  create table `dashboard`.stability_maccpu(select * from `dashboard_stb`.stability_maccpu);
Query OK, 138138 rows affected (2.16 sec)
Records: 138138  Duplicates: 0  Warnings: 0

mysql>  create table `dashboard`.stability_macmem(select * from `dashboard_stb`.stability_macmem);
Query OK, 138137 rows affected (2.07 sec)
Records: 138137  Duplicates: 0  Warnings: 0

mysql>  create table `dashboard`.stability_macssd(select * from `dashboard_stb`.stability_macssd);
Query OK, 138139 rows affected (2.17 sec)
Records: 138139  Duplicates: 0  Warnings: 0
# 此处省略N行
```

## 全库备份导入新库

数据库全量导出为sql
```
mysqldump -uxxx -pxxx dashboard > dashboard.sql
```
通过sql建立新库
```
# 建新库
mysql> create databases dashboard_new
# 导入数据
./mysql -uxxx -p --default-character-set=utf8 dashboard_new < dashboard.sql
```
【转载请注明：[mysql 简单全量备份和快速恢复](http://cuihuan.net/article/mysql%E6%95%B0%E6%8D%AE%E5%AF%BC%E5%BA%93%E5%B8%B8%E7%94%A8%E6%93%8D%E4%BD%9C.html) | [靠谱崔小拽](http://cuihuan.net) 】

