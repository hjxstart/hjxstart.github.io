---
title: Springboot项目
categories: 开发
tags:
date: 2021-07-31 19:34:21
---

##  Docker部署Springboot项目

### 1. docker 开启远程连接

1. 编辑docker.service文件

```shell
vi /usr/lib/systemd/system/docker.service
```

2. 修改 ExecStart 属性

```shell
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:2375
```

3. 重新加载Docker配置生效

```shell
systemctl daemon-reload 
systemctl restart docker
```

---

### 2. IDEA 配置

1. 连接docker

```shell
tcp://ip:2375
```

2. 配置镜像加速器

```shell
https://xsxk9861.mirror.aliyuncs.com
```

3. 集成mavn插件 pom.xml

```xml
    <properties>
        <java.version>1.8</java.version>
        <!--docker镜像前缀名称-->
        <docker.image.prefix>java</docker.image.prefix>
    </properties>
```


```xml
          <plugin>
                <groupId>com.spotify</groupId>
                <artifactId>docker-maven-plugin</artifactId>
                <version>1.0.0</version>

                <configuration>
                    <!--远程docker的地址-->
                    <dockerHost>http://45.77.120.192:2375</dockerHost>
                    <!--镜像名称，前缀/项目名-->
                    <imageName>${docker.image.prefix}/${project.artifactId}</imageName>
                    <!--Dockerfile的位置-->
                    <dockerDirectory>src/main/docker</dockerDirectory>
                    <resources>
                        <resource>
                            <targetPath>/</targetPath>
                            <directory>${project.build.directory}</directory>
                            <include>${project.build.finalName}.jar</include>
                        </resource>
                    </resources>
                </configuration>
            </plugin>
```

4. 创建src/main/docker/Dockerfile

```dockerfile
#依赖jdk8
FROM java:8
# 维护者信息
MAINTAINER hjxstart hjxstart@126.com
#容器卷
VOLUME /tmp
#拷贝jar包
ADD internal-system-java-0.0.1-SNAPSHOT.jar /test.jar
#暴漏端口
# EXPOSE 8080
#容器启动时执行
ENTRYPOINT [ "java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/test.jar" ]
```

### 3. 打包部署

1. 使用Plugins插件分别运行build
