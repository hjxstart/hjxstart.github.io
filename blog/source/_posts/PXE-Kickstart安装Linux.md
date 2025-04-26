---
title: PXE+Kickstart安装Linux
date: 2025-04-04 10:45:08
categories:
tags:
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

### 1.5 Client需要启动的文件(Ubuntu22.04)

> Ubuntu2204系统下载grubx64.efi文件

> 实现UEFI SecureBoot的bootx64.efi；启动引导文件grubx64.efi；菜单文件grub.cfg

```bash
apt-get download grub-efi-amd64-signed
mkdir grub
dpkg -x grub-efi-amd64-signed_1.187.6xxxxx_amd64.deb grub
# 下载 grubnetx64.efi.signed 文件到pxe的/var/lib/tftpboot/grub/grubx64.efi
# grub/usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed 
scp grub/usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed  root@192.168.35.5:/var/lib/tftpboot/grub/grubx64.efi
```

> Ubuntu2204系统下载shim.signed(UEFI SecureBoot的bootx64.efi)文件

```bash
apt-get download shim.signed
mkdir shim
dpkg -x shim-signed_1.51.4+15.8-0ubuntu1_amd64.deb shim
# 将shim/usr/lib/shim/shimx64.efi.signed.latest文件拷贝到pxe的/var/lib/tftpboot/grub/bootx64.efi
scp shim/usr/lib/shim/shimx64.efi.signed.latest root@192.168.35.5:/var/lib/tftpboot/grub/bootx64.efi
```

> Ubuntu2204镜像找到/boot/grub/grub.cfg文件

```bash
上传到PXE /var/lib/tftpboot/grub目录中
```

---

#### 1.5.1 grub启动菜单的美化

