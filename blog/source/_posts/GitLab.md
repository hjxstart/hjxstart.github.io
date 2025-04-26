---
title: GitLab
categories: 运维
tags:
  - Git
  - CICD
date: 2021-07-22 21:41:24
---

# 第一章 Docker 安装 gitlab

### 1. 运行 gitlab

```shell
sudo docker run --detach \
  --hostname 192.168.18.199 \
  --publish 20443:443 --publish 20080:80 --publish 20022:22 \
  --name gitlab \
  --restart always \
  --volume /home/hjx/docker/gitlab/config:/etc/gitlab \
  --volume /home/hjx/docker/gitlab/logs:/var/log/gitlab \
  --volume /home/hjx/docker/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
```

### 2. gitlab 重置密码

```shell
docker exec -it gitlab /bin/bash
gitlab-rails console -e production
user = User.where(id: 1).first
user.password = '密码'
user.password_confirmation = '密码'
user.save!
```

### 3. 配置邮件和修改clone地址

```shell
vim /etc/gitlab/gitlab.rb

gitlab_rails['time_zone'] = 'Asia/Shanghai'
gitlab_rails['gitlab_email_display_name'] = 'gitlab'
gitlab_rails['gitlab_email_from'] = 'xiangjiandev@163.com'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "xiangjiandev@163.com"
gitlab_rails['smtp_password'] = "授权码"
gitlab_rails['smtp_domain'] = "smtp.163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
user["git_user_email"] = "xiangjiandev@163.com"

gitlab_rails['gitlab_ssh_host'] = '192.168.52.129'
gitlab_rails['gitlab_shell_ssh_port'] = 8022

docker exec -it gitlab /bin/bash
gitlab-ctl reconfigure
gitlab-ctl restart
```

# 第一章 概述

## 一、业务要求

1. 使用docker部署gitlab.
2. 使用外部Nginx反向代理gitlab.
3. 使用gitlab.xj.com域名访问gitlab.
4. 使用Centos7.6
5. 使用内网地址192.168.18.125

---

# 第二章 步骤

## 一、docker安装gitlab镜像

1. 下载gitlab镜像

```
docker pull gitlab/gitlab-ce
```

2. 启动镜像

```
docker run --detach \
--hostname gitlab.xj.com \
--publish 20080:80 --publish 20022:22 \
--name gitlab \
--restart always \
--volume /data/gitlab/config:/etc/gitlab \
--volume /data/gitlab/logs:/var/log/gitlab \
--volume /data/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest
```

3. 测试本机安装的gitlab `http://192.168.18.125:20080`

## 二、配置使用外部的nginx服务器

