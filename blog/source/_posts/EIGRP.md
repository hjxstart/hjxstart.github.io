---
title: EIGRP
date: 2023-04-09 15:14:50
categories: 网络
tags:
  - EIGRP
  - 路由协议
---


# 概述

EIGRP(增强型内部网关路由协议): Enhanced Interior Gateway Routing Protocol, 思科设备、华三设备和部分华为设备支持

EIGRP相对于其他路由协议的优点

1. EIGRP硬件资源利用率非常高
2. EIGRP(HDV, 高级距离矢量协议): 100%无环(DUAL)
3. 收敛速度最快(毫米级) convergence

EIGRP报文

1. Hell
2. Update
3. Query
4. Reply
5. Ack

Layer2 | IPV4 | EIGRP | FCS (88协议号, 无连接协议, 确认机制和重传16次机制)

EIGRP组播地址: 224.0.0.10
RIPv2组播地址: 224.0.0.9


