---
title: 【GO学习一】 Hello World
date: 2017-10-06 21:21:35
tags: 
- golang
- 语言学习
---
> 最近项目中需要开发`抗并发的db proxy，API GATEWAY`等；同时，随着虚拟化的过程中出现各种问题。作为一个老程序员，go语言的学习，已经刻不容缓。

# 一、基础背景
Go是Google开发的一种`静态强类型、编译型、并发型`，并`具有垃圾回收`功能的编程语言

对于go语言的特性，网上大牛总结，对于个人来说特别看重`语言交互和并发性`：
- 自动垃圾回收
- 更丰富的内置类型
- 函数多返回值
- 错误处理
- 匿名函数和闭包
- 类型和接口
- 并发编程
- 反射
- 语言交互性

# 二、安装
建议参考：
http://dmdgeeker.com/goBook/docs/ch01/install.html

需要注意的是 gopath一定要配置，配置到自己的workspace即可：
```
# go path change by cuihuan
export GOPATH=/Users/cuixiaohuan/Desktop/workspace/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOPATH
```

workspace的基本目录规范可以参考：https://go-zh.org/doc/code.html

- src 目录包含Go的源文件，它们被组织成包（每个目录都对应一个包），
- pkg 目录包含包对象，
- bin 目录包含可执行命令。


# 三、hello world

## 代码
```
package main
import "fmt"

func main() {
   fmt.Println("Hello World")
}
```
语言简述：
1：package 是必须的，对于独立运行的执行文件，必须是package main
2：import 表示引入的包，或者库
3：程序中的主函数
4：执行函数

## 运行：
```
cuixiaozhuai:main cuixiaohuan$ go build hello.go
cuixiaozhuai:main cuixiaohuan$ ./hello
Hello World
```
编译和运行都非常简单，而且比较方便的是跨平台编译

```
# mac 下编译
cuixiaozhuai:main cuixiaohuan$ env GOOS=linux GOARCH=amd64 GOARM=7 go build hello.go 

# linux 开发机运行
[work@xx.com ~]$ ./hello
Hello World
```

【转载请注明：[【GO学习一】 Hello World](http://cuihuan.net/2017/10/06/【GO学习一】%20Hello%20World/) | [靠谱崔小拽](http://cuihuan.net) 】