X园区
答：一
可能性1：普通广播报文攻击（流量抑制）
解决方案：为了限制进入接口的广播、未知组播或者未知单播类型报文的速率，防止广播风暴，可以在接口视图下，入方向上配置对应报文类型的流量抑制功能，对广播、未知组播、未知单播、已知组播和已知单播报文按百分比、包速率和比特速率进行流量抑制。。
配置方法：在交换机与PC1互联接口G0/0/1上配置
<HUAWEI> system-view
[HUAWEI] sysname SwitchA
[SwitchA] interface gigabitethernet 0/0/1
[SwitchA-GigabitEthernet0/0/1] broadcast-suppression 80 

可能性2：DHCP报文攻击 （配置防止DHCP报文泛洪攻击）
解决方案：为了防止可能是DHPC报文泛洪工具可以在设备上开启HDPC Snooping功能，并在接口配置防止此攻击。
配置方法：在交换机与PC1互联接口G0/0/1上配置：
<HUAWEI> system-view
[HUAWEI] sysname Switch
[Switch] dhcp snooping enable
[Switch-GigabitEthernet0/0/1] dhcp snooping check dhcp-rate
[Switch-GigabitEthernet0/0/1] dhcp snooping check dhcp-rate 50

答：二

非法主机伪造合法主机的IP地址获取上网权限。此时，通过在Switch的接入用户侧的接口或VLAN上部署IPSG + DHCP Snooping功能，Switch可以对进入接口的IP报文进行检查，丢弃非法主机的报文，从而阻止此类攻击。
但是IPSG需要有相应的检测表项进行配合，这些表项可以通过DHCP Snooping自动收集，也可以通过手动添加user-bind的表项，
同时在接入终端的接口上部署IPSG功能。不是方法如下。（IPSG配置示例）
<HUAWEI> system-view
[HUAWEI] sysname Switch
[Switch] dhcp snooping enable
[Switch] user-bind static ip-address 10.0.0.1 mac-address xxxx-xxxx-xxx1
[Switch] interface gigabitethernet 0/0/X
[Switch-GigabitEthernet0/0/X] ip source check user-bind enable
[Switch-GigabitEthernet0/0/X] ip source check user-bind alarm enable
[Switch-GigabitEthernet0/0/X] ip source check user-bind alarm threshold 200
[Switch-GigabitEthernet0/0/X] quit

答：三

情况一：IPv6 RA Guard
ND协议是IPv6的一个关键协议，它功能强大，但是因为其没有任何安全机制，所以容易被攻击者利用。其中的RA报文攻击，攻击者仿冒网关向其他用户发送路由器通告报文RA（Router Advertisement），会改写其他用户的ND表项或导致其它用户记录错误的IPv6配置参数，造成这些用户无法正常通信。

根据RA报文攻击的特点，IPv6 RA Guard功能采用以下两种方式在二层接入设备上阻止恶意的RA报文攻击：
1、为接收RA报文的接口配置接口角色，系统根据接口角色选择转发还是丢弃该RA报文：
    若接口角色为路由器，则直接转发RA报文；
    若接口角色为用户，则直接丢弃RA报文。
2、为接收RA报文的接口配置IPv6 RA Guard策略，按照策略内配置的匹配规则对RA报文进行过滤：
    若IPv6 RA Guard策略中未配置任何匹配规则，则应用该策略的接口直接转发RA报文；
    若IPv6 RA Guard策略中配置了匹配规则，则RA报文需成功匹配策略下所有规则后才会被转发；否则，该报文被丢弃。
配置方法如下：
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
3、为了防止上述的RA报文工具，建议在接入交换机上部署ND Snooping功能，并将交换机与网关相连的接口配置成信任接口，这样交换机就会直接丢失来着接入层收到的RA报文，仅处理来说信任接口的RA报文，避免了伪造RA报文带来的各种危害，防止了上述情况。
<HUAWEI> system-view
[HUAWEI] sysname Switch
[Switch] nd snooping enable
[Switch] interface gigabitethernet 0/0/3
[Switch-GigabitEthernet0/0/3] nd snooping trusted
[Switch-GigabitEthernet0/0/3] quit


Y园区

情况一、
在SDN环境中，虚拟网络或者隧道配置错误，可能导致PC之间的通信流量绕过安全策略进行通信，
例如VXLAN配置错误，可能导致不应互通的PC处于同一个广播域，进而进行通信。

