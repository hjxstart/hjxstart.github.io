---
title: Docker
categories: 运维
tags: Docker
date: 2021-07-22 14:53:59
---

# 第一章 基础篇
## 1.1 Docker安装

[Docker官网安装教程](https://docs.docker.com/engine/install/centos/)

1. 卸载旧版本

```shell
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

2. 安装需要的安装包

```shell
sudo yum install -y yum-utils
```

3. 设置设置yum源

```shell
sudo yum-config-manager \
	--add-repo \ 
	https://download.docker.com/linux/centos/docker-ce.repo
```

4. 更新 yum 软件包索引

```shell
sudo yum makecache fast
```

5. 安装docker相关的内容

```shell
sudo yum install docker-ce docker-ce-cli containerd.io
```

6. 启动docker

```shell
sudo systemctl start docker
docker version
```

7. 运行 HelloWorld

```shell
sudo docker run hello-world
```

8. 卸载 Docker

```shell
sudo yum remove docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

9. 阿里云镜像加速 [链接](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)

```shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://xsxk9861.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## 1.3 HelloWorld运行过程

## 1.4 常用命令

---

# 第二章 进阶篇

## 2.1 Docker 镜像

## 2.2 容器数据卷

## 2.3 DockerFile

## 2.4 Docker 网络原理

### 2.4.1 原理

1. 启动一个docker容器，docker就会给docker容器分配一个ip。
2. 安装docker就会有一张docker0网卡，桥接模式，使用evth-pair技术！
3. evth-pair就是一对的虚拟设备接口，他们都是成对出现的，一端连着协议，一端彼此相连
4. 结论：容器和容器之间是可以互相ping通
5. Docker中的所有的网络接口都是虚拟的。虚拟的转发效率高！（内网传递文件）
6. 只要容器删除，对应网桥一对就没有了。
7. 实战：容器之间ip地址通信

```shell
# 安装tomcat
docker run -d -P --name tomcat01 tomcat
# 查看容器ip地址
docker exec -it tomcat01 ip addr
# 在启动一个容器测试，发现又多了一对网卡，例如：14: eth0@if15
```

---

### 2.4.2 link(不推荐使用)

1. 实战：容器之间容器通过name通信

```shell
# 实现: docker exec -it tomcat02 ping tomcat03
# 1. 使用 --link 链接两个容器
docker run -d -P --name tomcat03 --link tomcat02 tomcat
# 2. 两个容器 ping
docker exec -it tomcat03 ping tomcat02
```

2. inspect

```shell
# 查看网卡
docker network ls
# 查看具体网卡信息
docker network inspect a2a9b68069bc
```

---

### 2.4.3 自定义网络

1. 网络模式

```shell
# bridge: 桥接 docker （默认，自定义网络也是使用桥接模式）
# none: 不配置网络
# host: 和宿主机共享网络
# container: 容器网络连通！（用的少，局限性大）
```

2. 案例

```shell
# 默认的情况,两者等价
docker run -d -P --name tomcat-1 tomcat
docker run -d -P --name tomcat01  --net bridge tomcat

# docker0特点，默认是docker0网络：域名不能访问, --link 可以打通链接

# 1. 自定义网络： 网络，网关，名称
docker network create --driver bridge --subnet 192.168.0.0/16 --gateway 192.168.0.1 mynet

# 查看网络
docker network inspect mynet

# 2. 使用自定义网络mynet
docker run -d -P --name tomcat-net-01 --net mynet tomcat
docker run -d -P --name tomcat-net-02 --net mynet tomcat

# 3. 查看网络组成
 docker network inspect mynet

# 4. 同一个网络内，可以使用容器名进行互ping
docker exec -it tomcat-net-01 ping tomcat-net-02

# 5. 实现不同网络间的通信 容器 ping 另一个网络.（原理：一个容器2个IP地址）
# 自定义网络 mynet 链接 tomcat01 容器
docker network connect mynet tomcat01

# 6. 结论：
# a. 我们自定义的网络docker都已经帮我们维护好了对应的关系，推荐使用自定义网络。
# b. 可以通过划分不同的网络，实现集群间的通信，也更安全
```

### 2.4.4 redis 集群

---

# 第三章 实战篇

## 3.1 IDEA 整合 Docker

## 3.2 Docker Compose

## 3.3 Docker Swarm

## 3.4 DI\CD jenkins

---

# 第四章 番外篇

---

