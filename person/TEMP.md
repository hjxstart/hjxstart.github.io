


# 验证截图
## X园区
Export: ospf，tracert(Service_OA)
AC: AP
Core: ip, ospf, ip pool, routing-table
AGG: ip, routing-table, access-user, stack
ACC: interface
FW: ip, routing-table
Terminal1/2/5: ping (出口，99,100,101)

## Y园区 Terminal 互相ping 并ping（Service_RD1, Service_RD2, Service_common, Store(OA/RD)）
Terminal 03: R&D / Marketing
Terminal 04: Production
Terminal 05: Employee / Guest
Y_Export: ospf
Store_Export1: ping -vpn-instance(Store(OA/RD)), tracert -vpn-instance(vpn2/4, 5.254)

## Z园区
ALL PE: interface, config(isis/bgp), isis peer, mpls ldp, bgp peer
X_PE1: routing-table vpn-instance OA Service(OA/R&D) verbose, tracert(1->5 lo0)
Y_PE1: routing-table vpn-instance OA/R&D Service(OA/R&D) verbose, tracert(3->5 lo0)
Z_PE1/2: routing-table vpn-instance OA/RD,
Z_Export: ip, routing-table vpn-instance OA/RD

# 理论

## X园区论述
PC1 减少广播：流量抑制->流量抑制原理描述，流量抑制->配置接口的流量抑制，配置流量抑制示例
PC3 防止获取非法地址：mac地址绑定-> 静态ARP能否实现IP地址与MAC地址绑定, IPSG 配置举例
PC4 非法路由器，正确获取IPv6前缀：IPv6 RA Guard配置，ND Snooping原理描述

## Y园区论述
配置了安全策略，但是PC直接还可以通信。业务随行、准入

业务随行的角度：
在SDN环境中，虚拟网络（如VXLAN）或者隧道配置错误，可能导致pc间通信的流量会绕过安全策略进行通信，
例如虚拟机网络VLAN配置错误，可能导致不应互通的PC处于同一个广播域，进而进行通信。
解决方法：
1. 检查虚拟网络配置，确保每个PC所属的网络段和VXLAN的配置是正确的，符合策略安全要求的；
2. 确保不同的虚拟机网络之间有明确的隔离，防止未经授权的同学；
3. 检查隧道配置，确保隧道的源、目的地址、VNI（虚拟网络标识符）等参数的配置都正确，不会出现不应出现的PC间的通信。

策略准入的角度：
在SND负责的策略配置中，可能存在多个策略规则应用于一组主机或流量，如果策略优先级配置不当，
可能导致低优先级的阻断策略被高优先级的放行策略覆盖，导致不应互通的PC间通信未被阻止，或者存在多个精细的策略控制，
安装策略优先级进行执行，策略优先级数小的级别高。
解决方法：
1. 检查策略优先级；
2. 简化和优化策略规则，避免不必要的策略重叠，确保策略的执行顺序清晰明了。

## Z园区论述
答：Srv6基本原理，Srv6-te-policy数据转发


# SRv6

## All PE

```bash

flow-wred drop
    co g lo 70 hi 90 di 50
    co y lo 60 hi 90 di 50
    co r lo 50 hi 90 di 100
    quit

flow-queue qos
    queue af4 wfq weight 10 flow-wred drop
    queue ef pq flow-wred drop
    quit

qos-profile QOS
    user-queue cir 1000000 pir 1000000 flow-queue qos
    quit



int g 0/2/28
    qos-profile QOS
int g 0/2/29
    qos-profile QOS
int g 0/2/30
    qos-profile QOS

# Z_PE1/2
int g 0/20/31
    qos-profile QOS
```
# auto-frr

```bash
# X/Y_PE1
ipv4-family vpn-instance OA
    auto-frr 



```


# X_T1_Export

int g 0/0/7
  undo portswitch
  ip add 10.20.1.1 30
int g 0/0/8
  ip add 10.20.1.5 30
  quit

