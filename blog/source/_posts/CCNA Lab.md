---
title: CCNA Lab
date: 2023-04-07 20:13:29
categories: 网络
tags:
  - 思科网络实验
  - Cisco
---

## 一、简单的 VLAN 实验

设 PC1 和 PC3 都是 VLAN13，PC2 和 PC4 属于 VLAN24，实现同一个 VLAN 的设备可以互通。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20230408101203.png)

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
enable
configure terminal
vlan 10
exit
vlan 20
end
show vlan brief
#
configure terminal
interface range ethernet 0/0 - 1
shutdown
switchport trunk encapsulation dot1q
switchport mode trunk
no shutdown
end
show interface trunk
write
```

</details>

<details>
  <summary>SW2</summary>

```bash
#
enable
configure terminal
vlan 10
exit
vlan 20
end
show vlan brief
#
configure terminal
interface ethernet 0/0
shutdown
switchport trunk encapsulation dot1q
switchport mode trunk
no shutdown
end
show interface trunk
#
configure terminal
interface ethernet 0/1
switchport mode access
switchport access vlan 10
spanning-tree portfast disable
exit
interface ethernet 0/2
switchport mode access
switchport access vlan 20
spanning-tree portfast disable
end
show vlan brief
write
```

</details>

<details>
  <summary>SW3</summary>

```bash
#
enable
configure terminal
vlan 10
exit
vlan 20
end
show vlan brief
#
configure terminal
interface ethernet 0/0
shutdown
switchport trunk encapsulation dot1q
switchport mode trunk
no shutdown
end
show interface trunk
#
configure terminal
interface ethernet 0/1
switchport mode access
switchport access vlan 10
spanning-tree portfast disable
exit
interface ethernet 0/2
switchport mode access
switchport access vlan 20
spanning-tree portfast disable
end
show vlan brief
write
```

</details>

<details>
  <summary>PC</summary>

```bash
# PC1
ip 13.1.1.1 255.255.255.0
# PC2
ip 24.1.1.2 255.255.255.0
# PC3
ip 13.1.1.3 255.255.255.0
# PC4
ip 24.1.1.4 255.255.255.0
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

配置静态路由，是 Loopback 0 之间可以 Ping 通。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082233671.png)

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
enable
configure terminal
hostname R1
#
interface ethernet 0/0
no shutdown
ip address 12.1.1.1 255.255.255.0
exit
interface ethernet 0/1
no shutdown
ip address 13.1.1.1 255.255.255.0
exit
interface loopback 0
ip address 1.1.1.1 255.255.255.255
end
#
show ip interface brief
#
configure terminal
ip route 2.2.2.2 255.255.255.255 ethernet 0/0 12.1.1.2
ip route 3.3.3.3 255.255.255.255 ethernet 0/1 13.1.1.3
```

</details>

<details>
  <summary>R2</summary>

```bash
#
enable
configure terminal
hostname R2
#
interface ethernet 0/1
no shutdown
ip address 12.1.1.2 255.255.255.0
exit
interface loopback 0
ip address 2.2.2.2 255.255.255.255
end
#
show ip interface brief
#
configure terminal
ip route 1.1.1.1 255.255.255.255 ethernet 0/1 12.1.1.1
ip route 3.3.3.3 255.255.255.255 ethernet 0/1 12.1.1.1
```

</details>

<details>
  <summary>R3</summary>

```bash
#
enable
configure terminal
hostname R2
#
interface ethernet 0/0
no shutdown
ip address 13.1.1.3 255.255.255.0
exit
interface loopback 0
ip address 3.3.3.3 255.255.255.255
end
#
show ip interface brief
#
configure terminal
ip route 1.1.1.1 255.255.255.255 ethernet 0/0 13.1.1.1
ip route 2.2.2.2 255.255.255.255 ethernet 0/0 13.1.1.1
```

</details>

<details>
  <summary>查看路由信息</summary>

  <p>配置动态路由之前直连路由信息</p>
  
  ![R1直连路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082303379.png)
  ![R2直连路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082314508.png)
  ![R3直连路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082315384.png)

  <p>配置动态路由之后的路由信息</p>

![R1直连和静态路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082326950.png)
![R2直连和静态路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082328942.png)
![R3直连和惊天路由](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304082329117.png)

</details>

---

## 三、简单的 OSPF 实验

使用 OSPF 协议使 PC1 和 PC2 互通。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091126038.png)

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
enable
configure terminal
hostname R1
#
interface ethernet 0/0
no shutdown
ip address 12.1.1.1 255.255.255.0
exit
#
interface ethernet 0/1
no shutdown
ip address 13.1.1.1 255.255.255.0
exit
#
router ospf 110
router-id 1.1.1.1
network 12.1.1.1 0.0.0.0 area 0
network 13.1.1.1 0.0.0.0 area 0
exit
#
end
show ip ospf neighbor
show ip ospf database
show ip route ospf
#
```

