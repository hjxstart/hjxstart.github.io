---
title: cisp-practice03
date: 2025-08-23 19:33:12
categories: 安全
tags: cisp
---

## 03Windows访问控制列表配置实验

### **1、实验要求**

（1）所有部门的员工智能进入本部门文件夹和public（公共类区域）

（2）每个部门的部门经理对部门有写入权限，部门员工只能读取

（3）总经理可以参与所有的部门，也可以完全控制

（4）public文件夹，所有员工可以读取，经理可以写入

### **2、实验分析**

成员角色：

```
- 技术部：技术经理、技术员工
- 财务部：财务经理、财务员工
- 销售部：销售经理、销售员工
- 经理：总经理、销售经理、技术经理、财务经理
```

访问规则：

```
public文件夹访问规则：总经理、技术经理、财务经理、销售经理具有完全读写、修改权限；技术部员工、财务部员工、销售部员工只能查看。
jishubu文件夹访问规则：总经理、技术经理具有完全读写、修改权限；技术部员工仅具有查看权限
caiwubu文件夹访问规则：总经理、财务经理具有完全读写、修改权限；财务部员工仅具有查看权限
xiaoshoubu文件夹访问规则：总经理、销售经理具有完全读写
```

文件夹权限设置：

```
方便起见，文件创建在D:\之下！！
- public：经理组读写权限、技术部可读权限、财务部可读权限、销售部可读权限
- jishubu：技术部组可读权限、技术经理读写权限、总经理读写权限
- caiwubu：财务部组可读权限、财务经理读写权限、总经理读写权限
- xiaoshoubu：销售部组可读权限、销售经理读写权限、总经理读写权限
```

### **3、实验步骤**

**（1）命令创建用户、组并将用户划分到指定的组中**

```shell
# 创建组
net localgroup jishubu /add
net localgroup caiwubu /add
net localgroup xiaoshoubu /add
net localgroup jingli /add
```

![创建组](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823140438226.png)



```bash
# 创建用户
net user jishubujl 123.com /add
net user jishubuyg 123.com /add
net user caiwubujl 123.com /add
net user caiwubuyg 123.com /add
net user xiaoshoubujl 123.com /add
net user xiaoshoubuyg 123.com /add
net user zongjingli 123.com /add
```

![创建用户](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823140755381.png)



```bash
# 划分用户到组中
net localgroup jishubu jishubujl /add
net localgroup jishubu jishubuyg /add
net localgroup caiwubu caiwubujl /add
net localgroup caiwubu caiwubuyg /add
net localgroup xiaoshoubu xiaoshoubujl /add
net localgroup xiaoshoubu xiaoshoubuyg /add
net localgroup jingli zongjingli /add
net localgroup jingli jishubujl /add
net localgroup jingli caiwubujl /add
net localgroup jingli xiaoshoubujl /add
```

![用户添加到组中](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823141029076.png)



**（2）设置public文件夹权限**

​	打开属性界面在【安全】的【高级属性】界面中取消【继承权限】，再删除无用组，添加目的组或用户，并设置相关权限。

**（3）设置jishubu文件权限**

​	打开属性界面在【安全】的【高级属性】界面中取消【继承权限】，再删除无用组，添加目的组或用户，并设置相关权限。

**（4）设置caiwubu文件权限**

​	打开属性界面在【安全】的【高级属性】界面中取消【继承权限】，再删除无用组，添加目的组或用户，并设置相关权限。

**（5）设置xiaoshoubu文件权限**

​	打开属性界面在【安全】的【高级属性】界面中取消【继承权限】，再删除无用组，添加目的组或用户，并设置相关权限。

```bash
# 切换到D盘
cd /d D:
# 创建public jishubu caiwubu xiaoshoubu 四个目录
md public jishubu caiwubu xiaoshoubu
# 禁用继承并保留现有权限：icacls "目录路径" /inheritance:r
# 权限控制：禁用继承后，可通过 /grant 或 /deny 添加新权限，
# 如果需要让权限应用到目录下的所有子目录和文件，添加 /T 参数：
icacls "public" /inheritance:r /grant "mz":(F)  /T
icacls "public" /grant "jingli":(M) /grant "jishubu":(R) /grant "caiwubu":(R) /grant "xiaoshoubu":(R)
/T
icacls "jishubu" /inheritance:r /grant "mz":(F)  /T
icacls "jishubu" /grant "zongjingli":(M) /grant "jishubujl":(M) /grant "jishubuyg":(R)  /T
icacls "caiwubu" /inheritance:r /grant "mz":(F)  /T
icacls "caiwubu" /grant "zongjingli":(M) /grant "caiwubujl":(M) /grant "caiwubuyg":(R)  /T
icacls "xiaoshoubu" /inheritance:r /grant "mz":(F)  /T
icacls "xiaoshoubu" /grant "zongjingli":(M) /grant "xiaoshoubujl":(M) /grant "xiaoshoubuyg":(R)  /T
# 不保留MZ管理员权限的情况下
icacls "public" /inheritance:r /grant "jinli":(F) /grant "jishubu":(R) /grant "caiwubu":(R) /grant "xiaoshoubu":(R)  /T
icacls "jishubu" /inheritance:r /grant "zongjingli":(F) /grant "jishubujl":(F) /grant "jishubuyg":(R)  /T
icacls "caiwubu" /inheritance:r /grant "zongjingli":(F) /grant "caiwubujl":(F) /grant "caiwubuyg":(R) /T
icacls "xiaoshoubu" /inheritance:r /grant "zongjingli":(F) /grant "xiaoshoubujl":(F) /grant "xiaoshoubuyg":(R)  /T
```

保留MZ管理员情况下

![保留MZ管理员权限](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823151835816.png)

不保留MZ管理员的情况下

![创建目录和设置权限1](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823150125799.png)

### **4、实验结果验证**

（1）切换caiwubujl用户登录并查看对caiwubu文件夹的访问权限

（2）caiwubujl用户访问jishubu文件夹

（3）caiwubujl操作public文件夹

![caiwubujl权限](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823152900701.png)

（4）切换caiwubuyg用户访问caiwubu文件夹

（5）caiwubuyg用户访问jishubu文件夹

（6）caiwubuyg用户访问public文件夹

![caiwubuyg权限](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823153521457.png)

（7）切换zongjingli用户访问caiwubu文件夹

（8）zongjingli用户访问jishubu文件夹

（9）zongjingli用户访问public文件夹

![zongjingli权限](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823154407316.png)

### **5、实验总结**

对于文件或文件夹权限设置步骤：

（1）确定文件夹的类型（各个用户对该文件夹的访问权限）

（2）确定用户组，将用户划分到组中（需要整体考虑文件数量、扩展性等）

（3）创建用户、组

（4）将用户划分到组中

（5）分别为每个文件夹分配权限

（6）登录不同账户验证权限设置效果

### **6、收尾**

（1）删除目录

```bash
rd /s/q public jishubu xiaoshoubu caiwubu
```



![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823154606668.png)

（2）删除用户

```shell
net user jishubujl /del
net user jishubuyg /del
net user caiwubujl /del
net user caiwubuyg /del
net user xiaoshoubujl /del
net user xiaoshoubuyg /del
net user zongjingli /del
```

![删除用户](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823154753437.png)

（3）删除组

```bash
net localgroup jishubu /del
net localgroup caiwubu /del
net localgroup xiaoshoubu /del
net localgroup jingli /del
```

![删除组](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823154820352.png)
