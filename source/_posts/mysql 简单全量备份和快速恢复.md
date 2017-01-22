---
title: mysql 简单全量备份和快速恢复 
date: 2015-12-11 17:21:35
tags: 
- 备份
- mysql
---

> 一个简单的mysql全量备份脚本，备份最近15天的数据。

## 备份
```
#每天备份mysql数据库(保存最近15天的数据脚本)
DATE=$(date +%Y%m%d)
/home/cuixiaohuan/lamp/mysql5/bin/mysqldump -uuser -ppassword need_db > /home/cuixiaohuan/bak_sql/mysql_dbxx_$DATE.sql;
find /home/cuixiaohuan/bak_sql/ -mtime +15 -name '*.sql' -exec rm -rf {} \;
```

## 恢复
mysql 数据导入
```
drop databases need_db;
create databases need_db;
```
导入数据：必须设定编码进行恢复
```
./mysql -uroot -p --default-character-set=utf8 need_db < xx.sql

```

【转载请注明：[mysql 简单全量备份和快速恢复](http://cuihuan.net/article/mysql-%E7%AE%80%E5%8D%95%E5%85%A8%E9%87%8F%E5%A4%87%E4%BB%BD%E5%92%8C%E5%BF%AB%E9%80%9F%E6%81%A2%E5%A4%8D.html) | [靠谱崔小拽](http://cuihuan.net) 】