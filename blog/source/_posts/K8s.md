---
title: 'k8s'
categories: 运维
tags:
  - K8s
  - Docker
date: 2021-09-15 20:48:34
---

# 1. 安装docker

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

# 2. only centos

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
```

# 3.更改k8阿里云源

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

# 4.允许 iptables 检查桥接流量

```shell
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

# 5. 安装kubeadm

```shell
yum install -y kubelet-1.20.1-0 kubeadm-1.20.1-0 kubectl-1.20.1-0 --disableexcludes=kubernetes
sudo systemctl enable --now kubelet
```

---

# 6.编写docker文件

1. 编辑daemon文件：`vi /etc/docker/daemon.json`

```bash
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
```

---

# 7.设置科学上网(可以不设置)

1. 编辑配置文件：`vi /etc/profile`

```shell
# IP:同一个局域网内可以翻墙机器的IP地址，Port为代理的端口
export proxy="http://IP:Port"
export http_proxy=$proxy 
export https_proxy=$proxy 
export ftp_proxy=$proxy 
export no_proxy="localhost, 127.0.0.1, ::1"
```

2. 更新配置文件

```shell
source /etc/profile
```

3. 测试

```shell
curl http://www.google.com
```

---

# 8.Docker网络代理设置

1. 创建和编辑docker服务文件：

```shell
mkdir -p /etc/systemd/system/docker.service.d
```

2. 创建和编辑文件

```shell
vi /etc/systemd/system/docker.service.d/http-proxy.conf
i
# 中[proxy-addr]和[proxy-port]分别改成实际情况的代理地址和端口
[Service]
Environment="HTTP_PROXY=http://[proxy-addr]:[proxy-port]/" "HTTPS_PROXY=http://[proxy-addr]:[proxy-port]/"
```

3. 更新配置文件和重启docker

```
systemctl daemon-reload
systemctl restart docker
```

---

# 9.下载镜像

1. 下载安装k8s所需的镜像

```shell
kubeadm config images pull
```

2. 下载flannel

```shell
# 下载flanner镜像
docker pull quay.mirrors.ustc.edu.cn/coreos/flannel:v0.14.0 
docker tag quay.mirrors.ustc.edu.cn/coreos/flannel:v0.14.0  quay.io/coreos/flannel:v0.14.0
docker rmi quay.mirrors.ustc.edu.cn/coreos/flannel:v0.14.0
```

# 10.关闭代理

1. 关闭科学上网

- 编辑配置文件并注释相关配置

```shell
vi /etc/profile
```

- 如果要关闭代理，仅仅注释掉profile的代理内容是不行的，在文件内加入以下内容

```bash
unset http_proxy
unset https_proxy
unset ftp_proxy
unset no_proxy
```

- 更新配置文件

```shell
source /etc/profile
```

2. 关闭Docker代理(可以不关闭)

- 编辑配置文件，注释相关配置

```shell
vi /etc/systemd/system/docker.service.d/http-proxy.conf
```

- 更新配置并重启docker

```shell
systemctl daemon-reload
systemctl restart docker
```

# 11.在maste上创建集群

1. 在master上创建集群

```
# 192.168.18.200为masteip；10.244.0.0/16为pod地址池；kubeadm-config.yaml是配置 kubelet 的 cgroup 驱动的文件
# kubeadm init --apiserver-advertise-address 192.168.18.200 --pod-network-cidr=10.244.0.0/16 --config kubeadm-config.yaml
kubeadm init --apiserver-advertise-address 10.0.1.128 --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=...
```

2. 安装flanner网络

```shell
# 接着还需要执行如下命令安装 Pod 网络（这里我们使用 flannel），否则 Pod 之间无法通信。
# https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml需要科学上网才能访问，
# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f kube-flannel.yml
```

- 创建和编辑kube-flannel.yml文件: `vi kube-flannel.yml`

