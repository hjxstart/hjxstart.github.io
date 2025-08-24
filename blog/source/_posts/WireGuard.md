---
title: WireGuard
date: 2023-12-22 07:40:46
categories: 网络
tags:
---

# WireGuard

## 服务端配置

## 客户端配置

### 1.安装 wireguard-tools

```shell
brew install wireguard-tools
```

### 2.配置 wireguard-tools

```shell
# 创建文件夹
sudo mkdir /etc/wireguard

# 设置文件夹权限
sudo chmod 777  /etc/wireguard

# 切入到创建的目录下
cd /etc/wireguard

# 生成公钥与私钥
wg genkey | tee privatekey | wg pubkey > publickey

# 创建虚拟网卡配置文件
touch wg0.conf

# 编辑虚拟网卡配置文件内容
vi wg0.conf
```

### 3.wg0.conf 虚拟网卡配置

```shell
[Interface]
Address = 192.168.XX.20/24
PrivateKey = 客户端的私钥 (privatekey)
DNS = 192.168.XX.1

[Peer]
PublicKey = 服务端的公钥
Endpoint = 服务器公网IP:13231
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 30
```

### 4.相关命令

```shell
# 启动网卡
wg-quick up wg0
# 停止服务
wg-quick down wg0
# 查看配置
wg-quick strip wg0
```



```bash


[Interface]
PrivateKey = cOVbYQzoRcUsr31GtEV1rKgO9FK2vohF6WWy72R11l0=
Address = 192.168.44.11/32
DNS = 192.168.14.1

[Peer]
PublicKey = RGClYhAev1eJKKzlAMBWhh2N4LP4hLTuEMrurLl8j0w=
AllowedIPs = 1.0.0.0/8, 2.0.0.0/8, 3.0.0.0/8, 4.0.0.0/6, 8.0.0.0/7, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/2, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/6, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, 192.168.14.1/32
Endpoint = ros.huangfamily.cn:40044
PersistentKeepalive = 30

```