1. 关闭gitlab内部的nginx服务[官网](https://docs.gitlab.com/omnibus/settings/nginx.html#using-a-non-bundled-web-server)

```
vim /data/gitlab/config/gitlab.rb
```

在配置文件最末尾加上配置

```
nginx['enable'] = false 
web_server['external_users'] = ['www-data']
```

使配置生效

```
docker exec gitlab gitlab-ctl reconfigure
```

2. 配置本机上的nginx.新nginx虚拟机配置文件，我的虚拟机配置文件在/usr/local/nginx/conf/vhost

```
touch /usr/local/nginx/conf/vhost/gitlab.xj.com.conf
vim /usr/local/nginx/conf/vhost/gitlab.xj.com.conf
```

下载官方的配置文件[官网](https://gitlab.com/gitlab-org/gitlab-recipes/-/blob/master/web-server/nginx/gitlab-omnibus-nginx.conf).配置文件有http 和 https两个版本，这里我选择了http第一个

```
## GitLab 8.3+
##
## Lines starting with two hashes (##) are comments with information.
## Lines starting with one hash (#) are configuration parameters that can be uncommented.
##
##################################
##        CONTRIBUTING          ##
##################################
##
## If you change this file in a Merge Request, please also create
## a Merge Request on https://gitlab.com/gitlab-org/omnibus-gitlab/merge_requests
##
###################################
##         configuration         ##
###################################
##
## See installation.md#using-https for additional HTTPS configuration details.

upstream gitlab-workhorse {
  # On GitLab versions before 13.5, the location is
  # `/var/opt/gitlab/gitlab-workhorse/socket`. Change the following line
  # accordingly.
  # 修改这里==================1
  server unix:/data/gitlab/data/gitlab-workhorse/sockets/socket;
}

## Normal HTTP host
server {
  ## Either remove "default_server" from the listen line below,
  ## or delete the /etc/nginx/sites-enabled/default file. This will cause gitlab
  ## to be served if you visit any address that your server responds to, eg.
  ## the ip address of the server (http://x.x.x.x/)n 0.0.0.0:80 default_server;
  listen 0.0.0.0:80 default_server;
  listen [::]:80 default_server;
  # 修改这里==================2
  server_name gitlab.xj.com; ## Replace this with something like gitlab.example.com
  server_tokens off; ## Don't show the nginx version number, a security best practice
  root /opt/gitlab/embedded/service/gitlab-rails/public;

  ## See app/controllers/application_controller.rb for headers set

  ## Individual nginx logs for this GitLab vhost
  access_log  /var/log/nginx/gitlab_access.log;
  error_log   /var/log/nginx/gitlab_error.log;

  location / {
    client_max_body_size 0;
    gzip off;

    ## https://github.com/gitlabhq/gitlabhq/issues/694
    ## Some requests take more than 30 seconds.
    proxy_read_timeout      300;
    proxy_connect_timeout   300;
    proxy_redirect          off;

    proxy_http_version 1.1;

    proxy_set_header    Host                $http_host;
    proxy_set_header    X-Real-IP           $remote_addr;
    proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
    proxy_set_header    X-Forwarded-Proto   $scheme;

    proxy_pass http://gitlab-workhorse;
  }
}
```

3. 在nginx.conf上添加上

`vim /usr/local/nginx/conf/nginx.conf`

```bash
# 1.配置成root用户，gitlab代理权限问题
user root;

worker_processes  1
...

http {
    ...
    # g zip
    # 2.把配置文件包含进了
    include      /usr/local/nginx/conf/vhost/gitlab.xj.com.conf;
....
```

4. 配置完成后检查`./nginx -t` 是否正常，没问题重新载入配置即可。

```
cd /usr/local/nginx/sbin/
./nginx  启动
./nginx -s stop  停止
./nginx -s quit  安全退出
./nginx -s reload  重新加载配置文件
ps aux|grep nginx  查看nginx进程
```

## 三、修改目录权限

```
chown -R 777 /data/gitlab/data/gitlab-workhorse/
```

# 主要参考资料

1. [docker安装gitlab后的配置修改](https://blog.csdn.net/aouoy/article/details/109798929)
2. [docker安装部署gitlab，docker安装部署gitlab配置使用外部nginx](https://ssrvps.org/archives/5022)
3. [Install Docker Engine on CentOS](https://docs.docker.com/engine/install/centos/)
4. [镜像加速器](https://cr.console.aliyun.com/cn-hangzhou/instances/mirrors)



# GitLab私有部署

### 第一章 环境说明

1. Centos7.6 (/boot 需要2G)
2. gitlab-ce-12.5.2-ce.0.el7.x86_64.rpm

---

### 第二章 安装GitLab

```bash
yum localinstall gitlab-ce-12.5.2-ce.0.el7.x86_64.rpm
```

---

1. 修改配置文件

### 第三章 修改配置

2. Gitlab 邮箱配置

```bash
vim /etc/gitlab/gitlab.rb
# 将external_url 变量的地址修改为gitlab 所在centos 的ip 地址。
external_url 'http://gitlab.example.com'

# 因为修改了配置文件，故需要重新加载配置内容
gitlab-ctl reconfigure
gitlab-ctl restart
```

```bash
# 修改配置文件
vim /etc/gitlab/gitlab.rb

# 添加以下配置
gitlab_rails['time_zone'] = 'Asia/Shanghai'
gitlab_rails['gitlab_email_display_name'] = 'gitlab'
gitlab_rails['gitlab_email_from'] = 'hjxstart@163.com'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "hjxstart@163.com"
gitlab_rails['smtp_password'] = "授权码"
gitlab_rails['smtp_domain'] = "smtp.163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
user["git_user_email"] = "hjxstart@163.com"

# 测试配置是否成功
gitlab-rails console

# 发送邮箱
Notify.test_email('hjxstart@163.com','test mail', 'test mail').deliver_now
```

3. 第一次使用root 登陆

- 在浏览器输入ip地址即可

---

### 第四章 Gitlab 使用流程

#### 4.1 账号的申请

1. 开发人员提供以下资料给管理员：姓名（用于展示用户项目）；邮箱（用于接受密码接收推送通知等）
2. 收到重置密码邮箱之后进行密码重置，密码需要设置8为以上，建议使用自己的姓名+数字组成
3. 账号申请，组对应公司里开发团队
4. 创建账号，分别创建用户pm(项目经理)、dev1(开发1)、dev2(开发2)、test1(测试一)。账号创建后默认密码会发送邮件，第一次登陆哟去修改密码
5. 用户加入组: pm用户作为组的所有者

#### 4.2 客户端安装

1. 首先安装git
2. 然后安装TortoiseGit

#### 4.3 SSH key 使用

1. 生成ssh key

- 方法一：可视化创建ssh key, 在任意文件夹下点击右键，选择 Git GUI Here。在弹出的程序中选择主菜单的[Help] -> [Show SSH Key]
- 方法二：命令行方式创建ssh key

```bash
# linux
# 默认为rsa加密算法
ssh-keygen -C "hjxstart@126.com" -f ~/.ssh/id_rsa -N '' -q
# -t: 指定为dsa加密算法; -f: 指定存放的位置; -C: 邮箱；-P 密码; -q: 静默模式
ssh-keygen -t dsa -f ~/.ssh/id_dsa -C "hjxstart@126.com" -P '' -q
# windows
ssh-keygen.exe -f ~/.ssh/id_rsa -C "hjxstart@126.com" -N '' -q
```

2. 查看 SSH key

```bash
cat ~/.sshid_rsa.pub
```

3. 添加 SSH key。

- 打开Gitlab 登录自己的账号
- 进入用户设置，找到SSHkeys
- 点击右侧 Add SSH Key
- 输入上一步生成的key
- 点击Add key 即添加成功一个key

#### 4.4 新建项目规则

1. 创建项目组
2. 使用之前创建的项目组。
3. 进行添加用户。
4. 项目经理指定开发计划
   app   需求  开发者 完成日期
   v1.0  首页  dev1  2.5
   新闻  dev1  2.7
   支付  dev2  2.7
   博客  dev2  2.8

- 创建里程碑 lssues > Miletones > new Miletones (Title: v1.0; Description: 官网v1.0)
- 分配任务 lssues > new lssues（Title:首页; Descripiton: 首页开发；Assignce(指派): dev1；Miletones: v1.0;结束时间）

#### 4.5 项目检出check

```bash
# 1. 克隆项目
git clone 

# 2. 配置用户信息
git config --gloabl user.name dev1
git config --gloabl user.email dev1@126.com

# 3. 创建分支branch
git branch branchName

# 4. 代码提交Commit
git commit -m "我是提交描述"
# 提交时可以带上需要关闭的任务编号，确认请求会自动关闭问题
git commit -m "close #2"

# 5. 代码拉取Pull
git Pull

# 6. 代码推送Push
git push

# 7. 代码标签tag

# 8. 代码冲突解决

# 9. 创建忽略文件
.gitignore

# 10. 发出合并请求,先登录 dev1， Merge Requests > new merge request （选择 index分支）。
# Assignee: pm(指派给项目经理合并，权限)； 里程碑 Mileestone（V1.0）

# 11. 项目经理登录确认合并请求

# 12. 项目经理可以去 issues 手动关闭任务
```

---

### 第五章 Gitlab备份与回复

#### 5.1 备份管理

1. 配置文件中加入 # vim /etc/gitlab/gitlab.rb

```bash
gitlab_rails['backup_path'] = '/data/backup/gitlab'
gitlab_rails['backup_keep_time'] = 604800
```

2. 重置配置: gitlab-ctl reconfigure
3. 如果自定义备份目录需要赋予git权限

```bash
mkdir /data/backup/gitlab -p
chown -R git.git /data/backup/gitlab
```

4. 重置配置: gitlab-ctl reconfigure
5. 手动备份

```bash
gitlab-rake gitlab:backup:create
```

6. 查看备份

```bash
ls /data/backup/gitlab -ps
```

---

#### 5.2 恢复管理

恢复是删除原有数据，恢复备份tar包中的数据。

1. 先停止数据写入服务

```bash
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
```

2. 还原

```bash
# 1. 查看要还原的文件
ls /data/backup/gitlab -p
# 2. 还原，只需要写到时间戳就可以了1625903798_2021_07_10_12.5.2_gitlab_backup.tar
gitlab-rake gitlab:backup:restore BACKUP=1625903798_2021_07_10_12.5.2
# 3. 查看时间戳的时间
date -d @1625903798
```

3. 设定计划划任务

```bash
定时任务Crontab中加入
0 2 * * * /usr/bin/gitlab-rake gitlab:backup:create
策略建议: 本地保留三到七天 在异地备份永久保存
手动备份测试: gitlab-rake gitlab:backup:create
# ls /data/backup/gitlab/
1576053273_2019_12_11_12.5.2_gitlab_backup.tar
注意 gitlab.rb 和 gitlab-secrets.json 两个文件包含敏感信息。
未被备份到备份文件中。需要手动备份
```

---

### 第六章 基于Jenkins 实现持续集成

#### 6.1 持续集成(Continuous integration)

1. 持续集成(CI)简介。持续集成是一种软件开发实践，即团队开发成员经常集成他们的工作，通常每个成员媒体至少集成一次，也就意味着每天可能会发生多次集成。每次集成都通过自动化的构建（包括编译，发布，自动化测试）来验证，从而尽快地发现集成错误。许多团队发现这个过程可以大大减少集成的问题，让团队能够更快的开发内聚的软件。
2. 没有持续集成。项目做模块集成的时候，发现很多接口都不通(浪费大量时间)。需要人手动去编译打包最新的代码(构建过程不透明)。发布代码，上线，基本靠手(脚步乱发)。
3. 持续集成最佳实践。
4. 持续集成的过程

#### 6.2 持续交付(Continuous delivery, CD)

#### 6.3 持续部署(Continuous Deployment, CD)

---

### 第七章 常用命令

1. gitlab-ctl command

```bash
gitlab-ctl start # 启动所有服务
gitlab-ctl restart # 重启所有服务
gitlab-ctl stop # 关闭所有服务
gitlab-ctl status # 查看所有服务状态
gitlab-ctl tail	# 查看日志信息
gitlab-ctl service-list # 列举所有启动服务
gitlab-ctl  graceful-kill # 平稳停止一个服务
gitlab-ctl reconfigure # 修改配置文件之后，需要重新加载下
gitlab-ctl show-config # 查看所有服务配置文件信息
gitlab-ctl uninstall # 卸载这个软件
gitlab-ctl cleanse # 删除gitlab 数据，重新白手起家
```

---

### 第八章 目录

1. 库默认存储目录:
   /var/opt/gitlab/git-data/repositories/rootopt/gitlab
2. 应用代码和相应的依赖程序: /opt/gitlab
3. 命令编译后的应用数据和配置文件，不需要人为修改配置后的应用数据和
   配置文件: /var/opt/gitlab: gitlab-ctl reconfigure:命令编译后的应用数据和
   配置文件，不需要人为修改配置
4. 配置文件目录: /etc/gitlab
5. 此目录下存放了gitlab各个组件产生的日志: /var/log/gitlab
6. 备份文件生成的目录: /var/opt/gitlab/backups/
