---
title: YII2数据库查询实践 
date: 2016-01-10 17:21:35
tags: 
- db
- active record
- yii2
---

> 初探yii2框架，对增删改查，关联查询等数据库基本操作的简单实践。

## 数据库配置。
/config/db.php 进行数据库配置
配置可以参考[ yii文档 ](http://www.yiichina.com/doc/guide/2.0/start-databases)
实践过程中有个test库-》test表-》两条记录如下
```
mysql> select * from test;
+----+--------+
| id | name   |
+----+--------+
|  1 | zhuai  |
|  2 | heng   | 
+----+--------+
18 rows in set (0.00 sec)
```

## sql 查询方式
yii2 提供了原始的数据库查询方式findBySql；同时，`通过占位符的方式，自动进行了基本的sql注入防御`。上码
```
// 最基本的查询方式
$sql = "select * from test where 1";
$res = Test::findBySql($sql)->all();
var_dump(count($res));    // res->2 

// findbysql 防止sql注入方式
$id = '1 or 1=1';
$sql = "select * from test where id = " . $id;
$res = Test::findBySql($sql)->all();
var_dump(count($res));   // res-> 2

$sql = "select * from test where id = :id";
// 定位符会自动防止sql 注入
$res = Test::findBySql($sql,array(":id"=>$id))->all();
var_dump(count($res));  // res->1

```

## activeRecord查询方式
每个框架除了原有的sql方式，都会提供相应的封装的查询方式，yii2亦然。
### 创建model
yii的model基本方式如下，代码如下不赘述。
```
<?php

namespace app\models;

use Yii;
use yii\db\ActiveRecord;


class Test extends ActiveRecord
{
    // 可无，对应表：默认类名和表名匹配，则无需此函数
    public static function tableName()
    {
        return 'test';
    }

    // 可无，验证器：主要用于校验各个字段
    public function rules(){
        return [
            ['id', 'integer'],
            ['name', 'string', 'length' => [0, 100]],
        ];
    }
}
```
使用的时候需要引入model
```
use app\models\Test;
```

### 增加操作
```
// add 操作
$test = new Test();
$test->name = 'test';

// 合法性校验
$test->validate();
if($test->hasErrors()){
    echo "数据不合法";
    die;
}
$test->save();
```
### 查询操作
查询操作先上官方文档
[ activeRecord doc](http://www.yiichina.com/doc/api/2.0/yii-db-activerecord)
[ where doc](http://www.yiichina.com/doc/api/2.0/yii-db-query#where(-detail)
需要强调的是：yii查询提供了特别多丰富的库，例如代码中的批量查询处理等等，细节可以看文档。

```
// select
// id = 1
$res = Test::find()->where(['id' => 1])->all();
var_dump(count($res));  //1

// id > 0
$res = Test::find()->where(['>','id',0])->all();
var_dump(count($res));  //2

// id > =1 id <=2
$res = Test::find()->where(['between','id',1,2])->all();
var_dump(count($res));  //2

// name字段like
$res = Test::find()->where(['like', 'name', 'cuihuan'])->all();
var_dump(count($res));  //2


// 查询的使用 obj->array
$res = Test::find()->where(['between','id',1,2])->asArray()->all();
var_dump($res[0]['id']);  //2

// 批量查询,对于大内存操作的批量查询
foreach (Test::find()->batch(1) as $test) {
    var_dump(count($test));
}
```
### 删除操作
```
// delete 
// 选出来删除
$res = Test::find()->where(['id'=>1])->all();
$res[0]->delete();

// 直接删除
var_dump(Test::deleteAll('id>:id', array(':id' => 2)));
```

### 修改操作
除了代码中方式，yii2直接提供update操作。
```
// 活动记录修改
$res = Test::find()->where(['id'=>4])->one();
$res->name = "update";
$res->save();
```

### 关联查询操作
关联查询示例中两个表:
一个学生表(student):id ，name;
一个分数表(score)：id,stu_id,score
```
// 相应学生的所有score
$stu = Student::find()->where(['name'=>'xiaozhuai'])->one();
var_dump($stu->id);

// 基本获取
$scores_1 = $stu->hasMany('app\model\Score',['stu_id'=>$stu->id])->asArray()->all();
$scores_2 = $stu->hasMany(Score::className(),['stu_id'=>'id'])->asArray()->all();
var_dump($scores_1);
var_dump($scores_2);
```
两种关联查询方式；但是，在controller进行相关操作，代码显的过于混乱，在model中封装调用

首先在student model中封装相关关联调用函数
```
<?php

namespace app\models;

use Yii;
use yii\db\ActiveRecord;


class Student extends ActiveRecord
{
    public static function tableName()
    {
        return 'student';
    }

    // 获取分数信息
    public function getScores()
    {
        $scores = $this->hasMany(Score::className(), ['stu_id' => 'id'])->asArray()->all();

        return $scores;
    }

}

```
之后直接调用，两种调用方式
```
// 函数封装之后调用
$scores = $stu->getScores();
var_dump($scores);

// 利用__get 的自动调用的方式
$scores = $stu->scores;
var_dump($scores);

```

## 最后
上面在yii2的部署和使用过程中的一些基本的增删改查，关联查询等操作。但是如果想要将yii2的db操作使用好，还要看文档大法：
[ activeRecord doc](http://www.yiichina.com/doc/api/2.0/yii-db-activerecord)

【转载请注明：[YII2数据库查询实践](http://cuihuan.net/article/yii2%E6%95%B0%E6%8D%AE%E5%BA%93%E6%9F%A5%E8%AF%A2%E5%AE%9E%E8%B7%B5.html) | [靠谱崔小拽](http://cuihuan.net) 】








