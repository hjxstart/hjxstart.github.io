---
title: VLAN
date: 2024-01-27 11:42:02
categories: 网络
tags:
---

### VLAN

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/NetworkLab_004_VLAN.png)

#### 1. SW1 和 SW2 的互联接口类型设置为 Trunk

```shell
[SW1] vlan batch 10 20
[SW1] display vlan summary
[SW1] int g0/0/0
[SW1-g0/0/0] port link-type trunk
[SW1-g0/0/0] port trunk allow-pass vlan 10 20
```

#### 2. 交换机接入 PC 终端的接口类型改为 access 并划分到相应 VLAN

```shell
[SW1] int g0/0/1
[SW1-g0/0/1] port link-type access
[SW1-g0/0/1] port default vlan 10
[SW1-g0/0/1] dis vlan
```

#### 3. 相同 VLAN 的主机通信

```shell
ip 192.168.10.1 24
ping 192.168.10.3
```
