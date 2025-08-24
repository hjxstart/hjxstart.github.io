---
title: HCNA Lab
categories: 网络
tags: 
  - VLAN
  - OSPF
date: 2023-04-08 11:46:05
---

## 一、简单的VLAN实验

设PC1和PC3都是VLAN13，PC2和PC4属于VLAN24，实现同一个VLAN的设备可以互通。

<center>![网络拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304081908634.png)</center>


<details>
  <summary>配置概述</summary>

  ```bash
1. 交换机：在SW1~3都创建2个vlan；
2. 交换机-交换机：在交换机之间的连接接口配置中继，并且放行相应的VLAN；
3. 交换机-PC：在交换机与PC连接的接口配置Access接口，并且方通相应的VLAN；
4. PC：配置对于VLAN的IP。
  ```
</details>

<details>
  <summary>SW1</summary>

  ```bash
# 
system-view
sysname SW1
vlan batch 13 24
display vlan
# 
interface GigabitEthernet 0/0/1
port link-type trunk
port trunk allow-pass vlan 13 24
quit
interface GigabitEthernet 0/0/2
port link-type trunk
port trunk allow-pass vlan 13 24
# 
display port vlan
# 
  ```
</details>

<details>
  <summary>SW2</summary>

  ```bash
# 
system-view
sysname SW2
vlan batch 13 24
display vlan
# 
interface Ethernet 0/0/1
port link-type trunk
port trunk allow-pass vlan 13 24
quit
display port vlan
# 
interface Ethernet 0/0/2
port link-type access
port default vlan 13
stp edged-port enable
interface Ethernet 0/0/3
port link-type access
port default vlan 24
stp edged-port enable
quit
display port vlan
  ```
</details>

<details>
  <summary>SW3</summary>

  ```bash
# 
system-view
sysname SW3 
vlan batch 13 24 
display vlan
# 
interface Ethernet 0/0/1
port link-type trunk
port trunk allow-pass vlan 13 24
quit 
display port vlan
# 
interface Ethernet 0/0/2
port link-type access
port default vlan 13
stp edged-port enable
interface Ethernet 0/0/3
port link-type access
port default vlan 24
stp edged-port enable
quit
display port vlan
  ```
</details>

<details>
  <summary>实验验证</summary>

  ```bash
# PC1 ping PC3
ping 13.1.1.3
# PC2 ping PC4
ping 24.1.1.4
  ```
</details>

---

## 二、简单的静态路由实验

配置静态路由，是LoopbBack 0之间可以Ping通。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082342450.png)

<details>
  <summary>配置概述</summary>

  ```bash
1. 给设备命名
2. 配置路由器之间的接口IP地址
3. 添加静态路由
4. 测试Loopback0口之间的网络
  ```
</details>

<details>
  <summary>R1</summary>

  ```bash
# 
system-view
sysname R1
# 
interface GigabitEthernet 0/0/0
ip address 12.1.1.1 255.255.255.0
quit
# 
interface GigabitEthernet 0/0/1
ip address 13.1.1.1 255.255.255.0
quit
# 
interface LoopBack 0
ip address 1.1.1.1 255.255.255.255
quit
# 
display ip interface brief
display ip routing-table
#
ip route-static 2.2.2.2 32 GigabitEthernet 0/0/0 12.1.1.2
ip route-static 3.3.3.3 32 GigabitEthernet 0/0/1 13.1.1.3
display ip routing-table
  ```
</details>

<details>
  <summary>R2</summary>

  ```bash
# 
system-view
sysname R2
# 
interface GigabitEthernet 0/0/1
ip address 12.1.1.2 255.255.255.0
quit
# 
interface LoopBack 0
ip address 2.2.2.2 255.255.255.255
quit
# 
display ip interface brief
display ip routing-table
#
ip route-static 1.1.1.1 32 GigabitEthernet 0/0/1 12.1.1.1
ip route-static 3.3.3.3 32 GigabitEthernet 0/0/1 12.1.1.1
display ip routing-table
  ```
