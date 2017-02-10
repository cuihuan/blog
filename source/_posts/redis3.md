---
title: 【redis学习三】简单高可用redis架构实践 
date: 2017-02-05 17:21:35
tags: 
- redis
- 高可用架构
- 容灾方案
- redis主从
---
> 背景：支撑线上千万级别的天级查询请求，要求高可用。

# 一、方案调研
## 1.1 redis版本选择
redis当前主流版本是redis 2.x 和 redis 3.x，3.0对集群支持比较不错，官方解释如下：
> Redis是一个开源、基于C语言、基于内存亦可持久化的高性能NoSQL数据库，同时，它还提供了多种语言的API。近日，Redis 3.0在经过6个RC版本后，其正式版终于发布了。Redis 3.0的最重要特征是对Redis集群的支持，此外，该版本相对于2.8版本在性能、稳定性等方面都有了重大提高。

综合考虑之后扩展性和稳定性之后，选择版本 `redis 3.2.3-1`版本进行部署
## 1.2 是否选择搭建集群

是否搭建集群关键要看单机是否能够满足业务需求，做了个简单的数据评估。

### 数据量评估
- **测试**：单机写入2000w业务数据，占用内存1.5g，本机126g内存
- **评估**：单机的稳定数据承载量：2000w * （126/1.56）* 0.6 = 96923w 
- **结论**：9T 的数据承载量，远超当前千万级别的数据量

### 性能评估
- **测试**：简单压测了下
 - 写操作 1000w，80% 在20ms一下 ，98%在30ms，最大218ms，qps 5w/s，总耗时197s
 - 读操作 1000w，97% 在10ms一下 ，99.99%在24ms，qps 6w/s，总耗时160s
- **评估**：当前的调用量在千万每天，qps的话在百/s。 
- **结论**：当前单机的redis完全满足需求

因此：在单机远能够满足当下业务需求的情况下，决定不采用的集群的方式来部署redis，减少技术债务风险。

## 1.3 初定方案和架构图
选定了版本和基本部署方案之后，主要考虑服务的`容灾和稳定性`，经过思考之后采用`采用极简的主从从结构，001实时同步数据002和003；001读写，002，003只读`，机构图如下

[![redis 框架架构](http://cuihuan.net/wp_content/new/redis/redis_3_framework.png)](http://cuihuan.net/wp_content/new/redis/redis_3_framework.png)
# 二、实现过程
## 2.1 redis安装
此处略去，参考官方文档 https://redis.io/
## 2.2 配置读写master
- 修改端口：port 【目的：简单的修改默认端口是最好的防攻击】
- 添加密码：pwd
- 关闭压缩：rdbcompression no 【硬盘最够，降低cpu的能耗更利于提升性能】
- 开启守护进程：daemonize yes 【master开启守护，增加稳定性】
- 关闭protect-mode :允许他机器访问
- 添加白名单：bind xxx
- 修改log地址，pid地址和数据存储地址：logfile pidfile 【便于维护和安全】
- 添加慢查询：slowlog-log-slower-than 500 【根据业务需求，便于优化】
- 最大内存限制：maxmemory 【考虑稳定性和性能，一般不超过最大内存的60%】

## 2.3 配置只读slave
- 同master
- 设置主库:slaveof ip:port
- 主库密码：masterauth masterpwd
- 只读：slave-read-only yes

## 2.4 启动测试
### 启动主库写入数据

[![redis 写入主库](http://cuihuan.net/wp_content/new/redis/redis_3_master.png)](http://cuihuan.net/wp_content/new/redis/redis_3_master.png)


### 进入从库查看
最初没有数据，主库写入之后，从库去到数据

[![redis 写入从库](http://cuihuan.net/wp_content/new/redis/redis_3_slave.png)](http://cuihuan.net/wp_content/new/redis/redis_3_slave.png)

### 查看log确认过程

[![redis log](http://cuihuan.net/wp_content/new/redis/redis_3_log.png)](http://cuihuan.net/wp_content/new/redis/redis_3_log.png)

# 三、架构能力评估
## 3.1 容灾能力

- 主动容灾
 - 备份：master 全量备份，slave全量备份。
 - 备份安全：本机保存，hadoop同步保存一份。
 - 监控和探活：监控机分钟级探活和预警
- 被动容灾：
 - slave 宕机：重启之后直接从master恢复
 - master 宕机且硬盘数据为损坏：重启后数据自动恢复且和从库一致。
 - master 宕机且数据损坏：删除损坏数据，使用slave1的数据恢复，保证数据一致。
 - master 和slave 1 同时宕机：slave2 保证读正常，业务不影响，利用slave2 数据备份恢复master，启动slave 即可
 - 三台全宕机：服务挂掉，从hadoop获取数据恢复服务。

## 3.2 性能评估
压测数据，参见方案选择，完全hold住。

# 四、问题思考
## 4.1 内存清理策略
暂时采用：
noeviction -> 谁也不删，直接在写操作时返回错误。
之后采用：
volatile-lru -> 根据LRU算法删除带有过期时间的key。 最少使用算法删除。
如果达到内存限制，手工清理，通过监控脚本监控内存情况

## 4.2 伸缩性和单节点问题
扩展slave可以直接扩展，扩展master需要master之间数据同步，暂时是个瓶颈。对于主读业务的需求，暂时问题不大；写需求的话，暂时的想法是代码转写的方式。

## 4.3 采用redis sentinal 监听
默认不错的监听，尝试了下效果不错，还在调研中，配置conf即可，完成后可以查看监听的情况
```
127.0.0.1:port> INFO Sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=redis115,status=ok,address=ip:port,slaves=2,sentinels=1
```
# 五：常用代码

```
# 强制杀死redis，模仿宕机
ps aux |grep redis |awk '{print $2}'|xargs kill -9
# 优化模拟宕机 【根据Dual-X-raY提示-_-】
redis> DEBUG SEGFAULT

# 重启，指定conf
/home/work/xxx/bin/redis-server /home/work/xxx/etc/redis.conf

# 压测，具体参数可以参考benchmark
[cuihuan@cuihuan bin]$  ./redis-benchmark -h 127.0.0.1  -p 端口 -a 密码  -c 1000 -n 10000000  -d 1024 -r 100000 -t set,get,incr,del


```

【转载请注明：[【redis学习三】简单高可用redis架构实践](http://cuihuan.net/2017/02/05/redis3/) | [靠谱崔小拽](http://cuihuan.net) 】