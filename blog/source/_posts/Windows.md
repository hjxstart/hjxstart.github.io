---
title: Windows
date: 2025-08-24 11:19:05
categories: 运维
tags: Windows
top: 30
---





# Windosw7

## 虚拟机安装

```bash
# VM16pro，安装系统2C4G60G，删除打印机，工作网络，稍后提示，mz/aa
Windows7 企业版
# 安装VM Tools工具的补丁
windows6.1-kb4474419-v3-x64_b5614c6cea5cb4e198717789633dca16308ef79c.msu
# 禁用 Windows update
services.msc
启动类型：禁用；恢复：无操作
# 关闭 配置自动更新
gpedit.msc
管理模版 > Windows组件 > Windows Uupdate >> 配置自动更新 （已禁用）
# 关闭防火墙
控制面板\系统和安全\Windows 防火墙\自定义设置
# 压缩出一个D盘30G左右
# 克隆多一台WIn7虚拟机，并修改主机名mz-PC2
```



---

# Windows Server 2019

## 虚拟机安装

```bash
# 桌面体验版，30G系统盘，aA1234
D潘
# 桌面优化
图标
# VMTools
安装 VMTools
# 关闭防火墙
控制面板\系统和安全\Windows 防火墙\自定义设置
# 关闭更新
gpedit.msc
管理模版 > Windows组件 > Windows Uupdate >> 配置自动更新 （已禁用）
# 无须按 Ctrl + Alt + Del交互式登录
gpedit.msc > Windows设置 > 安全设置 > 本地策略 > 安全选项 > 交互式登陆：无须按Ctrl + Alt + Del （已启用）
# 快照

# 克隆&修改主机名
```

---

# Dos命令

## 文件&目录

### dir 查看目录文件

```bat
dir # 查看当前目录文件
dir /w # 只显示名字
dir /s # 显示当前目录和子目录的所以文件
dis /a # 也显示隐藏文件
dir /s /p # 显示当前目录和子目录的所以文件 / 翻页
```



### md 创建目录

```bat
md test # 创建test目录
md a/b/c # 创建a/b/c多层目录
md public jishubu caiwubu xiaoshoubu # 批量创建四个目录
```



### cd 进入目录

```bat
cd path # 进入目录
cd / # 返回盘根目录
cd /d [盘符]:/path # 直接跨盘符调整指定目录 
```



### rd 删除目录

```bat
rd /s test # 删除 test目录[需要确认]
rd /s/q a\b\c # 确定删除a\b\c目录[不用一个一个交互式确认删除]
rd public jishubu caiwubu xiaoshoubu # 批量删除四个目录
```



### cd> 创建文件

```bat
cd> aa.txt # 创建aa.txt文件
cd> a\aa.txt # 在a路径下创建aa.txt文件
```



### echo 输入文件内容

```bat
echo whoami > aa.txt # 往aa.txt文件覆盖写入内容whoami
echo whoami >> aa.txt # 往aa.txt文件追加写入内容whoami
echo whoami > a\aa.txt # 往a目录下的aa.txt文件覆盖写入内容whoami
```



### type 查看文件内容

```bat
type aa.txt # 查看aa.txt文件内容
```



### del 删除文件

```bat
del aa.txt # 删除 aa.txt 文件
```



### copy 复制文件

```bat
copy aa.txt test # 将aa.txt文件拷贝到test目录中
copy test\aa.txt bb.txt # 拷贝test目录下的aa.txt文件到根目录并修改为bb.txt文件
```



### ren 修改文件名

```bat
ren bb.txt cc.txt # 将 bb.txt 修改为 cc.txt
ren test\aa.txt bb.txt # 将test目录下的aa.txt 修改为bb.txt [后面不需要指定目录]
```



## 用户&组

### 用户

```bat
# 1、查看用户
whoami /user # 查看当前用户
vmic useraccount get name,sid # 查看所以账号的名称和sid
net user  # 查看所有用户
net user admin # 查看admin用户信息
# 2、启用或禁用指定用户
net user admin /active:yes # 启用admin用户
net user admin /active:no #  禁用admin用户
# 3、命令创建用户
net user mz aa123456 /add  # 创建用户mz 密码为aa123456
# 4、命令重置用户密码
net user mz "" # 将mz用户密码重置为空
# 5、修改用户密码
net user mz 123456 # 将mz用户的密码修改为123456
# 6、命令删除用户
net user mz /del # 删除mz用户
```



### 组

```bat
# 1、查看本地用户组
net localgroup 
# 2、命令创建 group1 组
net localgroup group1 /add
# 3、命令删除 group1 组
net localgroup group1 /del
# 4、命令添加 mz 用户到指定 group1 组
net localgroup group1 mz /add
# 5、把指定 mz用户踢出 group1 组
net localgroup group1 mz /del
```



## 文件系统&权限

### 文件系统&权限

```
Windowe系统格式：CDFS/UDF/FAT12/FAT16/FAT32/NTFS
NTFS (New Technology File System 新技术文件系统)

默认继承权限；可以通过禁用继承，修改权限和主体；
aa/bb: 如果aa禁用了继承，并修改权限；bb没有禁用继承，则bb会继承aa的权限；
cc/dd：如果dd禁用了继承，并修改权限；cc没有禁用继承，dd的权限保持不变；
```



