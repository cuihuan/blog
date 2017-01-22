---
title: php反射调用private方法实践 
date: 2015-12-20 17:21:35
tags: 
- 单元测试
- php
- phpunit
---
> 问题背景：单测中有个普遍性的问题，`被侧类中的private方法无法直接调用`。小拽在处理过程中通过`反射改变方法权限，进行单测`，分享一下，直接上代码。

## 简单被测试类
生成一个简单的被测试类，只有个private方法。

```
<?php

/**
 * 崔小涣单测的基本模板。
 *
 * @author cuihuan
 * @date 2015/11/12 22:15:31
 * @version $Revision:1.0$
 **/

class MyClass {

    /**
     * 私有方法
     *
     * @param $params
     * @return bool
     */
    private function privateFunc($params){
        if(!isset($params)){
            return false;
        }
        echo "test success";
        return $params;
    }
}
```

## 单测代码 

```
<?php
/***************************************************************************
 *
 * $Id: MyClassTest T,v 1.0 PsCaseTest cuihuan Exp$
 *
 **************************************************************************/

/**
 * 崔小涣单测的基本模板。 
 * 
 * @author cuihuan
 * @date 2015/11/12 22:09:31
 * @version $Revision:1.0$
 **/

require_once ('./MyClass.php');

class MyClassTest extends PHPUnit_Framework_TestCase {
    const CLASS_NAME = 'MyClass';
    const FAIL       = 'fail';

    protected $objMyClass;
    
    /**
     * @brief setup: Sets up the fixture, for example, opens a network connection.
     *
     * 可以看做phpunit的构造函数
     */
    public function setup() {
        date_default_timezone_set('PRC');
        $this->objMyClass = new MyClass();
    }

    /**
     * 利用反射，对类中的private 和 protect 方法进行单元测试
     *
     * @param $strMethodName  string  ：反射函数名
     * @return ReflectionMethod obj   ：回调对象
     */
    protected static function getPrivateMethod($strMethodName) {
        $objReflectClass = new ReflectionClass(self::CLASS_NAME);
        $method          = $objReflectClass->getMethod($strMethodName);
        $method->setAccessible(true);
        return $method;
    }


    /**
     * @brief :测试private函数的调用
     */
    public function testPrivateFunc()
    {
        $testCase = 'just a test string';

        // 反射该类
        $testFunc = self::getPrivateMethod('privateFunc');
        $res = $testFunc->invokeArgs($this->objMyClass, array($testCase));

        $this->assertEquals($testCase, $res);
        $this->expectOutputRegex('/success/i');
        
        // 捕获没有参数异常测试
        try {
             $testFunc->invokeArgs($this->transfer2Pscase, array());
        } catch (Exception $expected) {
            $this->assertNotNull($expected);
            return true;
        }

        $this->fail(self::FAIL);
    }
    
}
```

##运行结果
```
cuihuan:test cuixiaohuan$ phpunit MyClassTest.php 
PHPUnit 4.8.6 by Sebastian Bergmann and contributors.


Time: 103 ms, Memory: 11.75Mb

OK (1 test, 3 assertions)
```

## 关键代码分析

封装了一个，被测类方法的反射调用；同时，`返回方法之前处理方法的接入权限为true`，便可以访问private的函数方法。
```
/**
 * 利用反射，对类中的private 和 protect 方法进行单元测试
 *
 * @param $strMethodName  string  ：反射函数名
 * @return ReflectionMethod obj   ：回调对象
 */
protected static function getPrivateMethod($strMethodName) {
    $objReflectClass = new ReflectionClass(self::CLASS_NAME);
    $method          = $objReflectClass->getMethod($strMethodName);
    $method->setAccessible(true);
    return $method;
}

```

【转载请注明：[phpunit单测中调用private方法处理](http://cuihuan.net/article/phpunit%E5%8D%95%E6%B5%8B%E4%B8%AD%E8%B0%83%E7%94%A8private%E6%96%B9%E6%B3%95%E5%A4%84%E7%90%86.html) | [靠谱崔小拽](http://cuihuan.net) 】

