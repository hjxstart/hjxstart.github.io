---
title: CCNP Lab
date: 2023-06-01 10:46:26
categories: 网络
tags: 
- 思科网络实验
- Cisco
---

## 简单的 SLA 实验

使用 SLA 检测主链路的连接状态，实现主备链路的动态切换功能。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202306111953555.png)

<details>
  <summary>配置概述</summary>

```bash
1. 配置接口IP
2. 配置除目标网络的主备路由的其他路由信息
3. 配置SLA
4. 配置Track 23 ip sla 23
5. 配置主静态路由tarck 23
6. 配置备份静态路由 permanent
```

</details>

<details>
  <summary>R1</summary>

```bash
>
enable
#
configure terminal
hostname R1
##
interface ethernet 0/0
ip address 12.1.1.1 255.255.255.0
no shutdown
exit
#
interface ethernet 0/1
ip address 13.1.1.1 255.255.255.0
no shutdown
exit
#
ip route 2.2.2.2 255.255.255.255 ethernet 0/0 12.1.1.2
ip route 3.3.3.3 255.255.255.255 ethernet 0/1 13.1.1.3
```

</details>

<details>
  <summary>R2</summary>

```bash
>
enable
#
configure terminal
hostname R2
#
interface ethernet 0/0
ip address 12.1.1.2 255.255.255.0
no shutdown
exit
#
interface ethernet 0/1
ip address 23.1.1.2 255.255.255.0
no shutdown
exit
#
interface loopback 0
ip address 2.2.2.2 255.255.255.255
exit
#
ip route 13.1.1.0 255.255.255.0 ethernet 0/0 12.1.1.1
ip route 3.3.3.0 255.255.255.0 etheret 0/1 23.1.1.3 permanent
#
ip sla 23
icmp-echo 13.1.1.3 source 12.1.1.2
frequency 5
threshold 1000
timeout 2000
exit
#
ip sla schedule 23 start-time now life forever
track 23 ip sla 23 reachability
exit
#
ip route 3.3.3.3 255.255.255.255 ethernet 0/0 12.1.1.1 track 23

```

</details>

<details>
  <summary>R3</summary>

```bash
>
enable
#
configure terminal
hostname R3
#
interface ethernet 0/0
ip address 13.1.1.3 255.255.255.0
no shutdown
exit
#
interface ethernet 0/1
ip address 23.1.1.3 255.255.255.0
no shutdown
exit
#
interface loopback 0
ip address 3.3.3.3 255.255.255.255
exit
#
ip route 12.1.1.2 255.255.255.255 ethernet 0/0 13.1.1.1
ip route 2.2..2.0 255.255.255.0 ethernet 0/1 23.1.1.2 permanent
#
ip sla 23
icmp-echo 12.1.1.2 source-ip 13.1.1.3
frequency 5
threshold 1000
timeout 2000
exit
#
ip sla schedule 23 start-time now life forever
track 23 ip sla 23 reachability
exit
#
ip route 2.2.2.2 255.255.255.255 ethernet 0/0 13.1.1.1 track 23
```

</details>

<details>
  <summary>测试验证</summary>

```shell
# tarcert
traceroute 3.3.3.3 source 2.2.2.2 numeric
# ping
ping 3.3.3.3 source 2.2.2.2 repeat 10000
# show
show ip sla statistics
show run | section track
```

</details>

---

## SLA 和路由递归查询

路由递归查询的场景；静态路由联动 SLA 检测工具实现自动化切换；路由非直连下一跳与递归的应用。
若 R2 去往 R3 背后的 100 个网络，有 R1(主)和 R4(备)的 2 条路径，可使用递归查询的方式，只需要在 R2 上面写 100 条路由下一跳为 R3 e0/1 的递归路由和 2 条主备路由即可，

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202306112037348.png)

<details>
  <summary>配置概述</summary>

