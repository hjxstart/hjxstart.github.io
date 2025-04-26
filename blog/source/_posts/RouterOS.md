---
title: RouterOS
date: 2023-12-18 17:05:19
categories:
tags:
---

## Centos7.6 minimal安装ROS

### 下载

![下载](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250404102000.png)

```bash
yum -y install unzip
# 在线下载ROM执行
wget https://download.mikrotik.com/routeros/7.18.2/chr-7.18.2.img.zip
# 解压
unzip chr-7.18.2.img.zip
# 将镜像挂载到 /mnt
mount -o loop,offset=512 chr-7.18.2.img /mnt
# 执行 ip a 后确认打印的结果第二项为后依次执行以下命令
ADDR0=`ip addr show eth0 | grep global | cut -d' ' -f 6 | head -n 1`
GATE0=`ip route list | grep default | cut -d' ' -f 3`
# 以在镜像中创建配置内容。
mkdir -p /mnt/rw
echo "/ip address add address=$ADDR0 interface=[/interface ethernet find where name=eth0]
/ip route add gateway=$GATE0
" > /mnt/rw/autorun.scr
# 刷入镜像
umount /mnt
# 将文件系统设定为只读 (Read only)，执行
echo u > /proc/sysrq-trigger
fdisk -lu
# 执行dd写入重启
dd if=chr-7.18.2.img bs=1024 of=/dev/vda && reboot
```



## Ubuntu18.04安装ROS[可选]

### 前置条件

> 此文档使用的Ubuntu系统版本是16.04或者18.04
> Ubuntu系统只挂载了一个磁盘, 磁盘20G以上空间即可，多了浪费
> 此文档使用的Ubuntu系统的网卡是自动获取IP地址

### 下载MikroTik的CHR版本镜像

```bash
# 更新存储库，并下载wget和unzip程序
apt update  && apt install -y wget unzip
# 下载CHR镜像
wget https://download.mikrotik.com/routeros/7.18.1/chr-7.18.1.img.zip
# 解压CHR镜像
gunzip -c chr-7.18.1.img.zip > chr.img
```

### 挂载镜像

```bash
# 安装kpartx
apt-get install kpartx
# 挂载镜像
kpartx -av chr.img
mount -o loop /dev/mapper/loop0p1 /mnt
```

### 卸载镜像

```bash
umount /mnt
kpartx -dv /dev/loop0
losetup -d /dev/loop0
```

### 查看Ubuntu系统的盘符标识

```bash
# Ubuntu系统挂载为只读
echo u > /proc/sysrq-trigger
# 替换Ubuntu系统为MikroTik系统 lsblk
# 注意替换vda为实际的盘符标识
dd if=chr.img bs=1024 of=/dev/vda
# 重启系统
echo s > /proc/sysrq-trigger && sleep 5 && echo b > /proc/sysrq-trigger
```


---

## ESXI 创建ROS

### 创建 ROS 虚拟机

1. 创建虚拟机名字和选择 Linux 类型

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/Ros_create_1.png)

2. 修改虚拟机的配置，锁定内存和添加直通网卡

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS_Create_2.png)

3. 修改为 BIOS 引导启动

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/ROS_Create_3.png)

4. 添加一块现有的 ROS 的 VMDK 硬盘

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203140802.png)

5. 修改硬盘大小和类型

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203140955.png)

6. 使用 WinBox 工具的 Neighbors 选择，以 admin 空密码的方式连接到 ROS，首次登录建议修改密码

### 配置 ROS

1. 修改接口名字。通过插拔网线的方式，双击网卡重命名实际网卡的名称

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203141929.png)

2. 创建网桥。将多个 LAN 口连接起来。

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203142157.png)

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203142344.png)

3. 添加 ROS 的 IP 地址。

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203142721.png)

4. WAN 口获取地址. 添加 DNS 客户端

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203143132.png)

5. 添加 DNS

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203143527.png)

6. 设置 NAT。打开防火墙

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203143946.png)

![](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20240203144044.png)

7. 激活 License

8. 设置开机自启动



```bash


/interface/veth/add name=veth2 address=172.17.0.2 gateway=172.17.0.1
/interface/bridge/port add bridge=bridge interface=veth2


/container/config/set registry-url=https://registry-1.docker.io

/container mounts add dst=/var/log/nginx/ name=nginxlog src=”/disk1/nginx”


/container/add remote-image=nginx:latest interface=veth2 root-dir=disk1/nginx mounts=nginxlog logging=yes


```