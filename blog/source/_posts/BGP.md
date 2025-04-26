---
title: BGP
date: 2024-01-28 11:20:29
categories: 网络
tags:
---

```shell
# BGP进程AS号
bgp 4
# 路由器ID
router-id 4.4.4.4
# 关闭自动汇总, 默认关闭
undo summary automatic
# 关闭自动同步
undo synchronization
# 关闭IPv4, BPGv4+, 支持地址簇
undo default ipv4-unicast
# 建立邻居
peer 24.1.1.2 as-number 10
# 使用ipv4 单波地址簇
ipv4-family unicast
# 激活peer
peer 24.1.1.2 enable


## Group
# 创建命名internalGP的 IBGP Peer Group
group internalGP internal
# 使用环回口0与IBGP建立邻居
peer internalGP connect-interface LoopBack 0
# 将这个3.3.3.3 Peer添加到组中
peer 3.3.3.3 group interna

# 进入ipv4-family
ipv4-family unicast
# 激活这个IBGP Peer Group，不用每个Peer都激活
peer internalGP enable
# 发送路由时，修改路由的下一跳, 由于bug原因，不生效，需要单独为peer指定next-hop-local
peer internal next-hop-local
peer 3.3.3.3 next-hop-local


bgp 10
 router-id 3.3.3.3
 undo default ipv4-unicast
 peer 2.2.2.2 as-number 10
 peer 2.2.2.2 connect-interface LoopBack0
 #
 ipv4-family unicast
  undo synchronization
  peer 2.2.2.2 enable
  peer 2.2.2.2 next-hop-local

bgp 10
 router-id 3.3.3.3
 undo default ipv4-unicast
 peer 2.2.2.2 as-number 10
 peer 2.2.2.2 connect-interface LoopBack0
 #
 ipv4-family unicast
  undo synchronization
  peer 2.2.2.2 enable
  peer 2.2.2.2 next-hop-local
```

### 路由的说明

```shell
*>: *改路由经过的防环审核,>最优符号; r>: r由于管理距离的原因无法加入路由表,可以传递给邻居,>最优; s:抑制路由,不会加入路由表和传递路由.
Ogn: i: IGBP路由, e: EGBP路由, ?: 其他路由.
Path: AS Path (IGBP水平分割, EGBP水平分割)
MED
```

### MPLS

```shell
mpls lsr-id 1.1.1.1
mpls
mpls ld
quit
int g0/0/0
mpls
mpls ldp
int g0/0/1
mpls
mpls ldp

# R2 & R3, 让MPLS和BGP联动，让BGP通过MPLS 转发报文的时候，如果是BGP路由，可以递归到BGP的下一跳地址，查找对于的标签来封装报文
route recursive-lookup  tunnel
```