acl 2000
  undo rule 5
  rule permit source 10.1.11.0 0.0.0.255
  rule permit source 10.1.12.0 0.0.0.255
  rule permit source 10.1.13.0 0.0.0.255
  rule permit source 10.1.14.0 0.0.0.255
  rule permit source 10.1.15.0 0.0.0.255
  rule permit source 10.1.21.0 0.0.0.255
  rule permit source 10.1.22.0 0.0.0.255
  rule permit source 10.1.23.0 0.0.0.255
  rule permit source 10.1.24.0 0.0.0.255
  rule permit source 10.1.25.0 0.0.0.255
  rule permit source 10.1.51.0 0.0.0.255
  rule permit source 10.1.52.0 0.0.0.255
  rule permit source 10.1.53.0 0.0.0.255
  rule permit source 10.1.54.0 0.0.0.255
  rule permit source 10.1.55.0 0.0.0.255
  rule permit source 10.1.101.0 0.0.0.255
  rule permit source 10.1.102.0 0.0.0.255
  rule permit source 10.1.103.0 0.0.0.255
  rule permit source 10.1.104.0 0.0.0.255
  rule permit source 10.1.105.0 0.0.0.255
  quit

acl 2001
  rule permit source 10.1.11.0 0.0.0.255
  rule permit source 10.1.12.0 0.0.0.255
  rule permit source 10.1.13.0 0.0.0.255
  rule permit source 10.1.14.0 0.0.0.255
  rule permit source 10.1.15.0 0.0.0.255
  rule permit source 10.1.21.0 0.0.0.255
  rule permit source 10.1.22.0 0.0.0.255
  rule permit source 10.1.23.0 0.0.0.255
  rule permit source 10.1.24.0 0.0.0.255
  rule permit source 10.1.25.0 0.0.0.255
  rule permit source 10.1.31.0 0.0.0.255
  rule permit source 10.1.32.0 0.0.0.255
  rule permit source 10.1.33.0 0.0.0.255
  rule permit source 10.1.34.0 0.0.0.255
  rule permit source 10.1.35.0 0.0.0.255
  rule permit source 10.1.41.0 0.0.0.255
  rule permit source 10.1.42.0 0.0.0.255
  rule permit source 10.1.43.0 0.0.0.255
  rule permit source 10.1.44.0 0.0.0.255
  rule permit source 10.1.45.0 0.0.0.255
  rule permit source 10.1.51.0 0.0.0.255
  rule permit source 10.1.52.0 0.0.0.255
  rule permit source 10.1.53.0 0.0.0.255
  rule permit source 10.1.54.0 0.0.0.255
  rule permit source 10.1.55.0 0.0.0.255
  rule permit source 10.20.1.4 0.0.0.252
  quit
  
route-policy b2o permit node 10
  apply tag 10
route-policy o2b deny node 10
  if-match tag 20
route-policy o2b permit node 20
  if-match acl 2001
  quit

ip route-static 0.0.0.0 0 g 0/0/9 10.255.1.254
ip route-static 0.0.0.0 0 g 0/0/10 10.255.2.254

ospf 1 router-id 10.1.0.1
  default-route-advertise
  area 0
    network 10.1.0.1 0.0.0.0
    network 10.1.200.1 0.0.0.0
    quit
  import-route bgp route-policy b2o
  default cost inherit-metric
  quit

bgp 65001
  router-id 10.1.0.1
  network 10.20.1.4 30
  peer 10.20.1.2 as-number 65000
  preference 120 255 255
  import-route ospf 1 route-policy o2b
  quit
  

# 2

# X_T1_Export2

int g 0/0/7
  undo portswitch
  ip add 10.20.1.9 30
int g 0/0/8
  ip add 10.20.1.6 30
  quit

acl 2000
  rule permit source 10.1.11.0 0.0.0.255
  rule permit source 10.1.12.0 0.0.0.255
  rule permit source 10.1.13.0 0.0.0.255
  rule permit source 10.1.14.0 0.0.0.255
  rule permit source 10.1.15.0 0.0.0.255
  rule permit source 10.1.21.0 0.0.0.255
  rule permit source 10.1.22.0 0.0.0.255
  rule permit source 10.1.23.0 0.0.0.255
  rule permit source 10.1.24.0 0.0.0.255
  rule permit source 10.1.25.0 0.0.0.255
  rule permit source 10.1.51.0 0.0.0.255
  rule permit source 10.1.52.0 0.0.0.255
  rule permit source 10.1.53.0 0.0.0.255
  rule permit source 10.1.54.0 0.0.0.255
  rule permit source 10.1.55.0 0.0.0.255
  rule permit source 10.1.101.0 0.0.0.255
  rule permit source 10.1.102.0 0.0.0.255
  rule permit source 10.1.103.0 0.0.0.255
  rule permit source 10.1.104.0 0.0.0.255
  rule permit source 10.1.105.0 0.0.0.255
  quit

