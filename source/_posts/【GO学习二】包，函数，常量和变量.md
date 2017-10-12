---
title: 【GO学习二】包，函数，常量和变量
date: 2017-10-07 23:12:35
tags: 
- golang
- 语言学习
---
> 主要介绍go语言的基本元素，包引入，变量，函数声明

## 引入包：

go语言通过import引入包
最佳实践：`import顺序：系统package，第三方package，程序自己的package`
```
package main

import (
   "fmt"
   "math"
)

func main() {
   fmt.Printf("math test number %g ",math.Sqrt(7))
}


# 运行输出
cuixiaozhuai:main cuixiaohuan$ ./hello
math test number 2.6457513110645907
```

## 函数定义

go中函数可以没有参数或者接受多个参数

### 基本格式 
```
func xx(AA type,aa) Type {
}
```

```
package main

import (
   "fmt"
)

func funcNoParams() string {
   return "Hello no params func"
}

func add(x int, y int) int {
   return x + y
}
func main() {
   fmt.Println(funcNoParams())
   fmt.Println(add(3, 3))
}

cuixiaozhuai:main cuixiaohuan$ ./hello
Hello no params func
6

```
### func 可以多值返回

```
func swap(a, b string) (string, string) {
   return b, a
}

func main() {
   a, b := swap("cuihuan_first", "cuihuan_second");
   fmt.Println(a, b)
}

cuixiaozhuai:main cuixiaohuan$ ./hello
cuihuan_second cuihuan_first
```


## 变量操作
go 中通过var 定义变量，参数在前，类型在后

```
var boolVal, boolVal2 bool

func main() {
   var intVal int
   var stringVal string
   fmt.Println(boolVal, boolVal2, intVal, stringVal)
}

cuixiaozhuai:main cuixiaohuan$ ./hello
false false 0
```
### 变量默认值

没有赋值的时候会给上默认值。

```
var boolVal, boolVal2 bool = true, false

func main() {
   // 声明类型
   var intVal int = 33
   var stringVal string = "xiaozhuai string"
   fmt.Println(boolVal, boolVal2, intVal, stringVal)

   // 不声明类型
   var undefineType1,undefineType2,undefineType3 = "yo yo yo","qiekenao",666
   fmt.Println(undefineType1, undefineType2, undefineType3)
}

cuixiaozhuai:main cuixiaohuan$ ./hello
true false 33 xiaozhuai string
yo yo yo qiekenao 666
```

### := 赋值
函数中的赋值可以用 ：=代替var  【:= 标示声明又赋值，但是只能用于函数内】

```
var boolVal, boolVal2 bool = true, false

func main() {
   // 声明类型
   var intVal int = 33
   var stringVal string = "xiaozhuai string"
   fmt.Println(boolVal, boolVal2, intVal, stringVal)

   // 不声明类型 ：= 声明赋值
   undefineType1,undefineType2,undefineType3 := "yo yo yo","qiekenao",666
   fmt.Println(undefineType1, undefineType2, undefineType3)
}
```
注意：=  简介赋值，但是无法，声明，赋值，定义类型。和var的区别
函数外，必须用var func等等


### 变量基本类型
```
func main() {

   // go 变量全部类型和默认值
   var boolVal bool
   fmt.Println("bool default:",boolVal)

   var stringVal string
   fmt.Println("string default:",stringVal)

   // int 在32位上默认32 64位默认64，uint 和 uintptr类似
   var intVal int
   var int8Val int8
   var int16Val int16
   var int32Val int32
   var int64Val int64
   fmt.Println("int default:",intVal)
   fmt.Println("int8 default:",int8Val)
   fmt.Println("int16 default:",int16Val)
   fmt.Println("int32 default:",int32Val)
   fmt.Println("int64 default:",int64Val)
   fmt.Println("max int 64:", uint64(1<<64-1))

   var uintVal uint
   var uint8Val uint8
   var uint16Val uint16
   var uint32Val uint32
   var uint64Val uint64
   var uintptrVal uintptr
   fmt.Println("uint default:",uintVal)
   fmt.Println("uint8 default:",uint8Val)
   fmt.Println("uint16 default:",uint16Val)
   fmt.Println("uint32 default:",uint32Val)
   fmt.Println("uint64 default:",uint64Val)
   fmt.Println("uintptr default:",uintptrVal)

   // uint8 别名
   var byteVal byte
   fmt.Println("byte default:",byteVal)

   // int 32 别名，代表一个unicode
   var runeVal rune
   fmt.Println("rune default:",runeVal)

   // int 32 别名，代表一个unicode
   var floatVal float32
   fmt.Println("floatVal default:",floatVal)

   // int 32 别名，代表一个unicode
   var complexVal complex64
   fmt.Println("complex64Val default:",complexVal)
}

cuixiaozhuai:main cuixiaohuan$ ./hello
bool default: false
string default:
int default: 0
int8 default: 0
int16 default: 0
int32 default: 0
int64 default: 0
max int 64: 18446744073709551615
uint default: 0
uint8 default: 0
uint16 default: 0
uint32 default: 0
uint64 default: 0
uintptr default: 0
byte default: 0
rune default: 0
floatVal default: 0
complex64Val default: (0+0i)
```
int 类型的零值 是0 bool 默认false  字符串为”" 空字符串

18446744073709551615 byte 到底多大 【2097152TB】
int 64 可以表示200wTB的数据，那么问题来了，PB的数据如何表示，float
这里也可以通俗的理解下：数据库中的int（11）类型作为主键，基本不用担心满，200wTB*8 的数据量，足以


### 变量类型推导：
```
func main() {
   v := 666
   f := 666.666
   s := "string 666"
   i := v
   fmt.Printf("666 is of type %T\n", v)
   fmt.Printf("666.666 is of type %T\n", f)
   fmt.Printf("'string666' is of type %T\n", s)
   fmt.Printf("传递 is of type %T\n", i)
}

# 需要注意的是，go中属于强类型，一旦定义之后就不允许改变为其他类型。
cuixiaozhuai:main cuixiaohuan$ ./hello
666 is of type int
666.666 is of type float64
'string666' is of type string
传递 is of type int
```
另外变量的官方参考文档：
https://golang.org/ref/spec#Constant_expressions

## 常量：const
go中常量不能用：=
go中常量可以是字符，字符串，布尔和数字类型的值
```
const PI = 3.14

func main() {
   const test = "test const";
   fmt.Println(test, PI);
}
cuixiaozhuai:main cuixiaohuan$ ./hello
test const 3.14
```

