---
title: GO
categories: 开发
tags:
  - GO
  - 编程语言
date: 2021-08-26 11:50:00
---

## 1. 类型在变量名

函数参数声明变量`x, y int`
其他地方都是 var x, y int

```go
func add(x int, y int) int {
	return x + y
}
```

## 2. 多值返回

可以在函数声明多个返回值

```go
func swap(x, y string) (string, string) {
	return y, x
}
```

## 3. 命名返回值

命名返回值，相当于在函数顶部命名一个变量并赋值

```go
// Go 的返回值可被命名，它们会被视作定义在函数顶部的变量。
// 没有参数的 `return` 语句返回已命名的返回值。
func split(sum int) (x, y int) {
	x = sum * 4 / 9
	y = sum - x
	return
}
```

## 4.变量 var

```go
// `var` 语句用于声明一个变量列表，跟函数的参数列表一样，类型在最后。
var c, python, java bool
```

## 5.变量的初始化

```go
// 变量声明可以包含初始值，每个变量对应一个。
// 如果初始化值已存在，则可以省略类型；变量会从初始值中获得类型。
var i, j int = 1, 2

func main() {	var c, python, java = true, false, "no!"
	fmt.Println(i, j, c, python, java) // 1 2 true false no!
}
```

## 6.短变量声明

在函数中，简洁赋值语句 `:=` 可在类型明确的地方代替 `var` 声明。

```go
func main() {
	var i, j int = 1, 2
	k := 3
	c, python, java := true, false, "no!"

	fmt.Println(i, j, k, c, python, java) // 1 2 3 true false no!
}
```

## 7.基本类型

```
bool

string

int  int8  int16  int32  int64
uint uint8 uint16 uint32 uint64 uintptr

byte // uint8 的别名

rune // int32 的别名
    // 表示一个 Unicode 码点

float32 float64

complex64 complex128
```

```go
import (
	"fmt"
	"math/cmplx"
)

var (
	ToBe   bool       = false
	MaxInt uint64     = 1<<64 - 1
	z      complex128 = cmplx.Sqrt(-5 + 12i)
)

func main() {
        // Type: bool Value: false
	fmt.Printf("Type: %T Value: %v\n", ToBe, ToBe)
        // Type: uint64 Value: 18446744073709551615
	fmt.Printf("Type: %T Value: %v\n", MaxInt, MaxInt)
        // Type: complex128 Value: (2+3i)
	fmt.Printf("Type: %T Value: %v\n", z, z)
}
```

## 8.零值

没有明确初始值的变量声明会被赋予它们的 **零值**。

零值是：

* 数值类型为 `0`，
* 布尔类型为 `false`，
* 字符串为 `""`（空字符串）。

## 9.类型转换

Go 在不同类型的项之间赋值时需要显式转换。类型(值)

```
// 一些关于数值的转换：
var i int = 42
var f float64 = float64(i)
var u uint = uint(f)
// 或者，更加简单的形式：
i := 42
f := float64(i)
u := uint(f)</pre>
```

## 10.类型推导

可以省略类型，自动推导出类型

```
i := 42           // int
f := 3.142        // float64
g := 0.867 + 0.5i // complex128
```

## 11.常量

常量的声明与变量类似，只不过是使用 `const` 关键字。

常量可以是字符、字符串、布尔值或数值。

常量不能用 `:=` 语法声明。

## 12.for

Go 只有一种循环结构：`for` 循环。

Go 的 for 语句后面的三个构成部分外没有小括号， 大括号 `{ }` 则是必须的。

for 是 Go 中的 “while”

无限循环

```go
func main() {
	sum := 0
	for i := 0; i < 10; i++ {
		sum += i
	}
	fmt.Println(sum)
}
// 初始化语句和后置语句是可选的。
func main() {
	sum := 1
	for ; sum < 1000; {
		sum += sum
	}
	fmt.Println(sum)
}
// 此时你可以去掉分号，因为 C 的 `while` 在 Go 中叫做 `for`。
func main() {
	sum := 1
	for sum < 1000 {
		sum += sum
	}
	fmt.Println(sum)
}
如果省略循环条件，该循环就不会结束，因此无限循环可以写得很紧凑。
func main() {
	for {
	}
}
```

## 13.if

Go 的 `if` 语句与 `for` 循环类似，表达式外无需小括号 `( )` ，而大括号 `{ }` 则是必须的。

if 的简短语句

if 和 else

```go
func sqrt(x float64) string {
	if x < 0 {
		return sqrt(-x) + "i"
	}
	return fmt.Sprint(math.Sqrt(x))
}

// 同 `for` 一样， `if` 语句可以在条件表达式前执行一个简单的语句。
// 该语句声明的变量作用域仅在 `if` 之内。
func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	}
	return lim
}

// 在 `if` 的简短语句中声明的变量同样可以在任何对应的 `else` 块中使用。
func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	} else {
		fmt.Printf("%g >= %g\n", v, lim)
	}
	// 这里开始就不能使用 v 了
	return lim
}

```







# GO语言环境配置

```shell
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
go get golang.org/x/tools/gopls@latest
go env -w GO111MODULE=auto
```