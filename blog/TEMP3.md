X园区
一、
答：可能是普通报文攻击
为了限制入接口的广播、未知组播和未知单播的报文速率，可以在接口视图下对广播、未知组播、未知单播、已知组播和已知单播报文按百分比、包速率和比特速率进行流量抑制。
配置方法：
在交换机与PC1相连的接口上配置如下命令
<HUAWEI> system-view
[HUAWEI] sysname Switch
[Switch] interface gigabitethernet 0/0/1
[Switch-GigabitEthernet0/0/1] broadcast-suppression 80

答：可能是DHCP报文泛洪攻击
为了防止可能是DHCP报文泛洪工具可以在设备上部署DHCP Snooping功能，并在接口配置防止攻击。
配置方法：
<HUAWEI> system-view
[HUAWEI] sysname Switch
[Switch] dhcp snooping enable
[Switch] interface gigabitethernet 0/0/1
[Switch-GigabitEthernet0/0/1] dhcp snooping check dhcp-rate
[Switch-GigabitEthernet0/0/1] dhcp snooping check dhcp-rate 50

二、
非法主机伪造合法主机的IP地址获取上网权限。此时，通过在Switch的接入用户侧的接口或VLAN上部署IPSG+DHCP Snooping功能，Switch可以对进入接口的IP报文进行检查，丢弃非法主机的报文，从而阻止此类攻击。
但是IPSG需要相应的检测表项配合，这些检测表项可以通过DHCP Snooping自动收集，也可以通过手动添加user-bind的表项，同时在接入终端的接口上配置IPSG功能。
配置方法：
<HUAWEI> system-view
[HUAWEI] sysname Switch
[Switch] dhcp snooping enable
[Switch] user-bind static ip-address 10.0.0.1 mac-address xxxx-xxxx-xxx1
[Switch] interface gigabitethernet 0/0/x
[Switch-GigabitEthernet0/0/x] ip source check user-bind enable
[Switch-GigabitEthernet0/0/x] ip source check user-bind alarm enable
[Switch-GigabitEthernet0/0/x] ip source check user-bind alarm threshold 200
[Switch-GigabitEthernet0/0/x] quit

三、
情况一：IPv6 RA Guard
ND协议是IPv6的一个关键协议，它功能强大，但是因为其没有任何安全机制，所以容易被攻击者利用。其中的RA报文攻击，攻击者仿冒网关向其他用户发送路由器通告报文RA（Router Advertisement），会改写其他用户的ND表项或导致其它用户记录错误的IPv6配置参数，造成这些用户无法正常通信。

根据RA报文攻击的特点，IPv6 RA Guard功能采用以下两种方式在二层接入设备上阻止恶意的RA报文攻击：
1、为接收RA报文的接口配置接口角色，系统根据接口角色选择转发还是丢弃该RA报文：
    若接口角色为路由器，则直接转发RA报文；
    若接口角色为用户，则直接丢弃RA报文。
2、为接收RA报文的接口配置IPv6 RA Guard策略，按照策略内配置的匹配规则对RA报文进行过滤：
    若IPv6 RA Guard策略中未配置任何匹配规则，则应用该策略的接口直接转发RA报文；
    若IPv6 RA Guard策略中配置了匹配规则，则RA报文需成功匹配策略下所有规则后才会被转发；否则，该报文被丢弃。
配置方法：
<HUAWEI> system-view 
[HUAWEI] sysname Switch 
[Switch] interface gigabitethernet 0/0/1
[Switch-GigabitEthernet0/0/1] nd raguard role host
[Switch-GigabitEthernet0/0/1] quit
[Switch] interface gigabitethernet 0/0/2
[Switch-GigabitEthernet0/0/2] nd raguard role router
[Switch-GigabitEthernet0/0/2] quit

情况二：ND Snooping
1、ND Snooping是通过侦听基于ICMPv6实现的ND报文来建立前缀管理表和ND Snooping动态绑定表，使设备可以根据前缀管理表来管理接入用户的IPv6地址，并根据ND Snooping动态绑定表来过滤从非信任接口接收到的非法ND报文，从而可以防止ND攻击的一种安全技术。

