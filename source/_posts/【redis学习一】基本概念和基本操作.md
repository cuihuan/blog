---
title: 【redis学习一】基本概念和基本操作 
date: 2015-11-28 17:21:35
tags: 
- redis
---
## redis 基础
**官网地址**：[ http://redis.io/ ](http://redis.io/)

**基本介绍**：redis 是一个ansi c编写，支持网络的，基于内存的可持久化的日执行，kv数据库；10年期redis有vmare主持开发。

支持数据类型：redis支持strings,hashes list set sorted等结构。

持久化：存储于内存或虚拟内存中，有两种持久化的方式：
- ：截图，内存数据不断写入硬盘【性能较高】
- ：log：记录每次更新的日志。【稳定性好】

支持主从同步，性能非常优秀。
提供多种语言的api  基本上知道的都有。

使用场景：(个人觉的可以有的使用场景)
1：权限【权限每次都要入库校验，放在前端不靠谱，放在cache最合适】
2：缓存【例如批量操作数据，可以先缓存】
3：预取【例如topN数据,另外可能用到的数据，提前取出来，加快页面加载】
4：构建消息队列【可以根据redis的数据结构list，构造；数据批量入库，加快页面相应等方面不错】。
5：计数器【类似于批量入库的原理，可以计数，redis原子性的，可以精确支持】
6：其他场景还在不断探索中。

## 安装和基本操作
安装参考：[ http://www.runoob.com/redis/redis-install.html ](http://www.runoob.com/redis/redis-install.html)

基本操作：[ 官方文档地址 ](http://redisdoc.com/)

启动：./redis-server
关闭：redis-cli shutdown
```
[cuihuan bin]$ ./redis-cli shutdown
[cuihuan bin]$ ./redis-server    
[325] 24 Sep 18:49:06.632 # Warning: no config file specified, using the default config. In order to specify a config file use ./redis-server /path/to/redis.conf
                _._                                                 
           _.-``__ ''-._                                            
      _.-``    `.  `_.  ''-._           Redis 2.6.10 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                  
 (    '      ,       .-`  | `,    )     Running in stand alone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 325
  `-._    `-._  `-./  _.-'    _.-'                                  
 |`-._`-._    `-.__.-'    _.-'_.-'|                                 
 |    `-._`-._        _.-'_.-'    |           http://redis.io       
  `-._    `-._`-.__.-'_.-'    _.-'                                  
 |`-._`-._    `-.__.-'    _.-'_.-'|                                 
 |    `-._`-._        _.-'_.-'    |                                 
  `-._    `-._`-.__.-'_.-'    _.-'                                  
      `-._    `-.__.-'    _.-'                                      
          `-._        _.-'                                          
              `-.__.-'                                              

[325] 24 Sep 18:49:06.633 # Server started, Redis version 2.6.10
[325] 24 Sep 18:49:06.633 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
[325] 24 Sep 18:49:06.673 * DB loaded from disk: 0.039 seconds
[325] 24 Sep 18:49:06.673 * The server is now ready to accept connections on port 6379

```
安装成功的标志 redis-cli 可以成功进入   

```
[cuihuan bin]$ ./redis-cli
redis 127.0.0.1:6379>
```
> 注意：使用过程中如果是保密性高的数据，可以设置登录密码，增加安全想；但如果是简单数据，则可以不设置，优点就是速度稍快。

redis 基本配置：
daemonize: yes 标示在后台运行
bind：绑定请求的地址
port：端口号，默认6379
timeout:默认客户端连接超时  多长时间不操作关闭(默认永久，此处改为3600)

loglevel: log等级
databases：默认连接数据库的个数 【此处为8】
slaveof 主从库

masterauth :密码验证
requirepass:是否需要密码

maxclients :最大客户机个数 设置为10000
maxmemory:最大内存个数 6625156  [机器内存32G,分配大约6g]


最基本的操作
set name xxx
get name xxx
del name xxx
exists name xxx

举个栗子
```
# get val
redis 127.0.0.1:6379> get name
"cuixiaohuan"

# set val 
redis 127.0.0.1:6379> set name cuixiaohuan_2 
OK
redis 127.0.0.1:6379> get name
"cuixiaohuan_2"

# check exists; if exists return 1
redis 127.0.0.1:6379> exists name
(integer) 1

# del val
redis 127.0.0.1:6379> del name
(integer) 1
redis 127.0.0.1:6379> get name
(nil)
```

其他常用操作：
```
# ping :check connect
redis 127.0.0.1:6379> ping
PONG

# dbsize :check size
redis 127.0.0.1:6379> dbsize
(integer) 1

#flush :clear db
redis 127.0.0.1:6379> dbsize
(integer) 1
redis 127.0.0.1:6379> flushdb
OK
redis 127.0.0.1:6379> dbsize
(integer) 0

```
[ 个人小站原文链接 ](http://cuihuan.net/?p=266)