解决方法：
1、检查虚拟网络配置，确保每个PC所属的网络段或者VXLAN都配置正确，符合安全策略的要求；
2、确保不同虚拟网络直接有明确的隔离，防止未授权的通信；
3、检查隧道配置，确保隧道的源、目的地址和VNI（虚拟网络标识符）等参数都配置正确，不会导致不应有的PC之间的通信。


情况二：
在复杂的SDN策略配置中，可能存在多个策略规则应用于一组主机或者流量，如果策略优先级配置不当，可能导致低优先级的阻断策略被高优先级的放行策略覆盖，导致PC之间的通信未被阻断，或者

解决方法：
1、检查策略优先级；
2、简化和优化策略规则，避免不必要的策略重叠，确保策略的执行顺序清晰明了。


情况三、传统园区IP-Group组订阅未配置

当底层网络为传统网络，若认证点分散分别在两台ACC设备上，每个认证节点只记录自身下游IP的IP-Group关系，
若此时此刻NCE-Compus或者AC控制器没有为ACC1和ACC2配置IP-Group组订阅，可能导致ACC1不存在ACC2上通过认证的IP-Group信息，ACC2上也不存在ACC1上的IP-Group信息，导致策略矩阵即使部署了也无法进行控制。



Z园区（MPLS）：

一、SRv6 te Policy数据转发

在当前SRv6环境中，当数据到达PE源节点时，会封装一个新的IPv6报头，并根据配置SRv6 Policy中的Segment插入SRH扩展头，当时间开始转发时，每经过一个SRv6节点，Segments Left（SL）字段减1，IPv6 DA信息变换一次。Segments Left和Segment List字段共同决定IPv6 DA信息，进而实现路由规划。

1、CE1将CE2数据发出时，此时是私网数据，不存在IPv6报头和SRH扩展头；
2、PE1收到数据后，查表根据SRv6 Policy进行转发，此时的IPv6头和SRH封装信息如下：
    Segment-list <FC00::6[0], FC00::5[1], FC00::4[2]>
    Segment left = 2
    则IPv6 DA信息为：FC00::4，将数据转发给P1；
3、P1收到数据后，由于IPv6 DA信息并非本身，所以报文不做任何改变，仅查表进行转发，此时报文封装保持不变；
4、P2收到数据后，使用IPv6报文中的DA信息查看本地SID表，由于End.x SID是本地SID，所以P2将SL减1，IPv6 DA信息变更为FC00::5，使用DA FC00::5查表转发，将报文转发给PE2。
5、报文到达尾节点PE2之后，PE2使用报文的IPv6目的地址FC00::6查找My Local SID表，命中到End SID，所以PE2将报文SL减1，IPv6 DA更新为VPN SID FC00::600。
6、PE2使用VPN SID FC00::600查找My Local SID表，命中到End.DT4 SID，PE2解封装报文，去掉SRH信息和IPv6报文头，使用内层报文目的地址查找VPN SID FC00::600对应的VPN实例路由表，然后将报文转发给CE2。


二、TI-LFA-FRR

1、当P1与PE3之间的链路发生故障时，TI-LFA-FRR机制会计算绕过该故障点的备用路径。根据拓扑图，对应的SRv6段列表为：FC00::2（PE1）->FC00::4（P1）->FC00::5（P2）->FC00::7（PE4）->FC00::8（CE2）
2、经过TI_LFA计算的备份路径转发时数据结构如下:(包含segment-1ist，假设P2连接PE4的End.x为FC05::10为例)
    IPV6 <Source:Fc01::1，Destination:FC5::10>
    SRH(SL=1)<FC06::6[0]，FC5::10[1]>
    SRH(SL=2)<FC06::6[0]，Fc03::3[1],FC02::2[2]，FC01::1[3]
    Pyload(私网数据)
    此时TI LFA插入的segment-list<Fce6::6[0]，Fc05::10[1]>
3、将数据转发到P2 节点后，发现目的IPv6 地址为自身的end.x，进行SRv6转发，SL-1，并将指向的segment-list fc06::6 填充到新的IPv6 DA 地址中，且此时外层SRH 的SL=0，进行末二跳弹出机制，移除外层SRH 头部，保留内层SRH头部，并将数据转发到PE4；
4）后续PE4 收到数据后，根据原有的SRH 转规则继续进行转发。

三、SBFD

1、使用 SBFD（Seamless Bidirectional Forwarding Detection），可以快速检测Segment-list故障。如果一个候选路径下的Segment-list全部路径发生故障，则SBFD会触发备份路径的Hot-standby切换，减少对业务的影响。
2、通过配置sr-te-policy seamless-bfd min-tx-interval 10，可以指定BFD报文的最小发送间隔是10ms，确保P1和P3之间链路发生故障时，路由收敛速度在50ms内。



