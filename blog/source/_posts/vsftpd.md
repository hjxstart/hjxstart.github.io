---
title: vsftpd
categories: 运维
tags:
  - ftp
date: 2021-12-16 08:49:01
---

# 在Ubuntu1804搭建vsftpd服务

> 1. 环境：在 Ubuntu1804 的 Docker 环境下。
> 2. 要求：要在 Docker 容器中使用 Ftp 服务推送数据到 Windows10 的目录下。
> 3. 方案：在 Ubuntu1804 搭建基于 Vsftpd，设置 Ftp 的目录在虚拟机和物理机的共享目录下。

---

## 1. 更新下载源

1. 编辑下载源

```shell
# 备份源文件
sudo cp -rfv /etc/apt/sources.list /etc/apt/sources.list.back
# 编辑source.list文件
sudo vi /etc/apt/sources.list
```

2. 修改下载源

> 全选快捷键：shift+v 选中一行，shift+g 调到结尾实现全选
> 删除所选择的内容：dd
> 按 i 进入插入模式，复制如下内容：

```shell
deb http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse
```

## 2. 安装 vsftpd

```bash
sudo apt update && sudo apt install vsftpd
```

> 安装之后，检查 vsftpd 的状态

```bash
sudo service vsftpd status
```

## 3. 配置防火墙

```bash
sudo ufw allow OpenSSH
```

让我们为 FTP 打开端口 20 和 21，为被动 FTP 打开端口 40000-50000。我们还将为 TLS 打开端口 990，稍后将设置这个端口。

```bash
sudo ufw allow 20/tcp
```

```bash
sudo ufw allow 21/tcp
```

```bash
sudo ufw allow 40000:50000/tcp
```

```bash
sudo ufw allow 990/tcp
```

现在，如果还没有启用防火墙，就启用它。如果有关于破坏 SSH 连接的警告，请按 y 和 ENTER。

```bash
sudo ufw enable
```

要检查防火墙的状态，请运行:

```bash
sudo ufw status
```

## 4. 创建 FTP 用户

```bash
sudo adduser ftpuser
```

在 nano 中打开 SSH 配置。

```bash
sudo nano /etc/ssh/sshd_config
```

将以下代码添加到文件底部，用要拒绝 SSH 和 SFTP 访问的用户替换 ftpuser。

```none
DenyUsers ftpuser
```

要保存文件并退出，请按 CTRL + x，按 y，然后按 ENTER。
重新启动 SSH 服务。

```bash
sudo service sshd restart
```

## 5. 上传到主文件夹

```bash
# 自定义ftp上传目录
sudo mkdir /vagrant/ftpdata
```

将此目录的所有权分配给新的 FTP 用户

```bash
# 自定义ftp上传目录
sudo chown ftpuser:ftpuser /vagrant/ftpdata
```

## 6. 配置 vsftpd

在编辑配置文件之前，创建一个备份。

```bash
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
```

现在，在 nano 编辑器中打开配置文件。

```bash
sudo nano /etc/vsftpd.conf
```

你需要去下面的文件，并确保设置匹配那些下面。注意: 你可以使用 CTRL + w 来搜索 nano

```none
write_enable=YES
chroot_local_user=YES
local_umask=022
```

将以下内容粘贴到文件底部。(粘贴 nano，按下鼠标右键)

```bash
force_dot_files=YES
pasv_min_port=40000
pasv_max_port=50000
# 自定义ftp上传目录
local_root=/vagrant/ftpdata
allow_writeable_chroot=YES
```

要保存文件并退出，请按 CTRL + x，按 y，然后按 ENTER。

重新启动 vsftpd。

```bash
sudo systemctl restart vsftpd
```

## 7. 测试 FTP

查看日志

```bash
sudo tail /var/log/vsftpd.log -n 200
```
