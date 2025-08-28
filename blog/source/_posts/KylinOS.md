---
title: KylinOS
date: 2025-02-12 16:47:23
categories: 运维
top: 50
tags: KylinOS
---

# 一、概述

# 二、桌面

## 常见问题

### 数据

```bash
# 用户的回收站
cd ~/.local/share/Trash/files/

```

### 修改密码

```bash
# 进入单用户模式，修改root密码或者是开机用户的密码
# 1. 重启主机，在选择界面按: e
# 2. 将 linux 行的 ro 修改成 rw
# 3. 在 Linux 行的 audit=0后面或者 security 之前添加 init=/bin/bash console=tty0
# 4. 

```

### 刻录



### 清理缓存

```bash
rm -rf .config/ .cache/ .local/
sudo systemctl restart lightdm
```



## 默认配置

### 源

```bash
2403
#本文件由源管理器管理，会定期检测与修复，请勿修改本文件
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 10.1 main restricted universe multiverse
deb http://archive.kylinos.cn/kylin/KYLIN-ALL 10.1-2403-updates main restricted universe multiverse
deb http://archive2.kylinos.cn/deb/kylin/production/PART-V10-SP1/custom/partner/V10-SP1 default all

```



---


# 三、服务端


### 手动配置网卡

```bash
# 编辑网卡
sudo vi /etc/sysconfig/network-scripts/ifcfg-ens33
# 配置
DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=static
ONBOOT=yes
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4

# 重启网络配置
systemctl restart NetworkManager
```

### vsftp

```bash
# 1. 安装vsftp和ftp包
yum -y install vsftpd ftp

# 2. 创建ftpd FTP用户并设置密码
useradd ftpd
echo "Kylin@password1234" | passwd --stdin ftpd

# 3. 创建FTP文件夹和文件
mkdir -p /home/ftpd/test
chmod -R 777 /home/ftpd/test/

# 4. 编辑vsftpd的配置文件, 在文件后添加以下配置
vim /etc/vsftpd/vsftpd.conf

userlist_enable=YES
local_root=/home/ftpd/test
local_enable=YES

# 5. 重启vsftpd服务并检查状态
systemctl restart vsftpd
systemctl status vsftpd

# 6. 测试FTP连通性
ftp 127.0.0.1
ftpd
Kylin@password1234
exit

# 7. 其他：检查防火墙状态
systemctl status firewalld
```

---

# 四、邮件系统

## 部署

### 概述


### 规划

```bash
# 需要依赖，最好有图形化服务
yum  groupinstall "Server with UKUI GUI"
# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld
```


### 划分磁盘

```bash
# 创建物理卷. pvdisplay | pvscan
pvcreate /dev/sdb
pvcreate /dev/sdc

# 创建卷组 vgcreate vg_name pv_name. vgdisplay | vgscan
# node1
vgcreate datanode1 /dev/sdb
vgcreate datanode2 /dev/sdc
# node2
vgcreate datanode3 /dev/sdb
vgcreate datanode4 /dev/sdc

# 创建逻辑卷. lvdisplay
# node1
lvcreate -n node1 -l 100%FREE datanode1
lvcreate -n node2 -l 100%FREE datanode2
# node2
lvcreate -n node3 -l 100%FREE datanode3
lvcreate -n node4 -l 100%FREE datanode4

# drbd设备初始化操作
# node1
dd if=/dev/zero of=/dev/datanode1/node1 bs=1M count=100
dd if=/dev/zero of=/dev/datanode2/node2 bs=1M count=100
# node2
dd if=/dev/zero of=/dev/datanode3/node3 bs=1M count=100
dd if=/dev/zero of=/dev/datanode4/node4 bs=1M count=100
```

### 安装

```bash
# 安装软件
rpm -ivh --force nsmail-8.3.0.xxx.rpm
# 集群服务启停
/opt/AQYJ/nsmail/init.d/nsmailservice   /opt/AQYJ/nsmail/init.d/php  /opt/AQYJ/nsmail/init.d/cs2cmailsh.php  clustermail start

```

### 配置

