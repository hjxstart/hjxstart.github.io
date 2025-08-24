---
title: 1Panel
date: 2023-04-26 14:09:16
categories: 运维
tags:
---


# 1Panel

## 概述

## 网站

```bash

```

---

## Frp

### Frpc

```bash
# proxies
serverAddr = "154.222.24.218"
serverPort = 7000
auth.method = "token"
auth.token = "FRPS"

[[proxies]]
name = "7735h-rdp"
type = "xtcp"
secretKey = ""
localIP = "127.0.0.1"
localPort = 3389

# visitors
serverAddr = "154.222.24.218"
serverPort = 7000
auth.method = "token"
auth.token = "FRPS"

[[visitors]]
name = "zdy_"
type = "xtcp"
serverName = "7735h-rdp"
secretKey = ""
bindAddr = "0.0.0.0"
bindPort = 6000
keepTunnelOpen = true
```

---

## Cloudreve

```bash
# 七牛存储策略


```

---

## maxkb

```bash


```

---

## jumpserver

```bash


```

---

## zyplayer-doc

```bash
# 配置系统功能配置时，onlyoffice和drawio需要配置https域名
```

> docker-compose.yml

```yml
version: '3'

services:
  zyplayer:
    container_name: zyplayer-doc
    image: registry.cn-beijing.aliyuncs.com/zyplayer/zyplayer-doc:latest
    ports:
      - 8083:8083
    environment:
      - DATASOURCE_HOST_PORT=10.0.142.2:3306
      - DATASOURCE_DATABASE=zyplayer_doc
      - DATASOURCE_USER=zyplayer
      - DATASOURCE_PASSWORD=    # 指定数据库密码
    volumes:
      - ./files:/zyplayer/files
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8083"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 10s
```

---

## surveyking

```yml
services:
    surveyking:
        image: surveyking/surveyking:latest
        container_name: surveyking
        volumes:
            - ./files:/app/files  # 文件目录，存储上传的文件，冒号左侧改成自己的，下同
            - ./logs:/app/logs    # 运行日志
        ports:
            - 41991:1991 # 冒号左侧可改
        environment:
            - PROFILE=mysql                       # 使用外部 MySQL 数据库
            - MYSQL_USER=surveyking               # 数据库用户名
            - MYSQL_PASS=               # 数据库密码
            - DB_URL=jdbc:mysql://10.0.142.2:3306/surveyking?rewriteBatchedStatements=true&useUnicode=true&characterEncoding=UTF-8
        restart: always
```
