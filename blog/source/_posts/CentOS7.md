---
title: CentOS7
categories: 运维
tags:
date: 2021-06-07 23:16:42
---

# 安装

## 虚拟机安装

### 1.分区

/blos boot 2M
/boot 1G
/ 10G 修改为固定
/home 5G
swap 1G

## 最小安装配置

### 1.安装 net-tools

```shell
yum install net-tools
y
y
ifconfig
```

### 2.安装 openssh、openssl 并启动

```shell
yum install openssh*
y
yum -y install openssl openssl-devel patch
systemctl start sshd
```

### 3.安装 vim

```shell
yum -y install vim
```

### 4.安装 wget

```shell
yum -y install wget
```

### 5.安装 gcc 编译套件

```shell
yum install gcc
y
```

## 系统优化

### 1.关闭 selinux

```bash
sed -i 's/=enforcing/=disabled/' /etc/selinux/config
setenforce 0
```

---

### 2.更改为阿里 yum 源

```bash
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum makecache
```

---

### 3.优化 ssh 远程登录配置

```bash
#备份/etc/ssh/sshd_conf
cp /etc/ssh/sshd_config{,.`date +%F`.bak}
#不允许基于GSSAPI的用户认证
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
# 不允许sshd对远程主机名进行反向解析
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
systemctl restart sshd
```

### 4.历史记录数及登录超时环境变量设置

```bash
# 设置闲置超时时间为300s
echo 'export TMOUT=300' >>/etc/profile
# 设置历史记录文件的命令数量为100
echo 'export HISTFILESIZE=100' >>/etc/profile

# 设置命令行的历史记录数量
echo 'export HISTSIZE=100' >>/etc/profile
# 格式化输出历史记录(以年月日分时秒的格式输出)
echo 'export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S"' >>/etc/profile
source /etc/profile
tail -4 /etc/profile
```

---

### 5.调整 linux 描述符

```bash
#文件描述符是由无符号整数表示的句柄,进程使用它来标识打开的文件.文件描述符与包括相关信息(如文件的打开模式,文件的位置类型,文件的初始类型等)的文件对象相关联,这些信息被称作文件的上下文.文件描述符的有效范围是0到OPEN_MAX.
#对于内核而言,所有打开的文件都是通过文件的描述符引用的.当打开一个现有文件或创建一个新文件时,内核向进程返回一个文件描述符,当读或写一个文件时,使用open或create返回的文件描述符标识该文件,并将其作为参数传递给read或write.
# 查看系统文件描述符设置的情况可以使用下面的命令,文件描述符大小默认是1024.
ulimit -n
# 对于高并发的业务Linux服务器来说,这个默认的设置值是不够的,需要调整.
# 调整方法一:
# 调整系统文件描述符为65535
echo '*        -    nofile    65535' >>/etc/security/limits.conf
tail -l /etc/security/limits.conf
# 调整方法二:
# 直接把ulimit -SHn 65535命令加入/etc/rc.d/rc.local,用以设置每次开机启动时配置生效,命令如下:
echo " ulimit -HSn 65535" >>/etc/rc.d/rc.local
echo " ulimit -s 65535" >>/etc/rc.d/rc.local
```

---

### 6.定时清理邮件服务临时目录垃圾文件

```bash
# centos7默认是安装了Postfix邮件服务的,因此邮件临时存放地点的路径为/var/spool/postfix/maildrop,为了防止目录被垃圾文件填满,导致系统额inode数量不够用,需要定期清理.
# 定时清理的方法为:将清理命令写成脚本,然后做成定时任务,每日凌晨0点执行一次.
# 创建存放脚本的目录
[ -d /server/scripts/shell ] && echo "directory already exists." || mkdir /server/scripts/shell -p

# 编写脚本文件
echo 'find /var/spool/postfix/maildrop/ -type f|xargs rm -f' >/server/scripts/shell/del_mail_file.sh
# 查看
cat /server/scripts/shell/del_mail_file.sh
# 加入计划任务
echo "00 00 * * * /bin/bash /server/scripts/shell/del_mail_file.sh >/dev/null &1" >>/var/spool/cron/root
crontab -l
```

---

### 7.内核优化

Linux 服务器内核参数优化,主要是指在 Linux 系统中针对业务服务应用而进行的系统内核参数调整,优化并无一定的标准.下面是生产环境下 Linux 常见的内核优化:

