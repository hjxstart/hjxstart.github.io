---
title: Swarm
tags:
  - Docker
categories: 运维
date: 2021-08-28 20:46:10
---

# 常用命令

```shell
# 生成 manager(manager)
docker swarm init --advertise-addr 192.168.18.241

# 查看主机
hostnamectl status

# 设置主机名称
hostnamectl set-hostname swarmmanager01

# 查看网络
 docker network ls

# 加入节点(node)
docker swarm join --token SWMTKN-1-5018bftvba3fa2c0eake86ks6kcr8kq9dup6kd0xxtwdz1z8h6-34u6mlskhlkkk8hid7ncklx77 192.168.18.241:2377

# 查看所有节点
docker node ls

# 查看服务列表(manager)
 docker service ls

# 查看test1服务(manager)
docker service ps test1

# 创建服务(manager)
docker service create --name test1 alpine ping www.baidu.com

# 复制服务副本
docker service scale nginx=3

# 创建服务和更新服务(manage)
docker service create --name nginx nginx
docker service update --publish-add 8080:80 nginx
docker service inspect nginx

# 删除服务
docker service rm nginx
```

