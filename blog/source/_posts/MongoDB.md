---
title: MongoDB
categories: 数据库
tags:
  - MongoDB
  - 数据库
date: 2022-03-06 17:38:45
---

# 1.安装

## 1.1 离线安装方式 Win

1. 下载链接

> 1. 官方下载 [链接](https://www.mongodb.com/try/download/community 'title(hover)')
> 2. 其它下载 [链接](http://dl.mongodb.org/dl/win32/x86_64 'title(hover)')

2. 创建目录

> 文件中创建三个文件夹分别为：data、etc、logs，完整目录为：

```bash
mongodb #主文件夹
      data #用来存在数据库
      etc  #用来存储配置文件
      logs #存在mongodb 日志文件
      bin # mongodb的执行文件
      LICENSE-Community.text
      MPL-2
      README
      THIRD-PARTY-NOTICES
```

> etc 目录下编写配置文件 mongo.conf，在文件中添加内容：

```bash
dbpath=D:\mongodb\data #数据库路径  
logpath=D:\mongodb\logs\mongo.log #日志输出文件路径  
logappend=true #错误日志采用追加模式  
journal=true #启用日志文件，默认启用  
quiet=true #这个选项可以过滤掉一些无用的日志信息，若需要调试使用请设置为false  
port=27017 #端口号 默认为27017
```

> `注意`：dbpath 和 logpath。根据实际的路径填写。

3. 配置系统环境变量

```
变量名：MONGODB_HOME
变量值：D:\mongodb\bin

在PATH添加 %MONGODB_HOME%
```

4. 添加 MongoDB 服务

```ps1
mongod --dbpath "D:\mongodb\data\db" --logpath "D:\mongodb\logs\mongo.log" --install --serviceName "MongoDB"
```

> `注意`：需要在 data 目录下创建 db 文件。不然启动服务的时候可能会报错

5. 启动服务

```ps1
net start MongoDB
```

---

## 1.2 Docker 安装方式

1. 环境

> Centos7.9
> Docker20.10.8
> Mongo:laster

2. 安装

```shell
docker run -p 27017:27017 -v /home/docker-data/mongo:/data/db --name mongodb -d mongo
```

3. 代码连接

```js
const mongoose = require('mongoose');

mongoose.set('userCreateIndex', true);

class Database {
  constructor() {
    this.connect();
  }
  connect() {
    mongoose
      .connect('mongodb://47.241.104.103:27017/blog')
      .then(() => {
        console.log('database connection successful');
      })
      .catch((err) => {
        console.log('database connection error: ' + err);
      });
  }
}

module.exports = new Database();
```

## 1.3 Mac 安装

1. 下载 tgz 包和创建目录

```bash
mongodb-macos-x86_64-5.0.6.tgz
```

2. 解压安装包

```bash
sudo tar xf mongodb-macos-x86_64-4.4.3.tgz
```

3. 修改文件名为'mongodb'

```bash
sudo mv xf mongodb-macos-x86_64-4.4.3 mongodb\
```

4. 创建数据和日志目录

```bash
sudo mkdir -pv ./mongodb/data/{mongodb_data,mongodb_log}
```

5. 新建mongodb.log文件

```bash
sudo vim ./mongodb/data/mongodb_log/mongodb.log
```

6. 创建配置文件 mongodb.conf

```bash
sudo vim ./mongodb/data/mongodb.conf
```

```conf
port=27017
dbpath=./mongodb/data/mongodb_data/
logpath=./mongodb/data/mongodb_log/mongodb.log
fork=true
logappend=true
noauth=true
```

7. 启动mongodb服务

后台启动

```bash
sudo /Users/admin/software/mongodb/bin/mongod --port 27017 --fork --dbpath=/Users/admin/software/mongodb/data/mongodb_data/ --logpath=/Users/admin/software/mongodb/data/mongodb_log/mongodb.log --logappend
```

前台启动

```bash
sudo /Users/admin/software/mongodb/bin/mongod --port 27017  --dbpath=/Users/admin/software/mongodb/data/mongodb_data/ --logpath=/Users/admin/software/mongodb/data/mongodb_log/mongodb.log --logappend
```

8. 使用mongo

```bash
sudo ./mongodb/bin/mongo
```

9. 停止服务

```bash
use admin
db.shutdownServer();
```
