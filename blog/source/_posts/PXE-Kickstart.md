---
title: PXE+Kickstart
date: 2025-04-04 10:45:08
categories: 运维
tags: KylinOS
---

## 1 环境配置

### 1.1 PXE服务器端初始化

> Centos7.9最小安装后初始化

关闭防火墙/SELinux/配置yum源/安装常用软件/关闭sshd服务器的DNS

```bash
systemctl disable --now firewalld
systemctl disable --now postfix
sed -i.bak '/^SELINUX=/c SELINUX=disabled/' /etc/selinux/config
setenforce 0
cd /etc/yum.repos.d/ 
mkdir bak 
mv CentOS-* bak/ 
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.tencent.com/repo/centos7_base.repo
curl -o /etc/yum.repos.d/epel.repo http://mirrors.tencent.com/repo/epel-7.repo
yum install -y tree wget lrzsz vim gdisk lsof net-tools bash-completion autofs yum-utils rsync unzip
# vim /etc/profile.d/prompt.sh
PS1="\[\e[1;33m\][\u@\h \W]\[\e[0m\]\\$ " 
alias cgrep="egrep -v '^(#|$)'" 
alias nt='netstat -tnlp' 
alias ntu='netstat -tnlpu' 
alias cdnet='cd /etc/sysconfig/network-scripts/'
# vi /etc/ssh/sshd_config # UseDNS no
# 制作快照 shutdown -h now
```

---

### 1.2 安装和配置TFTP服务

> 安装tftp和xinetd

```bash
yum install -y tftp-server.x86_64 xinetd
rpm -ql tftp-server
systemctl enable --now tftp
systemctl enable --now xinetd
netstat -tnlpu | grep 69
```

> 修改配置文件

```bash
chmod -R 757  /var/lib/tftpboot/
sed -i.bak '/args/s/$/ -c/' /etc/xinetd.d/tftp
sed -i '14s#yes#no#' /etc/xinetd.d/tftp
systemctl restart xinetd
```

---

### 1.3 安装和配置DHCP服务

```bash
yum install -y dhcp
cp /usr/share/doc/dhcp-4.2.5/dhcpd.conf.example /etc/dhcp/dhcpd.conf
#start  vi /etc/dhcp/dhcpd.conf
option domain-name "baidu.com";
option domain-name-servers 180.76.76.76,119.29.29.29,223.5.5.5;

log-facility local7;
next-server 192.168.14.5;
filename "/grub/bootx64.efi";

subnet 192.168.14.0 netmask 255.255.255.0 {
  range 192.168.14.100 192.168.14.200;
  option routers 192.168.14.1;
  filename "/grub/grubx64.efi";
}

host tftp {
  hardware ethernet 00:0c:29:9d:f7:50;
  fixed-address 192.168.35.5;
}
#end
systemctl enable --now dhcpd
# 查看日志
tailf /var/log/messages
# DHCP数据库文件
cat /var/lib/dhcpd/dhcpd.leases
```

---


### 1.4 安装和配置HTTP服务

```bash
yum install -y httpd
systemctl enable --now httpd
sed -i.bak '/#ServerName/aServerName localhost:80' /etc/httpd/conf/httpd.conf
systemctl restart httpd
systemctl status httpd -l
```

---


### 1.5 Client需要启动的文件

> Ubuntu2204系统样例

```bash
##  实现UEFI SecureBoot的bootx64.efi；启动引导文件grubx64.efi；菜单文件grub.cfg
apt-get download grub-efi-amd64-signed
mkdir grub
dpkg -x grub-efi-amd64-signed_1.187.6xxxxx_amd64.deb grub
# 下载 grubnetx64.efi.signed 文件到pxe的/var/lib/tftpboot/grub/grubx64.efi
# grub/usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed 
scp grub/usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed  root@192.168.35.5:/var/lib/tftpboot/grub/grubx64.efi

## Ubuntu2204系统下载shim.signed(UEFI SecureBoot的bootx64.efi)文件
apt-get download shim.signed
mkdir shim
dpkg -x shim-signed_1.51.4+15.8-0ubuntu1_amd64.deb shim
# 将shim/usr/lib/shim/shimx64.efi.signed.latest文件拷贝到pxe的/var/lib/tftpboot/grub/bootx64.efi
scp shim/usr/lib/shim/shimx64.efi.signed.latest root@192.168.35.5:/var/lib/tftpboot/grub/bootx64.efi

## Ubuntu2204镜像找到/boot/grub/grub.cfg文件
#传到PXE /var/lib/tftpboot/grub目录中
```

