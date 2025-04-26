---
title: Hexo
categories: 工具
top: 15
tags:
  - Hexo
date: 2021-03-14 08:31:47
---

### 1.node 环境搭建

```bash
node -v
```

---

### 2.安装 hexo-cli

```bash
cnpm install -g hexo-cli
```

---

### 3.文件夹下初始化博客

```bash
sudo hexo init
```

---

### 4.创建一篇新文章

```bash
hexo new "My New Post"
```

---

### 5.本地运行预览

```bash
hexo server
```

---

### 6.清除文件

```bash
hexo clean
```

---

### 7.生成博客文件

```bash
hexo generate
```

---

### 8.安装 git 自动化部署

```bash
npm install hexo deployer-git --save
```

---

### 9.修改 \_config.yml 文件

```bash
deploy:
  type: git
  repo: https://github.com/xxx/xxx.github.io.git
  branch: master
```

---

### 10.推送到远端服务器

```bash
hexo deploy
```

---

### 11.下载 yilia 主题

```bash
git clone https://github.com/litten/hexo-theme-yilia themes/yilia
```

---

### 12.修改 \_config.yml 文件

```bash
themes：yilia
```

---

Hexo 文档： [Hexo](https://hexo.io/)
