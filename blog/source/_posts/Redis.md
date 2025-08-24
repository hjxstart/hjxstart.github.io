---
title: Redis
categories: 数据库
tags:
date: 2021-10-06 17:19:30
---

## Docker安装Reids

### redis安装

> [参考链接](https://www.jianshu.com/p/363e8ac2d9b3)

### 创建挂载的目录

```shell
mkdir -p /home/docker-data/redis/conf
mkdir -p /home/docker-data/redis/data
```

### 新增Redis配置文件

> 将bind 127.0.0.1注释掉，保证可以从远程访问到该Redis，不单单是从本地

> appendonly：开启数据持久化到磁盘

> requirepass：设置访问密码为123456

```shell
vim /home/docker-data/redis/conf/redis.conf
```

```bash
#bind 127.0.0.1
protected-mode no
appendonly yes
requirepass 123456
```

### 创建redis容器并启动

> redis redis-server 实现让docker容器运行时使用本地配置的Redis配置文件的功能了

```shell
docker run \
--name redis \
-p 6379:6379 \
-v /home/docker-data/redis/data:/data \
-v /home/docker-data/redis/conf/redis.conf:/etc/redis/redis.conf \
 -d redis redis-server /etc/redis/redis.conf
```

### 进入容器内部进行测试

1. 进入容器

```shell
docker exec -it redis redis-cli
```

2. 设置密码

```bash
auth 123456
```

3. 测试

```shell
set a 1
get a
```

## K8s安装Reids集群

### 1. 设置redis集群网卡及查看

```shell
docker network create redis --subnet 172.38.0.0/16
docker network ls
docker network inspect redis

```

---

### 2. 创建redis节点及设置

```shell
for port in $(seq 1 6);
do
mkdir -p /mydata/redis/node-${port}/conf
touch /mydata/redis/node-${port}/conf/redis.conf
cat << EOF >/mydata/redis/node-${port}/conf/redis.conf
port 6379
bind 0.0.0.0
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip 172.38.0.1${port}
cluster-announce-port 6379
cluster-announce-bus-port 16379
appendonly yes
EOF
done 

```

---

### 3. 拉取redis镜像并启动redis节点

1. 节点1

```shell
docker run -p 6371:6379 -p 16371:16379 --name redis-1 \
 -v /mydata/redis/node-1/data:/data \
 -v /mydata/redis/node-1/conf/redis.conf:/etc/redis/redis.conf \
 -d --net redis --ip 172.38.0.11 redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf
```

2 . 节点2

```shell
docker run -p 6372:6379 -p 16372:16379 --name redis-2 \
 -v /mydata/redis/node-2/data:/data \
 -v /mydata/redis/node-2/conf/redis.conf:/etc/redis/redis.conf \
 -d --net redis --ip 172.38.0.12 redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf
```

3 . 节点3

```shell
docker run -p 6373:6379 -p 16373:16379 --name redis-3 \
 -v /mydata/redis/node-3/data:/data \
 -v /mydata/redis/node-3/conf/redis.conf:/etc/redis/redis.conf \
 -d --net redis --ip 172.38.0.13 redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf
```

4 . 节点4

```shell
docker run -p 6374:6379 -p 16374:16379 --name redis-4 \
 -v /mydata/redis/node-4data:/data \
 -v /mydata/redis/node-4/conf/redis.conf:/etc/redis/redis.conf \
 -d --net redis --ip 172.38.0.14 redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf
```

5 . 节点5

```shell
docker run -p 6375:6379 -p 16375:16379 --name redis-5 \
 -v /mydata/redis/node-5/data:/data \
 -v /mydata/redis/node-5/conf/redis.conf:/etc/redis/redis.conf \
 -d --net redis --ip 172.38.0.15 redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf
```

6 . 节点6

```shell
docker run -p 6376:6379 -p 16376:16379 --name redis-6 \
 -v /mydata/redis/node-6/data:/data \
 -v /mydata/redis/node-6/conf/redis.conf:/etc/redis/redis.conf \
 -d --net redis --ip 172.38.0.16 redis:5.0.9-alpine3.11 redis-server /etc/redis/redis.conf
```

---

### 4. 以交互模式进入redis节点内

```shell
docker exec -it redis-1 /bin/sh
```

---

### 5. 创建redis集群


```shell
redis-cli --cluster create 172.38.0.11:6379 172.38.0.12:6379 \
172.38.0.13:6379 172.38.0.14:6379 172.38.0.15:6379 \
172.38.0.16:6379 --cluster-replicas 1
```

### [参考链接](https://blog.csdn.net/weixin_41896265/article/details/108245264)


# 数据结构

## string

> 可变对象，在1M大小以下空间扩展速度为1倍，1M以上速度为每次1M，最大512M，超过会报错。

```redis

```

## list

> 可以保存2^32-1个item
> 列表的插入数据O(1),索引定位O(n)
> 主要用于队列。rpush lpop
> 用于栈：rpush rpop

```redis
lpush key value1 vlue2
rpush key value1 vlue2
lpop key 
rpop key
linsert key before v3 v2
linsert key after v1 v2
lrange key start end [返回范围内的元素]
iset key index value [替换值，慎用]
lindex key index [返回索引值，慎用]
```

## hash

## set

## zset

