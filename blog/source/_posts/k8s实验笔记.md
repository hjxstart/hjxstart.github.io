---
title: k8s实验笔记
categories: 运维
top: 12
tags:
  - K8s
date: 2021-09-20 08:04:10
---

# 第一章 k8s install

## 1.1 该文基于k8s三件套以下版本

> kubectl v1.20.1-0
> kubeadm v1.20.1-0
> kubelet v1.20.1-0

---

## 1.2 安装docker

```shell
# 安装docker所需的工具
yum install -y yum-utils device-mapper-persistent-data lvm2
# 配置阿里云的docker源
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# 指定安装这个版本的docker-ce
yum install -y docker-ce-18.09.9-3.el7
# 启动docker
systemctl enable docker && systemctl start docker
```

---

## 1.3 only centos use

```shell
# 关闭防火墙
systemctl disable firewalld
systemctl stop firewalld
# 关闭selinux
# 临时禁用selinux
setenforce 0
# 永久关闭 修改/etc/sysconfig/selinux文件设置
sed -i 's/SELINUX=permissive/SELINUX=disabled/' /etc/sysconfig/selinux
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
# 禁用交换分区
swapoff -a
# 永久禁用，打开/etc/fstab注释掉swap那一行。
sed -i 's/.*swap.*/#&/' /etc/fstab
# 修改内核参数
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

---

## 1.4 更换k8s yum源

```shell
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```

---

## 1.5 安装 k8s三件套

```shell
yum install -y kubelet-1.20.1-0 kubeadm-1.20.1-0 kubectl-1.20.1-0 --disableexcludes=kubernetes
systemctl enable --now kubelet
```

---

## 1.6 编辑docker文件

```bash
# 创建文件 
vim /etc/docker/daemon.json
# 并写入
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
```

---

## 1.7 设置docker pull 代理

```bash
# 设置docker代理
mkdir -p /etc/systemd/system/docker.service.d
vim proxy.conf
# 输入以下内容
[Service]
Environment="HTTP_PROXY=http://192.168.18.140:8889/"
Environment="HTTPS_PROXY=http://192.168.18.140:8889/"
Environment="NO_PROXY=localhost,127.0.0.1,192.168.18.140"

systemctl daemon-reload
systemctl restart docker
```

---

## 1.8 下载镜像

```shell
kubeadm config images pull
# 可能不需要执行下面的命令
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.14.0
docker tag quay.mirrors.ustc.edu.cn/coreos/flannel:v0.14.0  quay.io/coreos/flannel:v0.14.0
docker rmi quay.mirrors.ustc.edu.cn/coreos/flannel:v0.14.0
```

---

## 1.9 创建集群

```shell
# 在master上创建集群
# 192.168.018.200为masteip；10.244.0.0/16为pod地址池；kubeadm-config.yaml是配置 kubelet 的 cgroup 驱动的文件
# kubeadm init --apiserver-advertise-address 192.168.18.200 --pod-network-cidr=10.244.0.0/16 --config kubeadm-config.yaml
kubeadm init --apiserver-advertise-address 192.168.18.200 --pod-network-cidr=10.244.0.0/16
# 接着还需要执行如下命令安装 Pod 网络（这里我们使用 flannel），否则 Pod 之间无法通信。
# https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml需要科学上网才能访问，
# 可在你的电脑访问后，在master服务器上创建kube-flannel.yaml后，粘贴进去。
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 查看节点状态，状态必须为ready
kubectl get nodes

