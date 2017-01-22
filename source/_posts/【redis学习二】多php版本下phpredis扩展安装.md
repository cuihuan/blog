---
title: 【redis学习二】多php版本下phpredis扩展安装 
date: 2015-11-28 17:21:35
tags: 
- redis
- phpredis
- php
---

> 背景：安装完redis之后，需要安装phpredis扩展，才能让php操作redis；本机有多个php版本，安装过程中遇到的坑分享一下。

##一 下载
git上下载redis的扩展包
    git clone https://github.com/nicolasff/phpredis

##二 挂载和configure
   在shell中输入 phpize 【注意：多个php版本的时候需要指定】
     ./configure 
【phpize是用来扩展php扩展模块的，通过phpize可以建立php的外挂模块】

注意：（phpize 如果包含多个php，必须指定位置）
    cuihuan:phpredis cuixiaohuan$ ../php/bin/phpize
    Configuring for:
    PHP Api Version:         20121113
    Zend Module Api No:      20121212
    Zend Extension Api No:   220121212
    Cannot find autoconf. Please check your autoconf installation and the
    $PHP_AUTOCONF environment variable. Then, rerun this script.

报错的话需要安装：brew install autoconf  [phpize 报错] 否则没有phpize  
    [work@cuixiaozhuai phpredis]$ ../php/bin/phpize        
    Configuring for:
    PHP Api Version:         20041225
    Zend Module Api No:      20060613
    Zend Extension Api No:   220060519
    [work@cuixiaozhuai phpredis]$  ./configure --with-php-config=/home/work/thirdparty/php5/bin/php-config 

当存在多个版本的php的时候，需要指定配置文件
     ./configure --with-php-config=/home/work/thirdparty/php5/bin/php-config 

##三 编译和安装
 make  之后最好make test  
   make install
    cuihuan:phpredis cuixiaohuan$ make
    。。。
    Build complete.
    Don't forget to run 'make test'.

    cuihuan:phpredis cuixiaohuan$ make test
    cuihuan:phpredis cuixiaohuan$ make install

##四 问题修复
【已修复，但是原因可能不太准确】
make编译报错
    .libs/redis_cluster.o(.data.rel.local+0x0): In function `ht_free_seed':
    /home/work/thirdparty/php5/php5/phpredis/redis_cluster.c:226:     multiple definition of `arginfo_scan'
    .libs/redis.o(.data.rel.local+0xe0):/home/work/thirdparty/php5/php5/p hpredis/redis.c:452: first defined here
    /usr/bin/ld: Warning: size of symbol `arginfo_scan' changed from 160 in .libs/redis.o to 200 in .libs/redis_cluster.o
    .libs/redis_cluster.o(.data.rel.local+0xe0): In function `create_cluster_context':
    /home/work/thirdparty/php5/php5/phpredis/redis_cluster.c:276:     multiple definition of `arginfo_kscan'
    .libs/redis.o(.data.rel.local+0x0):/home/work/thirdparty/php5/php5/phpredis/redis.c:364: first defined here
    collect2: ld returned 1 exit status
    make: *** [redis.la] Error 1

最初以为是php多个版本生成install问题，采用./configure 指定php版本，指定php位置。
但是效果还是有问题。
最终通过修改redis_cluester.c 中，注释掉了这两个重复的
      40 

      41 /* Argument info for HSCAN, SSCAN, HSCAN */

      42 /*ZEND_BEGIN_ARG_INFO_EX(arginfo_kscan, 0, 0, 2)

      43     ZEND_ARG_INFO(0, str_key)

      44     ZEND_ARG_INFO(1, i_iterator)

      45     ZEND_ARG_INFO(0, str_pattern)

      46     ZEND_ARG_INFO(0, i_count)

      47 ZEND_END_ARG_INFO();

      48 */

      49 

      50 /* Argument infor for SCAN */

      51 /*

      52 ZEND_BEGIN_ARG_INFO_EX(arginfo_scan, 0, 0, 2)

      53     ZEND_ARG_INFO(1, i_iterator)

      54     ZEND_ARG_INFO(0, str_node)

      55     ZEND_ARG_INFO(0, str_pattern)

      56     ZEND_ARG_INFO(0, i_count)

      57 ZEND_END_ARG_INFO();

      58 */
      
      
##五 简单测试

    <?php
        $redis = new Redis();
        $conn = $redis->connect('127.0.0.1',6379);

        echo "redis pass and status show</br>";
        var_dump($redis->ping());

        $redis->set('test_key','test_value');
        echo "test set val=".$redis->get('test_key')."</br>";

        $redis->setnx('unique_key',"unique_val");
        $redis->setnx('unique_key',"unique_val_2");

        echo $redis->get("unique_key");

        sleep(60);
        echo 'is exist'.$redis->exists('test_60s');
        echo 'not has value'.$redis->get('test_60s');
        $redis->delete('test_key','test_60s');

[ 个人小站原文链接 ](http://cuihuan.net/?p=248)