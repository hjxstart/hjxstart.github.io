```bash
bfd
  sbfd
  reflector discriminator 1.0.0.1
  destination ipv6 fc00:5 remote-discriminator 5.0.0.5
  quit

te ipv6-router-id fc00::1

segment-routing ipv6
  sr-te frr enable
  encapsulation source-address fc00::1

  locator HCIE ipv6-prefix FC02:1:: 96 static 16
    opcode ::1 end psp
    opcode ::10 end-x interface ethernet 3/0/0 nexthop fc01:10::x psp
    opcode ::20 end-x interface ethernet 3/0/1 nexthop fc01:10::x psp
    opcode ::30 end-x interface ethernet 3/0/2 nexthop fc01:10::x psp
    opcode ::100 end-op
    quit

  srv6-te-policy backup hot-standby
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
    quit
  
  srv6-te policy x1-z1 endpoint fc00::5 color 101
    candidate-path preference 200
      segment-list x1-z1-zhu
    candidate-path preference 100
      segment-list x1-z1-bei
      quit
    quit
  quit


  
  
  







































```