# 查看加入集群的命令
kubeadm token create --print-join-command
```

---

## 1.10 其他机器加入集群

```shell
# 在其他节点中执行1~8的步骤
# 执行第9步骤中加入集群的命令，类似以下的命令
kubeadm join 192.168.18.200:6443 --token opip9p.rh35kkvqzwjizely --discovery-token-ca-cert-hash sha256:9252e13d2ffd3569c40b02c477f59038fac39aade9e99f282a333c0f8c5d7b22
```

## 1.11 测试

```shell
# https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml需要科学上网才能访问，
# 可在你的电脑访问后，在master服务器上创建nginx-app.yaml后，粘贴进去。
kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml
# 执行如下命令查看副本（pod）情况
kubectl get pods -o wide
# 执行如下命令则可以查看 services 状态。
kubectl get service
```

---

# 第二章 k8s DashBoard

## 2.1 安装DashBoard

```yaml
# 用浏览器打开以下文件并复制
# https://kuboard.cn/install-script/k8s-dashboard/v2.0.0-beta5.yaml
# 打开你的电脑创建dashboard.yaml
# 粘贴复制的内容
# 找到以下内容
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
  type: NodePort # 加入这一行，使用NodePort模式
  selector:
    k8s-app: kubernetes-dashboard
```

---

## 2.2 生成token

```shell
kubectl apply -f https://kuboard.cn/install-script/k8s-dashboard/auth.yaml
# 查看token值
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```

生成类似以下的内容

```shell
Name:         admin-user-token-v57nw
Namespace:    kubernetes-dashboard
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: admin-user
              kubernetes.io/service-account.uid: 0303243c-4040-4a58-8a47-849ee9ba79c1

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1066 bytes
namespace:  20 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLXY1N253Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIwMzAzMjQzYy00MDQwLTRhNTgtOGE0Ny04NDllZTliYTc5YzEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.Z2JrQlitASVwWbc-s6deLRFVk5DWD3P_vjUFXsqVSY10pbjFLG4njoZwh8p3tLxnX_VBsr7_6bwxhWSYChp9hwxznemD5x5HLtjb16kI9Z7yFWLtohzkTwuFbqmQaMoget_nYcQBUC5fDmBHRfFvNKePh_vSSb2h_aYXa8GV5AcfPQpY7r461itme1EXHQJqv-SN-zUnguDguCTjD80pFZ_CmnSE1z9QdMHPB8hoB4V68gtswR1VLa6mSYdgPwCHauuOobojALSaMc3RH7MmFUumAgguhqAkX3Omqd3rJbYOMRuMjhANqd08piDC3aIabINX6gP5-Tuuw2svnV6NYQ
```

---

## 2.3 查看Dashboard运行的端口

```shell
kubectl -n kubernetes-dashboard get svc -o wide
NAME                        TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE     SELECTOR
dashboard-metrics-scraper   ClusterIP      10.98.73.37     <none>        8000/TCP        16m     k8s-app=dashboard-metrics-scraper
kubernetes-dashboard        NodePort       10.111.244.42   <none>        443:30307/TCP   16m     k8s-app=kubernetes-dashboard
# 浏览器输入https://node地址:30307(端口)
```

---

# 第三章 kubesphere

## 3.1 kubesphere 前置要求

> Kubernetes 版本必须为：1.17.x、1.18.x、1.19.x 或 1.20.x
> 确保您的机器满足最低硬件要求：CPU > 1 核，内存 > 2 GB
> 在安装之前，需要配置 Kubernetes 集群中的默认存储类型

---

## 3.2 k8s安装指定的版本

```shell
# 查看可安装的k8s版本
yum list kubelet kubeadm kubectl  --showduplicates|sort -r
# k8s安装指定的版本
# Kubernetes 版本必须为：1.17.x、1.18.x、1.19.x 或 1.20.x
# 所以就安装了1.20.x
yum install kubelet-1.20.1-0 kubeadm-1.20.1-0 kubectl-1.20.1-0
```

---



## 3.3 创建存储类型

> 因为公司只有俩台服务,node节点性能和硬盘较大， 所以在node节点上部署存储服务，使用的是nfs。

---
## 3.4 创建nfs服务端

```shell
#创建共享目录,(目录可自定义)
mkdir -p /data/kubernetes
# 安装组件
yum -y install nfs-utils rpcbind
# 编辑配置文件
vim /etc/exports
# 写入内容如下
/data/kubernetes 192.168.18.0/24(rw,sync,no_root_squash)
# 这里的192.168.18.0/24，表示客户端访问白名单。只有符合的ip，才能访问
# 启动nfs服务
service nfs start
service rpcbind start
# 设置开机启动
systemctl enable nfs
systemctl enable rpcbind
```

---

## 3.5 客户端使用nfs

> 在master安装nfs客户端

```shell
# 登录主机k8s-master，创建目录
mkdir nfsvolume
# 下载yaml文件
https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/rbac.yaml
https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/class.yaml
https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/deployment.yaml
# 修改 deployment.yaml 中的两处 NFS 服务器 IP 和目录
...
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 192.168.18.199
            - name: NFS_PATH
              value: /data/kubernetes
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.18.199
            path: /data/kubernetes