```bash
cat >>/etc/sysctl.conf<<EOF
#kernel_flag
#关闭ipv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1
# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1
#关闭路由转发
#net.ipv4.ip_forward = 0
#net.ipv4.conf.all.send_redirects = 0
#net.ipv4.conf.default.send_redirects = 0
#开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
#处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
#关闭sysrq功能
kernel.sysrq = 0
#core文件名中添加pid作为扩展名
kernel.core_uses_pid = 1
# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1
#修改消息队列长度
kernel.msgmnb = 65536
kernel.msgmax = 65536
#设置最大内存共享段大小bytes
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
#timewait的数量，默认180000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_wmem = 4096        16384   4194304
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
#每个网络接口接收数据包的速率比内核处理这些包的速率快时，允许送到队列的数据包的最大数目
net.core.netdev_max_backlog = 262144
#限制仅仅是为了防止简单的DoS 攻击
net.ipv4.tcp_max_orphans = 3276800
#未收到客户端确认信息的连接请求的最大值
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_timestamps = 0
#内核放弃建立连接之前发送SYNACK 包的数量
net.ipv4.tcp_synack_retries = 1
#内核放弃建立连接之前发送SYN 包的数量
net.ipv4.tcp_syn_retries = 1
#启用timewait 快速回收
net.ipv4.tcp_tw_recycle = 1
#开启重用。允许将TIME-WAIT sockets 重新用于新的TCP 连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 1
#当keepalive 起用的时候，TCP 发送keepalive 消息的频度。缺省是2 小时
net.ipv4.tcp_keepalive_time = 30
#允许系统打开的端口范围
net.ipv4.ip_local_port_range = 1024    65000
#修改防火墙表大小，默认65536
#net.netfilter.nf_conntrack_max=655350
#net.netfilter.nf_conntrack_tcp_timeout_established=1200
# 确保无人能修改路由表
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv4.conf.default.accept_redirects = 0
#net.ipv4.conf.all.secure_redirects = 0
#net.ipv4.conf.default.secure_redirects = 0
EOF
/sbin/sysctl -p
```

---

### 8.安装常用软件

```bash
yum install lrzsz ntpdate sysstat net-tools wget vim bash-completion dos2unix -y
```

---

### 9.更新系统到最新

```bash
# 更新补丁并升级系统版本
yum update  -y
# 只更新安全补丁，不升级系统版本
yum --security check-update    #检查是否有安全补丁
```

### 10.电脑不休眠

```bash
vim  /etc/systemd/logind.conf
# 修改为仅锁屏
HandleLidSwitch=lock
# 必须要使用如下命令才能使上面的配置生效
systemctl restart systemd-logind
```

---

# 使用

## Linux 中的权限、用户和组

### 1.修改权限

1. 字母修改权限

> 关键字有：[u, g, o, a][+, -][r, w, x]

```bash
chmod a+w filename.txt
```

2. 数字修改权限

> (r=0, w=1, x=0) => (010=2)

```bash
chmod 222 filename.txt
```

---

### 2.修改用户和组

1. 修改所属用户：chown [-R] 目标用户 文件或文件夹

```bash
chown username filename.txt
```

2. 修改所属组：chown [-R] 目标组 文件或文件夹

```bash
chgrp groupname filename.txt
```

3. 同时修改所属用户和组：chown [-R] 目标用户 目标组 文件或文件夹

```bash
chown username:groupname filename.txt
# 递归修改，目录包含的子文件或目录也修改
chown -R username:groupname filename.txt
```

---

### 3.目录说明

bin:可执行命令文件
boot:启动文件
dev:设备文件
etc:配置文件
home:用户的目录（每个用户在其下有一个用户的文件夹）
lib:库文件
media:设备挂载点文件（U 盘）
mnt:手动设备挂载点
opt:大型软件安装包（源码安装包）
usr:软件安装包（类似 Windows 中的 Programfiles）

---

### 4.PATH 运行变量

1. 查看运行变量：echo $PATH
2. 修改 PATH：PATH=$PATH":/home/test/testDir", testDir 下的运行文件就可以在系统的任何地方都可以运行。

---

### 5.文件内容查阅

1. cat: 由第一行开始显示文件内容

```bash
cat filename
```

