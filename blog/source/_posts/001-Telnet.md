---
title: 001-Telnet
date: 2024-01-27 10:45:39
categories: 网络
tags:
---

### Telnet

![Telnet](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/NetworkLab_001_Telnet.png)

#### 1. 路由器互联接口配置同网段 IP 地址

```shell
[R1] int g0/0/0
[R1-g0/0/0] ip add 12.1.1.1 24
[R2] int g0/0/0
[R2-g0/0/0] ip add 12.1.1.2 24
```

#### 2. 在被登录设备上配置 Telnet

```shell
# 配置 AAA 认证试图下，配置本地 Telnet 登录用户 hjxstart 和密码 HCIE
[R2] aaa
[R2-aaa] local-user `hjxstart` privilege level `3` password cipher `HCIE`
[R2-aaa] local-user `hjxstart` service-type `telnet`
# 在被登录设备上，开启 Telnet 服务器
[R2] `telnet` server enable
# 在被登录设备上，配置同一时间运行接入的虚拟终端数为 5
[R2] user-interface vty 0 4
[R2-ui-vty0-4] authentication-mode aaa
```

#### 3. 在发起登录设备 AR1 上 telent 登录被登录设备 AR2

```shell
<R1> telnet 12.1.1.2
```
