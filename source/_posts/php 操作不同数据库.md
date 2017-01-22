---
title: php 操作不同数据库 
date: 2015-11-30 17:21:35
tags: 
- 数据库同步
- mysql
- php
---
> php脚本经常，处理处理不同机器上，不同数据库之间数据；而且脚本特别容易写错，抽取了个工作中最常用到的多库同步，特此记忆！

## 上代码
举个php操作不同数据库，进行数据同步的栗子。
```
    /**
     * 同步库1的数据到库2
     * 
     * @author  ：cuihuan
     * @date    ：2015-10-11
     */
    public function synchDbDiff()
    {
        // 连接库1
        $crowd_conn_1 = mysql_connect('ip_1:port_1', 'name_1', 'pw_1');
        if (!$crowd_conn_1) {
            die("Could not connect:" . mysql_error());
        }

        mysql_select_db('test_data', $crowd_conn_1);

        // 连接库2
        $crowd_conn_2 = mysql_connect('ip_2:port_2', 'name_2', 'pw_2');
        if (!$crowd_conn_1) {
            die("Could not connect:" . mysql_error());
        }

        mysql_select_db('test_data', $crowd_conn_2);


        //获取未同步的数据
        $get_data_sql = "SELECT `id`, `text` FROM `fb_conversation` WHERE `flag` = 1";
        $c_result = mysql_query($get_data_sql, $crowd_conn_1);
        $this->check_res($c_result);
        if ($c_result) {
            while ($row = mysql_fetch_array($c_result, MYSQL_NUM)) {

                // 更新同步
                $new_data_sql = "update from fb_conversation set text =" . $row[1] . "  where id = " . $row[0];
                $res = mysql_query($new_data_sql, $crowd_conn_2);
                $this->check_res($c_result);
            }
        }
    }
```

[ 个人小站原文链接 ]( http://cuihuan.net/?p=275 )