</details>

<details>
  <summary>R2</summary>

```bash
#
enable
configure terminal
hostname R2
#
interface ethernet 0/0
no shutdown
ip address 12.1.1.2 255.255.255.0
exit
#
interface ethernet 0/1
no shutdown
ip address 2.2.2.254 255.255.255.0
exit
#
router ospf 110
router-id 2.2.2.2
network 12.1.1.2 0.0.0.0 area 0
exit
#
interface ethernet 0/1
ip ospf 110 area 0
exit
#
end
show ip ospf neighbor
show ip ospf database
show ip route ospf
#
```

</details>

<details>
  <summary>R3</summary>

```bash
#
enable
configure terminal
hostname R3
#
interface ethernet 0/0
no shutdown
ip address 13.1.1.3 255.255.255.0
exit
#
interface ethernet 0/1
no shutdown
ip address 3.3.3.254 255.255.255.0
exit
#
router ospf 110
router-id 3.3.3.3
network 13.1.1.3 0.0.0.0 area 0
exit
#
interface ethernet 0/1
ip ospf 110 area 0
exit
#
end
show ip ospf neighbor
show ip ospf database
show ip route ospf
#
```

</details>

</details>

<details>
  <summary>PC</summary>

```bash
# PC1
ip 2.2.2.1 255.255.255.0 2.2.2.254
# PC2
ip 3.3.3.2 255.255.255.0 3.3.3.254
```

</details>

<details>
  <summary>测试验证</summary>

![PC1 ping PC2](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091121409.png)
![R1的OSPF邻居&DB&路由表](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091119296.png)
![R2的OSPF邻居&DB&路由表](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091122906.png)
![R3的OSPF邻居&DB&路由表](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091123882.png)

</details>

---

## 四、简单的 FHRP 实验

在 R2 和 R3 的 ethernet0/1 口使用 FHRP 使 PC 的网关冗余。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091447043.png)

<details>
  <summary>配置概述</summary>

```bash
1. 配置对于的接口IP地址和路由协议
2. 在可能的网关设备的网关接口上配置FHRP的Virtual IP 和 优先级
```

</details>

<details>
  <summary>R1</summary>

```bash
#
enable
configure terminal
hostname R1
#
interface ethernet 0/0
no shutdown
ip address 12.1.1.1 255.255.255.0
exit
#
interface ethernet 0/1
no shutdown
ip address 13.1.1.1 255.255.255.0
exit
#
interface loopback 0
ip address 1.1.1.1 255.255.255.255
exit
#
router eigrp 90
eigrp router-id 1.1.1.1
network 12.1.1.1 0.0.0.0
network 13.1.1.1 0.0.0.0
network 1.1.1.1 0.0.0.0
exit
#
end
show ip route eigrp
#
```

</details>

<details>
  <summary>R2</summary>

