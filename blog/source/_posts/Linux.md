---
title: Linux
date: 2022-03-24 11:53:59
categories: 运维
top: 29
tags:
---

# Linux基础

## Linux 目录结构

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250825171924754.png)

![Linux目录结构](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250825172226876.png)



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

### cat命令

```bash
cat aa.txt # 查看文件内容
cat > aa.txt # 覆盖输入，按Ctrl + D结束
cat >> aa.txt # 追加输入，按Ctrl + D结束
cat aa.txt bb.txt cc.txt > dd.txt # 将3个文件的内容写到dd.txt中

```

### more命令

```bash
more # 空格(或者d)向下翻页，b向上翻页，回车下一行，=显示当前行号
more -6 aa.txt # 指定每一页显示6行 
more +6 aa.txt # 从第6行开始显示
```

### less命令

```bash
# 可以使用上下箭头来控制浏览内容
/a # / 向下搜索内容a
?a # ? 向上搜索内容a
less -i # 忽略大小写
less -N aa.txt # 显示行号，可以通过:跳转
```

### group命令（过滤，三剑客之一）

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

### WC命令（ 统计，三剑客之一）

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

### find命令（重要）

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



### 其他

```bash
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
apt update # 没有公钥解决方法：sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED65462EC8D5E4C5

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

