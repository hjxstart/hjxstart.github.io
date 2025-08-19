---
title: HomeLab
date: 2025-08-12 15:09:29
categories:
tags:
---

## 环境准备

```bash
# 修改主机名
hostnamectl set-hostname homelab_01
# Centos7 更换腾讯源
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.cloud.tencent.com/repo/centos7_base.repo
yum install -y net-tools vim wget gcc
yum -y install openssl openssl-devel patch
systemctl start sshd
# 安装1Panel. http://目标服务器 IP 地址:目标端口/安全入口
bash -c "$(curl -sSL https://resource.fit2cloud.com/1panel/package/v2/quick_start.sh)"
```







