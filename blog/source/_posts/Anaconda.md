---
title: Anaconda
date: 2025-06-21 20:56:49
categories: 开发
tags:
---

# 创建Python环境

```bash 
# 查看虚拟环境
conda env list
# 创建虚拟机环境
conda create -n hcie python=3.8.3
# 激活虚拟环境
conda activate hcie
# 退出虚拟环境
conda deactivate
# 删除虚拟环境
conda remove -n hcie --all
# 查看配置文件路径
pip -v config list
# 添加代理 pip.ini
[global]
proxy= http://127.0.0.1:7890
```