```bash
---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: psp.flannel.unprivileged
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: docker/default
    seccomp.security.alpha.kubernetes.io/defaultProfileName: docker/default
    apparmor.security.beta.kubernetes.io/allowedProfileNames: runtime/default
    apparmor.security.beta.kubernetes.io/defaultProfileName: runtime/default
spec:
  privileged: false
  volumes:
  - configMap
  - secret
  - emptyDir
  - hostPath
  allowedHostPaths:
  - pathPrefix: "/etc/cni/net.d"
  - pathPrefix: "/etc/kube-flannel"
  - pathPrefix: "/run/flannel"
  readOnlyRootFilesystem: false
  # Users and groups
  runAsUser:
    rule: RunAsAny
  supplementalGroups:
    rule: RunAsAny
  fsGroup:
    rule: RunAsAny
  # Privilege Escalation
  allowPrivilegeEscalation: false
  defaultAllowPrivilegeEscalation: false
  # Capabilities
  allowedCapabilities: ['NET_ADMIN', 'NET_RAW']
  defaultAddCapabilities: []
  requiredDropCapabilities: []
  # Host namespaces
  hostPID: false
  hostIPC: false
  hostNetwork: true
  hostPorts:
  - min: 0
    max: 65535
  # SELinux
  seLinux:
    # SELinux is unused in CaaSP
    rule: 'RunAsAny'
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: flannel
rules:
- apiGroups: ['extensions']
  resources: ['podsecuritypolicies']
  verbs: ['use']
  resourceNames: ['psp.flannel.unprivileged']
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - nodes/status
  verbs:
  - patch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: flannel
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: flannel
subjects:
- kind: ServiceAccount
  name: flannel
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flannel
  namespace: kube-system
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: kube-flannel-cfg
  namespace: kube-system
  labels:
    tier: node
    app: flannel
data:
  cni-conf.json: |
    {
      "name": "cbr0",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "flannel",
          "delegate": {
            "hairpinMode": true,
            "isDefaultGateway": true
          }
        },
        {
          "type": "portmap",
          "capabilities": {
            "portMappings": true
          }
        }
      ]
    }
  net-conf.json: |
    {
      "Network": "10.244.0.0/16",
      "Backend": {
        "Type": "vxlan"
      }
    }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-flannel-ds
  namespace: kube-system
  labels:
    tier: node
    app: flannel
spec:
  selector:
    matchLabels:
      app: flannel
  template:
    metadata:
      labels:
        tier: node
        app: flannel
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
      hostNetwork: true
      priorityClassName: system-node-critical
      tolerations:
      - operator: Exists
        effect: NoSchedule
      serviceAccountName: flannel
      initContainers:
      - name: install-cni
        image: quay.io/coreos/flannel:v0.14.0
        command:
        - cp
        args:
        - -f
        - /etc/kube-flannel/cni-conf.json
        - /etc/cni/net.d/10-flannel.conflist
        volumeMounts:
        - name: cni
          mountPath: /etc/cni/net.d
        - name: flannel-cfg
          mountPath: /etc/kube-flannel/
      containers:
      - name: kube-flannel
        image: quay.io/coreos/flannel:v0.14.0
        command:
        - /opt/bin/flanneld
        args:
        - --ip-masq
        - --kube-subnet-mgr
        resources:
          requests:
            cpu: "100m"
            memory: "50Mi"
          limits:
            cpu: "100m"
            memory: "50Mi"
        securityContext:
          privileged: false
          capabilities:
            add: ["NET_ADMIN", "NET_RAW"]
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        volumeMounts:
        - name: run
          mountPath: /run/flannel
        - name: flannel-cfg
          mountPath: /etc/kube-flannel/
      volumes:
      - name: run
        hostPath:
          path: /run/flannel
      - name: cni
        hostPath:
          path: /etc/cni/net.d
      - name: flannel-cfg
        configMap:
          name: kube-flannel-cfg
```

3. 查看节点状态，状态必须为ready

```shell
kubectl get nodes
```

4. 查看加入集群的命令

```shell
kubeadm token create --print-join-command
```

# 12.node加入集群

```shell
kubeadm join 192.168.18.200:6443 --token opip9p.rh35kkvqzwjizely --discovery-token-ca-cert-hash sha256:9252e13d2ffd3569c40b02c477f59038fac39aade9e99f282a333c0f8c5d7b22
```

# 13.测试

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

# 参考资源