2. tac: 从最后一行开始显示，可以看出 tac 是 cat 的倒置显示

```bash
tac filename
```

3. nl: 显示的时候，顺道输出行号！

```bash
nl filename
# 等同于
cat -n filename
```

4. more: 一页一页的显示文件内容。空格下一页，q 退出。

```bash
more filename
```

5. less: 与 more 类似，但是比 more 更好的是，他可以通过方向键往前翻页！

```bash
less filename
```

6. head: 只看头几行

```bash
head filename
head -3 filename
```

7. tail: 只看尾巴几行

```bash
tail filename
# 查看日志是，只查看后几行并实时更新
tail -f filename.log
```

8. od: 以二进位的方式读取文件内容（string）

```bash
od binfilename
string binfilename
```

---

### 6.档案和目录的默认权限与隐藏权限

1. 文件默认权限：umask,使用默认权限进行过来

默认文件权限 666: 110 110 110
umask 值为 0 022: 000 010 010
默认文件权限 & umask 值 = 过滤后的权限
过滤文件权限 644: 110 100 100
一开始是文件权限(755);默认创建文件夹的权限(644)
默认创建文件的权限(666);默认创建文件夹的权限(777)

```bash
umask
#0022 # 默认0(标志) 0(谁都不过滤) 2(过滤组的w权限) 2(过滤其他用户的w权限)
umask 000 # 修改 umask 值
umask -S
#u=rwx,g=r,o=r # umask的理解，umask -S 的命令
```

2. 文件隐藏权限

文件的 i 权限(不能修改)和 a 权限(只能添加)
修改隐藏权限: chattr [+-] [attr] 文件或文件夹

```bash
chattr +a dir # dir目录下只能添加文件，不能删除文件
chattr +i dir # dir目录下不能操作文件
```

---

### 7.文件类型查看

1. file 命令

```bash
file /bin/touch
file /usr/bin/passwd
file /var/lib/mlocate/mlocate.db
```

---

### 8.用户相关命令：

```bash
id	# 显示当前用户信息
passwd	# 修改当前用户的密码
groups	# 查看所属组

#添加用户：useradd [options] username
#选项：	-g	主组 	指定用户所属的用户组
#	-G	附属组	指定用户所属的附加组
#	-r	等效于--system 表示创建一个系统账号
#注：默认不会为系统用户创建对应的主目录

#锁定或解锁用户：passwd [options] [username]
#如果只提供用户名，则修改当前用户的密码
#选项：	-l	锁定用户
#	-u	解锁用户
#	-d	设置用户无密码，用户下次登陆时系统不再询问密码。
#非root用户临时使用root权限：sudo
#注：有时需要修改 vim /etc/sudoers, 把用户添加进去才可以
```

---

### 9.组相关命令

```bash
# 1.添加组：groupadd groupname
groupadd javadevgroup
# 2.删除组：groupdel [options] groupname
groupdel javadevgroup
# 注：-r 同时删除该用户的主目录
# 3.修改用户所属组：usermod [options] username
usermod -G javadevgroup hjx
# 注：-g 主组	-G 附属组
```

---

### 10.指令与档案的搜寻

1. 查找指令：which 命令

```bash
# 查找文件：find [查找位置] [查找参数]
# 示例：find . -name "s*" 按文件名查找，可使用通配符
# 选项：
#	-name 查找文件/文件夹名称
#	-iname 忽略大小写的名称查找
#	-user    查找所属用户的文件
#	-group 查找所属组的文件
#	-or 或条件
which ls
```

2. 查找内容：grep（全称 Global Regular Expression Pring）

```bash
# grep [option] pattern file
# 基于正则表达式搜索文本，并吧匹配的行显示出来。如果正则表达式中包括空格，则必须使# 用引号将正则表达式引起来。
# 选项:	-n    #显示行号
#	-i        #忽略大小写
#	-w       # 单词完整匹配
grep 'linux' test.txt #从文件中查找关键词
grep ^u test.txt # 找出以u开头的行
grep hat$   test.txt # 找出以hat结尾的行
```

---

### 11.Linux 常见的压缩与打包指令