</details>

<details>
  <summary>R3</summary>

  ```bash
# 
system-view
sysname R3
# 
interface GigabitEthernet 0/0/0
ip address 13.1.1.3 255.255.255.0
quit
# 
interface LoopBack 0
ip address 3.3.3.3 255.255.255.255
quit
# 
display ip interface brief
display ip routing-table
#
ip route-static 1.1.1.1 32 GigabitEthernet 0/0/0 13.1.1.1
ip route-static 2.2.2.2 32 GigabitEthernet 0/0/0 13.1.1.1
display ip routing-table
  ```
</details>


<details>
  <summary>查看路由信息</summary>

  <p>配置动态路由之前直连路由信息</p>
  
  ![R1直连路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304090005760.png)
  ![R2直连路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304090014248.png)
  ![R3直连路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304090014528.png)

  <p>配置动态路由之后的路由信息</p>

  ![R1直连和静态路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304090013966.png)
  ![R2直连和静态路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304090015008.png)
  ![R3直连和静态路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304090016644.png)
</details>


---

## 三、简单的OSPF实验

使用OSPF协议使PC1和PC2互通。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091024537.png)


<details>
  <summary>配置概述</summary>

  ```bash
1. 路由器启用OSPF进程
2. 设置路由器ID
3. 路由器之间的直连接口宣告到同一个区域
4. 路由器与非路由的接口也需要宣告一个区域
  ```
</details>

<details>
  <summary>R1</summary>

  ```bash
# 
system-view
sysname R1
# 
interface GigabitEthernet 0/0/0
ip address 12.1.1.1 255.255.255.0
quit
# 
interface GigabitEthernet 0/0/1
ip address 13.1.1.1 255.255.255.0
quit
# 
display ip interface brief
# 
ospf 10 router-id 1.1.1.1
area 0
network 12.1.1.1 0.0.0.0
network 13.1.1.1 0.0.0.0
quit
# 
display ospf peer brief
display ospf lsdb
display ip routing-table protocol ospf
# 
  ```
</details>

<details>
  <summary>R2</summary>

  ```bash
# 
system-view
sysname R2
# 
interface GigabitEthernet 0/0/0
ip address 12.1.1.2 255.255.255.0
quit
# 
interface GigabitEthernet 0/0/1
ip address 2.2.2.254 255.255.255.0
quit
# 
display ip interface brief
# 
ospf 10 router-id 2.2.2.2
area 0
network 2.2.2.254 0.0.0.0
quit
# 
interface GigabitEthernet 0/0/0
ospf enable 10 area 0
quit
# 
display ospf peer brief
display ospf lsdb
display ip routing-table protocol ospf
# 
  ```
</details>

<details>
  <summary>R3</summary>

  ```bash
# 
system-view
sysname R3
# 
interface GigabitEthernet 0/0/0
ip address 13.1.1.3 255.255.255.0
quit
# 
interface GigabitEthernet 0/0/1
ip address 3.3.3.254 255.255.255.0
quit
#
display ip interface brief
# 
ospf 10 router-id 3.3.3.3
area 0
network 13.1.1.3 0.0.0.0
network 3.3.3.254 0.0.0.0
quit
# 
display ospf peer brief
display ospf lsdb
display ip routing-table protocol ospf
# 
  ```
</details>

<details>
  <summary>测试验证</summary>

  ![PC1 ping PC2](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091031328.png)
  ![PC2 ping PC1](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091032131.png)
  ![R1的邻居&LSDB&路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091029671.png)
  ![R2的邻居&LSDB&路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091033508.png)
  ![R3的邻居&LSDB&路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091035347.png)

</details>

---

## Templet、实验模板

实验概述。

实验拓扑


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
system-view
sysname R1
  ```
</details>

<details>
  <summary>测试验证</summary>


</details>