acl 2001
  rule permit source 10.1.11.0 0.0.0.255
  rule permit source 10.1.12.0 0.0.0.255
  rule permit source 10.1.13.0 0.0.0.255
  rule permit source 10.1.14.0 0.0.0.255
  rule permit source 10.1.15.0 0.0.0.255
  rule permit source 10.1.21.0 0.0.0.255
  rule permit source 10.1.22.0 0.0.0.255
  rule permit source 10.1.23.0 0.0.0.255
  rule permit source 10.1.24.0 0.0.0.255
  rule permit source 10.1.25.0 0.0.0.255
  rule permit source 10.1.31.0 0.0.0.255
  rule permit source 10.1.32.0 0.0.0.255
  rule permit source 10.1.33.0 0.0.0.255
  rule permit source 10.1.34.0 0.0.0.255
  rule permit source 10.1.35.0 0.0.0.255
  rule permit source 10.1.41.0 0.0.0.255
  rule permit source 10.1.42.0 0.0.0.255
  rule permit source 10.1.43.0 0.0.0.255
  rule permit source 10.1.44.0 0.0.0.255
  rule permit source 10.1.45.0 0.0.0.255
  rule permit source 10.1.51.0 0.0.0.255
  rule permit source 10.1.52.0 0.0.0.255
  rule permit source 10.1.53.0 0.0.0.255
  rule permit source 10.1.54.0 0.0.0.255
  rule permit source 10.1.55.0 0.0.0.255
  rule permit source 10.20.1.4 0.0.0.252
  quit


acl 3000
  rule permit tcp source 10.1.60.101 0 source-port eq 80 destination any
  quit
  
traffic classifi web
  if-match acl 3000
traffic behavior web
  redirect ip-nexthop 10.255.4.254
traffic policy web
  classifier web behavior web
  quit
  
nat address-group 1 10.255.4.2 10.255.4.100
  
int lo0
  ip add 10.1.0.2 32
int g 0/0/1
  undo portswitch
  traffic-policy web inbound
  ip add 10.1.200.5 30
int g 0/0/9
  ip add 10.255.3.1 24
  nat outbound 2000
int g 0/0/10
  ip add 10.255.4.1 24
  nat outbound 2000 address-group 1
  nat server protocol tcp global cur 8081 inside 10.1.60.101 www
  quit
  
route-policy b2o permit node 10
  apply tag 20
route-policy o2b deny node 10
  if-match tag 10
route-policy o2b permit node 20
  if-match acl 2001
  quit

ip route-static 0.0.0.0 0 g 0/0/9 10.255.3.254
ip route-static 0.0.0.0 0 g 0/0/10 10.255.4.254

ospf 1 router-id 10.1.0.2
  default-route-advertise
  area 0
    network 10.1.0.2 0.0.0.0
    network 10.1.200.5 0.0.0.0
    quit
  import-route bgp route-policy b2o
  default cost inherit-metric
  quit

bgp 65001
  router-id 10.1.0.2
  network 10.20.1.4 30
  peer 10.20.1.10 as-number 65000
  preference 120 255 255
  import-route ospf 1 route-policy o2b
  quit
  

# 3 

# X_T1_AC1

vlan batch 51 to 55 101 to 105 100 203
int g 0/0/1
  port trunk allow vlan 51 to 55 101 to 105 
  quit

ospf 1 router-id 10.1.0.11
  area 0
    network 10.1.0.11 0.0.0.0
    network 10.1.100.254 0.0.0.0
    network 10.1.200.10 0.0.0.0
    quit
  quit


vlan pool wireless_employee
  vlan 51 to 55 
  assign hash
vlan pool wireless_guest
  vlan 101 to 105 
  assign hash
  quit
wlan
  ap-id 1 ap-mac e0cc-7a42-5940
  ap-name X_T2_AP2
y
  ap-group X
y
  quit
  ssid-profile name Employee
    ssid X_Employee_010
y
  ssid-profile name Guest
    ssid X_Guest_010
y
  vap-profile name Employee
    service-vlan vlan-pool wireless_employee
y
  vap-profile name Guest
    service-vlan vlan-pool wireless_guest
y
  security-profile name Employee
    security wpa-wpa2 psk pass-phrase Huawei@123 aes
y
  security-profile name Guest
    security wpa-wpa2 psk pass-phrase Huawei@123 aes
