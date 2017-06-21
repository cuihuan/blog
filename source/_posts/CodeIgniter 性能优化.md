---
title: CodeIgniter 性能优化
date: 2017-06-05 23:21:35
tags: 
- php
- 性能优化
- codeIgniter
---
> 背景：部署一套PHP微服务接口，需要兼顾性能，开发效率，未来扩展性。选择了CodeIgniter；同时优化框架的默认启动项，在qps1000+的压力下整个`启动时间优化到5ms`以内。

## 一、选型
- 背景：使用php作为微服务的接口，具有一定的性能要求和并发要求。
- 方案：
 - 1：选一个轻量的php框架。最好是具有简单高效的路由，模块化即可。
 - 2：在框架的基础上，自定义的优化

### 1.1 从压测数据看性能
https://www.ruilog.com/blog/view/b6f0e42cf705.html
具体细节就不赘述，除了直接写php之外，ci和lumen的并发性能不错，在考虑范围内。

[![ci performance](http://cuihuan.net/wp_content/new/codeIgniter/performance.png)](http://cuihuan.net/wp_content/new/codeIgniter/performance.png)

### 1.2 从流行度上看。

排名前四的是laravel,symfony,ci,yii2。最火的是laravel毋庸置疑。但前四均在考虑范围内

[![ci github](http://cuihuan.net/wp_content/new/codeIgniter/githup_php.png)](http://cuihuan.net/wp_content/new/codeIgniter/githup_php.png)

### 1.3 从文档来看。
laraval,ci,yii的中文社区都还不错。

综合考虑之后，在满足功能的情况下，选择性能最好，也易入手的codeIgniter作为基础框架。（`整个包才2.5M，删除了web文件夹后更小`）


## 二、30ms+到10ms
框架的基本部署，直接参考官网：https://codeigniter.org.cn/


### 2.1 问题描述
配置了数据库之后，添加了一个默认的controller，一个model，默认加载时间竟然30ms—_-。瞬间懵逼了，nginx+fpm 1-2ms，框架竟然30ms，肯定那里配置错了，决定沿着路由追一下。

### 2.2 问题追查
沿着ci的路由顺序追查，从index入，一步一步卡时间。[`括号内为运行到的总计数`]

-》index.php [`1ms`]
-》core/CodeIgniter.php
-》加载常量[`1ms`] 
-》加载common(包括log，show，error,is_https等)[1ms]load hooks [`2ms`] 
-》加载autoload 方法 
-》加载benchmark 
-》实例化hooks 
-》实例化pre_controller
-》实例化post_controller_constructor
-》实例化post_controller
-》实例化post_system
-》加载config [`3ms`]
-》加载扩展mbstring,iconv,hash,stardard
-》load 组件utf8，uri
-》load router [`4ms`]
-》load output，input，lang[`5ms`]
-》autoload package,cinfig,helper,language,driver,lib,model,db,cache
-》404 &empty$...handle [`31ms`]
-》controller remap（测试性能写了个remap）[`35ms`]
-》controller 业务逻辑 [`35ms`]

这个ci的加载过程之后，基本一幕了然，在autoload里面耗时25ms。然后对autoload里面8个组件一个一个分析。

### 2.3 问题原因
分析完之后，问题特别简单，下面这行代码
```
$autoload['libraries'] = array('database');
```
ci 出于单例和复用角度考虑，选择`默认加载database`，也就是mysql在默认初始化。对于mysql链接在并发情况下，init基本上要耗费10-30ms，干掉之后，压测基本上在10ms左右。

压测数据图


## 三、从10ms到5ms
### 3.1 优化目标
抛出了配置等常用错误后，ci在高并发下依然有10ms左右的加载时间，需要结合自身逻辑优化下，干掉很多不需要的功能。

### 3.2 分析
之前在追查问题的过程中，粗读了一遍代码的流程，这次需要细看下每个模块的功能，干掉不需要的，逐步优化。


-》index.php 
- 作用：加载了部分全局变量，文件路径等入口
- 优化：干掉了整个web文件，调整了部分路径

-》core/CodeIgniter.php
- 作用：ci的核心文件，基本上加载了整个模块
- 优化：进入内部优化

-》加载common.php
- 作用：框架特别基本的一些函数log，show，error，is_xxx等，800行左右代码
- 优化：暂时未处理

-》composer autoload func 
-》加载benchmark 
- 作用：benchmark性能追查工具，设置了全局的开始和结束时间
- 优化：`直接干掉`，全局处理。但是性能需要卡，就在index中初始化了一个入库的timer
```
// 定义全局开始追查
list($msec, $sec) = explode(' ', microtime());
define('START_TIME', (float)sprintf('%.0f', (floatval($msec) + floatval($sec)) * 1000));
// 定义全局uuid
define('UUID', uniqid('xxx', true));

```
-》实例化hooks和预变量 
- 作用：设计特别棒，对于一些hook或者针对不同模块的预加载函数。
- 优化：`直接干掉`，7,8个hook后期用到再针对性添加

-》加载config 
- 作用：对应的是ci的get_config等函数，加载了base_url,uri,cache path等 。
- 优化：`直接干掉`，全局变量占用需要自己加就行，这种不可控的干掉

-》加载扩展mbstring,iconv,hash,stardard
- 作用：一些额外的扩展。
- 优化：`直接干掉`，试了下干掉对功能不影响，ci写的太全面了，后期可以通过加载自己的lib弥补。

-》load 组件utf8，uri
- 作用：uri路由方式处理，utf8的处理。
- 优化：`直接干掉`。

-》load router [`4ms`]
- 作用：路由。
- 优化：`干不掉`。
- 额外：laravel 据说是使用COC最好的框架，看了下ci的router也不错，基本上都是遵循COC

-》load output，input
- 作用：output和浏览器交互输出的处理组件，input包括获取数据array_merge等等。
- 优化：`干掉`,需要自己写

-》autoload package,cinfig,helper,language,driver,lib,model,db,cache
- 作用：各种各样的组建了。
- 优化：全`不`加载

-》404 &empty$...handle 
- 作用：异常处理。
- 优化：加载

-》controller remap（测试性能写了个remap）
- 作用：指向其他controller。
- 优化：无

-》controller 业务逻辑 

到此将整个框架过程优化完成，初始一下4-5ms感觉还不错。

## 四、压测数据

### 4.1 高并发压测

2000qps+ ，均值约6ms

### 4.2 长时间高负载压测
1500qps 10min，均值约6ms

超时分布
[![time_distribute](http://cuihuan.net/wp_content/new/codeIgniter/time_distribute.png)](http://cuihuan.net/wp_content/new/codeIgniter/time_distribute.png)

### 4.3 无限发压
nginx + php 均值：17ms
框架均值：9ms
[![nginx_time](http://cuihuan.net/wp_content/new/codeIgniter/nginx_time.png)](http://cuihuan.net/wp_content/new/codeIgniter/nginx_time.png)

## 五、汇总
ci 是一个比较优秀的轻量级MVC框架，可以用来，业能否支撑1000-2000pqs的业务接口。
最后来一张ci的路由图
[![all](http://cuihuan.net/wp_content/new/codeIgniter/all.png)](http://cuihuan.net/wp_content/new/codeIgniter/all.png)


```

【转载请注明：[【CodeIgniter 性能优化](http://cuihuan.net/2017/06/05/CodeIgniter 性能优化/) | [靠谱崔小拽](http://cuihuan.net) 】