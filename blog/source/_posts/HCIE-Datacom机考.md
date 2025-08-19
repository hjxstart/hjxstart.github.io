---
title: HCIE Datacom机考
date: 2025-08-07 19:33:32
categories:
tags:
---


# X园区（MPLS）



# Z园区（MPLS）

## X_PE

```bash
# ALL_PE
drop-profile rd
  wred dscp
  dscp 34 lo 50 hi 90 dis 50
  quit
traffic classifier rd
  if-match dscp 34
traffic behavior rd
  queue af bandwidth 300000
  drop-profile rd
traffic classifier pro
  if-match dscp 46
traffic behavior pro
  queue llq bandwidth 100000
traffic policy RD
  classifier rd behavior rd
  classifier pro behavior rd
  quit
interface g 0/0/1
  traffic-policy RD outbound
interface g 0/0/2
  traffic-policy RD outbound
interface g 0/0/0
  traffic-policy RD outbound
# Z_PE1/2
interface g 0/0/10.20
  traffic-policy RD outbound

# ALL_PE
bfd
  mpls-passive
  quit
isis 1
  is-level level-2
  cost-style wide
  network-entity 49.0001.0010.0000.0001.00
  domain-authentication-mode md5 cipher Huawei@123
  bfd all-interfaces enable
  bfd all-interfaces min-tx-interval 15 min-rx-interval 15 
  frr
    loop-free-alternate level-2
    quit
  quit
int lo0
  isis enable 1
interface g 0/0/1
  isis enable 1
  isis circuit-type p2p
  isis ppp-negotiation 2-way
  isis authentication-mode md5 cipher Huawei@123
interface g 0/0/2
  isis enable 1
  isis circuit-type p2p
  isis ppp-negotiation 2-way
  isis authentication-mode md5 cipher Huawei@123
interface g 0/0/0
  isis enable 1
  isis cost 4
  isis circuit-type p2p
  isis ppp-negotiation 2-way
  isis authentication-mode md5 cipher Huawei@123
  quit

mpls lsr-id 1.0.0.1
mpls
  mpls bfd enable
  mpld bfd-trigger host
  mpls bfd min-tx-interval 15 mini-rx-interval 15
  quit
mpls ldp
interface g 0/0/1
  mpls
  mpls ldp
  mpls mtu 1382
  


```


# Z园区（SRv6）

## X_PE1

```bash
# ALL_PE
flow-wred drop
  co g lo 70 hi 90 dis 50
  co y lo 60 hi 90 dis 50
  co r lo 50 hi 90 dis 50
flow-queue qos
  queue af4 wfq weight 10 flow-wred drop
  queue llq pq flow-wred drop
qos-profile QOS
  user-queue cir 1000000 pir 1000000 flow-queue qos
  quit
interface g 0/0/0
  qos-profile QOS outbound
interface g 0/0/1
  qos-profile QOS outbound
interface g 0/0/2
  qos-profile QOS outbound
# Z_PE1/2
interface g 0/0/10.20
  qos-profile QOS outbound

# ALL_PE
bfd
  sbfd
  reflector discriminator 1.0.0.1
  destination ipv6 fc00::5 remote-discriminator 5.0.0.5
  quit

te ipv6-router-id fc00::1

segment-routing ipv6
  sr-te frr enable
  encapsulation source-address fc00::1

  locator HCIE ipv6-prefix fc02:1:: 96 static 16
    opcode ::1 end psp
    opcode ::10 end-x interface g 0/0/0 nexthop fc01:10::x psp
    opcode ::20 end-x interface g 0/0/1 nexthop fc01:10::x psp
    opcode ::30 end-x interface g 0/0/2 nexthop fc01:10::x psp
    opcode ::100 end-op
    quit

  srv6-te-policy backup hot-standby enable
  srv6-te-policy locator HCIE 
  srv6-te-policy bfd seamless enable
  srv6-te-policy bfd no-bypass
  srv6-te-policy bfd min-tx-interval 50

  segment-list x1-z1-zhu
    index 10 sid ipv6 fc02:1::30
  segment-list x1-z1-bei
    index 10 sid ipv6 fc02:1::10
    index 20 sid ipv6 fc02:2::30
    index 30 sid ipv6 fc02:6::10
  srv6-te policy x1-z1 endpoint fc00::5 color 101
    candidate-path preference 200
      segment-list x1-z1-zhu
    candidate-path preference 100
      segment-list x1-z1-bei
      quit
    quit
  quit

route-policy fz1 permit node 10
  apply extcommunity color 0:101
route-policy fz2 permit node 10
  apply cost 10
route-policy oa_med permit node 10
  apply cost 10
  quit

tunnel-policy x1-z1
  tunnel select-seq ipv6 srv6-te-policy load-balance-number 1
  quit

ip vpn-instance OA
  route-distinguisher 65001:1
  vpn-target 1:4 export-extcommunity evpn
  vpn-target 4:1 import-extcommunity evpn
  tnl x1-z1 evpn
  quit

interface g 0/0/10
  ip binding vpn-instance OA
  ip add 10.20.1.2 30
  quit

isis 1
  is-level level-2
  cost-style wide
  network-entity 49.0001.0010.0000.0001.00
  domain-authentication-mode md5 cipher Huawei@123
  ipv6 enable topology ipv6
  ipv6 bfd all-interfaces enable
  ipv6 bfd all-interfaces min-tx-interval 15 min-rx-interval 15
  segment-routing ipv6 locator HCIE
  avoid-microloop frr-protected
  ipv6 avoid-microloop segment-routing 
  ipv6 frr
    loop-free-alternate level-2
    quit
  quit
interface lo0
  isis ipv6 enable 1
interface g 0/0/1
  isis ipv6 enable 1
  isis circuit-type p2p
  isis ppp-negotiation 2-way
  isis authentication-mode md5 cipher Huawei@123
interface g 0/0/2
  isis ipv6 enable 1
  isis circuit-type p2p
  isis ppp-negotiation 2-way
  isis authentication-mode md5 cipher Huawei@123
interface g 0/0/0
  isis ipv6 enable 1
  isis ipv6 cost 4
  isis circuit-type p2p
  isis ppp-negotiation 2-way
  isis authentication-mode md5 cipher Huawei@123
  quit

bgp 65000
  router-id 1.0.0.1
  undo default ipv4-unicast
  peer fc00::5 as-number 65000
  peer fc00::5 connect-interface loopback 0
  peer fc00::5 password cipher Huawei@123
  peer fc00::6 as-number 65000
  peer fc00::6 connect-interface loopback 0
  peer fc00::6 password cipher Huawei@123
  l2vpn-family evpn
    peer fc00::5 enable
    peer fc00::5 route-policy fz1 import
    peer fc00::5 advertise encap-type srv6
    peer fc00::6 enable
    peer fc00::6 route-policy fz1 import
    peer fc00::6 advertise encap-type srv6
  ipv4-family vpn-instance OA
    advertise l2vpn evpn
    segment-routing ipv6 locator HICE evpn
    segment-routing ipv6 traffic-engineer best-effort evpn
    peer 10.20.1.1 as-number 65001
    peer 10.20.1.1 route-policy oa_med export
    quit
  quit

```

# 论述