```bash
# 1. zip压缩（归档）：
#	zip [目标压缩文件名] [源文件名]
zip test1to3 test1.txt test2.txt test3.txt
#	unzip [压缩文件名]
unzip testto3.zip
# 2. gzip压缩 (压缩)：
#	gzip [file-list] # 压缩后会删除原始文件，压缩后的文件后缀为.gz
gzip file1 file2
#	gzip -d [zip-file-list] # 解压缩文件
gzip -d file.gz
# 3. tar (归档)
tar -cvf filename.tar ./dir1 # 将dir1目录归档
tar -xvf filename.tar # 解压
tar -cvzf filename.tar.gz ./dir1 #归档的同时使用gzip压缩
tar -xvzf filename.tar.gz # 解压
```

---

### 12.Linux 安装软件的方式

```bash
# 二进制文件的安装，常用于归档的编译好的文件压缩包。（XXX.tar 或者 XXX.tar.gz）
# 1. rmp文件安装
rpm(Red-Hat Package Manager)红帽的一种安装包方式
rpm -qa | grep [keywords] # 查询是否已经安装某个应用程序
rpm -ivh software.rpm # 安装软件 -v显示纤细安装信息， -h 显示进度
rpm -e --nodeps software.rpm # 卸载软件 --nodeps表示不检查依赖关系，强制卸载

# 2. yum安装：
# 是一个rpm的前端程序，使用在线仓库来检索和安装RPM软件包，能够自动解决RPM的依赖关系。
# yum list installed | grep [keywords] # 查看是否已经安装某个应用程序
yum search keywords # 从仓库中查找软件包
yum install software-name # 安装软件包
yum remove software-name # 卸载软件包
```

---

### 13.安装 JDK8 和 Tomcat8

```bash
# 1.安装JDK8
# 上传文件到 /opt 下，并解压，修改解压文件名称为 jkd8，
# 再到/etc/profile中添加环境变量PATH
export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL
JAVA_HOME="/opt/jdk8"
PATH=$JAVA_HOME"/bin:"$PATH

# 2.安装Tomcat8，跟JDK8类似
cd /etc/sysconfig/network-scripts
# 网卡配置
DEVICE=eth0
HWADDR=00:0C:29:6D:73:FA
TYPE=Ethernet
UUID=ee3f1297-cff6-416d-9bb4-a95939413426
ONBOOT=yes
NM_CONTROLLED=yes
BOOTPROTO=dhcp

# 改为
ONBOOT="yes"
IPADDR=192.168.18.125
GATEWAY=192.168.18.1
NETMASK=255.255.255.0
DNS1=180.76.76.76
DNS2=114.114.114.114
```

---

### 14.安装 MySQL8

```bash
rpm -qa | grep mysql # 查看老版本mysql
rpm -e --nodeps mysqll-XXXX（一个一个）# 删除老版本mysql
rm -rf /usr/share/mysql # 删除mysql的文件
rm -rf /var/lib/mysql # 删除mysql文件
# 下载并解压在/opt/mysql文件下
tar -xvf mysql-8.0.20-1.el7.x86_64.rpm-bundle.tar

# 顺序安装MySql
rpm -ivh mysql-community-common-8.0.20-1.el7.x86_64.rpm
rpm -ivh mysql-community-libs-8.0.20-1.el7.x86_64.rpm --force --nodeps
rpm -ivh mysql-community-client-8.0.20-1.el7.x86_64.rpm --force --nodeps
rpm -ivh mysql-community-server-8.0.20-1.el7.x86_64.rpm --force --nodeps
rpm -ivh mysql-community-devel-8.0.20-1.el7.x86_64.rpm --force --nodeps

# Yum安装
wget -i -c https://dev.mysql.com/get/mysql80-community-release-el6-3.noarch.rpm
yum -y install mysql80-community-release-el7-3.noarch.rpm
yum -y install mysql-community-server

service mysqld start # 启动服务

# root用户的初始密码在/var/log/mysqld.log文件中，查看密码：
grep 'temporary password' /var/log/mysqld.log

# 重置mysql密码
mysql> alter user 'root'@'localhost' identified by 'password';

# 重启mysql服务
service mysqld stop
service mysqld start
```

# 自动化运维

## 运维基础

### 1.at 简介

> 1. at 一次性计划任务只执行一次，一般用于满足临时的任务需求
> 2. 主要是时间点比较灵活
> 3. 前提:系统开启 atd 服务

```shell
yum install at
# 开启服务
systemctl start atd.service
# 开机自启动
systemctl enable atd.service
# 查看当前的
systemctl status atd
```

