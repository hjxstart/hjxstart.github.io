---
title: Openstack
date: 2025-04-24 09:04:36
categories:
tags:
---

# 概述

## 环境搭建

```bash
RHOPS13（红帽-商业版 V13）
内容：Openstack的运维（基于原生的Q版）
环境：配套环境的文件夹 -> RHSOP13 -> RHOSP13.wmx
硬件：内存32G以上，开启CPU虚拟化
网络：仅主机，172.25.254.0/24,关闭DHCP
打开虚拟机: 选择我已经复制虚拟机
账号信息: kiosk/redhat  root/Asimov
切换到root设置时间: su - root
    date -s "20220909 11:01" # 设置2022年1月以后
    hwclock -w
环境调整：(关机后调整)
    controller/director: 调整为CPU 6C,内存12G（12288）
    utility: 6C/6G (6144)
    验证环境：ssh student@workstation后
        ssh director
        source overcloudrc
        openstack service list
环境初始化：
    virt-manager # 查看虚拟机
    rht-f0finish # 启动环境
常用命令: 
    rht-vmctl restart all -y # 开启所有
    rht-vmctl fullreset all -y # 完整恢复
    rht-vmctl reset 节点名称
    其他：如果无法启动就手动启动
关闭OpenStack课堂环境集群
    生产环境：不需要关闭
    课堂环境：不使用后要关闭，因为不关闭内存里面会产生脏数据，影响后面学习使用
    步骤1: 停止OpenStack平台中所有的虚拟机(关机)
    步骤2: 到director运行脚本做各个物流节点的下单处理: ssh director
    步骤3：切换到student/student: ssh student@workstation
    步骤4:：rht-overcloud.sh start
```

## 环境介绍

![课堂环境](https://cdn.jsdelivr.net/gh/hjxstart/PicGo@main/img/20250424093017420.png)

```bash
Undercloud(云下环境): director: 存储OpenStack中各种组件的应用程序，便于节点安装（All in One）
Overcloud(云上环境): 实际作用:模拟生产环境节点
    controller: 控制节点，安装有各种API，网络的组件，身份验证API，Keystone等
    compute: 计算节点（一般不止一个）：做虚拟机迁移，资源不够网其他节点去迁移等
    computehci：超融合节点，
    ceph: 存储后端节点
power(电源管理)：实际生产环境没有这个节点，模拟的带外管理口，IPMI协议.
utility：实质是模拟IDM集成身份验证的机器（有点类似于Windows基础架构中的AD服务器的作用，实际这个在生产环境中根据需要配置）
网络介绍:
    调配网络(director): 172.25.249.X/24；控制各个物理机开关，如果想安装各个物理机，可以将物理机的网络连接到director，进行安装。
    管理网络(Managerment)：172.24.X.0/24；多VLAN角色，细化各个角色的流量。
    外部网络(External): 使用workstation登录到各个节点去做使用的网络
    实例网络(): 在OpenStack虚拟机创建后分配的浮动IP地址
课堂中的网络拓扑：
    openstack service api: Internal API (Vlan 10)
    租户网络: Tenant (vlan 20)
    存储数据网络: Storage (vlan 30)
    存储管理网络: Storage Mgmt (vlan 40)
    管理网络：Management (vlan 50)
classroom服务器：充当时间同步服务器使用
    在openstack中，一定要加载时间同步服务器，一定要保证各个节点的时间0误差，因为会涉及到keystone认证时间戳问题。
身份认证服务器(IDM): IPMI协议 623端口；root@power，执行 netstat -uln | grep 623
    随时对设备进行上电和下单的处理-模拟带外管理口
```

## OpenStack介绍

```bash
# 什么是OpenStack
    开源的云计算管理平台项目
    官网(原生平台): https://www.openstack.org/
    官方文档: https://docs.openstack.org/
    发行列表: https://releases.openstack.org/
    提供一个企业级云环境
    NASA和Rackspace合作研发
    最终目的是为了构建和管理企业的公有云、私有云、混合云环境
    注意：OpenStack是云管平台，不是虚拟化平台，OpenStack创建虚拟机底层使用的是KVM
# RHOSP
    Red Hat OpenStack Platform
    提供企业级OpenStack发行版
    优点：
        针对企业环境优化，如果有漏洞，有重大问题—>可以打补丁来保证平台的稳定性
        可以和容器podman、OpenShift、RHEL Linux、红帽卫星去集成等
        与各个服务器、软件服务商、云服务商达成战略合作并形成生态圈
    国内：华为HCS、阿里飞天等
# 描述UnderCloud
    介绍UnderCloud
        是在RHOSP平台的Director的节点上单独安装的All in One的Openstack
        原生的Openstack的All in one：
            https://www.rdoproject.org/install/packstack
            相当于吧OpenStack中所有的东西部署在一个节点上，仅能测试，不建议生产使用
        想构建UnderCloud需要哪些功能？
            身份服务: ketstone, 提供UnderCloud组件用户身份认证和授权
            镜像服务: glance, 存储在裸机上安装操作系统和KVM已经各种需要的软件 (针对于不是Openstack裸机镜像)
            技术服务: nova, 根据glance提供的镜像，配合IPMI来安装虚拟机和物理机
            编排服务: heat，一组yaml魔板，根据定义好的代码来配置合适的OverCloud节点
            对象存储服务: swift, 用于存储undercloud的用户镜像和日志
            网络服务: 提供undercloud的调配网络访问，在调配网络中
```

## Test


```bash


```