[gfxterm文档](https://hugh712.gitbooks.io/grub/content/configuration-parameters.html)

> /var/lib/tftpboot/grub/grub.cfg

> 颜色
```bash
# 未选中菜单项的颜色，菜单框背景颜色
set menu_color_normal=white/cyan
# 突出显示的菜单项的颜色及其在菜单框中的背景
set menu_color_highlight=yellow/blue
# 指定菜单框外文字的前景色和背景色
set color_normal=yellow/black
```

> 字体[下载链接(dejavu-fonts-ttf-2.37.zip)](https://dejavu-fonts.github.io/Download.html)
```bash
# 准备工作
wget https://dejavu-fonts.github.io/Download.html
unzip dejavu-fonts-ttf-2.37.zip 
grub2-mkfont -s 23 -o dejavu-sans-mono.pf2 dejavu-fonts-ttf-2.37/ttf/DejaVuSansMono.ttf
rm -rf dejavu-fonts-ttf-2.37*
# 配置信息
loadfont /grub/dejavu-sans-mono.pf2
terminal_output gfxterm
```

---

#### 1.5.2  grub菜单的 menuentry

```bash
# 说明
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

### 6. ks自动应答文件配置


#### 6.1 Kylin Server

```bash
#version=DEVEL
# Use graphical install
text

%packages
@^minimal-environment
#@^kylin-desktop-environment
#@development
#@man-hlep
#@system-tools

#chrony
gdisk
#autofs
#lsof
tree
net-tools
lrzsz
wget
vim
#git
#yum-utils
bash-completion
#man-pages
mlocate
unzip
#bind-utils
%end

# Keyboard layouts
keyboard --vckeymap=cn --xlayouts='cn','us'
# System language
lang zh_CN.UTF-8 --addsupport=en_US.UTF-8

# Network information
network  --bootproto=dhcp --onboot=on --onboot=on --ipv6=auto --activate --hostname=kylin.cn
# bond
#network --hostname=kylin.cn
#network --bootproto=static --device=bond0 --bondslaves=eth0,eth1 --bondopts=mode=balance-rr,miimon=100 --onboot=yes --ip=192.168.35.53 --netmask=255.255.255.0 --gateway=192.168.35.2 --nameserver=192.168.35.2
#network --bootproto=dhcp --device=bond0 --bondslaves=eth0,eth1 --bondopts=mode=balance-rr,miimon=100 --onboot=yes
# 静态IP
#network --device=eth1 --bootproto=static --ip=192.168.35.53 --netmask=255.255.255.0 --gateway=192.168.35.2 --nameserver=192.168.35.2,180.76.76.76



# Use CDROM installation mdedia
#url --url=http://192.168.35.5/iso/ks-v10-sp3-20240626-x86_64/

# Run the Setup Agent on first boot
firstboot --disable
selinux --disable
firewall --disable
reboot
eula --agreed

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

# System timezone
timesource --ntp-pool=ntp1.aliyun.com
timesource --ntp-pool=ntp.ntsc.ac.cn
timezone Asia/Shanghai --utc

# Root password
# python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
rootpw --iscrypted $6$kP.a8Tx6yG7O53JN$cinUa46WrKnRSy1ifhpzwyd4x3DuXE7lFIs5FzduZ6gUvEX/.wJRC0mWDrV15Io2IGxtkeZy0cOwjnRFmZ/pJ0

## 创建普通用户
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


%pre
#       %include http://192.168.35.5/ks/ks-sda-nvme-standard.cfg
       %include http://192.168.35.5/ks/ks-sda-nvme-lvm.cfg
%end


%post --interpreter=/usr/bin/bash --log=/root/ks-post.log

cat > /etc/yum.repos.d/local.repo <<EOF
[local]
name=local
baseurl=http://192.168.35.5/iso/ks-v10-sp3-20240626-x86_64/
gpgcheck=0
#gpgkey=http://192.168.35.5/iso/ks-v10-sp3-20240626-x86_64/RPM-GPG-KEY
#/etc/pki/rpm-ggp/RPM-GPG-KEY-kylin
EOF

%include http://192.168.35.5/ks/sub-ks-v10-sp3-20240626-x86_64-gui.ks
%end
```

#### 6.2 Kylin Desktop

```bash
[Encrypty]
# true开启加密，false 为关闭
encrypty=false
# 加密密钥，如 qwer1234
encryptyPWD=@ByteArray(qwer1234)
# true开启lvm逻辑卷安装（不常用），false 为非逻辑卷安装（常用）
lvm=false


[config]
# 自动登陆，0 为不自动登录
autologin=0
# 自动安装，不用改动
automatic-installation=1

# 全盘安装指定设备，默认为/dev/sda,若需指定安装设备，将/dev/sda替换成指定设备名即可;
# （推荐）若不填磁盘设备名（将下面设备名/dev/sda去掉），系统会默认选择合适磁盘安装。默认磁盘优先级：先最大nvme盘，再最大固态sdX盘，最后最大机械sdX盘
devpath=
# 使用 swapfile 替代swap分区，false 为不使用 swapfile，990/9A0 使用swapfile
enable-swapfile=false
# 出厂备份，0 为不出厂备份
factory-backup=0
# 主机名，仅包含字母、数字、下划线和连接符，长度不超过 64
hostname=kylin-pc
# 语言，默认为中文
language=zh_CN
# 密码，默认为 qwer1234，至少 8 位，至少包含两类字符
password=@ByteArray(qwer1234)
#配置安装完成是否重启。1表示重启，0表示关机
reboot=1
# 时区，默认上海
timezone=Asia/Shanghai
# 用户名、全名，小写字母开头，且仅包含字母、数字、下划线和短横线，长度不超过 32
username=kylin

#配置单独数据盘，若不填表示不配置；若填写具体磁盘设备名，如/dev/sda,表示将磁盘/dev/sda设置为系统的数据盘；
#若填auto，表示自动选择系统数据盘，会默认选择一块磁盘作为系统的数据盘；若系统只有一块盘，默认无单独的数据盘
#默认磁盘优先级：先最大nvme盘，再最大固态sdX盘，最后最大机械sdX盘（在选取系统盘后，剩下的磁盘中选择）
data-device=

#是否走oobe流程,false为不走oobe流程,true为oobe流程,其中审核模式必须走oobe流程
oem-config=false

# 保留用户数据安装(保留的是系统data分区下的数据),true为保留数据安装,false为不保留数据安装
data-unformat=false

# 预安装软件配置清单,软件包名用逗号分隔,前后不要使用引号
#PreinstallApps=wps-office,sc-reader



#以下主要用于自动安装的自定义分区和双系统需求，若无此需求，下面的配置无需改动
[custompartition]

# true为开启全盘安装的自定义分区，false为关闭。
# 自定义分区安装，不支持加密安装、逻辑卷分区安装和保留用户数据安装,需要确认上面选项"encrypty=false""lvm=false""data-unformat=false"
# 其中自动安装需要在grub.cfg中增加automatic参数
disk-custom=false

# true为格式化整块磁盘,false为不格式化整块磁盘,不格式化磁盘主要用于安装第二个系统。
format-disk=true

# 系统偏移安装,可以根据需要，对系统在磁盘的起始位置进行设置。单位为MB，默认为1MB，且最小不能小于1MB
# 安装第二个系统时，需根据第一个系统占用磁盘大小，合理设置偏移安装的起始位置
kos-start=1
# 预留磁盘末尾空间安装，0表示不预留(默认),可以根据需要，对磁盘末尾的空间进行预留。单位为MB，最小不能小于1MB
kos-end=0

#  自定义分区清单。请将所需的分区名称填入下面的双引号内，分区之间请用“;”隔开(双引号和“;”均为英文输入格式)。
#  下面分区的前后顺序，表示新装系统分区的顺序，可以根据需要进行调整。如下所示，efi、boot、root分别为系统的第一、二、三分区。
custom-partitions="efi;boot;root;backup;data;swap;"

# 自定义分区设置格式。custom-XXX中XXX为上面自定义的分区名称。fs=分区格式;mount=挂载点;size=分区大小,单位为MB;
# 请将分区格式、挂载点和大小填入下面的双引号内，之间用“;”隔开(双引号和“;”均为英文输入格式)。
custom-XXX="fs=***;mount=***;size=***;"

# efi分区。默认格式为fat32; 挂载点为/boot/efi; 大小建议在0.5~2g之间，设置单位为MB; default表示默认大小（512MB）
custom-efi="fs=fat32;mount=/boot/efi;size=default;"
# boot分区。默认格式为ext4; 挂载点为/boot; 大小建议在0.5~2g之间，设置单位为MB;default表示默认大小（2048MB）
custom-boot="fs=ext4;mount=/boot;size=default;"
# 系统根分区。默认格式为ext4; 挂载点为/; 大小,建议不小于25g，设置单位为MB;default表示默认大小（根据磁盘空间会自动分配大小）
custom-root="fs=ext4;mount=/;size=default;"
# backup分区。默认格式为ext4; 挂载点为/backup; 大小设置单位为MB;default表示默认大小（根据磁盘空间会自动分配大小）
custom-backup="fs=ext4;mount=/backup;size=default;"
# data分区。默认格式为ext4; 挂载点为/data; 大小设置单位为MB;default表示默认大小（根据磁盘空间会自动分配大小）
custom-data="fs=ext4;mount=/data;size=default;"
# swap分区。默认格式为linux-swap; 挂载点为[swap]; 大小,建议不小于机器内存大小的1.2倍。default表示默认大小（根据磁盘空间会自动分配大小）
custom-swap="fs=linux-swap;mount=[swap];size=default;"





# 自动安装，下面的配置不用改动
bootloader=/dev/sda ATA ST1000DM003-1SB1
partitions="/boot/efi:/dev/sda1;/:/dev/sda7;linux-swap:/dev/sda5;"

[setting]
EnableSwap=false
FileSystem="ext4;ext3;fat32;xfs;btrfs;kylin-data;efi;linux-swap;unused"
FileSystemBoot="ext4;vfat"
PartitionMountedPoints=";/;/boot;/backup;/tmp"

[specialmodel]
computer="mips64el/loongson-3;loongsonarch64/generic"

```

---

### 7. 标准分区 

> ks-sda-nvme-standard.cfg

> 安装系统前检查和确定分区方案，并输出到/tmp/sda-nvme.txt中，等安装系统时执行

```bash
#!/bin/sh
#!/bin/bash
if lsblk | grep nvme0n1;then
        echo 'ignoredisk --only-use=nvme0n1' > /tmp/sda-nvme.txt
        echo 'part /boot --fstype="xfs" --ondisk=nvme0n1 --size=1024' >> /tmp/sda-nvme.txt
        echo 'part / --fstype="xfs" --ondisk=nvme0n1 --size=1 --grow' >> /tmp/sda-nvme.txt
        echo 'part /boot/efi --fstype="efi" --ondisk=nvme0n1 --size=512 --fsoptions="umask=0077,shortname=winnt"' >> /tmp/sda-nvme.txt
        echo 'part swap --fstype="swap" --ondisk=nvme0n1 --size=2048' >> /tmp/sda-nvme.txt
else
        echo 'ignoredisk --only-use=sda' > /tmp/sda-nvme.txt
        echo 'part /boot --fstype="xfs" --ondisk=sda --size=1024' >> /tmp/sda-nvme.txt
        echo 'part / --fstype="xfs" --ondisk=sda --size=1 --grow' >> /tmp/sda-nvme.txt
        echo 'part /boot/efi --fstype="efi" --ondisk=sda --size=512 --fsoptions="umask=0077,shortname=winnt"' >> /tmp/sda-nvme.txt
        echo 'part swap --fstype="swap" --ondisk=sda --size=2048' >> /tmp/sda-nvme.txt
fi
```


## Other

> bond.sh

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