### 2.at 简单使用

定义定时任务 1

```shell
# 设置当前用户的一次性任务命令
at 23:30
# 定义定时任务要执行的命令
systemctl restart httpd
```

> `注意:` 一次性的计划任务使用 ctr+D 来结束提交

定义定时任务 2

```bash
echo "systemctl restart httpd" | at 23:30
```

查看定时任务

```shell
at -l
```

删除编号为 2 的定时任务

```shell
atrm 2
```

> 使用帮助： `at --help` 或者 `man at`

---

### 3.cron 简介

1. 简介

> 1. 能够周期性地、有规律地执行某些具体的任务
> 2. Linux 系统中默认启用的 crond 服务
> 3. 参数格式

![image.png](/images/2021/06/09/02e49f81-65f9-451b-8aa6-6794e740882d.png)

2. crontab 命令书写格式中符号的含义

> 1. `*` 代表每
> 1. `,` 来分别表示多个时间段，例如“8,9,12”表示 8 月、9 月和 12 月
> 1. `-` 来表示一段连续的时间周期(例如字段“日”的取值为“12-15”，则表示每月的 12~15 日)
> 1. `/` 表示执行任务的间隔时间(例如“\*/2”表示每隔 2 分钟执行一次任务)

示例

```shell
# 注释格式who,when,why?
# 每周1，周3，周五的3:25分
25 3 * * 1,3,5 command
# 每周工作日(周一至周五)1:00
0 1 * * 1-5 command
# 每隔5分钟
*/5 * * * * command
# 在上午8点到11点的第3和 第15分钟执行
3,15 8-11 * * *
# 每隔两天的上午8点到11点的第3 和第15分钟执行
3,15 8-11 */2 * *
```

> 1. `注意1`：如果时上有值，分钟必须有值
> 2. `注意2`：定时任务中%无法执行，需要转义\%

---

### 4.系统级的计划任务

1. 简述

> 1. 系统设置好的，一般了解就行了，不要更改配置文件是/etc/crontab

2. 文件/etc/crontab

```shell
# For details see man 4 crontabs
# Example of job definition:
# .---------------- minute (0 - 59)
# | .------------- hour (0 - 23)
# | | .---------- day of month (1 - 31)
# | | | .------- month (1 - 12) OR jan,feb,mar,apr ...
# | | | | .----dayofweek(0-6)(Sunday=0or7)OR sun,mon,tue,wed,thu,fri,sat
# | | | | |
# * * * * * user-name command to be executed
```

---

### 5.用户级的计划任务

1. crontab 常用选项

- -e: 编辑计划任务 edit
- -l: 查看计划任务 display
- -u: 指定用户 user
- -r: 删除计划任务 remove

2. 示例

```bash
# 每月1、10、22日的4:45重启network服务
45 4 1,10,22 * * systemctl restart network
45 4 1,10,22 * * /usr/bin/systemctl restart network

# 每周六、周日的1:10重启network服务
10 1 * * 6-7 sytemctl restart network

# 每天18:00至23:00之间每隔30分钟重启network服务
*/30 18-23 * * * systemctl restart network

# 每隔两天的上午8点到11点的第3和第15分钟执行一次重启
3,15 8-11 */2 * * systemctl reboot
# 每周日凌晨2点30分，运行cp命令对/etc/fstab文件进行备份，存储位置为/backup/fstab-YYYY-MM-DD-hh-mm-ss;
# date +%F-%H-%M-%S > 2021-06-09-09-35-38
30 2 * * 7 cp /etc/fatab /backup/fstab-date +\%F-\%H-\%M-\%S
30 2 * * 0 cp /etc/fatab /backup/fstab-date +\%F-\%H-\%M-\%S

# 晚上11点到早上7点之间，每隔一小时重启smb
0 23,0-7/1 * * * systemctl restart smb
```

> 1. `注意1：`vim /etc/crontab (系统级) 与 crontab -e (用户自定义)写入的定时运行的区别
> 2. `注意2：`用户自定义的定时任务文件路径：/var/spool/cron/username

3. 再玩一次