# 部署创建
kubectl create -f rbac.yaml
kubectl create -f class.yaml
kubectl create -f deployment.yaml
```

```shell
# 每个节点都要安装nfs-tuils
yum -y install nfs-utils
# 在master执行
kubectl get storageclass
# 以下是终端打印示例内容
NAME                            PROVISIONER      AGE
managed-nfs-storage    fuseim.pri/ifs   139m
# 查看nfs pod, 确保状态正常
kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
nfs-client-provisioner-59777fb457-dkf87   1/1     Running   0          153m
# 标记一个默认的StorageClass
# 最多只有一个StorageClass能够标记为默认
kubectl patch storageclass managed-nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# 验证标记是否成功
kubectl get storageclass
NAME                            PROVISIONER      AGE
managed-nfs-storage (default)   fuseim.pri/ifs   139m
```

---

## 3.6 安装kubeSphere

```shell
# 安装的kubesphere 3.1.1
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.1.1/kubesphere-installer.yaml   
kubectl apply -f https://github.com/kubesphere/ks-installer/releases/download/v3.1.1/cluster-configuration.yaml
# 检查安装日志
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
# 使用 kubectl get pod --all-namespaces 查看所有 Pod 是否在 KubeSphere 的相关命名空间中正常运行。如果是，请通过以下命令检查控制台的端口（默认为 30880）:
kubectl get svc/ks-console -n kubesphere-system
# 确保在安全组中打开了端口 30880，并通过 NodePort (IP:30880) 使用默认帐户和密码 (admin/P@88w0rd) 访问 Web 控制台。
```

---



# 第四章 error

## 4.1 关于prometheus-k8s-0 启动失败，一直 pending 状态。

> 虽然kubesphere安装成功，但是健康检测服务可能没起来
> 主要原因是没有pvc
> [参考连接](https://kubesphere.com.cn/forum/d/5445-prometheus-k8s-0-pending)

```shell
# 创建pvc
vim pvc.yaml
# 写入以下内容
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-pvc
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 21Gi
# 执行pvc.yaml
kubectl create -f pvc.yaml
# 验证是否成功
kubectl get pvc
```

> 修改/etc/kubernetes/manifests/kube-apiserver.yaml

```yaml
# 在以下内容
spec:
  containers:
  - command:
    - kube-apiserver
# 加入这行
- --feature-gates=RemoveSelfLink=false
# 执行
kubectl apply -f /etc/kubernetes/manifests/kube-apiserver.yaml
```

---

## 4.2 cni0问题

```shell
# 可以使用类似以下的命令查看pod的运行描述信息
kubectl describe pod coredns-*** -n kube-system
# 发现报错信息为类似"network: failed to set bridge addr: "cni0" already has an IP address different from 10.244.0.1/24"
```

**解决办法**

> 该方法会重置集群！！！！！该方法会重置集群！！！！！该方法会重置集群！！！！！该方法会重置集群！！！！！

```shell
# 在所有节点（master和slave节点）删除cni0，以及暂停k8s和docker。
kubeadm reset 
systemctl stop kubelet
systemctl stop docker
rm -rf /var/lib/cni/
rm -rf /var/lib/kubelet/
rm -rf /etc/cni/
ifconfig cni0 down
ifconfig flannel.1 down
ifconfig docker0 down
ip link delete cni0
ip link delete flannel.1
# 在所有节点重启kubelet和docker
systemctl start kubelet
systemctl start docker
# 重新创建集群
```