y
  quit
  dis ap all
  
    
# 4

dhcp enable
vlan batch 51 to 55 60 100 to 105 201 to 209
int g 0/0/2
  port link-type access
  port default vlan 202
int g 0/0/3
  port trunk allow vlan 51 to 55 101 to 105 203
int g 0/0/4
  port link-type trunk
  port trunk allow vlan 204 205
  undo port trunk allow vlan 1
  undo stp enable
int g 0/0/5
  port link-type trunk
  port trunk allow vlan 206 207
  undo port trunk allow vlan 1
  undo stp enable
int g 0/0/6
  port link-type access
  port default vlan 60
int eth2
  mode lacp
  port link-type trunk
  port trunk allow vlan 100 209
  trunkport g 0/0/21 to 0/0/22
  trunkport g 1/0/21 to 1/0/22
  quit

ip vpn-instance Employee
  route-distinguisher 65001:1
ip vpn-instance Guest
  route-distinguisher 65001:2
  quit

ip pool wired_finance1
 vpn-instance Employee
 gateway-list 10.1.31.254
 network 10.1.31.0 mask 255.255.255.0
#
ip pool wired_finance2
 vpn-instance Employee
 gateway-list 10.1.32.254
 network 10.1.32.0 mask 255.255.255.0
#
ip pool wired_finance3
 vpn-instance Employee
 gateway-list 10.1.33.254
 network 10.1.33.0 mask 255.255.255.0
#
ip pool wired_finance4
 vpn-instance Employee
 gateway-list 10.1.34.254
 network 10.1.34.0 mask 255.255.255.0
#
ip pool wired_finance5
 vpn-instance Employee
 gateway-list 10.1.35.254
 network 10.1.35.0 mask 255.255.255.0
#
ip pool wired_hr1
 vpn-instance Employee
 gateway-list 10.1.41.254
 network 10.1.41.0 mask 255.255.255.0
#
ip pool wired_hr2
 vpn-instance Employee
 gateway-list 10.1.42.254
 network 10.1.42.0 mask 255.255.255.0
#
ip pool wired_hr3
 vpn-instance Employee
 gateway-list 10.1.43.254
 network 10.1.43.0 mask 255.255.255.0
#
ip pool wired_hr4
 vpn-instance Employee
 gateway-list 10.1.44.254
 network 10.1.44.0 mask 255.255.255.0
#
ip pool wired_hr5
 vpn-instance Employee
 gateway-list 10.1.45.254
 network 10.1.45.0 mask 255.255.255.0
#
ip pool wired_market1
 vpn-instance Employee
 gateway-list 10.1.11.254
 network 10.1.11.0 mask 255.255.255.0
#
ip pool wired_market2
 vpn-instance Employee
 gateway-list 10.1.12.254
 network 10.1.12.0 mask 255.255.255.0
#
ip pool wired_market3
 vpn-instance Employee
 gateway-list 10.1.13.254
 network 10.1.13.0 mask 255.255.255.0
#
ip pool wired_market4
 vpn-instance Employee
 gateway-list 10.1.14.254
 network 10.1.14.0 mask 255.255.255.0
#
ip pool wired_market5
 vpn-instance Employee
 gateway-list 10.1.15.254
 network 10.1.15.0 mask 255.255.255.0
#
ip pool wired_procure1
 vpn-instance Employee
 gateway-list 10.1.21.254
 network 10.1.21.0 mask 255.255.255.0
#
ip pool wired_procure2
 vpn-instance Employee
 gateway-list 10.1.22.254
 network 10.1.22.0 mask 255.255.255.0
#
ip pool wired_procure3
 vpn-instance Employee
 gateway-list 10.1.23.254
 network 10.1.23.0 mask 255.255.255.0
#
ip pool wired_procure4
 vpn-instance Employee
 gateway-list 10.1.24.254
 network 10.1.24.0 mask 255.255.255.0
#
ip pool wired_procure5
 vpn-instance Employee
 gateway-list 10.1.25.254
 network 10.1.25.0 mask 255.255.255.0
#
ip pool wireless_employee1
 vpn-instance Employee
 gateway-list 10.1.51.254
 network 10.1.51.0 mask 255.255.255.0
#
ip pool wireless_employee2
 gateway-list 10.1.52.254
 network 10.1.52.0 mask 255.255.255.0
#
ip pool wireless_employee3
 vpn-instance Employee
 gateway-list 10.1.53.254
 network 10.1.53.0 mask 255.255.255.0
