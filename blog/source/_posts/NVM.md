---
title: NVM
categories: 工具
tags:
  - Nodejs
date: 2021-07-05 08:15:33
---

> 本文介绍在 Moc, Windows10 和 Centos7.9 环境下安装 Node 版本管理工具NVM

# 一、Mac

## 1.1 安装

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
```

## 1.2 配置 `~/.bashrc`

```bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```

> 启用配置：source ~/.bashrc

## 1.3 安装 Node

1. 查看远端版本

```bash
nvm ls-remote 
```

2. 安装指定的版本

```bash
nvm install 16.14.0
```

3. 安装指定版本

安装指定版本直接在后面加上版本号即可

```bash
nvm use 16.14.0
```

---

# 二、Win10

## 2.1 nvm 安装

**_注意：如果本地已经安装了 node，要先卸载 node 再安装 nvm_**

```bash
nvm -v // 检查nvm是否安装成功
```

## 2.2 使用 nvm 安装 node

1. 查看 nvm 的指令

```bash
nvm -h
```

2. 查看本地已经安装的 node 版本列表

```bash
nvm list
```

3. 查看可以安装的 node 版本

```bash
nvm list available
```

4. 安装最新版本的 node

```bash
nvm install latest
```

5. 安装指定版本的 node. 例如安装 10.16.0 版本

```bash
nvm install 10.16.0
```

6. 使用对应版本的 node

```bash
nvm use 10.16.0
```

7. 卸载对应版本的 node

```bash
nvm uninstall 10.16.0
```

---

# 三、Centos7.9

## 2.1 安装 git

```bash
yum install git
```

查看 git 版本

```bash
git --version
```

## 2.2 安装 nvm

```bash
git clone git://github.com/creationix/nvm.git ~/nvm
```

验证安装

```bash
command -v nvm
```

设置 nvm 自动运行

```bash
echo "source ~/nvm/nvm.sh" >> ~/.bashrc
source ~/.bashrc
```

查询 Node.js 版本

```bash
nvm list-remote
```

安装 Node.js 版本

```bash
nvm install v16.14.0
```

切换 Node.js 版本

```bash
nvm use v16.14.0
```

升级 npm

```bash
npm -g
```
