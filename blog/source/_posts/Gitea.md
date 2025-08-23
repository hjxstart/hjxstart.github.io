---
title: Gitea
categories: 运维
tags:
  - Git
  - CICD
date: 2021-12-19 21:53:48
---

# 1. 安装

> 官方参考[链接](https://docs.gitea.io/zh-cn/install-with-docker/#ssh-%E5%AE%B9%E5%99%A8%E7%9B%B4%E9%80%9A)

## 1.1 前期配置

1. 创建 git 用户并且指定 uid 和 gid

```bash
gruopadd git -g 1000
useradd git -u 1000 -g 1000
```

2. 将 git 用户百年规定 git 组的某个文件

```shell
chown -R git:git /app/gitea/gitea
```

3. 创建/app/gitea/gitea 文件

```shell
ssh -p 4002 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
```

---

## 1.2 安装配置

```yaml
version: "3"

networks:
  gitea:
    external: false

services:
  server:
    image: gitea/gitea:1.15.7
    container_name: gitea
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - DB_TYPE=mysql
      - DB_HOST=db:3306
      - DB_NAME=gitea
      - DB_USER=gitea
      - DB_PASSWD=gitea
      - DOMAIN=git.huangfamily.cn
    restart: always
    networks:
      - gitea
    volumes:
      - ./gitea:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - /home/git/.ssh/:/data/git/.ssh
    ports:
      - "4001:3000"
      - "4002:22"
    depends_on:
      - db

  db:
    image: mysql:8
    restart: always
    security_opt:
      - seccomp:unconfined
    environment:
      - MYSQL_ROOT_PASSWORD=gitea
      - MYSQL_USER=gitea
      - MYSQL_PASSWORD=gitea
      - MYSQL_DATABASE=gitea
    networks:
      - gitea
    volumes:
      - ./mysql:/var/lib/mysql
```

---

# 2. 整合 Drone CI

> 基于 Gitea 和 Drone 的轻量级的 CI 解决方案。

## 2.1 安装配置

```yml
services:
  drone-server:
    container_name: drone-server
    image: drone/drone:latest
    restart: always
    environment:
      - DRONE_GITEA=true
      - DRONE_GITEA_SERVER=http://192.168.18.241:3000
      - DRONE_GITEA_CLIENT_ID=569bfde3-640d-417c-a3eb-58f5065c2b07
      - DRONE_GITEA_CLIENT_SECRET=IWz8rOOIzTclkg2oNYfFxpprtGbfhSWxum8nESpWS0Qp
      - DRONE_GIT_ALWAYS_AUTH=true
      - DRONE_GITEA_SKIP_VERIFY=true
      - DRONE_RUNNER_CAPACITY=2
      - DRONE_SERVER_PROTO=http
      - DRONE_SERVER_HOST=192.168.18.241:7890
      - DRONE_NETWORK=cicd_default
      - DRONE_RUNNER_NETWORKS=cicd_default
      # 这个密钥是给runner用的
      - DRONE_RPC_SECRET=07d3caaa3e2d2d33bc1ce18c60d43213
      - DRONE_AGENTS_ENABLED=true
      - SET_CONTAINER_TIMEZONE=true
      - CONTAINER_TIMEZONE=Asia/Shanghai
      - DRONE_USER_CREATE=username:test_admin,admin:true
    ports:
      # 控制台页面端口
      - "7890:80"
    #   - 9000:9000
    volumes:
      - /etc/timezone:/etc/timezone
      - /etc/localtime:/etc/localtime

  drone-runner:
    container_name: drone-runner
    image: drone/drone-runner-docker:latest
    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/timezone:/etc/timezone
      - /etc/localtime:/etc/localtime
    environment:
      - SET_CONTAINER_TIMEZONE=true
      - CONTAINER_TIMEZONE=Asia/Shanghai
      - DRONE_RPC_PROTO=http
      # 如果直接使用本配置，这儿不需要改，如果部署到DRONE_RUNNER_LABELS其他服务器，需要填server的域名
      - DRONE_RPC_HOST=drone-server
      # server配置的DRONE_RPC_SECRET
      - DRONE_RPC_SECRET=07d3caaa3e2d2d33bc1ce18c60d43213
      - DRONE_RUNNER_CAPACITY=2
      - DRONE_RUNNER_NAME=drone-runner
      - DRONE_RPC_SKIP_VERIFY=true
      # 下面注释的是runner的控制台，没必要加上，server可以直接看到
      # - DRONE_UI_USERNAME=root
      # - DRONE_UI_PASSWORD=root
    # ports:
    #   - 3000:3000
```

## 2.2 CI 配置文件

```yml
---
kind: pipeline
type: docker
name: default

clone:
  depth: 2

steps:
  - name: restore-cache
    image: ccr.ccs.tencentyun.com/huangfamily/drone-volume-cache:0.1
    settings:
      restore: true
      mount:
        - ./.npm-cache
        - ./node_modules
    volumes:
      - name: cache
        path: /cache

  - name: npm-install
    image: ccr.ccs.tencentyun.com/huangfamily/node:16.14.0-alpine
    commands:
      - npm config set cache ./.npm-cache --global
      - npm install

  - name: rebuild-cache
    image: ccr.ccs.tencentyun.com/huangfamily/drone-volume-cache:0.1
    settings:
      rebuild: true
      mount:
        - ./.npm-cache
        - ./node_modules
    volumes:
      - name: cache
        path: /cache

  - name: docker-build
    image: plugins/docker:20.10.9
    settings:
      registry: registry.cn-guangzhou.aliyuncs.com
      username:
        from_secret: docker_username
      password:
        from_secret: docker_password
      tag: 0.0.1
      dockerfile: Dockerfile
      repo: registry.cn-guangzhou.aliyuncs.com/hjxstart/graduation_project
    when:
      status: [push]

  - name: deploy
    image: appleboy/drone-ssh:1.6.3
    settings:
      host:
        from_secret: PROD_IP
      username: root
      password:
        from_secret: PROD_PWD
      port: 22
      script:
        - echo ====暂停容器开始=======
        - docker stop graduation_project`
        - docker rm -f graduation_project`
        - docker images | grep graduation_project
        - docker rmi -f `docker images | grep graduation_project | awk '{print $3}'`
        - echo ====开始部署=======
        - docker pull registry.cn-guangzhou.aliyuncs.com/hjxstart/graduation_project:0.0.1
        - docker run -p 5000:5000 -d --name=graduation_project registry.cn-guangzhou.aliyuncs.com/hjxstart/graduation_project:0.0.1
        - docker logs graduation_project
        - docker ps | grep graduation_project
        - echo ====部署成功======

  - name: notification
    image: lddsb/drone-dingtalk-message:1.2.8
    settings:
      token: https://oapi.dingtalk.com/robot/send?access_token=XXX
      type: markdown
      secret: SEC7fe9d27f27ea58d1d54dc602XXXXX
      tpl_build_status_success: "流水线执行成功 🎉🎉🎉"
      tpl_build_status_failure: "流水线执行失败"
      tpl: "./dingtalk.tpl"
    when:
      status: [failure, success]
volumes:
  - name: cache
    host:
      path: /tmp/cache/graduation_project
```

## 2.3 钉钉通知模板

```tpl
[TPL_REPO_SHORT_NAME] [TPL_COMMIT_BRANCH] [TPL_BUILD_STATUS] 耗时[TPL_BUILD_CONSUMING]s
```