```bash
## 访问集群url
http://192.168.110.101:8022

## 创建主机群；主机管理-创建
node1-manager       192.168.110.101
node1-storage       192.168.120.101
node1-hearbeat      192.168.130.101
node1-vip           192.168.110.103

node2-manager       192.168.110.102
node2-storage        192.168.120.102
node2-hearbeat      192.168.130.102
node2-vip           192.168.110.104

## 创建第一组DRBD磁盘关系
资源名称        drbd0
节点IP          设置node1存储的IP
物理IP          设置node1的管理IP
端口号默认      20000
块设备          设置node1服务器的第一块盘
对端节点IP      设置node2的存储IP
对端物理节点IP  设置node2的管理IP
对端节点块设备  设置node2服务器的第一块盘
端口号默认      20000

## 创建第二组DRBD磁盘关系
资源名称        drbd1   
节点IP          设置node2存储的IP
物理IP          设置node2的管理IP
端口号          设置20001
块设备          设置node2服务器的第二块盘
对端节点IP      设置node1的存储IP
对端物理节点IP  设置node1的管理IP
对端节点块设备  设置node1服务器的第二块盘
端口号默认      20001

## drbd磁盘格式化
# Drbd管理 - 点击“查看”按钮
查看磁盘同步是否完成100%，手动执行磁盘格式化
步骤: 在 node1 服务器手动格式化 drbd0 磁盘
sudo mkfs.ext4 /dev/drbd0
步骤: 在 node2 服务器手动格式化 drbd1 磁盘
sudo mkfs.ext4 /dev/drbd1

## 创建节点组
# 集群管理 > 添加节点组



## 创建集群组-添加节点组


## 创建集群组-添加虚拟IP


## 创建集群组-添加心跳

## 创建集群组-创建存储

## 创建集群组-确认配置

## 集群发布

## 集群启用

## 集群序列号激活 ```XXJW```

## 管理员访问方式

## 用户访问方式

## 快速上手
# 登录系统管理员-mail_admin

# 创建企业及域名

# 登录并重置企业管理员密码

## 


```


### 优化&问题

```bash
## sp3的版本适配问题 -- 夏杰大佬 （创建第一组DRBR磁盘关系的时候发现 “快设备” 没有识别）解决方法
# 环境信息：release V10 SP3 2403/(Halberd)-x86_64-Build20/20240426
# 两个节点都需要执行以下操作
cd /opt/AQYJ/nsmail/bin
mv fdisk  fdisk_bak
mv sqlite3 sqlite3_bak
ln -s  /usr/sbin/fdisk  /opt/AQYJ/nsmail/bin/fdisk
ln -s /usr/bin/sqlite3 /opt/AQYJ/nsmail/bin/

```

## 快速使用

```
```



# 五、应用商店

## 安装

```
软件管理平台：http://192.168.16.118:8880/login ， 默认账号: admin/admin
软件更新平台：http://192.168.16.118:8880/login，默认账号：root/Kylin2023*
```

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826124633042.png)

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826124712618.png)

### 环境准备

```bash
# 麒麟服务器系统，最小化安装（选择安装开发工具），4C8G，150G空间
默认服务器账号和密码
# 部署软件商店需要ifconfig命令，故需要安装net-tools工具
yum update
yum install -y net-tools
# 挂载镜像，将镜像安装资源拷贝除了
mount /opt/Kylin-softwarestore-V2-2.7-Release-20250220-X86_64.iso /mnt
mkdir /opt/software
cp -r /mnt/* /opt/software/
```

![环境准备](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826103946384.png)

### 初始化

```bash
cd /opt/software/00init
tar zxvf init-x86_64.tar.gz
cd base-env-x86_64/
bash init.sh
```

![初始化环境](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826181708738.png)

### 部署软件管理平台

```bash
cd /opt/software/01soft_manager
cat ksm-inline-v2.7-amd64.tar.gz.sha* > ksm-inline-v2.7-amd64.tar.gz
tar xvzf ksm-inline-v2.7-amd64.tar.gz
#复制激活⽂件`.kyinfo`和`LICENSE`到`ksm-inline`同级安装⽬录
 cd ksm-inline/shell/
bash deploy.sh
```



### 部署更新管理平台

```bash
cd /opt/software/02update_manager/
cat kss-2.2.1-amd64.tar.gz.sha0 > kss-2.2.1-amd64.tar.gz
tar xvzf kss-2.2.1-amd64.tar.gz
cd kss_deploy/
# 使用脚本安装更新管理拓扑
bash ./shell/main.sh
```

## 软件管理平台

### 清空公网软件包

```bash
# show tables;
docker exec -it mysql bash
mysql -uroot -pmysql@kylin
use kylin_soft_shop;
update t_kylinos_application_status set delete_status = 1,update_time=now() where 1=1;
update t_kylinos_application_basic set update_time=now() where 1=1;
update t_kylinos_store_android_info set delete_status =1 where 1=1;
flush privileges;
exit
```

## 软件上架-软件商店

### 1、创建仓库源

