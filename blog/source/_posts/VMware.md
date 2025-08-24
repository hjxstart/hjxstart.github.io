---
title: VMware
categories: 工具
tags:
date: 2021-09-09 15:38:41
---

# VMware挂载虚拟硬盘

Linux磁盘分区、格式化、目录挂载[参考链接](https://www.cnblogs.com/jyzhao/p/4778657.html)

```shell
# 根据帮助提醒分区，这里是把/dev/xvdb分成一个区
fdisk /dev/sdb
# 依次输入 n 1 p w

# 磁盘格式化，分区为ext4的文件系统格式
mkfs.ext4 /dev/sdb1

# 手工挂载
mkdir /nfs_dir
mount /dev/xvdb1 /nfs_dir

# 开机自动挂载
vi /etc/fstab
```