---

### 1.6 grub启动菜单的美化

[gfxterm文档](https://hugh712.gitbooks.io/grub/content/configuration-parameters.html)

> /var/lib/tftpboot/grub/grub.cfg

```bash
## 颜色
# 未选中菜单项的颜色，菜单框背景颜色
set menu_color_normal=white/cyan
# 突出显示的菜单项的颜色及其在菜单框中的背景
set menu_color_highlight=yellow/blue
# 指定菜单框外文字的前景色和背景色
set color_normal=yellow/black

## 字体下载链接(dejavu-fonts-ttf-2.37.zip) https://dejavu-fonts.github.io/Download.html
## 准备工作
# wget https://dejavu-fonts.github.io/Download.html
# unzip dejavu-fonts-ttf-2.37.zip 
# grub2-mkfont -s 23 -o dejavu-sans-mono.pf2 dejavu-fonts-ttf-2.37/ttf/DejaVuSansMono.ttf
# rm -rf dejavu-fonts-ttf-2.37*
##字体
loadfont /grub/dejavu-sans-mono.pf2
terminal_output gfxterm

##grub菜单的 menuentry 说明
menuentry "title" [--class-class ..] [--users=users] [--unrestricted] [--hotkey-key] [--id=id] [arg...] {command; ...}
# linux加载内核文件，initrd加载虚拟根文件；
# linux和linuxefi是一样的，initrd和initrdefi是一样的
# 内核文件/var/lib/tftpboot/kernel/{Kylin}
# R系列；/images/pxeboot/目录下的vmlinuz 和 initrd.img，镜像需要挂载在目录上。
menuentry --hotkey=c "c  Centos7.9" {
        set gfxpayload=keep
        echo "Loading Centos7.9 Kernel..."
        linux kernel/Centos7.9/vmlinuz inst.repo="http://${IP}/iso/Centos7.9" inst.ks="http://${IP}/ks/Centos7.9.cfg"
        echo "Loading Centos7.9 RamDisk..."
        initrd kernel/Centos7.9/initrd.img
}
# U系列，/casper/目录下的vmlinuz 和 initrd.img，镜像只需要放在目录上。
menuentry --hotkey=u "u  Ubuntu2204" {
        set gfxpayload=keep
        echo "Loading Ubuntu2204 Kernel..."
	linux kernel/Ubuntu2204/vmlinuz ip=dhcp url="http://${IP}/iso/src/Ubuntu2204.iso"
        echo "Loading Ubuntu2204 RamDisk..."
        initrd kernel/Ubuntu2204/initrd.img
}
# 子菜单
submenu --hotkey=a 'a  Other Version System...' {
        set IP=192.168.35.5
        set menu_color_normal=white/black
        set menu_color_highlight=yellow/black
        set color_normal=light-magenta/black
        source /grub/KylinServer.cfg
        source /grub/KylinDesktop.cfg
}
## 其他
# 进入系统
if [ "$grub_platform" = "efi" ]; then
menuentry --hotkey=n 'n  Boot from next volume' {
        exit 1
}
# 进入Bios设置
menuentry --hotkey=u 'u  UEFI Firmware Settings' {
        fwsetup
}
# 关机和重启
menuentry --hotkey=h 'h  halt' { halt }
menuentry --hotkey=r 'r  reboot' { reboot }
else
menuentry 'Test memory' {
        linux16 /boot/memtest86+.bin
}
fi
```

---


## 麒麟

### 概述

### 服务器 (RedHat系)

> ks.confg

```bash
#version=DEVEL
# Use graphical install
text
#graphical

%packages
## 带UKUI GUI的服务器
@^kylin-desktop-environment
#@container-management # 容器管理，用于管理Linux容器的工具。
#@debugging # 调试工具，调试行为异常程序以及诊断性能问题的工具。
#@development # 开发工具，基本开发环境。
#@dns-server # DNS名称服务器，该软件包组允许您在系统上运行DNS名称服务器（BIND）。
#@file-server # 文件及存储服务器，CIFS，SMB，NFS，iSCSI，iSER及iSNS网络存储服务器。
#@ftp-server # FTP服务器，这些工具允许您在系统上运行FTP服务器。
#@gnome-apps # GNOME应用程序，一组经常使用的GNOME应用程序。
#@headless-management # 无图形终端系统管理工具，用于管理无图像终端系统的工具。
#@infiniband # Infiniband支持，该软件旨在使用基于RDMA的InfiniBand，iWARP，RoCE和OPS架构来支持集群，网络连接和低延迟，高带宽存储。
@kysecurity-SDK # 安全套件SDK，安全套件SDK。
#@kysecurity-enhance # 麒麟安全增强工具，麒麟软件安全增强工具。
#@legacy-unix # 传统UNIX兼容性。
#@legacy-x # 传统X Windows系统的兼容性，用于从继承X Windows环境中迁移或者可用于该环境的兼容程序。
#@mail-server # 邮件服务器，这些软件包运行您配置IMAP或Postfix邮件服务器
@man-help # Man手册，Man手册帮助系统
#@performance # 性能工具，诊断系统和程序级别性能问题的工具。
#@remote-desktop-clients # 远程桌面客户端，远程桌面软件。
#@remote-desktop-servers # 远程桌面服务端，远端桌面服务端软件。
#@remote-system-management # Linux的远程管理，Linux的远程管理界面。
#@scientific # 科学计数法支持
#@security-tools # 安全性工具，用于完整性和可信验证的安全性工具。
#@smart-card # 智能卡支持，支持使用智能卡验证。
#@smb-server # 文件及存储服务器，CIFS，SMB，NFS，iSCSI，iSER及iSNS网络存储服务器。
#@system-tools # 系统工具，这组软件包是各类系统工具的集合，如：连接SMB共享的客户；监控网络交通的工具。
#@virtualization-hypervisor # 虚拟化 Hypervisor，最小的虚拟化主机安装。
#@virtualization-tools # 虚拟化工具，用于离线虚拟映像管理的工具。
#@web-server # 基本网页服务器，这些工具运行您在系统上运行万维网服务器。
%end

# Keyboard layouts 键盘布局
keyboard --xlayouts='cn'

# System language
lang zh_CN.UTF-8 --addsupport=en_US.UTF-8

# Network information 网络信息
network  --bootproto=dhcp --onboot=on --onboot=on --ipv6=auto --activate --hostname=kylin.cn

# Use CDROM installation mdedia
#url --url=http://192.168.35.5/iso/ks-v10-sp3-20240626-x86_64/

# Run the Setup Agent on first boot
firstboot --disable
selinux --disable # selinux禁用
firewall --disable # 防火墙禁用
reboot # 部署后重启
eula --agreed # 同意协议

# System services
#service --enable="chronyd"
services --enabled="chronyd" --disabled="avahi-daemon,rpcbind,cpus,libvirtd.service,postfix.service"


#ignoredisk --only-use=sda
# Partition clearing information
# clearpart --none --initlabel
zerombr
clearpart --all --initlabel
# Disk partitioning information
%include /tmp/sda-nvme.txt

## 必须加上这句话，不然无法启动桌面
xconfig --startxonboot

## System timezone 系统时区
# timesource --ntp-pool=ntp1.aliyun.com
#timesource --ntp-pool=ntp.ntsc.ac.cn
timezone Asia/Shanghai --utc

# 设置Root password，明文是 Kylin@123
# python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
rootpw --iscrypted $6$kP.a8Tx6yG7O53JN$cinUa46WrKnRSy1ifhpzwyd4x3DuXE7lFIs5FzduZ6gUvEX/.wJRC0mWDrV15Io2IGxtkeZy0cOwjnRFmZ/pJ0

## 创建普通 kylin 用户, 密码明文是 Kylin@123
user --name=kylin --password=$6$kP.a8Tx6yG7O53JN$cinUa46WrKnRSy1ifhpzwyd4x3DuXE7lFIs5FzduZ6gUvEX/.wJRC0mWDrV15Io2IGxtkeZy0cOwjnRFmZ/pJ0 --iscrypted --gecos="kylin"
# --groups=whell

## addon指定附加组件，常用来配置KDUMP。购买了许可，出现了内核崩溃，可以联系技术人员会付费解决该问题
%addon com_redhat_kdump --disable --reserve-mb='1024M'
%end


## 控制系统的安装界面;pwpolicy:设置密码策略
%anaconda
pwpolicy root --minlen=8 --minquality=1 --strict --nochanges --notempty
pwpolicy user --minlen=8 --minquality=1 --strict --nochanges --emptyok
pwpolicy luks --minlen=8 --minquality=1 --strict --nochanges --notempty
%end

## 安装系统前检查，并生成 /tmp/sda-nvme.txt
%pre
#       %include http://192.168.14.5/ks/disk/ks-sda-nvme-standard.cfg
       %include http://192.168.14.5/ks/disk/ks-sda-nvme-lvm.cfg
%end

## 安装后的操作
%post --interpreter=/usr/bin/bash --log=/root/ks-post.log

cat > /etc/yum.repos.d/local.repo <<EOF
[local]
name=local
baseurl=http://192.168.14.5/iso/ks-v10-sp3-20240626-x86_64/
gpgcheck=0
#gpgkey=http://192.168.14.5/iso/ks-v10-sp3-20240626-x86_64/RPM-GPG-KEY
#/etc/pki/rpm-ggp/RPM-GPG-KEY-kylin
EOF

%include http://192.168.14.5/ks/Other/sub-ks-v10-sp3-20240626-x86_64-gui.ks
%end
```

> 软件环境

```bash
## 最小安装
#@^minimal-environment
#@container-management # 容器管理，用于管理Linux容器的工具。
#@debugging # 调试工具，调试行为异常程序以及诊断性能问题的工具。
#@development # 开发工具，基本开发环境。
#@headless-management # 无图形终端系统管理工具，用于管理无图像终端系统的工具。
#@kysecurity-SDK # 安全套件SDK，安全套件SDK。
#@kysecurity-enhance # 麒麟安全增强工具，麒麟软件安全增强工具。
#@legacy-unix # 传统UNIX兼容性。
#@man-help # Man手册，Man手册帮助系统
#@scientific # 科学计数法支持
#@security-tools # 安全性工具，用于完整性和可信验证的安全性工具。
#@smart-card # 智能卡支持，支持使用智能卡验证。
#@standard # 标准，标准安装。
#@system-tools # 系统工具，这组软件包是各类系统工具的集合，如：连接SMB共享的客户；监控网络交通的工具。

## 基础设施服务器
#@^server-product-environment
#@container-management # 容器管理，用于管理Linux容器的工具。
#@debugging # 调试工具，调试行为异常程序以及诊断性能问题的工具。
#@development # 开发工具，基本开发环境。
#@dns-server # DNS名称服务器，该软件包组允许您在系统上运行DNS名称服务器（BIND）。
#@file-server # 文件及存储服务器，CIFS，SMB，NFS，iSCSI，iSER及iSNS网络存储服务器。
#@ftp-server # FTP服务器，这些工具允许您在系统上运行FTP服务器。
#@hardware-monitoring # 硬件监控工具，一组用来监控服务器硬件的工具。
#@headless-management # 无图形终端系统管理工具，用于管理无图像终端系统的工具。
#@infiniband # Infiniband支持，该软件旨在使用基于RDMA的InfiniBand，iWARP，RoCE和OPS架构来支持集群，网络连接和低延迟，高带宽存储。
#@kysecurity-SDK # 安全套件SDK，安全套件SDK。
#@kysecurity-enhance # 麒麟安全增强工具，麒麟软件安全增强工具。
#@legacy-unix # 传统UNIX兼容性。
#@mail-server # 邮件服务器，这些软件包运行您配置IMAP或Postfix邮件服务器
#@man-help # Man手册，Man手册帮助系统
#@network-file-system-client # 网络文件系统客户端，启用该系统附加到网络存储。
#@performance # 性能工具，诊断系统和程序级别性能问题的工具。
#@remote-system-management # Linux的远程管理，Linux的远程管理界面。
#@scientific # 科学计数法支持
#@security-tools # 安全性工具，用于完整性和可信验证的安全性工具。
#@smart-card # 智能卡支持，支持使用智能卡验证。
#@smb-server # 文件及存储服务器，CIFS，SMB，NFS，iSCSI，iSER及iSNS网络存储服务器。
#@system-tools # 系统工具，这组软件包是各类系统工具的集合，如：连接SMB共享的客户；监控网络交通的工具。
#@virtualization-hypervisor # 虚拟化 Hypervisor，最小的虚拟化主机安装。
#@web-server  # 基本网页服务器，这些工具运行您在系统上运行万维网服务器。

## 文件及打印服务器
#@^file-print-server-environment
#@container-management # 容器管理，用于管理Linux容器的工具。
#@debugging # 调试工具，调试行为异常程序以及诊断性能问题的工具。
#@development # 开发工具，基本开发环境。
#@directory-client # 目录客户端，用于整合到使用目录服务管理的网络的客户端。
#@hardware-monitoring # 硬件监控工具，一组用来监控服务器硬件的工具。
#@headless-management # 无图形终端系统管理工具，用于管理无图像终端系统的工具。
#@java-platform # Java平台，Linux服务器和桌面平台的Java支持。
#@kysecurity-SDK # 安全套件SDK，安全套件SDK。
#@kysecurity-enhance # 麒麟安全增强工具，麒麟软件安全增强工具。
#@large-systems # 大系统性能，用于大型系统的性能支持工具。
#@legacy-unix # 传统UNIX兼容性。
#@man-help # Man手册，Man手册帮助系统
#@network-file-system-client # 网络文件系统客户端，启用该系统附加到网络存储。
#@performance # 性能工具，诊断系统和程序级别性能问题的工具。
#@remote-system-management # Linux的远程管理，Linux的远程管理界面。
#@scientific # 科学计数法支持
#@security-tools # 安全性工具，用于完整性和可信验证的安全性工具。
#@smart-card # 智能卡支持，支持使用智能卡验证。
#@system-tools # 系统工具，这组软件包是各类系统工具的集合，如：连接SMB共享的客户；监控网络交通的工具。

## 基本网页服务器
#@^web-server-environment
#@container-management # 容器管理，用于管理Linux容器的工具。
#@debugging # 调试工具，调试行为异常程序以及诊断性能问题的工具。
#@development # 开发工具，基本开发环境。
#@directory-client # 目录客户端，用于整合到使用目录服务管理的网络的客户端。
#@hardware-monitoring # 硬件监控工具，一组用来监控服务器硬件的工具。
#@headless-management # 无图形终端系统管理工具，用于管理无图像终端系统的工具。
#@java-platform # Java平台，Linux服务器和桌面平台的Java支持。
#@kysecurity-SDK # 安全套件SDK，安全套件SDK。
#@kysecurity-enhance # 麒麟安全增强工具，麒麟软件安全增强工具。
#@large-systems # 大系统性能，用于大型系统的性能支持工具。
#@legacy-unix # 传统UNIX兼容性。
#@man-help # Man手册，Man手册帮助系统
#@network-file-system-client # 网络文件系统客户端，启用该系统附加到网络存储。
#@performance # 性能工具，诊断系统和程序级别性能问题的工具。
#@python-web # Python Web，基于Pyhton网络应用程序支持。
#@remote-system-management # Linux的远程管理，Linux的远程管理界面。
#@scientific # 科学计数法支持
#@security-tools # 安全性工具，用于完整性和可信验证的安全性工具。
#@smart-card # 智能卡支持，支持使用智能卡验证。
#@system-tools # 系统工具，这组软件包是各类系统工具的集合，如：连接SMB共享的客户；监控网络交通的工具。

## 虚拟化主机
#@^virtualization-host-environment
#@container-management # 容器管理，用于管理Linux容器的工具。
#@debugging # 调试工具，调试行为异常程序以及诊断性能问题的工具。
#@development # 开发工具，基本开发环境。
#@headless-management # 无图形终端系统管理工具，用于管理无图像终端系统的工具。
#@kysecurity-SDK # 安全套件SDK，安全套件SDK。
#@kysecurity-enhance # 麒麟安全增强工具，麒麟软件安全增强工具。
#@legacy-unix # 传统UNIX兼容性。
#@man-help # Man手册，Man手册帮助系统
#@network-file-system-client # 网络文件系统客户端，启用该系统附加到网络存储。
#@openvswitch # 虚拟switch，安装vswitch。
#@remote-system-management # Linux的远程管理，Linux的远程管理界面。
#@scientific # 科学计数法支持
#@security-tools # 安全性工具，用于完整性和可信验证的安全性工具。
#@smart-card # 智能卡支持，支持使用智能卡验证。
#@system-tools # 系统工具，这组软件包是各类系统工具的集合，如：连接SMB共享的客户；监控网络交通的工具。

## 带UKUI GUI的服务器
@^kylin-desktop-environment
#@container-management # 容器管理，用于管理Linux容器的工具。
#@debugging # 调试工具，调试行为异常程序以及诊断性能问题的工具。
#@development # 开发工具，基本开发环境。
#@dns-server # DNS名称服务器，该软件包组允许您在系统上运行DNS名称服务器（BIND）。
#@file-server # 文件及存储服务器，CIFS，SMB，NFS，iSCSI，iSER及iSNS网络存储服务器。
#@ftp-server # FTP服务器，这些工具允许您在系统上运行FTP服务器。
#@gnome-apps # GNOME应用程序，一组经常使用的GNOME应用程序。
#@headless-management # 无图形终端系统管理工具，用于管理无图像终端系统的工具。
#@infiniband # Infiniband支持，该软件旨在使用基于RDMA的InfiniBand，iWARP，RoCE和OPS架构来支持集群，网络连接和低延迟，高带宽存储。
@kysecurity-SDK # 安全套件SDK，安全套件SDK。
#@kysecurity-enhance # 麒麟安全增强工具，麒麟软件安全增强工具。
#@legacy-unix # 传统UNIX兼容性。
#@legacy-x # 传统X Windows系统的兼容性，用于从继承X Windows环境中迁移或者可用于该环境的兼容程序。
#@mail-server # 邮件服务器，这些软件包运行您配置IMAP或Postfix邮件服务器
@man-help # Man手册，Man手册帮助系统
#@performance # 性能工具，诊断系统和程序级别性能问题的工具。
#@remote-desktop-clients # 远程桌面客户端，远程桌面软件。
#@remote-desktop-servers # 远程桌面服务端，远端桌面服务端软件。
#@remote-system-management # Linux的远程管理，Linux的远程管理界面。
#@scientific # 科学计数法支持
#@security-tools # 安全性工具，用于完整性和可信验证的安全性工具。
#@smart-card # 智能卡支持，支持使用智能卡验证。
#@smb-server # 文件及存储服务器，CIFS，SMB，NFS，iSCSI，iSER及iSNS网络存储服务器。
#@system-tools # 系统工具，这组软件包是各类系统工具的集合，如：连接SMB共享的客户；监控网络交通的工具。
#@virtualization-hypervisor # 虚拟化 Hypervisor，最小的虚拟化主机安装。
#@virtualization-tools # 虚拟化工具，用于离线虚拟映像管理的工具。
#@web-server # 基本网页服务器，这些工具运行您在系统上运行万维网服务器。
%end
```

### 桌面 (Ubuntu系)

---

## Centos


## Ubuntu



## Other

### 标准分区 

> 安装系统前检查和确定分区方案，并输出到/tmp/sda-nvme.txt中，等安装系统时执行

> ks-sda-nvme-lvm.cfg

```bash
#!/bin/bash

# 检查系统中是否存在nvme0n1磁盘
if lsblk | grep -q 'nvme0n1'; then
    echo "检测到NVMe磁盘(nvme0n1)，采用方案A配置"
    
    # 生成Kickstart分区配置文件
    cat > /tmp/sda-nvme.txt << 'EOF'
ignoredisk --only-use=nvme0n1
part pv.112 --fstype="lvmpv" --ondisk=nvme0n1 --grow
part /boot --fstype="xfs" --ondisk=nvme0n1 --size=1024
part /boot/efi --fstype="efi" --ondisk=nvme0n1 --size=512 --fsoptions="umask=0077,shortname=winnt"
volgroup ks1 --pesize=4096 pv.112
logvol / --fstype="xfs" --size=1 --grow --name=root --vgname=ks1
logvol swap --fstype="swap" --size=2048 --name=swap --vgname=ks1
EOF

else
    echo "未检测到NVMe磁盘，采用方案B配置(SATA磁盘)"
    
    # 生成SATA磁盘的备用配置
    cat > /tmp/sda-nvme.txt << 'EOF'
ignoredisk --only-use=sda
part pv.112 --fstype="lvmpv" --ondisk=sda --grow
part /boot --fstype="xfs" --ondisk=sda --size=1024
part /boot/efi --fstype="efi" --ondisk=sda --size=512 --fsoptions="umask=0077,shortname=winnt"
volgroup ks1 --pesize=4096 pv.112
logvol / --fstype="xfs" --size=1 --grow --name=root --vgname=ks1
logvol swap --fstype="swap" --size=2048 --name=swap --vgname=ks1
EOF

fi

# 添加可选分区示例 (按需取消注释)
# echo 'logvol /data --fstype="xfs" --size=3145728 --name=data --vgname=ks1' >> /tmp/sda-nvme.txt
# echo 'logvol /home --fstype="xfs" --size=51200 --name=home --vgname=ks1' >> /tmp/sda-nvme.txt
```

> 

### 网卡bond.sh

```bash
#!/bin/bash

echo "请输入bond接口名称"
read bond_name

echo "请输入bond ip（如192.168.1.1/24）"
read bond_ip

echo "请输入bond 网关（如192.168.1.254）"
read bond_gateway

echo "请输入物理网卡名称（如 eth0,eth1）"
read physical_interfaces

#将物理网卡列表转为数组
IFS=',' read -ra physical_interfaces_array <<< "$physical_interfaces"

bond_create() {
    #创建bond 接口
    nmcli connection add type bond con-name $bond_name ifname $bond_name mode $bond_mode
    if [ $? -ne 0 ]; then
        echo "bond 接口 $bond_name 创建失败"
        exit 1
    fi
    #将物理网卡添加到bond接口
    for interface in "${physical_interfaces_array[@]}"; do
        nmcli connection add type ethernet slave-type bond con-name "${interface}-slave" ifname $interface master $bond_name
        if [ $? -ne 0 ]; then
            echo "将网卡$interface 添加到bond接口失败"
            exit 1
        fi
    done
    #配置bond接口的ip
    nmcli connection modify $bond_name ipv4.addresses $bond_ip  ipv4.gateway $bond_gateway  ipv4.method manual
    if [ $? -ne 0 ]; then
        echo "修改 $bond_name 网络参数失败"
        exit 1
    fi

    #激活bond 接口
    nmcli connection up $bond_name
    if [ $? -ne 0 ]; then
        echo "$bond_name 激活失败"
        exit 1
    fi
    echo "$bond_name 成功配置及激活"

}

echo "bond配置菜单如下："
echo "1.配置bond0（balance-rr）轮询"
echo "2.配置bond1（active-backup）主备"
echo "3.配置bond4（802.3ad）动态聚合链路"

read Bond

case $Bond in
    1)
        bond_mode="balance-rr"
        bond_create
        ;;
    2)
        bond_mode="active-backup"
        bond_create
        ;;
    3)
        bond_mode="802.3ad"
        bond_create
        ;;
    *)
        echo "请输入1-3数字"
        ;;
esac

```

### 安装后的优化

> sub-ks-v10-sp3-20240626-x86_64-gui.ks

```bash
# wget -O /etc/yum.repos.d/Centos-Base.repo https://repo.huaweicloud.com/repository/conf/CentOS-7-reg.repo
# wget -O /etc/yum.repos.d/epel.repo http://mirrors.cloud.tencent.com/repo/epel-7.repo

#cat > /etc/yum.repos.d/nginx.repo << EOF
#[nginx-stable]
#name=nginx stable repo
#baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
#gpgcheck=1
#enable=1
#gpgkey=https://nginx.org/keys/nginx_signing.key
#module_hotfixes=true
#EOF
# aolis7.9/openEuler 不能使用nginx源

# 禁止某些用户登录，等保要求
#sed -i 's/^Ip/#Ip/g' /etc/passwd
#sed -i 's/^sysnc/#sync/g' /etc/passwd
#sed -i 's/^shutdown/#shutdown/g' /etc/passwd
#sed -i 's/^halt/#halt/g' /etc/passwd
#sed -i 's/^operator/#operator/g' /etc/passwd
#sed -i 's/^games/#games/g' /etc/passwd
#sed -i 's/^ftp/#ftp/g' /etc/passwd

# 系统优化，增加用户最大线程数，最大打开文件数
#cat > /etc/security/limits.d/mylimits.conf << -EOF_LIMITS
#*      soft    nproc   131072
#*      hard    nproc   131072
#*      soft    nofile  65536
#*      hard    nofile  65536
#EOF_LIMITS

# 系统优化2，
#cat > /etc/profile.d/prompt.sh << EOF
#PS1="\[\e[1;33m\][\u@\h \W]\[\e[0m\]\\$ "
#alias cgrep="egrep -v '^(#|$)'"
#alias nt='netstat -tnlp'
#alias ntu='netstat -tnlpu'
#alias cdnet='cd /etc/sysconfig/network-scripts/'
#ailas scandisk='echo ---> /sys/class/scsi_host/host0/scan;echo ---> /sys/class/scsi_host/host1/scan;echo ---> /sys/class/scsi_host/host2/scan'
#export HISTZIE=10000
#export HISTTIMEFORMAT="%F-%T `whoami` "
#EOF
# source /ect/profile.d/prompat.sh

# 系统优化3，
# Centos7和Centos8有些不同
#sed -i.bak '/^#UseDNS/aUseDNS no' /etc/ssh/sshd_config
# sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/sshd/sshd_config

## 网卡Bound设置
# nmcli connection delete eth0
# nmcli connection delete eth1
# nmcli connection add type bond ifname bond0 con-name bond0 mode active-backup miimon 100
# nmcli connection add type bond-slave ifname eth0 con-name bond0-eth0 master bond0
# nmcli connection add type bond-slave ifname eth1 con-name bond0-eth1 master bond0
# nmcli connection modify bond0 ipv4.method manual ipv4.addresses 192.168.35.53/24 ipv4.gateway 192.168.35.2 autoconnect yes
# nmcli connection up bond0
# ifconfig
# mkdir /etc/network
# echo "interface=bond0" >> /etc/network/default_gw
# cat /etc/network/default_gw
# nmcli connection show
```