Z园区（SRv6）:
一、LDP隧道建立不起来的原因
1、LDP邻居未建立成功：
在底层网络打通的情况下，LDP邻居正常建立即可发布Loopback接口路由的标签，若此时使用display mpls ldp无法查看标签，可能的原因是LDP邻居未建立成功，可以从以下几种原因进行分析：
    （1）LDP协议报文是否被ACL过滤；
    （2）LDP会话建立接口的路由是否可达，LDP会话认证配置是否正确；
    （3）LDP LSR-ID 是否冲突；
    （4）接口上是否使能了MPLS和LDP。
2、LDP邻居成功建立：
    （1）OSPF多区域场景是否需要与LSP建立路由，OSPF外部路由做了路由汇总。
    （2）LSP的触发策略配置可能错误，配置了LSP过滤。

二、导致R1和R3的LSP故障
1、LDP会话震荡本类故障的常见原因主要包括:对LDPGR定时器LDP MTU、LDP认证、LDP Keepalive定时器、LDI传输地址的配置进行新增、修改或删除、接口振荡路由振荡。
2、LDP会话Down掉本类故障的常见原因主要包括:关闭了建立会话的接、执行了undo mpls、undo mpls ldp、undo mpls ldpremote peer操作、路由不存在、LDP Keepalive定时器超时、LDP Hello-hold定时器超时。
3、LDP LSP震荡本类故障的常见原因主要包括:路由振荡、LDP会话振荡。
4、LDP LSP Down掉本类故障的常见原因主要包括:路由问题、LDP会话Down、资源不足，如PafLicense、、Token、Label达至上限，内存不足等、配置了LSP策略控制

三、RT，减少BGP邻居，通过RT来控制路由策略。

情况1：在PE2 上可以设置多个出方向的Export RT 时：
    总部的HUB-PE VPN_In RT 为：Import：111:1
    总部的HUB-PE VPN_Out RT 为：Export：222:1
    根据流量走向需求规划如下RT:
    Site1 的PE1 VPN RT 规划为： Export：1:1 Import：2:2
    Site2 的PE2 VPN RT 规划为：Export：2:2 111:1 Import：222:1 1:1
    Site3 的PE3 VPN RT 规划为：Export：111:1 Import：222:1
情况2：在PE2 上只能存在一个出方向的Export RT 时：
    总部的HUB-PE VPN_In RT 为：Import：111:1
    总部的HUB-PE VPN_Out RT 为：Export：222:1
    根据流量走向需求规划如下RT:
    Site1 的PE1 VPN RT 规划为：Export：1:2 Import：111:1
    Site2 的PE2 VPN RT 规划为：Export：111:1 Import：222:1 1:2
    Site3 的PE3 VPN RT 规划为：Export：111:1 Import：222:1
注：此时Site1 会收到Site2 和Site3 的路由，但是Site1 的路由只会被Site2收到，所以能够达成要求，但是会有不必要的路由存在于Site1 中

RD设计:PE1:65000:1，PE2:65000:2,PE3:65000:3、HUB-PE1入方向:65000:4、HUB-PE1出方向::65000:5

（3）P1、P2和P3之间不部署BGP对等体，P1、P2和P3都与Hub-PE建立vpnv4对等体关系，即减少BGP对等体关系；
从而基于TE也实现了所有PE互访都需要经过HUB-PE的效果；
（4）路由传递过程:
以CE3设备为例，首先CE3设备发送普通的IP路由报文，PE3收到后，放入相应的VRF表项，
然后根据VPN实例加入RD:65003:3、RT:3:2 111:1，通过VPNV4路由传递给HUB-PE设备，
HUB-PE设备收到后，与本身的入方向RT:111:1匹配成功，加入IN方向VRF路由表，然后通过EBGP对等体关系发送给HUB-CE设备，
然后HUB-CE重新封装发送IP报文发送给HUB-PE的OUT方向的子接口，然后HUB-PE收到后加入对应的VRF路由表，将该路由加入RD:65000:5 RT:222:2发送给PE1与PE2设备，
首先PE2设备收到后根据入方向RT:222:2成功匹配自身的入方向RT:222:2，将路中加入相应的VRE路由表，然后通过EBGP对等体发送给CE2设备。
PE1收至后匹配收到的入方向RT:222:2，匹配失败直接丢弃该报文。



