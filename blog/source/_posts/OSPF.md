---
title: OSPF
categories: 网络
tags: 协议
date: 2023-04-07 19:19:35
---

# 一、概述

Open Shortest Path First (OSPF) 是一种 Link-State Routing Protocol, OSPF 中的 **Router** 都会向 **Neighbor** 交换自己的 **Link-State**, 当 Router 收到这些 Link-State 之后，就会使用 Dijkstra Algorithm (狄杰斯特拉算法) 计算出最短的路径 (Shortest Path).

## 1.1 AreaArea

Area 是 OSPF 在中大型网络中为了解决管理上的问题，设置的一种分层系统, Area 一般使用一个 16 Bits (0~65535)的数字表示, 其中 Area 0 是一个特别的 Area, 我们一般称之为 Backbone Area (骨干区域), 其他所有的 Area 必须与 Area 0 连接。从设计层面降低环路出现的风险。

## 1.2 Router

1. Internal Router: 参与 OSPF 的所有 Interface 都连接在同一个 Area 的 Router.
2. Backbone Router: 最少一个参与 OSPF 的 Interface 连接在 Backbone Area 的 Router.
3. Area Border Router (**ABR**): 连接两个 Area (必须包含一个 **Area0**) 或以上的 Router.
4. Autonomous System Border Routers (**ASBR**): 有 Interface 连接到其他 AS，并且引入了外部路由 的 Router.

## 1.3 Neighbor 与 Adjacency 的建立

1. Down: 没有发送 Hello Message.
2. Init: 刚刚向对方发送 Hello Message.
3. 2-Way: 两个 Router 以成为 Neighbor. 他们开始沟通了! 在这个时候，他们会选出 DR 和 BDR. 如果未能成为 DR 和 BDR, 则成为 DROTHER, DROTHER 会停在 2-Way 的状态.
4. ExStart: 准备交换 Link 的信息.
5. Exchange: 他们开始交换 DBD (Database Descriptors).
6. Loading: 正在交换 LSA.
7. Full: 两个 Router 成为 Adjacency。LSA 交换完成, 此时同一个 Area 的 Router 里面的 Topology Table 应该是完成相同的.

## 1.4 成为 Neigbhor 的条件:

> Router-id: 按照优先级可以是指定的 Router-id; Loopback Interface 的最大 IP Address; 参与 OSPF 的 Interface IP Address.
> Priority: 用于选举 DR/BDR/DROTHER,越大越优先; 如果优先级一样就比较 Router-id.
> Dead Time: 默认由 40 秒开始倒数，如果一直倒数到 0 秒没有还收到 Hello, 就判断 Neighbor 离线了.
> State: 可以表示 Neighbor 的状态和 DR/BDR/DROTHER 的角色.

1. Area ID 相同.
2. Area Type 相同. Backbone Area (Area 0), Standard Area, Stub Area, Totally Stubby Area, Not-so-stubby Area 和 Totally Not-so-stubby Area.
3. Prefix 与 Subnet Mask 必须相同.
4. Interval Timer 时间相同. Hello Interval 和 Dead Interval 时间必须相同.
5. Authentication 认证相同. 认证方式有无密码认证, 明文认证和密文认证.

# 四、Designated Router

1. 在 Broadcast Multi-Access 的网络中, 例如我们常用的 Ethernet,
2. 同一个网络中可能会连接着 3 个或以上的 Router, 即每个 Router 需要建立 n-1 的 connection,
3. Full Mesh 的 connection 数量为 n(n-1)/2;
4. 如果在网络中选一位 DR(Designated Router), 其他的 Router 只需与 DR 建立 connection,
5. 每次有 Routing Update, Router 只需把 Update 传给 DR, 再由 DR 统一发给其他 Router;
6. 这样网络中每个 Router 只需处理一条 Connection;
7. 还要选一位 BDR(Backup Designated Router), 是在 DR 离线时由 BDR 顶上变成 DR.

# 五、Network Type

![Network Type](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231229162056.png)

# 六、Link-state Advertisement (LAS)

1. Router LSA (Type 1): 描述 Router 连接的 Router 信息. Area 内的 Router 都会产生一条, Area 内传递.
2. Network LSA (Type 2): 描述 DR 连接的 Router 信息. Area 内的 DR 产生一条, Area 内传递.
3. Network Summary LSA (Type 3): 描述 Area 内的 Router 去往 Area 间的路由信息. ABR 产生, 一条 Area 间路由产生一条 LSA, Area 间传递.
4. ASBR Summary (Type 4): 描述 Area 内的 Router 去往 ASBR 的路由信息. ABR 产生, 一台 ASBR 产生一条 LSA, Area 间传递.
5. External LSA (Type 5): 描述 Area 外的 External Network 路由信息. ASBR 产生, 一条外部路由产生一条 LSA, Area 传递.(除了 Stub Area)
6. (Type 7)

![LSA](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20231229162242.png)

# 七、特殊区域

> 减少 LSA 的发送, 简化 Route Table.
> Stub Area 和 Totally Stubby Area 适用于没有连接 External Network 的 Area

1. Stud Area: 禁止 Type4 和 Type5 的 LSA 进入, ABR 会下发一条 Default Rtoue 的 Type3 LSA.
2. Totally Stubby Area: 除了 ABR 下发的 Default Route，所有的 Type3 LSA 也禁止了.
3. NSSA: 禁止 Type4 和 Type5 的 LAS 进入, ASBR 改用 Type7 传递 External Network 的路由信息.
4. Not So Stubby Area (NSSA): 除了 ASBR 下发的 Default Route, 所有的 Type3 LSA 也禁止了.

# 八、Route

1. Metric
2. Cost
3. Route Type
4. 路由选择
5. 路由汇总

# 九、区域合并

1. Virtual Link
2. Tunnle

# 10. OSPF 优化

1. Pacing Timer
2. SPF Throttle Timer
3. LSA Throttle Timer