2、为了区分可信任和不可信任的IPv6节点，ND Snooping将设备连接IPv6节点的接口区分为以下两种角色。
    ND Snooping信任接口：该类型接口用于连接可信任的IPv6节点，对于从该类型接口接收到的ND报文，设备正常转发，同时设备会根据接收到的RA报文建立前缀管理表。
    ND Snooping非信任接口：该类型接口用于连接不可信任的IPv6节点，对于从该类型接口接收到的RA报文，设备认为是非法报文直接丢弃；对于收到的NA/NS/RS报文，如果该接口或接口所在的VLAN使能了ND报文合法性检查功能，设备会根据ND Snooping动态绑定表对NA/NS/RS报文进行绑定表匹配检查，当报文不符合绑定表关系时，则认为该报文是非法用户报文直接丢弃；对于收到的其他类型ND报文，设备正常转发。

3、为了防止上述的RA报文攻击，建议在交换机上部署ND Snooping功能，并将交换机与网关相连的接口配置成ND Snooping信任接口，这样交换机就会直接丢失来着接入终端int g0/0/1-4（默认为非信任接口）的RA报文，仅处理信任接口的RA报文，防止伪造RA报文带来的各种危害，避免上述情况发生。
配置方法：
<HUAWEI> system-view 
[HUAWEI] sysname Switch 
[Switch] nd snooping enable
[Switch] interface gigabitethernet 0/0/3
[Switch-GigabitEthernet0/0/3] nd snooping trusted
[Switch-GigabitEthernet0/0/3] quit


Y园区：
情况一：虚拟网络和隧道
在SDN环境中，虚拟网络或者隧道配置错误，可能导致PC之间的流量绕过安全策略进行通信，例如VXLAN配置错误，可能导致不应互通的PC处于同一个广播域，进而进行通信。
解决方法：
1、检查虚拟网络配置，确保每个PC所属的网络段或者VXLAN都配置正确，符合安全策略的要求。
2、确保不同虚拟网络之间有明确的隔离，防止未经授权的通信；
3、检查隧道配置，确保隧道的源、目的地址和VNI（虚拟网络标识符）等参数配置正确，符合安全策略的要求。

情况二：策略优先级
在复杂的SND策略配置中，可能存在多个策略规则应用于一组主机或者流量，如果策略优先级配置不当，可能导致低优先级的阻断策略被高优先级的放行策略覆盖，导致PC之间的通信未被阻止，或者当存在多条精细控制规则时，按照优先级顺序进行匹配，优先级数值小的级别高。
解决方法：
1、检查策略优先级；
2、简化和优化策略规则，避免不必要的策略重叠，确保策略执行顺序清晰明了。

情况三：传统园区IP-Group组订阅未配置
当底层网络为传统网络是，认证点被分散在2台ACC设备上，每台认证点只会记录自身下游PC的IP-Group信息，若此时此刻在NCE-Compus或者AC控制器上没有为ACC1和ACC2配置IP-Group组订阅，可能导致ACC1不存在ACC2上的IP-Group组信息，ACC2上也不存在ACC1的IP-Group信息，导致策略矩阵即使部署了也无法实现控制。


Z园区（MPLS）

一、SRv6基本原理，SRv6 te policy 数据转发
在当前SRv6环境中，数据达到PE1源节点节点时，会被封装一个新的IPv6报头，并根据配置SRv6 Policy的Segment-list插入SRH扩展头，当数据开始转发时，每经过一个SRv6节点，Segments Left（SL）字段减1，IPv6 DA信息变换一次。Segments Left和Segment List字段共同决定IPv6 DA信息，进而实现路径规划。

1、CE1将CE2数据发送出去，此时是私网数据，不存在IPv6报头和SRH扩展头信息。
2、PE1收到数据后，查表根据SRv6 Policy进行转发，此时IPv6头和SRH封装信息如下：
    Segment-list <FC04::400[0], FC04::4[1], FC03::3[2]>
    Segment Left = 2
    则IPv6 DA信息为FC03::3, 将数据转发给P1；
3、P1收到后，由于IPv6 DA信息并非本身SID，所以不对报文做任何改变，仅进行查表转发，此时封装信息保持不变；
4、P2收到后，P2使用IPv6报文的DA信息查找My Local SID表，命中到End SID，所以P2将报文SL减1，IPv6 DA更新为FC04::4，将数据转发给PE2；
报文到达尾节点PE2之后，PE2使用报文的IPv6目的地址FC04::4查找My Local SID表，命中到End SID，所以PE2将报文SL减1，IPv6 DA更新为VPN SID FC04::400。
PE2使用VPN SID FC04::400查找My Local SID表，命中到End.DT4 SID，PE2解封装报文，去掉SRH信息和IPv6报文头，使用内层报文目的地址查找VPN SID FC04::400对应的VPN实例路由表，然后将报文转发给CE2。

