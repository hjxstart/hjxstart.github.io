---
title: Harbor
categories: 运维
tags: K8s
date: 2021-09-08 18:04:32
---

# 1. 概述

harbor 是一个可以部署在本地的Docker仓库

# 2. 部署步骤

1. 下载harbor的tar包[github链接](https://github.com/goharbor/harbor/releases)
2. 上传到Linux系统
3. 解压 `tar -zxvf harbor-xxx.tar`
4. 移动harbor `mv harbor /usr/local`
5. 生成openssl证书: `openssl genrsa -des3 -out server.key 2048`(密码123456)
6. 创建证书请求：`openssl req -new -key server.key -out server.csr`(密码:123456, 国家：CN, 省会:GD, 市:ZJ, 机构:XJ, 单位：XJ，域名 hub.xj.com, 邮箱: hjxstart@126.com, 密码：123456,公司名字:XJ).中途输入错误可以`Ctr+C`退出.
7. 复制文件：cp server.key server.key.org
8. 取消密码认证：`openssl rsa -in server.key.org -out server.key`(密码123456)
9. 创建证书（类型:x509,有效期：365天）：`openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt`
10. 创建相应文件:`mkdir -p /data/cert`
11. 移动证书相关文件:`mv server.* /data/cert`
12. 修改`barbor配置文件`的`hostname(hub.xj.com) 和 https(certificate: server.crt; private_key: server.key)`
13. 运行prepare文件:`./prepare`
14. 安装harbor: `./install.sh`
15. 修改镜像仓库地址: `vi /etc/docker/daemon.json` `hub.xj.com`
16. 重启docker: `systemctl restart docker`
17. harbor的使用
    
```bash
docker tag nginx:latest hub.xj.com/harborProject/nginx:v1
```

```bash
docker push 
```

## Harbor部署

### 1. 环境说明

1. 系统版本Centos7.9最小安装
2. 使用二进制安装k8s[链接](https://www.toutiao.com/a6935437095985054219/?log_from=7099e5155a92b_1631092889404)

### 2. 安装步骤

1. 创建目录及下载harbor离线包

```
# 创建并进入相应目录
mkdir /data && cd /data
# 下载离线包，也可以直接通过连接下载
wget https://github.com/goharbor/harbor/releases/download/v2.2.0/harbor-offline-installer-v2.2.0.tgz
# 解压并删除离线包
tar xf harbor-offline-installer-v2.2.0.tgz && rm harbor-offline-installer-v2.2.0.tgz
```

2. 修改harbro配置

```
# 进入harbor目录
cd harbor
# 负责harbor配置文件
cp harbor.yml.tmpl harbor.yml
# 修改harbor配置
vi harbor.yml
    5 hostname: harbor.xj.com
    17   certificate: /data/harbor/ssl/tls.cert
    18   private_key: /data/harbor/ssl/tls.key
    34 harbor_admin_password: boge666
```

3. 创建harbor访问域名证书

```
mkdir /data/harbor/ssl && cd /data/harbor/ssl
openssl genrsa -out tls.key 2048
openssl req -new -x509 -key tls.key -out tls.cert -days 360 -subj /CN=*.xj.com
```

4. 准备好单机编排工具`docker-compose`

```
> 从二进制安装k8s项目的bin目录拷贝过来
scp /etc/kubeasz/bin/docker-compose 192.168.18.200:/usr/bin/

> 也可以在docker官方进行下载
https://docs.docker.com/compose/install/
```

5. 开始安装

```
# 回到harbor目录
cd /data/harbor
# 安装harbor
./install.sh
# 安装成功后可以配置hosts文件进行域名访问了
```

6. 推送镜像到harbor

```
# 添加hosts文件
echo '192.168.18.200 harbor.xj.com' >> /etc/hosts
# 登录
docker login harbor.xj.com
# 打标签
docker tag nginx:latest  harbor.xj.com/library/nginx:latest
# 推送镜像到harbor
docker push harbor.boge.com/library/nginx:1.18.0-alpine
# 登出
docker logout harbor.xj.com
# 查看登录信息，不退出会存在隐患
cat ~/.docker/config.json
```

7. 在其他节点上面拉取harbor镜像

```
> 在集群每个 node 节点进行如下配置
> ssh to 192.168.18.199(centos7)

mkdir -p /etc/docker/certs.d/harbor.xj.com
scp 192.168.18.200:/data/harbor/ssl/tls.cert /etc/docker/certs.d/harbor.xj.com/ca.crt
```

