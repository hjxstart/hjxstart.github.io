---
title: Nginx
categories: 运维
top: 7
tags:
  - Nginx
date: 2021-08-11 23:28:55
---

# 1. Nginx作用

```java
1. Http代理，反向代理：作为web服务器最常用的功能之一，尤其是反向代理。
2. Nginx提供的负载均衡策略有2种：内置策略和扩展策略。内置策略为轮询，加权轮询，Ip hash。扩展策略，就天马行空，只有你想不到的没有他做不到的。iphash对客户端请求的ip进行hash操作，然后根据hash结果将同一个客户端ip的请求分发给同一台服务器进行处理，可以解决session不共享的问题。
3. 动静分离，在我们的软件开发中，有些请求是需要后台处理的，有些请求是不需要经过后台处理的（如：css、html、jpg、js等等文件），这些不需要经过后台处理的文件称为静态文件。让动态网站里的动态网页根据一定规则把不变的资源和经常变的资源区分开来，动静资源做好了拆分以后，我们就可以根据静态资源的特点将其做缓存操作。提高资源响应的速度。
```

---

# 2. linux下安装Nginx

1. 安装gcc

```shell
yum install gcc-c++
```

2. PCRE pcre-devel 安装

```shell
yum install -y pcre pcre-devel
```

3. zlib 安装

```shell
yum install -y zlib zlib-devel
```

4. OpenSSL 安装

```shell
yum install -y openssl openssl-devel
```

5. 下载安装包[链接](https://nginx.org/en/download.html)
6. 解压

```shell
tar -zxvf nginx-1.18.0.tar.gz
cd nginx-1.18.0
```

7. 配置

```shell
./configure
make
make install
```

8. 查找安装路径

```shell
whereis nginx
```

9. Nginx常用命令

```shell
cd /usr/local/nginx/sbin/
./nginx  启动
./nginx -s stop  停止
./nginx -s quit  安全退出
./nginx -s reload  重新加载配置文件
ps aux|grep nginx  查看nginx进程
```

10. Linux其他相关命令

```shell
# 开启
service firewalld start
# 重启
service firewalld restart
# 关闭
service firewalld stop
# 查看防火墙规则
firewall-cmd --list-all
# 查询端口是否开放
firewall-cmd --query-port=8080/tcp
# 开放80端口
firewall-cmd --permanent --add-port=80/tcp
# 移除端口
firewall-cmd --permanent --remove-port=8080/tcp
#重启防火墙(修改配置后要重启防火墙)
firewall-cmd --reload
# 参数解释
1. firwall-cmd：是Linux提供的操作firewall的一个工具；
2. --permanent：表示设置为持久；
3. --add-port：标识添加的端口；
```

11. 负载均衡联系

```shell
upstream lb{
    server 127.0.0.1:8080 weight=1;
    server 127.0.0.1:8081 weight=1;
}
location / {
    proxy_pass http://lb;
}
```