> 1. 设置一次性计划任务在 18:00 时关闭系统，并查看任务 信息。
> 2. 每周日凌晨 2 点 30 分，运行 cp 命令对/etc/fstab 文件进行 备份，存储位置为/backup/fstab-YYYY-MM-DD-hh-mm- ss。
> 3. 每周 2、4、7 备份/var/log/secure 文件至/logs 目录中， 文件名格式为“secure-yyyymmdd”。
> 4. 每两小时取出当前系统/proc/meminfo 文件中以 S 或 M 开 头的行信息追加至/tmp/meminfo.txt 文件中。

```shell
# 1.设置一次性计划任务在18:00时关闭系统，并查看任务 信息。
at 18:00
systemctl poweroff
at -l

# 2.每周日凌晨2点30分，运行cp命令对/etc/fstab文件进行 备份，存储位置为/backup/fstab-YYYY-MM-DD-hh-mm-ss。
30 2 * * 7 cp /etc/fstab /backup/fstab-$(date +\%F-\%H-\%M-\%S)

# 3.每周2、4、7备份/var/log/secure文件至/logs目录中， 文件名格式为“secure-yyyymmdd”。
0 0 * * 2,4,7 cp /var/log/secure /logs/secure-$(date + \%Y\%m\%d)

# 4.每两小时取出当前系统/proc/meminfo文件中以S或M开 头的行信息追加至/tmp/meminfo.txt文件中。
0 */2 * * * grep ^[SM] /proc/meminfo  >> /tem/meminfo.txt
```

---

### 6.rsyslog 日志管理

1. 简介

> 0. Centos6.x 日志服务已经由 rsyslogd 取代了原先的 syslogd 服务,有如下优点
> 1. 基于 TCP 网络协议传输日志信息;
> 2. 更安全的网络传输方式;
> 3. 有日志消息的及时分析框架;
> 4. 后台数据库;
> 5. 配置文件中可以写简单的逻辑判断; ü 与 syslog 配置文件相兼容。

2. 系统中常见的日志文件

> 0. `/var/log/message` 系统重要的日志
> 1. `/var/log/cron` 定时任务的日志
> 2. `/var/log/dmesg` 开机时内核自检的信息
> 3. `lastb /var/log/btmp` 错误登录的日志
> 4. `last /var/log/wtmp`所有用户登录和注销信息
> 5. `/var/run/utmp`记录当前已经登录的用户信息，要使用 w,who,users 等命令查询
> 6. `/var/log/secure`记录验证和授权方面的信息

3. 日志格式。

> 1. 只要是由日志服务 rsyslogd 记录的日志文件，他们的格式是一样的。基本日志格式包含以下四列:
> 2. `事件产生的时间`,;`发生事件的服务器的主机名`;`产生事件的服务名或程序名`;`事件的具体信息。`

```shell
tail -2 /var/log/messages
Jun  9 10:11:03 localhost dbus[6555]: [system] Activating service name='org.freedesktop.problems' (using servicehelper)
Jun  9 10:11:03 localhost dbus[6555]: [system] Successfully activated service 'org.freedesktop.problems'
```

4. /etc/rsyslog.conf 配置文件格式

> 1. 服务名：\*, authpriv, cron, ftp, daemon(守护进程), kern, mall, syslog, user
> 2. 连接符号：`.`(大于), `.=`(等于),`.!`(不等于)
> 3. 日志级别: null, debug, info, notice, warning, err(错误), crit(临界状态), alert(警告), emerg(疼痛，宕机)
> 4. 日志记录位置：文件，远程主机(tcp@@IP:514, udp@IP)需要在线，并用户对等传输(root->root)

```shell
服务名称[连接符号]日志等级 日志记录位置
authpriv.* /var/log/secure
认证相关服务.所有日志等级 记录在/var/log/secure 日志中
```

5. 日志服务 rsyslogd

存放日志的服务器（开启接受功能）:192.168.17.130

```shell
# 编辑配置文件
vim /etc/rsyslog.conf
```

```shell
# Provides UDP syslog reception 开启UDP传输
$ModLoad imudp
$UDPServerRun 514
# Provides TCP syslog reception 开启TCP传输
$ModLoad imtcp
$InputTCPServerRun 514
```

```shell
# 重启服务
systemctl restart rsyslog
# 查看514端口是否在监听
netstat -tnlup | grep :514
# 实时查看日志后，进行测试
tail /var/log/maillog -f
```

产生日志服务器（发送日志）:192.168.17.133

