---
title: LLDP
date: 2024-01-27 11:31:16
categories: 网络
tags:
---

### LLDP

![LLDP](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/NetworkLab_003_LLDP.png)

#### 1. 路由器互联接口配置同网段 IP 地址

```shell
[R1] int g0/0/0
[R1-g0/0/0] ip add 12.1.1.1 24
[R2] int g0/0/0
[R2-g0/0/0] ip add 12.1.1.2 24
```

#### 2. 在系统视图下开启 LLDP

```shell
[R1] lldp enable
[R2] lldp enable
```

#### 3. 查看 LLDP 邻居信息

```shell
display lldp neighbor
```
