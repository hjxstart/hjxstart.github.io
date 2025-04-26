---
title: Ingress
categories: 运维
tags:
  - K8s
date: 2021-09-08 23:56:01
---

# Ingress安装

### 1.环境说明

1. centos7.9最小安装
2. k8s二进制部署
3. harbor部署


### 2.安装步骤[链接](https://github.com/bogeit/LearnK8s/blob/main/%E7%AC%AC6%E5%85%B3%20k8s%E6%9E%B6%E6%9E%84%E5%B8%88%E8%AF%BE%E7%A8%8B%E4%B9%8B%E6%B5%81%E9%87%8F%E5%85%A5%E5%8F%A3Ingress%E4%B8%8A%E9%83%A8.md)

1. 创建nginx-ingress.yaml
2. 安装nginx-ingress

``
`shell
### 根据脚步创建pod
kubectl apply -f nginx-ingress.yaml
```