1. 标题1，2，3 文档：[参考连接](https://segmentfault.com/a/1190000037682150)
2. 标题4，5 文档 [参考连接](https://kubernetes.io/zh/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
3. 标题6，7，10 文档 [参考连接](https://www.ihawo.com/archives/139.html)
4. 标题8，10 文档 [参考连接](https://blog.csdn.net/styshoo/article/details/55657714)


# 部署KubeSphere

## 1. 设置默认存储类型

### 1.1 安装nfs

1. 创建共享目录

```
mkdir -p /data/kubernetes
```

2. xxxxxxxxxx 前因后果状态。​bash

```
yum -y install nfs-utils rpcbind
```

3. 编辑配置文件

```
vi /etc/exports
```

4. 内容如下：

```
/data/kubernetes 192.168.31.0/24(rw,sync,no_root_squash)
```

注意：这里的192.168.31.0/24，表示客户端访问白名单。只有符合的ip，才能访问。

5. 启动nfs服务

```
service nfs start
service rpcbind start
```

6. 设置开机自启动

```
systemctl enable nfs
systemctl enable rpcbind
```

7. 登录**主机k8s-master**，安装客户端组件

```
yum -y install nfs-utils rpcbind
```

8. 测试nfs

```
## showmount -e 192.168.31.179
Export list for 192.168.31.179:
/data/kubernetes 192.168.31.0/24
```

## 1.2 安装 StorageClass

1. 登录**主机k8s-master**，创建目录

```
mkdir nfsvolume
```

2. 下载yaml文件

```
https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/rbac.yaml
https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/class.yaml
https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/nfs-client/deploy/deployment.yaml
```

3. 修改 deployment.yaml 中的两处 NFS 服务器 IP 和目录

```
...
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: 192.168.31.179
            - name: NFS_PATH
              value: /data/kubernetes
      volumes:
        - name: nfs-client-root
          nfs:
            server: 192.168.31.179
            path: /data/kubernetes
```

### 1.3 部署创建

1. 具体的说明可以去官网查看

```
kubectl create -f rbac.yaml
kubectl create -f class.yaml
kubectl create -f deployment.yaml
```

2. 注意：请确保每一个k8s node节点，安装了nfs-utils

```
yum -y install nfs-utils
```

3. 查看storageclass

```
## kubectl get storageclass
NAME                            PROVISIONER      AGE
managed-nfs-storage    fuseim.pri/ifs   139m
```

4. 查看nfs pod

```
## kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
nfs-client-provisioner-59777fb457-dkf87   1/1     Running   0          153m
```

5. 标记一个默认的 StorageClass

```
kubectl patch storageclass managed-nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

6. 验证标记是否成功

```
## kubectl get storageclass
NAME                            PROVISIONER      AGE
managed-nfs-storage (default)   fuseim.pri/ifs   139m
```

出现了一个default，表示成功了。

## 2. 安装KubeSphere

### 参考管访问当

## 参考文章

1. 标题1参考文章: [文章连接](https://cloud.tencent.com/developer/article/1677566)


# K8s的API对象

### 1. Namespace

命名空间实现同一集群上的资源隔离

### 2. Pod

K8s的最小运行单元

### 3. ReplicaSet

实现pod平滑迭代更新及回滚用，这个不需要我们实际操作

### 4. Deployment

用来发布无状态应用

### 5. Health Check

服务健康状态检测

实现的需求：

1. 零停机部署
2. 避免部署无效的服务镜像
3. 更加安全地滚动升级

不同点：

1. 不同之处在于检测失败后的行为：Liveness 检测是重启容器；Readiness 检测则是将容器设置为不可用，不接收 Service 转发的请求。
2. 用 Liveness 检测判断容器是否需要重启以实现自愈；用 Readiness 检测判断容器是否已经准备好对外提供服务。
3. Health Check 在 业务生产中滚动更新（rolling update）的应用场景

### 6. Service,Endpoint

实现同一lables下的多个pod流量负载均衡

### 7. Labels

标签，服务间选择访问的重要依据

### 8. Ingress

K8s的流量入口

### 9. DaemonSet

用来发布守护应用，例如我们部署的CNI插件

### 10. HPA

Horizontal Pod Autoscaling自动水平伸缩

### 11. Volume

存储卷
### 12. Pv, pvc, StorageClass

持久化存储，持久化存储声明，动态存储pv

### 13. StatefulSet

用来发布有状态应用

### 14. Job,CronJob

一次性任务及定时任务

### 15. Configmap, serect

服务配置及服务加密配置

### 16. Kube-proxy

提供service服务流量转发的功能支持，这个不需要我们实际操作

### 17. RBAC

serviceAccount, role, rolebindings, clusterrole, clusterrolebindings基于角色的访问控制

### Events

K8s事件流，可以用来监控相关事件用，这个不需要我们实际操作。

