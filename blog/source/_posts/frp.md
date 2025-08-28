---
title: FRP
date: 2022-08-24 12:47:11
categories:
tags:
---

# 一、概述

> 1. 环境：一个域名、一台腾讯云的 centos7.6 服务器和一台内网 centos7.6 服务器
> 2. 场景：实现可以域名通过公网的 IP 地址访问内网的访问

## xxxxxxxxxx ​​bash

1. 域名申请

```shell
本次使用的域名是 huangfamily.cn
```

2. SSL 证书申请

```shell
腾讯云[申请链接](https://console.cloud.tencent.com/ssl)
```

3. DNS 解析

```shell
腾讯云[DNSPod](https://console.cloud.tencent.com/cns/detail/huangfamily.cn/records/0)
```

## 三、公网服务器

### 3.1 frps 配置

1. 启动命令

```shell
nohup ./frps -c frps.ini &
```

2. frps.ini 配置文件

```shell
[common]
# frp监听的端口，用作服务端和客户端通信
bind_port = 4000
token = XXX

# 服务端通过此端口接监听和接收公网用户的https请求
vhost_https_port = 4499
# 服务端通过此端口接监听和接收公网用户的http请求
vhost_http_port = 4498

# frp提供了一个控制台，可以通过这个端口访问到控制台。可查看frp当前有多少代理连接以及对应的状态
dashboard_port = 4500
dashboard_user = username
dashboard_pwd = password

# 服务端的subdomain_host需要和客户端配置文件中的subdomain、local_port配合使用，
# 可通过{subdomain}.{subdomain_host} 的域名格式来访问自己本地的 web 服务。
# 假如服务端的subdomain_host为dev.msh.com，客户端某个配置组中的
# subdomain为a,local_port为8585，
# 则：
# 访问 a.dev.msh.com ，等同于访问本地的localhost:8585

subdomain_host = huangfamily.cn
```

### 3.2 nginx 配置

1. frp.conf

```shell
server {
    listen 80;
    server_name huangfamily.cn home.huangfamily.cn dev.huangfamily.cn staging.huangfamily.cn git.huangfamily.cn;

    location / {
        # 7071端口即为frp监听的http端口
        proxy_pass http://127.0.0.1:4498;
        proxy_set_header Host $host:80;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_connect_timeout 7d;
        proxy_send_timeout 7d;
        proxy_read_timeout 7d;

        }
    # 防止爬虫抓取
    if ($http_user_agent ~* "360Spider|JikeSpider|Spider|spider|bot|Bot|2345Explorer|curl|wget|webZIP|qihoobot|Baiduspider|Googlebot|Googlebot-Mobile|Googlebot-Image|Mediapartners-Google|Adsbot-Google|Feedfetcher-Google|Yahoo! Slurp|Yahoo! Slurp China|YoudaoBot|Sosospider|Sogou spider|Sogou web spider|MSNBot|ia_archiver|Tomato Bot|NSPlayer|bingbot")
        {
            return 403;
        }
}
```

2. ssl.conf

```shell
server {
        #SSL 访问端口号为 443
        listen 443 ssl;
        #填写绑定证书的域名
        server_name huangfamily.cn;
        #证书文件名称
        ssl_certificate huangfamily.cn_bundle.crt;
        #私钥文件名称
        ssl_certificate_key huangfamily.cn.key;
        ssl_session_timeout 5m;
        #请按照以下协议配置
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        #请按照以下套件配置，配置加密套件，写法遵循 openssl 标准。
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        ssl_prefer_server_ciphers on;
        location / {
           #网站主页路径。此路径仅供参考，具体请您按照实际目录操作。
           #例如，您的网站运行目录在/etc/www下，则填写/etc/www。
           proxy_pass http://huangfamily.cn;
        }
}
#server {
#    listen 80;
#    #填写绑定证书的域名
#    server_name huangfamily.cn;
#    #把http的域名请求转成https
#    return 301 https://$host$request_uri;
#}
```

## 四、frp 使用

1. 内网客户端配置

```shell
[common]
# 部署frp服务端的公网服务器的ip
server_addr = 106.55.104.24
# 和服务端的bind_port保持一致
server_port = 4000
token = XXX

[huangfamily]
type = https
local_port = 80
custom_domains = huangfamily.com
plugin = https2http
plugin_local_addr = 127.0.0.1:80

# HTTPS 证书相关的配置
plugin_crt_path = ./huangfamily.cn_bundle.crt
plugin_key_path = ./huangfamily.cn.key
plugin_host_header_rewrite = 127.0.0.1
plugin_header_X-From-Where = frp

[http]
type = http
local_port = 80
custom_domains = huangfamily.cn

[http-home]
type = http
# local_port代表你想要暴露给外网的本地web服务端口
local_port = 3000
# subdomain 在全局范围内要确保唯一，每个代理服务的subdomain不能重名，否则会影响正常使用。
# 客户端的subdomain需和服务端的subdomain_host配合使用
subdomain = home

[http-staging]
type = http
local_port = 3001
subdomain = staging


[http-dev]
type = http
local_port = 3002
subdomain = dev

[http-gitee]
type = http
local_port = 4001
subdomain = git
```

2. 配置开机自启动

> vim /lib/systemd/system/frps.service

```shell
[Unit]
Description=frps service
After=network.target syslog.target
Wants=network.target

[Service]
Type=simple
#启动服务的命令（此处写你的frps的实际安装目录）
ExecStart=/root/frp38/frps -c /root/frp38/frps.ini

[Install]
WantedBy=multi-user.target
```
