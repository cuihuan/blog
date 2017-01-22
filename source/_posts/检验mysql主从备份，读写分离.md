---
title: 检验mysql主从备份，读写分离 
date: 2016-01-03 17:21:35
tags: 
- 读写分离
- 主从备份
- mysql
---

> 先说背景：mysql的主从部署，读写分离，负载均衡之后；需要简单测试和校验一下，在实践中写了个简单的php脚本和校验过程，mark一下，方便再次部署校验。


## 数据库部署和实践
数据库在实践中，`往往需要进行多机主从备份保证安全`，这个毋庸置疑；`进行读写分离和负载均衡可以极大的提升mysql的读写性能`。作者在实践中采用阿里的ameoba进行了读写分离和负载均衡操作。细节步骤参考小拽文章:[ mysql主从备份，读写分离和负载均衡实践 ](http://www.baidu.com)

那么问题来了，部署完了，校验也需慎重，下面是简单的校验过程。

## php简单读写库脚本
上码：能用代码说的，最好不用文字说话！
```
<?php
/**
 * 进行读写分离的校验
 * @notice ：需要关闭主从备份的情况下进行
 * 原理：打开主从，写主库，从库获取数据，校验主从备份；关闭主从写ameoba,校验读写分离和负载
 *
 * @author: cuixiaohuan
 * Date: 15/12/29
 * Time: 下午9:10
 */

class ReadAndWriteTest {
   
    // ameoba 设定端口,校验读写时，放主库配置
    const IP   ="ip:port";
    const PWD  ="pwd";
    const USER ="user";
    const DB   ="db";

    public function __construct(){
        error_reporting(E_ALL ^ E_DEPRECATED);

        $this->initDb();
        $this->_writeTest();
        $this->_selectTest();
    }


    /**
     * 进行10次读操作
     */
    public function _selectTest(){
        for ($i = 0; $i < 10; $i++) {
            $read_sql = 'select * from test limit 10';
            $g_result = mysql_query($read_sql);
            var_dump($g_result);
            mysql_free_result($g_result);
        }
    }

    /**
     * 进行10次写操作
     */
    public function _writeTest(){
        for ($i = 0; $i < 10; $i++) {
            $id        = uniqid();
            $content   = "pingce" . uniqid();
            $write_sql = 'INSERT INTO `test`(`test`, `test1`) VALUES ("' . $id . '","' . $content . '")';
            $g_result = mysql_query($write_sql);
            var_dump($g_result);
        }
    }

    /**
     * 初始化数据库连接信息 info
     */
    private function initDb()
    {
        $crowd_conn = mysql_pconnect(self::IP, self::USER, self::PWD);
        if (!$crowd_conn) {
            die("Could not connect:" . mysql_error());
        }

        $crowd_db = mysql_select_db(self::DB, $crowd_conn);
    }
}

$rw = new ReadAndWriteTest();
```

## 主从备份校验
- 开启slave
- 调整数据库信息为mysql，主库信息，运行脚本。
- 查看从库的log，有如下写入操作，说明实时主从备份成功。
```
151231 15:36:21 4 Query start slave
14 Connect Out pingce@10.95.112.120:3666
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e5c85","pingce5684d957e5cf2")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e7937","pingce5684d957e7982")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e8e96","pingce5684d957e8ee4")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957ea2c2","pingce5684d957ea2eb")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eb565","pingce5684d957eb5b3")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957ec7ee","pingce5684d957ec83e")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eda2f","pingce5684d957eda78")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eeca4","pingce5684d957eecf0")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eff16","pingce5684d957eff61")
15 Query COMMIT /* implicit, from Xid_log_event */
15 Query BEGIN
15 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957f121e","pingce5684d957f126d")
15 Query COMMIT /* implicit, from Xid_log_event */
```
## 检验读写分离

- 读写分离，首先需要关闭从机器上的slave。原因：存在主从的话，无法通过log查看出读写分离操作。
``` 
mysql> stop slave;
Query OK, 0 rows affected (0.08 sec)
```
- 运行脚本：如下信息标示，运行成功。
```
[cuixiaohuan TestScript]$ /home/work/lamp/php5/bin/php ReadAndWriteTest.php
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e5c85","pingce5684d957e5cf2")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e7937","pingce5684d957e7982")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e8e96","pingce5684d957e8ee4")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957ea2c2","pingce5684d957ea2eb")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eb565","pingce5684d957eb5b3")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957ec7ee","pingce5684d957ec83e")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eda2f","pingce5684d957eda78")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eeca4","pingce5684d957eecf0")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eff16","pingce5684d957eff61")bool(true)
INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957f121e","pingce5684d957f126d")bool(true)
resource(5) of type (mysql result)
resource(6) of type (mysql result)
resource(7) of type (mysql result)
resource(8) of type (mysql result)
resource(9) of type (mysql result)
resource(10) of type (mysql result)
resource(11) of type (mysql result)
resource(12) of type (mysql result)
resource(13) of type (mysql result)
resource(14) of type (mysql result)
```

- 查询读写库的log
> 解释：之所以主库放一个读写库，是因为有些要求超高一致性的数据，备份可能会有延迟；所以，主库承担读写操作，和高负载。
```
#读写机器log：  进行了10次写和 四次读
151231 15:29:27 19 Query set names gbk^@
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e5c85","pingce5684d957e5cf2")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e7937","pingce5684d957e7982")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957e8e96","pingce5684d957e8ee4")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957ea2c2","pingce5684d957ea2eb")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eb565","pingce5684d957eb5b3")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957ec7ee","pingce5684d957ec83e")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eda2f","pingce5684d957eda78")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eeca4","pingce5684d957eecf0")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957eff16","pingce5684d957eff61")
19 Query INSERT INTO `test`(`test`, `test1`) VALUES ("5684d957f121e","pingce5684d957f126d")
19 Query select * from test limit 10
151231 15:29:28 19 Query select * from test limit 10
19 Query select * from test limit 10
19 Query select * from test limit 10
19 Query select * from test limit 10
```
- 查看读库的log
```
# 只进行了读操作，校正了数据库的读写分离操作。
151231 15:29:20 4 Query stop slave
151231 15:29:27 3 Query set names gbk^@
3 Query select * from test limit 10
3 Query select * from test limit 10
3 Query select * from test limit 10
3 Query select * from test limit 10
3 Query select * from test limit 10
3 Query select * from test limit 10
```

## 最后
一句话：打开slave，校验主从备份；关闭slave，校验读写分离。

【转载请注明：[ 检验mysql主从备份，读写分离 ](http://cuihuan.net/article/%E6%A3%80%E9%AA%8Cmysql%E4%B8%BB%E4%BB%8E%E5%A4%87%E4%BB%BD%EF%BC%8C%E8%AF%BB%E5%86%99%E5%88%86%E7%A6%BB.html) | [靠谱崔小拽](http://cuihuan.net) 】