![新建仓库](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826181800414.png)

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826130335613.png)

### 2、上传软件包

```bash
# 下载向日葵软件 https://sunlogin.oray.com/download/linux?type=personal
SunloginClient_11.0.1.44968_kylin_amd64.deb
# 错误类型deb文件名不能存在大写，软件名_版本_架构.deb
sunloginclient_11.0.1.44968_amd64.deb

```

![上传软件](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826181834670.png)

### 3、填写基本信息

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826154718035.png)

### 4、上传相关图片

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826154753088.png)

### 5、添加表情

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826154825035.png)

### 6、发布软件

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826154905136.png)





## 客户端使用

```
软件管理平台：http://192.168.16.118:8880/login ， 默认账号: admin/admin
软件更新平台：http://192.168.16.118:18080，默认账号：root/Kylin2023*
```





### 客户端配置

1、软件商店添加源地址

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826151717074.png)

````bash
# 注释其他源地址，添加源 vim /etc/apt/sources.list
deb http://192.168.16.118:8002/DEB/KYLIN_DEB bank_test main
# 禁止修改
sudo chattr +i /etc/apt/sources.list
# 取消锁定
sudo chattr -i /etc/apt/sources.list
lsattr /etc/apt/sources.list

````

2、软件商店修改服务器地址

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826122328849.png)

3、常用命令

```bash
# 常用命令
sudo apt update # 更新源
apt policy sunloginclient # 查看软件包
```

![apt policy](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250826151920510.png)



## 更新管理平台

## 其他





---



# 六、KMS

## 安装

---

# 七、问题&解决方法-待删除

## 通用

