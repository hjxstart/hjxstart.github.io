---
title: ESXI+ROS+WDS+MDT
date: 2024-07-28 21:33:05
categories:
tags: IT Helpdesk
---

# 概述

> 搭建一套自动化批量安装 Windows 电脑的服务

# ESXI 安装与配置

## 硬件环境概述

> 畅网 N305 多网口迷你小主机一台
> 32G DDR5 4800MHZ 内存条一根
> 长城 1TB M.2 PCIE 3.0 固态硬盘一根
> 网线 2 根, PEU 盘一个, 鼠标键盘一套

## 安装

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222224148.png)
![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222224320.png)
![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222224521.png)

1. 按 Enter 继续安装

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222224705.png)

2. 按 F11 接受许可

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222225551.png)

3. 按 Enter 选择硬盘

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222225341.png)

4. 按 Enter 重启

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222225745.png)

5. 选择 OS

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222225912.png)

6. 输入管理员密码

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222230033.png)

7. 选择 F11 Install

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222230241.png)

8. 重启

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222230445.png)

9. 管理员登录

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222230753.png)

10. 选择修改管理网络

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222230951.png)

11. 打开网络设备

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222231317.png)

12. 选择管理口

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222231628.png)

13. 选择 IPv4

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222231733.png)

14. 设置静态 IP

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231222232011.png)

15. ESC 退出和保存配置，就可以使用浏览器通过 IP 地址访问 ESXI 了

16. 网卡直通，过滤出可直通的设备，选择除管理网卡外的网络直通

---

# ROS 安装与配置

## 安装

1. 创建 Linux4.x 以上的系统

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS-创建虚拟机1.png)

2. 自定义配置和锁定 1G 及以上内存

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS-新建虚拟机2.png)

3. 添加 PCIE 设备

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS-新建虚拟机3.png)

4. 配置虚拟机引导方式为 BIOS 启动，点击下一步，最后点击完成

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS-新建虚拟机4.png)

5. 将 ROS 官网下载的 VDMK 硬盘上次，并添加到 ROS 虚拟机后，点击保存

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS-新建虚拟机5.png)

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS-新建虚拟机5.2.png)

6. 修改 VMDK 的打开和磁盘模式后，点击和打开虚拟机去配置即可。

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS-新建虚拟机6.png)

## ROS 快速配置

---

# WDS 安装与配置

```shell
# 修改主机名
# 修改静态IP
# 关闭防火墙
# 打开远程连接
# 安装WDS
# 配置WDS()
```

# MDT 安装与配置

## Rules

```shell
[Settings]
Priority=Default
Properties=MyCustomProperty

[Default]
OSInstall=YES
_SMSTSOrgName=CICCHK
SkipBDDWelcome=YES
SkipCapture=YES
SkipAdminPassword=YES
AdminPassword=XXX
SkipAppsOnUpgrade=YES
SkipProductKey=YES
SkipComputerBackup=YES
SkipBitLocker=YES
SkipComputerName=YES
ComputerName=CICCHK
SkipDomainMembership=YES
SkipTaskSequence=YES
TaskSequenceID=Test
SkipTimeZone=YES
TimeZoneName=China Standard Time
SkipLocaleSelection=YES
KeyboardLocale=en-US
UserLocale=en-US
UILanguage=en-US
SkipLocalSelection=YES
SkipUserData=YES
SkipSummary=YES
HideShell=YES
FinishAction=LOGOFF
```

## Bootstrap

```shell
[Default]
DeployRoot=\\WDS\DeploymentShare$
SkipBDDWelcome=YES
UserDomain=workgroup
UserID=administrator
UserPassword=
KeyboardLocale=en-US
```