二、
1、在P1与PE3链路发送故障时，TI-LFA-FRR机制会计算出绕过故障点的备份路径，根据当前拓扑图，对应的备份路径列表段为：P1->P2->PE4；
2、当经过TI-FFA的备份路径时数据结构封装信息如下所示：（假设P2与PE4的End.x SID FC05::10）
    SRH(SL=1)，Segment-list <FC06::6[0], FC05::10>
    SRH(SL=2)，Segment-list <FC06::6[0], FC03::3[1], FC02::2[2]，FC01::1[3]>
    pyload(私网数据)
    此时TI-LAF插入的Segment-list <FC06::6[0], FC05::10>
3、将数据转发到P2节点后，发现目的IPv6地址为自身的End.x，进行SRv6转发，SL减1，并将插向的segment-list FC06::6填充到新的IPv6 DA地址中，且此时外层SRH的SL=0，进行末二弹出机制，移除外层SRH头部，保留内层SRH头部，并将数据转发到PE4;
4、PE4收到数据后，根据原有的SRH转发规则继续进行转发。


三、
1、使用SBFD （Bidirectional Forwarding Detection），可以快速检测Segment-list故障。如果一个候选路径下的Segment-list全部发生故障，则sbfd会触发候选路径Segment-list切换，减少对业务的影响。
2、可以配置 srv6-te-policy bfd min-tx-interval 10命令，制定bfd报文的最小发送间隔为10ms，当P1与PE3链路发送故障时，路由收敛速度在50ms内。 


Z园区（SRv6）

一、LDP隧道未建立成功的原因。
1、LDP邻居未建立成功
    在底层已经打通的情况下，LDP邻居建立成功即可发布Loopback接口路由的标签，若此时使用display mpls ldp无法查看到标签，可能的原因是LDP邻居未建立成功，可以从以下问题进行分析：
    （1）LDP协议报文是否被ACL过滤；
    （2）LDP会话建立的接口路由是否可达，LDP会话的认证配置是否正确；
    （3）LDP LSR-ID是否冲突；
    （4）接口是是否使能了 mpls 和 ldp。
2、LDP邻居建立成功
    （1）OSPF多区域场景下是否需要与LSP建立邻居关系，OSPF外部路由做了路由汇总。
    （2）LSP的触发配置可能存在错误，可能配置LSP了过滤。

二、
1、
# PE2 只能设置2个出方向
总部HUB-PE VPN_Out RT: export: 222:1
总部HUB-PE VPN_In RT: import: 111:1
Site1 PE1 RT: export 1:2 import 2:1
Site2 PE2 RT: export 2:1 111:1 import 1:2 222:1
Site3 PE3 RT: export 111:1 import 222:1
RD: PE1:65000:1 PE2:65000:2 PE3:65000:3 HUB-PE 入方向：65000:4 HUB-PE 65000:5
# PE2 只能设置1个出方向
总部HUB-PE VPN_Out RT: export: 222:1, 总部HUB-PE VPN_In RT: import: 111:1
Site1 PE1 RT: export 1:2 import 111:1
Site2 PE2 RT: export 111:1 import 2:1 222:1
Site3 PE3 RT: export 111:1 import 222:1
RD: PE1:65000:1 PE2:65000:2 PE3:65000:3 HUB-PE 入方向：65000:4 HUB-PE 65000:5
注意：此时Site1会收到Sites2和Sites3的路由，Site1的路由只被Sites2收到。

3、PE1、PE2和PE3之间不部署BGP对等体，PE1、PE2、PE3全部与HUB-PE建立VPNV4对等体关系，即减少BGP对等体关系，从而基于RT实现所有PE的互访都需要经过HUB-PE的效果。
4、
以CE3设备为例，CE3发送IP路由报文，PE3收到报文后，根据VPN实例加入RD:65000:3 RT:111:1，变成VPNV4路由传递给HUB-PE；
HUB-PE收到后，与入方向RT 111:1 匹配成功，加入In方向路由表，通过EBGP发给HUB-CE，HUB-CE将报文重新封装发给HUB-PE的Out方向的子接口；
HUB-PE收到后，加入相应的VRF路由表，加入RD:65000:5 RT:222:1, 将报文转发给PE2和PE1设备；
然后PE2设备收到后根据入方向RT:222:2匹配成功吱声的入方向RT: 222:2，将路由加入相应的路由表，让后通过EBGP对等体关系发送CE2设备。
PE1收到后匹配到入方向的RT:222:2失败，直接丢失该报文。




