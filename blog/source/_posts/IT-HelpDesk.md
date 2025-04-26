---
title: IT HelpDesk
date: 2023-11-30 21:21:59
categories:
tags:
---

# 常用命令

## CMD

```bash
# 快速打开win10高级设置的run命令
sysdm.cpl
# 快速打开remote desktop connect
mstsc
# 键盘管理员打开CMD
运行 Win + R, 输入 CMD 后，按 Ctrl + Shift + Enter回车
# 查看用户账号状态命令
net user usernamexxx /domain
# 激活win10
wmic path softwarelicensingservice get OA3xOriginalProductKey
slmgr -ipk XXXX-XXXXX
slmgr -ato
# 普通用户视图下提权安装软件 需要知道administrator 的密码
runas /user:%computername%\administrator /profile "full_pathxxx.exe"
# 重新注册DNS
ipconfig /registerdns
# 刷新当前DNS
ipconfig /flushdns 
```
### 常用命令

1. 查看被占用端口对应的 PID

```ps1
netstat -aon|findstr "8081"
```

2. 查看指定 PID 的进程

```ps1
tasklist|findstr "9088"
```

3. 结束进程

```ps1
taskkill /T /F /PID 9088
```


## PsTools

> **[PsTools下载链接](https://download.sysinternals.com/files/PSTools.zip)**


```bash
# 管理员权限打开CMD，并且进入PsTools解压目录
# 运行PsExec.exe \\IP cmd 进入目标主机的CMD试图
# 使用ipconfig和hostname命令查询当前试图下的IP地址和主机名是否是目标用户的
```

## Remote Server Administration Tools for Windows 

> **[AD管理工具下载](https://www.microsoft.com/en-hk/download/details.aspx?id=45520)**

```bash
# 可以执行AD的一些操作，例如用户和电脑的权限
# 用户的账号解锁，密码重置和组的增删查改等
# 电脑的查询
```

## AD

```bash
# 同步AD策略，打开CMD执行以下命令可以同步AD策略。
gpupdate
# 查询用户的状态
net user usernameXXX /domain
```

---

# 常用软件

## Chrome

```bash
# 优化
关闭显卡，关闭后台运行，关闭预加载
# 网站排查
开启调试模式，关闭缓存，清理缓存数据
```

### 性能优化

```bashe


```

### 浏览器崩溃

### 清除缓存

### 页面不安全

---

## 会议软件

### 腾讯

### Zoom

### Teams

---

## 远程软件

### 会议软件共享远程

### msra 远程

### 系统 Remote

---

# Office 套件

## Outlook

### 性能优化

### 邮件 Archive

### 安全模式&插件

### 共享日程安排


---

# Win10 系统制作

## 环境准备

## 自封装母盘

### 自定义组件

### 系统优化

> 禁用 加密文件系统（EFS）

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202410310838397.png)

## 自定义系统设置

### 更新补丁

### 安装运行库

### 设置通知&因素

### 修改时区与时间

### 开启远程

## 安装软件

### 字体&输入法

### 浏览器

### 办公软件

## 清理环境

## 镜像封装

### 一阶封装

### 二阶封装

## 系统安装

### BIOS 设置

1. Storage: 选择 AH

### U 盘安装

### 无人值守安装

---

# Win10 系统运维

## 系统更新

### 手动更新

### 在线更新

---

## 驱动更新

### 在线更新

### 手动更新

---

## C 盘空间满

### 清除恢复空间

### 设置分页缓存

### 关闭睡眠快速重启

> powercfg.exe /h off

### 删除Windows.edb文件

> C:\ProgramData\Microsoft\Search\Data\Applications\Windows

---

## 电脑开机蓝屏

### 重启

### 卸载最新更新

### 清灰&查看内存

---

## 电脑自动重启

---

## 登录界面没有字体

---

## 电脑异响

---

# Win10 系统迁移

## 新电脑数据迁移

## 原系统数据迁移

### 磁盘镜像备份

### 磁盘镜像恢复

### 脱域和修改主机名

### 清除和安装驱动

### 验证


# Other

## Win10电脑性能优化

### 1. 禁用特效

> System Properties > Advanced > Visual Effects > Custom 打开以下配置
> 1. Enable Peek / 启用预览
> 2. Smooth edges of screen fonts / 平滑屏幕字体边缘
> 3. Show thumbnails instead of icons / 显 示缩列图，而不是显示图标

### 2. 电源计划 & 快速启动 

> Control Panel > All Control Panel Items > Power Options
> 1. 选择 Hide additional plans 

### 3. 有效内存

> Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management
> 1. DisablePagingExecutive = 1  使用内存运行程序
> 2. LargeSystemCache = 1 开启大容量换成
 
### 4. 打开最大预加载到内存里的文件数量

> powershell > mmagent
> 1. 输入 set-mmagent 回车，在输入要修改的值 8192，默认是 256


### 5. 启动项优化


### 6. Office优化

> 禁用硬件图像加速

### 7. Chrome浏览器优化

> 1. 关闭 使用图形加速功能（如果可用）”；
> 2. 关闭 Google Chrome 后继续运行后台应用；
> 3. 关闭 预加载网页。

### 8. 注册表优化


### 9. AHCI / NVME

BIOS > Storage > SATA/NVMe Operation > AHCI/NVMe




### 10. 关闭微软的遥控服务 

Connected User Experiences and Telemetry


### 11. 虚拟内存 1.5X～2.5X

> System Configuration > Boot > Advanced options > Maximum memory 去掉勾选 

> 16G 24576 - 40960
> 32G 49152 - 81920


### 12. 从信息系统项目管理师的角度看工作

```bash

1. 项目立项


2. 项目整体管理


3. 项目范围管理


4. 项目进度管理


5. 项目成本管理


6. 项目质量管理


7. 项目沟通管理


8. 项目干系人管理


9. 项目风险管理


10. 项目采购管理


11. 信息系统项目管理

```
