---
title: Mybatis
categories: 开发
tags: Java
date: 2021-07-13 10:38:01
---

# Mybatis配置代码

## 1. Log4j的配置

### 步骤1 导入包

```pom
<!-- https://mvnrepository.com/artifact/log4j/log4j -->
<dependency>
    <groupId>log4j</groupId>
    <artifactId>log4j</artifactId>
    <version>1.2.17</version>
</dependency>

```

---

### 步骤2 log4j.properties

```properties
#将等级为DEBUG的日志信息输出到console和file两个目的地
log4j.rootLogger=DEBUG,console,file

#控制台输出的相关设置
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.Target=System.out
log4j.appender.console.Threshold=DEBUG
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=【%c】-%m%n

#文件输出的相关配置
log4j.appender.file=org.apache.log4j.RollingFileAppender
log4j.appender.file.File=./log/kuang.log
log4j.appender.file.MaxFileSize=10mb
log4j.appender.file.Threshold=DEBUG
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=【%p】[%d{yy-MM-dd}【%c】%m%n

#日志输出级别
log4j.logger.org.mybatis=DEBUG
log4j.logger.java.sql=DEBUG
log4j.logger.java.sql.Statement=DEBUG
log4j.logger.java.sql.ResultSet=DEBUG
log4j.logger.java.sql.PreparedStatement=DEBUG
```

--- 
### 步骤3 设置使用log4j

### 4 使用log4j

```java
static Logger logger = Logger.getLogger(xx.class)
logger.info("进入到了log4j");
```

## 1. Log4j的配置

### 步骤1 导入包

```pom
<!-- https://mvnrepository.com/artifact/log4j/log4j -->
<dependency>
    <groupId>log4j</groupId>
    <artifactId>log4j</artifactId>
    <version>1.2.17</version>
</dependency>

```

---

### 步骤2 log4j.properties

```properties
#将等级为DEBUG的日志信息输出到console和file两个目的地
log4j.rootLogger=DEBUG,console,file

#控制台输出的相关设置
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.Target=System.out
log4j.appender.console.Threshold=DEBUG
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=【%c】-%m%n

#文件输出的相关配置
log4j.appender.file=org.apache.log4j.RollingFileAppender
log4j.appender.file.File=./log/kuang.log
log4j.appender.file.MaxFileSize=10mb
log4j.appender.file.Threshold=DEBUG
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=【%p】[%d{yy-MM-dd}【%c】%m%n

#日志输出级别
log4j.logger.org.mybatis=DEBUG
log4j.logger.java.sql=DEBUG
log4j.logger.java.sql.Statement=DEBUG
log4j.logger.java.sql.ResultSet=DEBUG
log4j.logger.java.sql.PreparedStatement=DEBUG
```

--- 

### 步骤3 设置使用log4j

```xml

```

--- ###4 使用log4j

```java
static Logger logger = Logger.getLogger(xx.class)
logger.info("进入到了log4j");
```

## 第二章 配置模式

### 1.1 配置

1. application.yaml


2. 全局配置文件

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

</configuration>
```

3. mapper 映射文件

```xml

```





### 1.2 使用

1. 定义实体类

```java
package com.fh.oa.entity;

import lombok.Data;

@Data
public class Account {
    private Long id;
    private String userId;
    private Integer money;
}
```


2. 定义接口

```java
package com.fh.oa.dao;

import com.fh.oa.entity.Account;

public interface AccountDao {
    // 根据 id 获取用户
    public Account getAcct(Long id);
}
```

3. mapper

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com/fh/oa/dao/AccountDao">
<!--  查询账号，根据ID  -->
    <select id="getAcct" resultType="com/fh/oa/entity/Account">
        select * from account_tab where id=#{id}
    </select>
</mapper>
```






---




## 第三章 MyBatis-Plus简单使用

### 1. pom.xml

```xml
	<!--MyBatis Plus-->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>3.4.1</version>
        </dependency>
        <!--代码生成器依赖-->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-generator</artifactId>
            <version>3.4.1</version>
        </dependency>
        <!--模版引擎-->
        <dependency>
            <groupId>org.apache.velocity</groupId>
            <artifactId>velocity-engine-core</artifactId>
            <version>2.0</version>
        </dependency>
        <!--MySql-->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.12</version>
            <scope>runtime</scope>
        </dependency>
```