```shell
# 默认端口为514
echo 'mail.info @192.168.17.130:514'>> /etc/rsyslog.conf
# 测试
[root@localhost ~]# systemctl restart rsyslog # 重启服务
# 发送测试消息
[root@localhost ~]# logger -p mail.info "this is a test for rmote log."
```

6. 作业

扩展：集中日志管理工具 elk, 有收集，分析，展示日志功能，并支持分布式

```shell
1.将authpriv设备日志记录到 /var/log/auth.log
	1).修改日志文件位置
	# vim /etc/rsyslog.conf
	#authpriv.* /var/log/secure
	authpriv.* /var/log/auth.log
	2).重启程序，触发日志生成
	# systemctl restart rsyslog.service
	# ll /var/log/auth.log
2.改变应用程序sshd的日志设备为local5,并定义lcoal5设备日志记录到/var/log/local5.local。
	1).设置ssh程序的日志设备为自定义设备。
	# vim /etc/ssh/sshd_config
	#SyslogFacility AUTHPRIV
	SyslogFacility FOCAL5
	2).设置自定义设备日志文件存放位置。
	# vim /etc/rsyslog.conf
	local5.* /var/log/local5.local
	3).重启失效
	# systemctl restart ssh // 重启sshd程序
	# systemctl restart rsyslog // 重启日志
	4).尝试登录，触发日志。
	5).观察日志。理解自定义日志设备。
3.使用logger程序写日志到指定的设备及级别。
	服务器1(192.168.17.133)发送日志
	# vim /etc/ssh/sshd_config
	#SyslogFacility AUTHPRIV // 将原来配置注释
	SyslogFacility LOCAL5 // 自定义接受设备 local5
	# vim /etc/rsyslog.conf // 此文件来管理日志
	local5.* @192.168.17.130:514 // 此处填写日志服务器的IP地址
	# systemctl restart sshd // 重启sshd程序
	# systemctl restart rsyslog // 重启日志

	服务器2(192.168.17.130)接受日志
	# vim /etc/rsyslog.conf
	$ModLoad imudp
	$UDPServerRun 514 // 这两个注释去掉，使用udp
	local5.* /var/log/server12.log
	# systemctl restart rsyslog
	尝试ssh登录服务器1,并观察本地日志
	# tail -f /var/log/server12.log
```

---

### 7.logrotate 日志轮转

1. 简介

> 1. 日志轮转也叫日志轮替，日志切割:
> 2. 如果没有日志轮转，日文件会越来越大;
> 3. 将丢弃系统中最旧的日志文件，以节省空间;
> 4. logrotate 本身不是系统守护进程，它是通过计划任务 crond 每天执行;

```shell
cat /etc/cron.daily/logrotate
```

```shell
#!/bin/sh
/usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.conf
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
```

2. 日志文件命名规则

日志轮替最主要的作用就是把旧的日志文件移动并改名， 同时建立新的空日志文件，当旧日志文件超出保存的范围 之后，就会进行删除。那么旧的日志文件改名之后，如何 命名呢?主要依靠/etc/logrotate.conf 配置文件中
“dateext”参数:

- 如果配置文件中拥有“dateext”参数，那么日志会用日期来作为日志文件的后缀，例如“secure-20180605”。这样的话日志文件名不会重叠，所以也就不需要日志文件的改名，只需要保存指定的日志个数，删除多余的日志文件即可。
- 如果配置文件中没有“dateext”参数，那么日志文件就需要 进行改名了。当第一次进行日志轮替时，当前的“secure”日志会自动改名为“secure.1”，然后新建“secure”日志，用 来保存新的日志。当第二次进行日志轮替时，“secure.1”会 自动改名为“secure.2”，当前的“secure”日志会自动改名 为“secure.1”，然后也会新建“secure”日志，用来保存新 的日志，以此类推。

3. logrotate 配置文件

```shell
# vim /etc/logrotate.conf
weekly  // 轮转的周期，一周轮转
rotate 4 // 保留4份
create // 轮转后创建新文件
dateext // 使用日期作为后缀
#compress // 是否压缩，
include /etc/logrotate.d // 包含该目录下的文件也轮询

/var/log/wtmp { // 对该日志文件设置轮转的方法
    monthly	// 一月轮转一次
    create 0664 root utmp	// 轮转后创建新文件，并设置权限
    minsize 1M	// 最小达到1M才轮转
    rotate 1	// 保留一份
}
/var/log/btmp {
    missingok	// 丢失不提示
    monthly	// 每月轮转一次
    create 0600 root utmp	// 轮转后创建新文件，并设置权限
    rotate 1	// 保留一份
}
```

