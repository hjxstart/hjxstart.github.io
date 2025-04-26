---
title: OpenWrt
date: 2023-11-18 17:03:16
categories: 网络
tags:
---

1. 打开并登录 https://openwrt.ai;
2. 构建 OpenwWrt 的固件. 勾选 luci-app-ttyd, luci-app-ipsec-server
   默认主题: Argon;
   后台地址: 192.168.44.1/24;
   后台密码: H;
   Web 服务器: Nginx
   EFI 镜像: 勾选
   主机名: OpenWrt
   根目录: 1004
   自定义签名: HuangFamily
   去除作者外链: 勾选
   文件系统: SquashFS
   WMDK 镜像(ESXI 专用): 勾选
3. 下载镜像: ESXI 专用, 解压后使用.
4. 打开并登录 ESXI 8.0。https://192.168.44.3
5. 新建虚拟机。 名称:OpenWrt;
   兼容性: ESXI 8.0 虚拟机;
   客户机操作系统系列: Linux
   操作机操作系统版本: 其他 Linux 64 位
6. 自定义虚拟机的配置: CPU:2; 内存: 1G;
   删除硬盘、USB 控制器 1、CD/DVD 驱动器 1
   添加 3 个 PCI 设备;
   添加硬盘 > 现有磁盘 > 上传 VMDK 文件。
   保持并打开虚拟机
7. 修改网络 IP 地址： vi /etc/config/network
   service network restart
8. 登录https://192.168.44.1
9. 添加腾讯云的 DDNS，luci-app-tencentddns_0.1.0-1_all.ipk
10. 配置腾讯云 DDNS: 密钥 ID: 4; 密钥 Token: 9;
11. OpenWrt > 系统 > 高级设置 > NGINX > 将 80 端口修改为 14480 和 443 端口修改为 14443
12. 创建 /etc/nginx/conf.d/crt 目录，并上传正式

13. Nginx 设置，并打开防火墙的入站数据

```conf
server {
        listen 443 ssl;
        server_name huangfamily.cn;
        ssl_certificate /etc/nginx/conf.d/crt/huangfamily.cn_bundle.crt;
        ssl_certificate_key /etc/nginx/conf.d/crt/huangfamily.cn.key;
        ssl_session_timeout 5m;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        ssl_prefer_server_ciphers on;
        location / {
            proxy_pass https://192.168.44.1:14443;
            proxy_redirect off;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $http_host;
            proxy_set_header X-NginX-Proxy true;

			proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
}
server {
    listen 80;
    server_name huangfamily.cn;
    return 301 https://$host$request_uri;
}
```