---

### 2. 自动代码生成类

```java
package com.fh.oateat;


import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.generator.AutoGenerator;
import com.baomidou.mybatisplus.generator.config.DataSourceConfig;
import com.baomidou.mybatisplus.generator.config.GlobalConfig;
import com.baomidou.mybatisplus.generator.config.PackageConfig;
import com.baomidou.mybatisplus.generator.config.StrategyConfig;
import com.baomidou.mybatisplus.generator.config.rules.NamingStrategy;

public class AutoMapper {
    public static void main(String[] args) {
        // 创建 AutoGenerator, MP中对象
        AutoGenerator ag = new AutoGenerator();

        // 设置全局配置
        GlobalConfig gc = new GlobalConfig();
        // 设置代码的生成位置，磁盘的目录
        String path = System.getProperty("user.dir");
        gc.setOutputDir(path + "/src/main/java");
        // 设置生成的类的名称 （命名规则）所有的Dao类都是Mapper结尾的，例如UserMapp;
        gc.setMapperName("%sMapper");
        gc.setServiceName("%sService");
        gc.setServiceImplName("%sServiceImple");
        gc.setControllerName("%sController");
        // 设置作者
        gc.setAuthor("hjxstart");
        // 设置主键id 的设置，可能需要安装数据情况进行更改
        gc.setIdType(IdType.AUTO);
        // 把GlobalConfig 复制给 AutoGenerator
        ag.setGlobalConfig(gc);

        // 设置数据源 DataSource
        DataSourceConfig ds = new DataSourceConfig();
        // 设置驱动
        ds.setDriverName("com.mysql.cj.jdbc.Driver");
        // 设置url
        ds.setUrl("jdbc:mysql://localhost:3306/oa?serverTimezone=UTC&characterEncoding=utf8&useUnicode=true&useSSL=false&allowPublicKeyRetrieval=true");
        // 设置数据库的用户名
        ds.setUsername("root");
        // 设置密码
        ds.setPassword("hadoop");
        // 把 DataSourceConfig 赋值给 AutoGenerator
        ag.setDataSource(ds);

        // 设置Package信息
        PackageConfig pc = new PackageConfig();
        // 设置模块名称，相当于包名，在这个包的下面有 mapper, service, controller
        pc.setModuleName("v1");
        // 设置夫包名,order 就在父包的下面生成
        pc.setParent("com.fh.oateat");
        ag.setPackageInfo(pc);

        // 设置策略
        StrategyConfig sc = new StrategyConfig();
        // 设置支持驼峰的命名规则
        sc.setNaming(NamingStrategy.underline_to_camel);
        sc.setColumnNaming(NamingStrategy.underline_to_camel);
        ag.setStrategy(sc);

        // 执行代码的生成
        ag.execute();
    }
}

```

---

### 3. Application

```java

@MapperScan("com.fh.oateat.v1.mapper") // 该注解可以省略在每个mapper接口的注解
@SpringBootApplication
```

---

### 4. application.yaml

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/oa?serverTimezone=UTC&characterEncoding=utf8&useUnicode=true&useSSL=false&allowPublicKeyRetrieval=true
    username: root
    password: hadoop # hadoop service
    driver-class-name: com.mysql.cj.jdbc.Driver

mybatis-plus:
  configuration:
    // 控制台输出对数据库的操作
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl

```

---

### 5. 分页插件

```java
@Configuration
public class MybatisPlusConfig {
    //分页查询 mybatis-plus
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        PaginationInnerInterceptor paginationInnerInterceptor = new PaginationInnerInterceptor();
        paginationInnerInterceptor.setDbType(DbType.MYSQL);
        paginationInnerInterceptor.setOverflow(true);
        interceptor.addInnerInterceptor(paginationInnerInterceptor);
        return interceptor;
    }
}
```

---

### 6. 创建好数据库即可

1. 会根据数据库的表自动生成entity,mapper,service,controller

---

### 7. Controller测试


## 第二章 逻辑删除

### 1. 在实体类和数据库添加enable字段

```java
private Integer enabled;
```

### 2. 添加注解，实现局部逻辑删除

```java
@TableLogic
    private Integer enabled;
```