[命令行关闭息屏|休眠|睡眠](https://askubuntu.com/questions/47311/how-do-i-disable-my-system-from-going-to-sleep)

```bash
# 关闭
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
# 开启
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

### sftp

```bash
# 1. 安装SSH服务
sudo yum install openssh-server
# 2. 配置防火墙
# firewalld
sudo firewall-cmd --permanent --zone=public --add-service=ssh
sudo firewall-cmd --reload
# iptables
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
# 3. 
sudo systemctl restart sshd
```


### wireguard

```bash
# 1. 安装WireGuard
sudo add-apt-repository ppa:wireguard/wireguard
sudo apt-get update
sudo apt-get install wireguard wireguard-tools

# 2. 启用IP转发
sudo vi /etc/sysctl.conf
#
net.ipv4.ip_forward=1
#
sudo sysctl -p

## 3. 创建WireGuard接口
# 生成密钥对
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey > /dev/null

## 4. 创建配置文件
sudo vi /etc/wireguard/wg0.conf
#
[Interface]
Address = 10.0.0.2/24
PrivateKey = <客户端私钥>
DNS = 10.0.70.1
 
[Peer]
PublicKey = <服务器公钥>
AllowedIPs = 0.0.0.0/0, ::/0  # 允许所有IP流量通过VPN隧道（谨慎使用）
Endpoint = <服务器IP>:51820  # 服务器的公网IP和端口号
PersistentKeepalive = 30  # 保持连接活跃的频率（秒）

# 5. 启动WireGuard服务
sudo wg-quick up wg0
```

## 桌面

## 服务器



## 概述

> 要求：4C8G 128G
> 不同业务场景下进行批量激活桌面和服务器产品的工具。

## 
1、雅安市党政机关-desktop-电脑网卡重启后无法识别问题，已联系安全套件厂家确认中可能是套件的策略原因；
2、391883017萨嘎县人民政府-desktop-财政系统无法打开问题，已解决；
3、62324211西藏那曲比如县财政局-desktop-光驱无法识别问题，已解决；
4、34767054中共阿里地委办公室工会委员会-系统激活问题，已解决；
5、32940012西藏自治区民政厅-desktop-打印机驱动安装问题，已解决。



# 其他

## 安装和使用

```bash

```

## 麒麟激活授权

```bash
1. 登录麒麟系统终端输入 kylin-system-verify 回车；
2. 输入序列号后回车，回激活 二维码；
3. 打开麒麟软件客服，点击右下角的 “扫描二维码” 扫描系统上显示的二维码；
4. 输入服务序列号后，点击激活，界面上会显示激活码；
5. 在服务器上回车后，将麒麟软件客服上得到的激活码输入到服务器操作系统上即可激活；
6. 检查激活状态，输入 kylin_activation_check 即可查看当前激活状态。
# 无法加载激活码，可以联网
apt install kylin-activation --reinstall
apt install libkylin-activation --reinstall
sudo rm -rf /etc/.kyhwid && sudo kylin_activation_check
```

## 技服基础培训


### 技术服务介绍

```bash
## 服务产品介绍
# 1.基础服务：标准支持服务5X8 | 优先支持服务7X24;
# 2.高级服务：问题解决服务：Case包(30个起)，远程 | 主动服务: 高级工程师现场服务5人天起，现场|远程 | 驻场服务: 年度起，现场 
# 3.定制服务：
# 4.厂商服务：OEM、ODM、ISV、IHV等厂家的服务；400专线入口，7X9
# 5.代理服务：面向分销代理用户（中建材）；
# 6.Centos服务接管：Centos6: 2026年11月30日 | Centos7: 2028年6月30日 | Centos8: 2028年6月30日
# 7.迁移服务：Centos迁移到麒麟服务器操作系统；迁移咨询（20-100套，一年） 和 迁移实施

## 服务鉴权说明
# 1. 索要服务识别信息（服务序列号），确认用户的身份身份是否合法。 不可以主动告诉用户的信息，只可以确认服务期限。
# 2. 鉴权工具：微信公众号；售后管理系统-鉴权查询(PC/APP) 
# 3. 鉴权流程：服务发起-信息收集-鉴权查询-信息判定-任务派发-服务引导

## 服务级别管理
# 1. SLA:(Service Level Agreement), 服务等级协议 | OLA:(Operation Level Agreement), 操作级别协议
# 2. 服务受理基本要求： 技术问题服务支持原则：流程处理流程要求；问题处理优先级要求
# 3. OLA要求（通用）：P1是7X24小时；服务台待受理(0.5h),服务台受理中(0.5h),一线处理中(1.5h),二线待受理(0.5),二线处理中(8h),三线处理中(109.5h)
# 4. 级别判断与调整
# 4.1 紧急：对项目进展存在严重影响或给客户造成重大风险如无法及时处理会导致风险范围扩大；未及时处理会影响客户业务运行，存在导致业务中断等重大风险；客户明确表示问题紧急并告知影响风险；
# 4.2 一般：客户无特殊要求和问题无潜在风险扩大的情况；
# 4.3 较低：经客户评估该问题可延后处理或推迟处理；未对客户产生实际业务影响或通过临时方案已经解决客户侧问题。
# 5. P1级别判断：
# 5.1: 影响范围：超过50台或者50人；
# 5.2：业务影响面：重点核心业务系统发生了宕机、关键业务数据丢失、关机业务中断等
# 5.3：影响的人员：属于重点的核心人员或高管。利如CEO,CTO,CFO或签约关键人
# 5.4：安全事件：属于较大安全事件及以上的安全事件
```

## 工单系统使用

### 麒麟软件售后服务管理系统的使用

```bash
## 业务与流程
# 1. 服务流程标准流程-五大节点：请求单(呼叫中心|客户自助|1现技服|销售人员|客户经理)-集中式服务台(售后支持|非售后)-L1资源-L2资源池-L3资源池；
# 2. 售后业务：售后业务特指销售合同标识，需要为合同内产品提供售后保障服务，及合同产品为服务产品的业务类型；
# 3. 非售后业务：售前阶段技术支持、售中问题技术支持、超合同范围；
# 4. 服务方式：上门（售前服务单|超合同范围服务单|高级服务-主动服务单）;远程服务(基础|售中服务单|高级服务-问题解决单|上门的全部)
# 5. 当选择现场支持后，此工单不能再升级二线，如需升级二线，需另创建新的工单生活给二线队列
# 6. 主要的角色与虚拟组: 请求收集人(麒麟内部员工)、服务台角色(麒麟内部经理)、L1技术支持工程师、L2技术支持工程师、L3支持（研发）
# 7. 虚拟组: 为了更好提供业务流程流程性及便捷胯部门协作，
# 8. 服务时效-服务级别与OLA: P1-重大停机故障、P2-性能严重下降、P3-普通故障、P4-低
# 9. 工单状态：已开启(请求单-经过服务台->服务单)、已解决(受理人确认问题已解决)、已关闭（已满调）
# 10. 请求收集说明：400客服、销售人员、售前工程师、售后工程师、客户自助

## 操作演示
# 1. 登录环境：统一平台，APP售后服务
# 2. 流程演示：
# 2.1 基础服务单：创建请求单-服务台判断与派发-创建基础服务单-L1受理-完成服务单-升级L2
# 2.2 高级服务-主动服务：创建请求单、服务台判断与派发-创建高级服务单-使用App进行现场服务-服务台扣减-完成服务单
# 2.3 售前阶段技术服务-上门：创建请求单-服务台判断与派发-创建售前节点技术支持单（现场）-使用App进行现场服务-完成服务单
# 2.4 售前阶段服务支持-远程：创建请求单-服务台判断与派发-创建售前阶段技术支持单(远程)-L1处理-完成服务单-升级L2
# 3. 日常工作记录：用于记录日常性工作及相应工时，如学习、培训、会议、项目实施工作等事务性内容

## 常见问题处理建议
# 1. 上门模式服务单是否还可以升级L2线？不可以。
# 2. 选择上门支持后，技服人员在电脑端点击抵达上门为什么没有反应？当选择上门支持后，技服人员必须通过APP进行操作。
# 3. 需关注：为关闭工单


```


### 服务人员服务过程信息录入


```bash
# 1. 工单流转概述：创建请求单-(升级服务台)->服务台受理-(创建服务单)->工单处理-->工单已解决-(满调)->工单关闭
# 2. 服务单创建要求：
# 2.1 标题: (涉及跨部门的需要注明“协同”（例如跨区域、行业、客服）)客户单位名称【项目名称（非项目实施阶段可不填，必须和CRM立项名称一致）】+问题现象描述）。（示例：（协同）麒麟软件【信息管理平台迁移项目】-私有化软件商店导入Kirin9a0商业源报XXXX错误）
# 2.2 客户信息：公司名称
# 2.3 姓名：填写服务对象真实对接联系人姓名和电话。例如：张三（总集成）
# 2.4 请求类型：售后：针对项目实施部署完成后提供标准服务产品范围以内的服务支持，使用本类型（需有明确服务序列号信息）
# 2.5 行业属性选择：当前行业相关人员创建时需要选择，选择时按照实际行业划分选择，非行业人员默认不填写。
# 2.5 区域熟悉选择：安装客户所对应区域进行选择，不确定的可以选择北京。
# 2.6 请求信息：咨询类，售后类
# 2.7 问题类型：根据反馈问题的实际内容选择对应场景类别，类别选择时候需要基于当前场景信息选择到最后一级。
# 2.8 问题描述：问题描述本着真实全面，应秉持3W1H（When, where, what）
# 2.9 系统环境：物理机/虚拟机/容器
# 2.10 网络环境：外网/私有网络/无网络
# 2.11 硬件环境：包含具体使用硬件机器型号、品牌、CPU型号、内存、硬盘等硬件信息
# 2.12 软件环境（含第三方软件）：包含系统环境信息，安装的第三方软件信息等软件相关信息；
# 2.13 问题现象详细模式：需详细说明在什么场景下出现了什么问题，问题的现象是什么（描述需完整，如有日志、图片等新消息可通过附件形式上传）
# 2.14 问题影响范围：需说明以上问题发生后对用户产生的实际影响，影响的范围有哪些，实际产生的影响程度是什么（需详细说明，便于处理人员到实际产生的影响）
# 2.15 解决方案：需说明针对该问题我们做了什么动作，分析的结果是什么，根据该结果给出解决方案是什么，如果无法直接解决的需要记录当前已经排查的信息，分析的结果


```

# 培训2

## 正则表达式

### 了解正则表达式的特点及作用

locate
find
sed
grep
vim
awk


### 正则表达式元字符

1. 定位符（某开通，某结尾）

```bash
# &
```

2. 匹配符

3. 限定符



### 正则表达式POSIX符号



## 云铖

系统激活与安装文档

### 天津麒麟 - 银河麒麟桌面

```bash
Ubuntu: U系列；驱动齐全，
源于 debian
V10 - 4.X内核
V10-SP1 - 5.4, 5.10内核
```

### 中标麒麟 - 服务器

```bash
Centos: R系列
早期：中标V7（桌面/服务器）

# 补丁
https://update.cs2c.com.cn

```

### 芯片

```bash
# c86
#       海光兆芯
#       intel amd

# arm
#       飞腾 - 鲲鹏 920
#       华为(推荐最新的包)
#               990/9006c/9000c/m900/华为芯片

# mips  
#       3a4000


# 龙芯
#       3a5000
#       3a6000

```

### 整机

```bash
## 镜像是OEM
## cat /etc/apt/source.list 判断源是否一样，更换.kyinfo和LICESEN

# 浪潮

# 706

# 同方



```


### 统信 - 

```bash
#       deepin - 深度windows
#       诚迈科技 - UOS

```bash


```

### 周报


```bash
前因后果状态。

```