```bash
1. 配置接口IP和环回地址
2. 配置去往R3背后网络的静态路由(不可以配置出接口)
3. 配置备份路径的静态路由，修改管理距离为10
4. 配置SLA,SLA的检查路径1= R2 0/0 到 R1 e0/1, 路径2= R3 0/1 到 R1 e0/0
5. 配置track 23 ip sla 23
6. 配置主路径的静态路由 track
# 配置非直连下一跳的静态路由的时候不要携带出接口信息
```

</details>

<details>
  <summary>R1</summary>

```bash
>
enable
#
configure terminal
hostname R1
#
interface ethernet 0/0
ip address 124.1.1.1 255.255.255.0
no shutdown
#
interface ethernet 0/1
ip address 134.1.1.1 255.255.255.0
no shutdown
exit
#
ip route 2.2.2.2 255.255.255.255 ethernet 0/0 124.1.1.2
ip route 3.3.3.3 255.255.255.255 ethernet 0/1 134.1.1.3
#
```

</details>

<details>
  <summary>R2</summary>

```bash
>
enable
#
configure terminal
hostname R2
#
interface ethernet 0/0
ip address 124.1.1.2 255.255.255.0
no shutdown
#
interface loopback 0
ip address 2.2.2.2 255.255.255.255
exit
#
ip route 3.3.3.3 255.255.255.255 134.1.1.3
ip route 134.1.1.0 255.255.255.0 ethernet 0/0 124.1.1.4
#
ip sla 2011
icmp-echo 134.1.1.1 source-ip 124.1.1.2
frequency 5
threshold 1000
timeout 2000
exit
ip sla schedule 2011 start-time now life forever
track 21 ip sla 2011 reachability
exit
ip route 134.1.1.3 255.255.255.255 ethernet 0/0 124.1.1.1 track 21
#
```

</details>

<details>
  <summary>R3</summary>

```bash
>
enable
#
configure terminal
hostname R3
#
interface ethernet 0/0
ip address 124.1.1.4 255.255.255.0
no shutdown
#
interface ehternet 0/1
ip address 134.1.1.4 255.255.255.0
no shutdown
#
ip route 2.2.2.2 255.255.255.255 ethernet 0/0 124.1.1.2
ip route 3.3.3.3 255.255.255.255 ethernet 0/1 134.1.1.3
#
ip sla 3010
icmp-echo 124.1.1.1 source-ip 134.1.1.3
frequency 5
threshold 1000
timeout 2000
exit
ip sla schedule 3010 start-time now life forever
track 31 ip sla 3010 reachability
exit
ip route 124.1.1.2 255.255.255.255 ethernet 0/0 134.1.1.1 track 31
```

</details>

<details>
  <summary>R4</summary>

```bash
>
enable
#
configure terminal
hostname R4
#
interface ethernet 0/0
ip address 134.1.1.3 255.255.255.255
no shutdown
#
interface loopback 0
ip address 3.3.3.3.3 255.255.255.255
exit
#
ip route 2.2.2.2 255.255.255.255 124.1.1.2
ip route 124.1.1.0 255.255.255.0 ethernet 0/0 134.1.1.4
#

```

</details>

<details>
  <summary>测试验证</summary>

```shell
show ip sla sta
show ip sla sum
```

</details>

---

## 动态路由协议

实验概述。

![实验拓扑]()

<details>
  <summary>配置概述</summary>

```bash
1.
```

xxxxxxxxxx ​bash

<details>
  <summary>R1</summary>

```bash
#
enable
configure terminal
hostname R1
```

</details>

<details>
  <summary>测试验证</summary>

</details>

---

## 实验模板

实验概述。

![实验拓扑]()

<details>
  <summary>配置概述</summary>

```bash
1.
```

</details>

<details>
  <summary>R1</summary>

```bash
#
enable
configure terminal
hostname R1
```

</details>

<details>
  <summary>测试验证</summary>

</details>
