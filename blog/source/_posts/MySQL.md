---
title: MySQL
date: 2022-03-19 21:51:35
categories: 数据库
tags: MySQL
---

# 安装

## Docker 安装 MySQL5.7


### 1.安装命令

```shell
docker run -d -p 3306:3306 --privileged=true \
-v /home/hjx/docker/mysql/conf/my.cnf:/etc/my.cnf \
-v /home/hjx/docker/mysql/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=hadoop \
--name mysql mysql:5.7 \
--character-set-server=utf8mb4 \
--collation-server=utf8mb4_general_ci
```

> 创建用户

```shell
# 先进入容器
docker exec -it mysql bash

# 执行MySQL命令, 输入root密码, 连接MySQL
mysql -uroot -p

# 输入密码后, 执行下面命令创建新用户 (用户名: test , 密码: test123)
GRANT ALL PRIVILEGES ON *.* TO 'test'@'%' IDENTIFIED BY 'test123' WITH GRANT OPTION;
```


### 1. Docker 安装 MySQL8

1. 拉起镜像
```shell
docker pull mysql:8.0.12
```

2. 创建数据目录和配置文件

```shell
mkdir -p /usr/mysql/conf /usr/mysql/data
chmod -R 755 /usr/mysql/
```

3. 创建配置文件

> vim /usr/mysql/conf/my.cnf

```bash
[client]
#socket = /usr/mysql/mysqld.sock
default-character-set = utf8mb4

[mysqld]
#pid-file        = /var/run/mysqld/mysqld.pid
#socket          = /var/run/mysqld/mysqld.sock
#datadir         = /var/lib/mysql
#socket = /usr/mysql/mysqld.sock
#pid-file = /usr/mysql/mysqld.pid
datadir = /usr/mysql/data
character_set_server = utf8mb4
collation_server = utf8mb4_bin
secure-file-priv= NULL
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Custom config should go here
```

4. 创建容器

```shell
docker run --restart=unless-stopped -d --name mysql8 \
-v /usr/mysql/conf/my.cnf:/etc/mysql/my.cnf \
-v /usr/mysql/data:/var/lib/mysql \
-p 3306:3306 -e MYSQL_ROOT_PASSWORD=hadoop mysql
```

5. 修改mysql密码以及可访问主机

```shell
use mysql
# 修改访问主机以及密码等，设置为所有主机可访问
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '新密码';
# 刷新
flush privileges;
```

# 高效学习 MySQL 干活知识

## MySQL 快速上手

### 1.MySQL 基本命令

1. 查看库

```bash
show databases;
```

2. 创建库

```bash
create database db_name
```

3. 删除库

```bash
drop database db_name;
```

4. 选择库

```bash
use db_name;
```

5. 查看表

```bash
show tables;
```

6. 查看创建库创建语句

```bash
show create database db_name;
```

7. 查看选中的数据库

```bash
select database();
```

8. 修改数据库字符集

```bash
alter database db_name default charset=utf8;
```

## 2.数据库概念和使用

### 数据库和主键的概念

## 3.数据操作

## 3.用户管理

## 4.数据库表操作

## 5.MySQL 函数

## 6.MySQL 子查询

## 7.MySQL 连表查询

## 8.MySQL 触发器

## 9.MySQL 数据库引擎

## 10.MySQL 事务

## 11.MySQL 分区分表

## 12.MySQL 视图

## 13.MySQL 数据库设计及SQL优化

## 14.MySQL 数据备份还原