### icacls 命令

```bat
## icacls "目录路径" [/参数] [用户/组:权限] [/选项]
#目录路径：需操作的目标目录（含空格时需用引号包裹）。
#参数：控制操作类型（如 /grant、/deny、/remove）。
#用户/组：指定权限对象（支持友好名称或 SID 格式，如 Administrators 或 *S-1-5-32-544）。
#权限：定义访问权限（如 F 完全控制、M 修改、RX 读取执行）。
#选项：控制操作范围（如 /T 递归、/C 继续错误、/Q 静默模式）。
# (I)(OI)(CI)(F)： 继承父目录权限，且对子文件（OI）和子文件夹（CI）生效

## 1、查看当前权限
icacls "C:\Data"

## 2、修改权限
# 授予权限：为 Users 组授予目录及其子项的读取和执行权限（/T 递归生效）。
icacls "C:\Data" /grant "Users":(RX) /T
# 拒绝权限：显式拒绝 Guest 用户对目录的写入权限（优先于其他权限）。
icacls "C:\Data" /deny "Guest":(W)
# 删除权限：从 ACL 中移除 Everyone 组的所有权限条目。
icacls "C:\Data" /remove "Everyone"

## 3、继承权限
# 禁用继承并移除继承权限：目录将不再继承父目录权限，并删除所有已继承的权限条目。
icacls "C:\Data" /inheritance:r
# 禁用继承但保留权限：恢复继承父目录权限的设置。
icacls "C:\Data" /inheritance:d

## 4、备份与恢复权限
# 备份 ACL 到文件：将目录及其子项的 ACL 保存到文本文件，供后续恢复使用。
icacls "C:\Data" /save "C:\Backup\Data_ACL.txt" /T
# 从文件恢复 ACL：恢复目录及其子项的 ACL 为备份时的状态。
icacls "C:\Data" /restore "C:\Backup\Data_ACL.txt"

## 5、重置权限为默认继承
# 删除所有显式设置的权限，恢复为父目录的继承设置（慎用，可能导致权限丢失）。
icacls "C:\Data" /reset /T

## 典型应用{"OI,CI": "影响未来子文件和目录", "RWD": "不可以执行和修改权限其他都可", "/T": "需要递归现存的子孙文件和目录"}
icacls "public" /inheritance:r /grant "owner":(OI)(CI)(F) /grant "admin":(OI)(CI)(M|[RX,W,D]) /grant "group_rwd":(OI)(CI)(R,W,D) /grant "group_rx":(OI)(CI)(RX) /grant "group_r":(OI)(CI)(R) /T
```

### **权限掩码说明**

|   权限   |                             含义                             |
| :------: | :----------------------------------------------------------: |
|   `F`    | 完全控制（Full Control）：包含所有其他权限（`M` + `RX` + `W` + `D` + `WDAC`） |
|   `M`    | 修改（Modify）：`RX` + `W` + `D`（可读写、执行、删除，但**不能更改权限或所有者**）。 |
|   `RX`   | 读取和执行（Read and Execute）：`R` + 执行权限（对目录需遍历权限）& 执行程序 |
|   `R`    |        只读（Read-only）：查看文件内容 & 列出目录内容        |
|   `W`    |        只写（Write-only）：修改文件内容 & 创建新文件         |
|   `D`    |    删除（Delete）：删除 & 重命名文件（需同时有 `W` 权限）    |
|  `WDAC`  | 写入 DAC（Write Data Access Control List）：允许修改文件的 **安全描述符**（即 ACL 本身） |
| **`OI`** | 子文件（子对象）/ **不递归** / 影响指定的目录及其**未来子项（动态继承）** |
| **`CI`** | 子文件夹（容器）/ **不递归** / 影响指定的目录及其**未来子项（动态继承）** |
| **`/T`** | 目录及所有子项 / **递归** / 影响当前目录及所有**现有子项（静态修改）** |
| **`GR`** | **通用读取**：允许用户查看目录内容或文件内容，但不允许修改或执行 |
| **`GE`** |   **通用执行**：允许用户运行可执行文件或访问目录中的子内容   |
| **`IO`** | **（更推荐用`/inheritance`）**仅继承：当需要确保某个权限仅对子对象生效，而不对父目录本身生效时使用 |
|    I     |           继承权限（只读）：查看权限时标识继承状态           |



## 其他

```bat
cls # 清屏
ver # 查看当前dos版本
chkdsk # 检查当前磁盘，chkdsk d: 检查D盘
time # 显示时间
date # 显示日期
certmgr # 证书管理窗口
mstsc # 打开远程窗口
explorer # 文件管理器
calc # 计时器工具
cleanmgr # 磁盘清理工具
gpedit # 本地组策略编辑器
lusrmgr # 本地用户和组
notepad # 打开记事本
regedit # 注册表
sfc # 检查文件， sfc /SCANNOW 
taskmgr # 任务管理器
write # 写字板
help = command /? # 查看有什么命令
color 0a # 修改cmd窗口颜色
```



---



# 练习

### 练习1

---

# 漏洞

## 0001 5次shift漏洞



## 0002 永恒之蓝