其他配置信息

- size 大小:日志只有大于指定大小才进行日志轮替，而不是按 照时间轮替。如 size 100k
- prerotate/endscript:在日志轮替之前执行脚本命令。 endscript 标示 prerotate 脚本结束。
- postrotate/endscript:在日志轮替之后执行脚本命令。 endscript 标示 postrotate 脚本结

logrotate 命令的格式

- [root@localhost ~]# logrotate [选项] 配置文件名
- 选项: 如果此命令没有选项，则会按照配置文件中的条件进行日志轮替
  -v: 显示日志轮替过程。加了-v 选项，会显示日志的轮替的过程
  -f: 强制进行日志轮替。不管日志轮替的条件是否已经符合，强制配置文件中所有的日志进行轮替

4. 轮转案例:对/var/log/err.log 轮转

```shell
# vim /etc/logrotate.d/err_log # 编辑轮转规则
/var/log/err.log {
        # 每天轮转
        daily
        # 使用日期命名
        dateext
        # 创建新文件
        create
        # 保留5分
        rotate 5
        # 丢失不提示
        missingok
}

# logrotate -f /etc/logrotate.d/err_log # 手动强制启动轮转
# ll /var/log/
-rw-------. 1 root   root    11449 6月   8 03:31 boot.log-20210608
```

5. 作业

```shell
logrotate日志轮转

1、将我们自己生产的/var/log/err.log 日志志加入日志轮替的策略
	vim /etc/logrotate.d/err
	# 创建err文件，把/var/log/err.log加入轮替

	/var/log/err.log {
		weekly				#每周轮替一次
		rotate 6			#保留6个轮替日志
		sharedscripts		#以下命令只执行一次
		prerotate
			/usr/bin/chattr -a /var/log/err.log
			#在日志轮替前取消a属性，以便让日志可以轮替
		endscript

		sharedscripts
		postretate
			/usr/bin/chattr +a /var/log/err.log
			#日志轮替完毕再加上a属性
		endscript

		sharedscripts
		postrotate
			/bin/kill -HUP $(/bin/cat /var/run/syslogd.pid 2>/dev/null) &>/dev/null
			#重启rsyslog服务，确保日志轮替正常
		endscript
	}

2、要把 Nginx 服务的日志加入日志轮替，则也需要重启 Nginx 服务
	首先，安装nginx
	// yum install http://nginx.org/packages/rhel/7/x86_64/RPMS/nginx-1.10.3-1.el7.ngx.x86_64.rpm
	其次，启动服务后，客户端访问及可产生日志
		# systemctl start nginx
		# systemctl enable nginx#
		# ls /var/log/nginx/
		access.log  error.log

	最后，对访问和错误日志加入轮替
	vim /etc/logrotate.d/nginx
	/var/log/nginx/access.log /var/log/nginx/error.log {
		daily
		rotate 15
		sharedscripts
		postrotate
			/bin/kill -HUP $(/bin/cat /var/run/syslogd.pid) &>/dev/null
			#重启 rsyslog 服务
			/bin/kill -HUP $(/bin/cat /var/run/nginx.pid) &>/dev/null
			#重启 Nginx 服务
		endscript
	}
```

### 8.sshd

1. sshd 简介

- 传统的网络服务程序，如:ftp 和 telnet 在本质上都是不安全的，因为它们在网络上用明文传送口令和数据，别有用心的人非常容易就可以截获这些口令和数据。
- 演示 tcpdump 截获 ftp 用户名和密码。

```shell
1.前置条件
[root@localhost ~]# yum install vsftpd -y	// 安装 ftp 服务期端
[root@localhost ~]# systemctl start vsftpd	// 启动 ftp 服务
[root@localhost ~]# yum install tcpdump		// 安装 tcpdump
[root@localhost ~]# tcpdump -i ens33 -nnX port 21	// 使用 tcpdump 监听 21端口

[root@localhost ~]# useradd ftpuser	// 创建ftp测试用户
[root@localhost ~]# echo "hadoop" | passwd --stdin ftpuser
```
