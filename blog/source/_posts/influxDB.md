---
title: InfluxDB
categories: 数据库
tags:
date: 2022-03-06 12:47:36
---

# 1 安装

InfluxDB时序数据库，可存储物联网检测设备数据。

## 1.1 离线安装方式

**1. 下载**

> 1. 官方下载 [链接](https://portal.influxdata.com/downloads 'title(hover)')
> 2. 参考教程 [链接](https://www.codeleading.com/article/62764503797/ 'title(hover)')

**2. 安装**

> 解压后对配置文件 influxdb.conf 进行修改，修改项（红字部分）如下：

```conf
# Change this option to true to disable reporting.
reporting-disabled =true
bind-address = ":8087"
```

**3. 根据配置文件运行**

```ps1
influxd -config influxdb.conf
```

> 验证：在浏览器中打开 http://localhost:8087

---

## 1.2 Docker 安装方式

### 1.2.1 安装

> [参考连接](https://blog.csdn.net/ron03129596/article/details/109408018)

**1. 拉取相关版本镜像**

```shell
docker pull influxdb:1.7.9
```

**2. 使用镜像创建容器**

```shell
docker run -d -p  8083:8083 -p 8086:8086 --name influxdb influxdb:1.7.9
```

**3. 开放防火墙端口[可选]**

```shell
firewall-cmd --zone=public --add-port=8083/tcp --permanent
firewall-cmd --zone=public --add-port=8086/tcp --permanent
firewall-cmd --reload
```

**4. 进入容器内部**

```shell
docker exec -it influxdb /bin/bash
```

---

### 1.2.2 创建用户

**1. 进入`influxdb`命令交互模式**

```bash
influx
```

**2. 创建数据库**

```bash
create database test;
show databases;
use test;
```

**3. 创建用户**

```bash
CREATE USER "hjxstart" WITH PASSWORD '123456' WITH ALL PRIVILEGES;
show users;
```

---

### 1.2.3 配置权限

**1. 安装 vim 命令**

```bash
apt-get update
apt-get install vim
```

**2. 编辑配置配置文件**

```bash
vim /etc/influxdb/influxdb.conf
```

**3. 修改[http]处的 auth-enabled 属性为 true**

```bash
[meta]
  dir = "/var/lib/influxdb/meta"

[data]
  dir = "/var/lib/influxdb/data"
  engine = "tsm1"
  wal-dir = "/var/lib/influxdb/wal"

[http]
  enabled = true
  bind-address = ":8086"
  auth-enabled = true
  log-enabled = true
  write-tracing = false
  pprof-enabled = false
  https-enabled = false
```

**4. 重启容器**

```shell
docker restart influxdb
```

---

### 1.2.4 测试

**1. 进入容器**

```shell
docker exec -it influxdb /bin/bash
```

**2. 进入交互模式**

```shell
influx -username 'hjxstart' -password '123456'
```

**3. 使用数据库**

```shell
use test;
```

---

### 1.2.5 整合 Grafana

**1. 安装 Grafana**

```shell
docker run -d -p 3000:3000 --name=grafana grafana/grafana
```

**2. 开放防火墙端口**

```shell
firewall-cmd --zone=public --add-port=3000/tcp --permanent
firewall-cmd --reload
```

**3. 访问**

```shell
# 用户名密码默认：admin
http://ip:8086
```
