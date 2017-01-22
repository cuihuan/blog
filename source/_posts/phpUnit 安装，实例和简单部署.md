---
title: phpUnit 安装，实例和简单部署 
date: 2015-11-28 17:21:35
tags: 
- 单元测试
- php
- phpunit
---
> 背景：一个小脚本，保证稳定为主；所以试用了下phpunit，快捷方便

### phpunit 的安装

phpunit是一个轻量级的php单元测试框架，通过pear安装
安装过程
```
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit
phpunit --version
```
成功之后显示如下:
```
cuihuan:~ cuixiaohuan$ phpunit --version
PHPUnit 4.8.6 by Sebastian Bergmann and contributors.
```

### 简单试用

测试类集成框架

**class PsCaseTest extends PHPUnit_Framework_TestCase{}**

其中phpunit
默认首先执行 setup
默认最后执行 teardown

举个栗子：
```

<?php
/***************************************************************************
 *
 * $Id: PsCaseTest,v 1.0 PsCaseTest cuihuan Exp$
 *
 **************************************************************************/

/**
 * @file PsCaseTest.php
 * @author cuihuan
 * @date 2015/09/11 10:09:31
 * @version $Revision:1.0$
 * @brief  pscase接口单元测试
 *
 **/

require_once dirname(__FILE__) . ('/PsCase.php');

class PsCaseTest extends PHPUnit_Framework_TestCase
{
    /**
     * @var object pscase类
     */
    protected $pscase;

    /**
     * @brief setup: Sets up the fixture, for example, opens a network connection.
     *
     * This method is called before a test is executed.  
     */
    public function setup(){
        $this->pscase = new PsCase();
    }

    /**
     * @brief teardown: Tears down the fixture, for example, closes a network connection.
     * 
     * This method is called after a test is executed.
     */
    public function teardown(){
    }


    /**
     * @brief : 测试config文件的获取
     *
     */
    public function testGetConfig()
    {
        $this->assertEquals(true,$this->pscase->debugText("11"));
    }
}

```

### 运行

运行方式：phpunit  —bootstrap [源文件] 测试文件 
具体如下：
```
cuihuande:newcode cuixiaohuan$ phpunit --bootstrap ./PsCase.php ./PsCaseTest.php

32015-09-11 02:09:36:11<br>
5

Time: 116 ms, Memory: 11.75Mb

OK (1 test, 1 assertion)  【表示运行成功】

```

### 部署
部署就不不赘述了，写个shell脚本，crontab天极运行，加个报警邮件，简单的单元测试ok，从此再也不用担心错误和回归测试了。

[ 个人小站原文链接 ](http://cuihuan.net/?p=260)
