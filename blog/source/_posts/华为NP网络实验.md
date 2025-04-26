---
title: 华为NP网络实验
date: 2023-06-01 10:46:04
categories: 网络
---

## 01 BFD实验

1. 是什么: BFD可用于端到端双向转发检测的公有协议；
2. 应用场景: 静态路由的冗余备份场景，实现主备路由切换。
3. 场景设计: 两个网络A/B之间仅存在两条静态路由a/b(a为明细路由, b为汇总路由)，BFD可检测a路由之间的联通性，从而联动a路由，实现数据包a/b路由的切换。


![实验拓扑]()


<details>
  <summary>配置概述</summary>

  ```bash
1. 在AR1路由器上，配置接口IP，和通往2个網絡的靜態路由。
2. 在AR2路由器上，配置接口IP，配置LoopBack地址模擬其中一個網絡，添加1條靜態路由，啟用BFD和配置AR2/3的a路由的鏈路檢測，配置1條靜態路由並關聯BFD。
3. 在AR3路由器上，配置接口IP，配置LoopBack地址模擬其中一個網絡，添加1條靜態路由，啟用BFD和配置AR3/2的a路由的鏈路檢測，配置1條靜態路由並關聯BFD。
  ```
</details>

<details>
  <summary>AR1</summary>

  ```bash
# 
system-view
sysname AR1
# 
interface GigabitEthernet 0/0/0
ip address 12.1.1.1 24
# 
interface GigabitEthernet 0/0/1
ip address 13.1.1.1 24
# 
quit
display ip interface brief
# 
ip route-static 2.2.2.2 32 GigabitEthernet 0/0/0 12.1.1.1
ip route-static 3.3.3.3 32 GigabitEthernet 0/0/1 13.1.1.1
# 
display ip routing-table protocol static
  ```
</details>

<details>
  <summary>AR2</summary>

  ```bash
# 
system-view
sysname AR2
# 
interface GigabitEthernet 0/0/0
ip address 23.1.1.2 24
# 
interface GigabitEthernet 0/0/1
ip address 12.1.1.2 24
# 
quit
display ip interface brief
#
ip route-static 13.1.1.3 24 GigabitEthernet 0/0/1
ip route-static 3.3.3.0 24 GigbitEthernet 0/0/0 23.1.1.3
display ip routing-table protocol static
#   
bfd
quit
# 
bfd 1 bind peer-ip 13.1.1.3 source-ip 12.1.1.2 auto
quit
# 
ip route-static 3.3.3.3 32 GigabitEthernet 0/0/1 12.1.1.1 track bfd-session 1
display ip routing-table protocol static
  ```
</details>

<details>
  <summary>AR3</summary>

  ```bash
# 
system-view
sysname AR3
# 
interface GigabitEthernet 0/0/0
ip address 12.1.1.2 24
# 
interface GigabitEthernet 0/0/1
ip address 23.1.1.2 24
# 
quit
display ip interface brief
#
ip route-static 12.1.1.2 24 GigabitEthernet 0/0/0
ip route-static 2.2.2.0 24 GigbitEthernet 0/0/1 23.1.1.2
display ip routing-table protocol static
# 
bfd
quit
# 
bfd 1 bind peer-ip 12.1.1.2 source-ip 13.1.1.3 auto
quit
# 
ip route-static 2.2.2.2 32 GigabitEthernet 0/0/0 13.1.1.1 track bfd-session 1
display ip routing-table protocol static
  ```
</details>

<details>
  <summary>测试验证</summary>

  ```bash
tracert -a 2.2.2.2 3.3.3.3
ping -c 10000 -a 2.2.2.2 3.3.3.3 
  ```
</details>

---


## 02 NQA實驗

实验概述。


![实验拓扑]()


<details>
  <summary>配置概述</summary>

  ```bash
1. 
  ```
</details>

<details>
  <summary>AR1</summary>

  ```bash
# NQA
nqa test-instance Admin Tigerlab
test-type icmp
destination-address ipv4 13.1.1.3
source-address ipv4 12.1.1.2
threshold rtd 1
frequency 5
timeout 2
probe-count 1
start now



# 聯動方法和BFD一樣，檢查命令如下
display nqa results
display nqa history
tracert -a 2.2.2.2 3.3.3.3 
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
  <summary>AR1</summary>

  ```bash
# 
enable
configure terminal
hostname AR1
  ```
</details>

<details>
  <summary>测试验证</summary>

</details>