#
ip pool wireless_employee4
 vpn-instance Employee
 gateway-list 10.1.54.254
 network 10.1.54.0 mask 255.255.255.0
#
ip pool wireless_employee5
 vpn-instance Employee
 gateway-list 10.1.55.254
 network 10.1.55.0 mask 255.255.255.0
#
ip pool wireless_guest1
 vpn-instance Guest
 gateway-list 10.1.101.254
 network 10.1.101.0 mask 255.255.255.0
#
ip pool wireless_guest2
 vpn-instance Guest
 gateway-list 10.1.102.254
 network 10.1.102.0 mask 255.255.255.0
#
ip pool wireless_guest3
 vpn-instance Guest
 gateway-list 10.1.103.254
 network 10.1.103.0 mask 255.255.255.0
#
ip pool wireless_guest4
 vpn-instance Guest
 gateway-list 10.1.104.254
 network 10.1.104.0 mask 255.255.255.0
#
ip pool wireless_guest5
 vpn-instance Guest
 gateway-list 10.1.105.254
 network 10.1.105.0 mask 255.255.255.0
#

int lo1
  ip binding vpn-instance Employee
  ip add 10.1.0.4 32
int lo2
  ip binding vpn-instance Guest
  ip add 10.1.0.5 32
int vlan 202
  ip add 10.1.200.6 30
int vlan 204
  ip add 10.1.200.13 30
int vlan 205
  ip add 10.1.200.17 30
int vlan 206
  ip binding vpn-instance Employee
  ip add 10.1.200.21 30
int vlan 207
  ip binding vpn-instance Guest
  ip add 10.1.200.25 30
int vlan 208
  ip binding vpn-instance Employee
  ip add 10.1.200.29 30
  dhcp select global
int vlan 209
  ip binding vpn-instance Employee
  ip add 10.1.200.33 30
  dhcp select global
int vlan 51
  ip binding vpn-instance Employee
  ip add 10.1.51.254 24
  dhcp select global
int vlan 52
  ip binding vpn-instance Employee
  ip add 10.1.52.254 24
  dhcp select global
int vlan 53
  ip binding vpn-instance Employee
  ip add 10.1.53.254 24
  dhcp select global
int vlan 54
  ip binding vpn-instance Employee
  ip add 10.1.54.254 24
  dhcp select global
int vlan 55
  ip binding vpn-instance Employee
  ip add 10.1.55.254 24
  dhcp select global
int vlan 60
  ip binding vpn-instance Employee
  ip add 10.1.60.254 24
int vlan 101
  ip binding vpn-instance Guest
  ip add 10.1.101.254 24
  dhcp select global
int vlan 102
  ip binding vpn-instance Guest
  ip add 10.1.102.254 24
  dhcp select global
int vlan 103
  ip binding vpn-instance Guest
  ip add 10.1.103.254 24
  dhcp select global
int vlan 104
  ip binding vpn-instance Guest
  ip add 10.1.104.254 24
  dhcp select global
int vlan 105
  ip binding vpn-instance Guest
  ip add 10.1.105.254 24
  dhcp select global
  quit

ip ip-prefix Guest deny 10.1.101.0 24
ip ip-prefix Guest deny 10.1.102.0 24
ip ip-prefix Guest deny 10.1.103.0 24
ip ip-prefix Guest deny 10.1.104.0 24
ip ip-prefix Guest deny 10.1.105.0 24
ip ip-prefix Guest permit 0.0.0.0 0 less-equal 32
ip ip-prefix Employee deny 10.1.11.0 24
ip ip-prefix Employee deny 10.1.12.0 24
ip ip-prefix Employee deny 10.1.13.0 24
ip ip-prefix Employee deny 10.1.14.0 24
ip ip-prefix Employee deny 10.1.15.0 24
ip ip-prefix Employee deny 10.1.21.0 24
ip ip-prefix Employee deny 10.1.22.0 24
ip ip-prefix Employee deny 10.1.23.0 24
ip ip-prefix Employee deny 10.1.24.0 24
ip ip-prefix Employee deny 10.1.25.0 24
ip ip-prefix Employee deny 10.1.31.0 24
ip ip-prefix Employee deny 10.1.32.0 24
ip ip-prefix Employee deny 10.1.33.0 24
ip ip-prefix Employee deny 10.1.34.0 24
ip ip-prefix Employee deny 10.1.35.0 24
ip ip-prefix Employee deny 10.1.41.0 24
ip ip-prefix Employee deny 10.1.42.0 24
ip ip-prefix Employee deny 10.1.43.0 24
ip ip-prefix Employee deny 10.1.44.0 24
ip ip-prefix Employee deny 10.1.45.0 24
ip ip-prefix Employee deny 10.1.51.0 24
ip ip-prefix Employee deny 10.1.52.0 24
ip ip-prefix Employee deny 10.1.53.0 24
ip ip-prefix Employee deny 10.1.54.0 24
ip ip-prefix Employee deny 10.1.55.0 24
ip ip-prefix Employee deny 10.1.60.0 24
ip ip-prefix Employee permit 0.0.0.0 0 less-equal 32