```bash
#
enable
configure terminal
hostname R2
#
interface ethernet 0/0
no shutdown
ip address 12.1.1.2 255.255.255.0
exit
#
interface ethernet 0/1
no shutdown
ip address 100.1.1.252 255.255.255.0
exit
#
router eigrp 90
eigrp router-id 2.2.2.2
network 12.1.1.2 0.0.0.0
network 100.1.1.252 0.0.0.0
exit
#
end
show ip route eigrp
#
configure terminal
interface ethernet 0/1
standby 100 ip 100.1.1.254
standby 100 priority 105
exit
#
end
show standby brief
#
```

</details>

<details>
  <summary>R3</summary>

```bash
#
enable
configure terminal
hostname R3
#
interface ethernet 0/0
no shutdown
ip address 13.1.1.3 255.255.255.0
exit
#
interface ethernet 0/1
no shutdown
ip address 100.1.1.253 255.255.255.0
exit
#
router eigrp 90
eigrp router-id 3.3.3.3
network 13.1.1.3 0.0.0.0
network 100.1.1.253 0.0.0.0
exit
#
end
show ip route eigrp
#
configure terminal
interface ethernet 0/1
standby 100 ip 100.1.1.254
exit
#
end
show standby brief
#
```

</details>

<details>
  <summary>测试验证</summary>

1. PC1 一直 ping R1 的 Loopback
2. 将 R2 的 ethernet 0/1 shutdown
3. 查看 PC1 的 ping 状态、交换机的 mac address-table 是否有变化
4. 查看路由器的 standby

![PC1 ping R1 Loopback0](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091502939.png)
![SW1](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091502847.png)
![R1](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091505387.png)
![R2](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091508725.png)
![R3](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304091509854.png)

</details>

---

## 五、简单的 EIGRP 实验

配置 EIGRP 使路由器的 Loopback0 口都可以互通。

![实验拓扑](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304100751654.png)

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
#
interface ethernet 0/0
no shutdown
ip address 12.1.1.1 255.255.255.0
exit
interface ethernet 0/1
no shutdown
ip address 13.1.1.1 255.255.255.0
exit
interface loopback 0
ip address 1.1.1.1 255.255.255.255
end
#
show ip interface brief
#
configure terminal
router eigrp 90
no auto-summary
eigrp router-id 1.1.1.1
network 1.1.1.1 0.0.0.0
network 12.1.1.1 0.0.0.0
network 13.1.1.1 0.0.0.0
exit
#
end
show ip eigrp interfaces
show ip eigrp neighbors
show ip route eigrp
#
```

</details>

<details>
  <summary>R2</summary>

```bash
#
enable
configure terminal
hostname R2
#
interface ethernet 0/0
no shutdown
ip address 12.1.1.2 255.255.255.0
exit
interface loopback 0
ip address 2.2.2.2 255.255.255.255
end
#
show ip interface brief
#
configure terminal
router eigrp 90
no auto-summary
eigrp router-id 2.2.2.2
network 2.2.2.2 0.0.0.0
network 12.1.1.2 0.0.0.0
exit
#
end
show ip eigrp interfaces
show ip eigrp neighbors
show ip route eigrp
#
```

</details>

<details>
  <summary>R3</summary>

```bash
#
enable
configure terminal
hostname R3
#
interface ethernet 0/0
no shutdown
ip address 13.1.1.3 255.255.255.0
exit
interface loopback 0
ip address 3.3.3.3 255.255.255.255
end
#
show ip interface brief
#
configure terminal
router eigrp 90
no auto-summary
eigrp router-id 3.3.3.3
network 3.3.3.3 0.0.0.0
network 13.1.1.3 0.0.0.0
exit
#
end
show ip eigrp interfaces
show ip eigrp neighbors
show ip route eigrp
#
```

</details>

<details>
  <summary>测试验证</summary>

![R1](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304100755226.png)
![R2](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304100758230.png)
![R3](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/202304100802550.png)

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