ospf 1 router-id 10.1.0.3
  area 0
    network 10.1.0.3 0.0.0.0
    network 10.1.200.2 0.0.0.0
    network 10.1.200.6 0.0.0.0
    network 10.1.200.9 0.0.0.0
  area 1
    network 10.2.200.13 0.0.0.0
    filter ip-prefix Employee import
  area 2
    network 10.2.200.17 0.0.0.0
    filter ip-prefix Employee import
    stub
    quit
  quit
ospf 65001 vpn-instance Employee router-id 10.1.0.4
  vpn-instance-capability simple
  silent-interface vlan 51
  silent-interface vlan 52
  silent-interface vlan 53
  silent-interface vlan 54
  silent-interface vlan 55
  silent-interface vlan 60
  area 1
    network 10.1.0.0 0.0.255.255
    quit
  quit
ospf 65002 vpn-instance Guest router-id 10.1.0.5
  vpn-instance-capability simple
  silent-interface vlan 101
  silent-interface vlan 102
  silent-interface vlan 103
  silent-interface vlan 104
  silent-interface vlan 105
  area 2
    network 10.1.0.0 0.0.255.255
    stub
    quit
  quit

acl 3000
  rule permit ip source 10.1.51.0 0.0.0.255 destination 10.1.60.0 0.0.0.255
  rule permit ip source 10.1.52.0 0.0.0.255 destination 10.1.60.0 0.0.0.255
  rule permit ip source 10.1.53.0 0.0.0.255 destination 10.1.60.0 0.0.0.255
  rule permit ip source 10.1.54.0 0.0.0.255 destination 10.1.60.0 0.0.0.255
  rule permit ip source 10.1.55.0 0.0.0.255 destination 10.1.60.0 0.0.0.255
  quit
acl 3001
  rule permit tcp source 10.1.60.101 0 source-port eq 80 destination any
  quit
int g 0/0/3
  traffic-redirect inbound acl 3000 vpn-instance Employee ip-nexthop 10.1.200.22

int vlan 204
  traffic-redirect inbound acl 3001 ip-nexthop 10.1.200.5
  quit




# 5

# X_T1_AGG1

dhcp enable
vlan batch 11 to 15 21 to 25 100 208

int eth2
  port link-type hybrid
y
  port hybrid tagged vlan 11 to 15 21 to 25 100
int eth3
  port link-type hybrid
y
  port hybrid tagged vlan 11 to 15 21 to 25 100
  quit

int vlan 11
  ip add 10.1.11.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 12
  ip add 10.1.12.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 13
  ip add 10.1.13.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 14
  ip add 10.1.14.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 15
  ip add 10.1.15.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 21
  ip add 10.1.21.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 22
  ip add 10.1.22.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 23
  ip add 10.1.23.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 24
  ip add 10.1.24.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
int vlan 25
  ip add 10.1.25.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.29
  quit
  
vlan pool market
  vlan 11 to 15 
vlan pool procure
  vlan 21 to 25
  quit
  
radius-server template Employee
  radius-server authen 10.1.60.2 1812
  radius-server acc 10.1.60.2 1813 
  radius-server shar cipher Huawei@123
radius-server author 10.1.60.2 shared-key cipher Huawei@123

aaa
  authentication-scheme Employee
    authentication-mode radius
  accounting-scheme Employee
    accounting-mode radius
  authentication-scheme ap_noauthen
    authentication-mode none
    quit
  domain Employee
    authentication-scheme Employee
    accounting-scheme Employee
    radius-server Employee
  domain ap_noauthen
    authentication-scheme ap_noauthen
y
    quit
  quit
domain Employee
domain ap_noauthen mac-authen force mac-address ac8d-347b-3700 mask ffff-ffff-ffff

dot1x-access-profile name Employee
quit
mac-access-profile name Employee
quit
authentication-profile name Employee
  dot1x-access-profile Employee
  mac-access-profile Employee
  quit
  
int eth2
  authentication-profile Employee
int eth3
  authentication-profile Employee
  quit


# 6

# X_T1_AGG1

dhcp enable
vlan batch 31 to 35 41 to 45  100 209

int eth1
  mode lacp
  port link-type trunk
  port trunk allow vlan 100 209
  trunkport g 0/0/23 to 0/0/24
  trunkport g 1/0/23 to 1/0/24

int eth2
  mode lacp
  port link-type hybrid
y
  port hybrid tagged vlan 31 to 35 41 to 45  100
  trunkport g 0/0/22
  trunkport g 1/0/22
int eth3
  mode lacp
  port link-type hybrid
y
  port hybrid tagged vlan 31 to 35 41 to 45 100
  trunkport g 0/0/21
  trunkport g 1/0/21
  quit

int vlan 31
  ip add 10.1.31.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 32
  ip add 10.1.32.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 33
  ip add 10.1.33.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 34
  ip add 10.1.34.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 35
  ip add 10.1.35.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 41
  ip add 10.1.41.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 42
  ip add 10.1.42.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 43
  ip add 10.1.43.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 44
  ip add 10.1.44.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
int vlan 45
  ip add 10.1.45.254 24
  dhcp select relay
  dhcp relay server-ip 10.1.200.33
  quit
  
vlan pool finance
  vlan 31 to 35 
vlan pool hr
  vlan 41 to 45
  quit
  
radius-server template Employee
  radius-server authen 10.1.60.2 1812
  radius-server acc 10.1.60.2 1813 
  radius-server shar cipher Huawei@123
radius-server author 10.1.60.2 shared-key cipher Huawei@123

aaa
  authentication-scheme Employee
    authentication-mode radius
  accounting-scheme Employee
    accounting-mode radius
  authentication-scheme ap_noauthen
    authentication-mode none
y
    quit
  domain Employee
    authentication-scheme Employee
    accounting-scheme Employee
    radius-server Employee
  domain ap_noauthen
    authentication-scheme ap_noauthen
y
vlan batch 204 to 207

int g 0/0/1
  portswitch
  port link-type trunk
  port trunk allow vlan 204 205
  undo port trunk allow vlan 1
int g 0/0/2
  portswitch
  port link-type trunk
  port trunk allow vlan 206 207
  undo port trunk allow vlan 1
  quit
int lo1
int lo2
  quit
vsys enable
vsys name Employee
  assign vlan 204
  assign vlan 206
  assign int loopback 1
vsys name Guest
  assign vlan 205
  assign vlan 207
  assign int loopback 2
  quit
int lo1
  ip add 10.1.0.8 32
int lo2
  ip add 10.1.0.9 32
int vlan 204
  ip add 10.1.200.14 30
int vlan 205
  ip add 10.1.200.18 30
int vlan 206
  ip add 10.1.200.22 30
int vlan 207
  ip add 10.1.200.26 30
interface virtual-if 1
  ip ad 10.1.200.253 30
interface virtual-if 2
  ip ad 10.1.200.254 30
  quit

switch vsys Employee
sys
  firewall zone trust
    add interface vlan 206
  firewall zone untrust
    add interface vlan 204
    add interface virtual-if 1
    quit
  security
    rule name ospf
      source-zone untrust trust local
      destination-zone untrust trust local
      service ospf
      ac permit
      quit
return
sys
switch vsys Guest
sys
  firewall zone trust
    add interface vlan 207
  firewall zone untrust
    add interface vlan 205
    add interface virtual-if 2
    quit
  security
    rule name ospf
      source-zone untrust trust local
      destination-zone untrust trust local
      service ospf
      ac permit
      quit
return
sys
      



  

  
    quit
  quit
domain Employee
domain ap_noauthen mac-authen force mac-address e0cc-7a42-5940 mask ffff-ffff-ffff

dot1x-access-profile name Employee
quit
mac-access-profile name Employee
quit
authentication-profile name Employee
  dot1x-access-profile Employee
  mac-access-profile Employee
  quit
  
int eth2
  authentication-profile Employee
int eth3
  authentication-profile Employee
  quit


# 7
