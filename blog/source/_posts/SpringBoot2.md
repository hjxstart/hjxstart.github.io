---
title: SpringBoot2学习
categories: 开发
tags:
  - Java
date: 2021-06-08 16:51:25
---

# SpringBoot2核心技术-核心功能

## 1、配置文件

### 1.1、yaml

#### 1.1.1、简介

YAML 是一种采用递归缩进表示层级关系的标记语言，非常适合用来以数据为中心的配置文件.
可以使用

#### 1.1.2、基本语法

- key: value; kv之间有空格
- 大小写敏感
- 使用缩进表示层次关系
- 缩进不允许使用tab，只允许空格
- 缩进的空格数不重要，只要相同层级的元素左对齐即可
- ‘#’表示注释
- “与”表示字符串内容会被 转义/不转义

#### 1.1.3、数据类型

- 字面量：单个的，不可再分的值。date、boolean、string、number、null

```yaml
k: v
```

- 对象：键值对的集合。map、hash、set、object

```yaml
行内写法：k: {k1:v1,k2:v2,k3:v3}
#或
k:
  k1: v1
  k2: v2
  k3: v3
  K4: v4
```

- 数组：一组按次序排列的值。array、list、queue

```yaml
行内写法：k: [v1,v2,v3]
#或者
k:
 - v1
 - v2
 - v3
```

---

#### 1.1.4、示例

- Person.java & Pet.java

```java
@ConfigurationProperties(prefix = "data.person")
@Component
@ToString
@Data
public class Person {
    
    private String userName;
    private Boolean boss;
    private Date birth;
    private Integer age;
    private Pet pet;
    private String[] interests;
    private List<String> animal;
    private Map<String, Object> score;
    private Set<Double> salarys;
    private Map<String, List<Pet>> allPets;
}

@ToString
@Data
public class Pet {
    private String name;
    private Double weight;
}
```

- application.yaml

```yaml
data:
  person:
    userName: hjxstart
    boss: true
    birth: 1998/5/11
    age: 23
    interests: [跑步,游泳]
    animal: [猫,狗]
    socre:
      java: 80
      mysql: 90
      linux: 100
    salarys:
      - 9999.98
      - 9999.99
    pet:
      name: 猫
      weight: 99.99
    allPets:
      sick:
        - {name: 阿狗,weight: 99.99}
        - name: 阿猫
          weight: 88.88
        - name: 小鱼
          weight: 77.77
      health: [{name: 阿花, weight: 19.99},{name: 阿明, weight: 9.99}]
```

---

## 2、web开发

[参考文档](https://docs.spring.io/spring-boot/docs/2.3.4.RELEASE/reference/html/spring-boot-features.html#boot-features-developing-web-applications)

### 2.1 简单功能分析

#### 2.1.1、静态资源访问

- 默认支持的静态资源的目录
  /static(or /public or /resources or /META-INF/resources)
- 可以自定义静态资源访问前缀(默认为"/**")和静态资源目录
  **注意**：自定义静态资源访问前缀会导致对欢迎页和Favicon的支持失效

```yaml
spring:
  mvc:
    static-path-pattern: /res/** #自定义静态资源访问前缀
  resources:
    static-locations: [classpath:/staticfile] # 自定义静态资源目录
```

#### 2.1.2、欢迎页支持

- 把欢迎页(index.html)放在 /static or /template 目录下即可。
- 如果在上面两个文件目录下找不到就处理 / 的Controller。

#### 2.1.3、自定义favicon

- 把 favicon 放在静态资源目录下即可，默认放在(/static)

#### 2.1.4、静态资源配置原理

1. 补充：配置类只有一个有参构造器的情况

- 示例

```java
// 有参构造器所有参数的值都会从容器中确定
//ResourceProperties resourceProperties；获取和spring.resources绑定的所有的值的对象
//WebMvcProperties mvcProperties 获取和spring.mvc绑定的所有的值的对象
//ListableBeanFactory beanFactory Spring的beanFactory
//HttpMessageConverters 找到所有的HttpMessageConverters
//ResourceHandlerRegistrationCustomizer 找到 资源处理器的自定义器。=========
//DispatcherServletPath  
//ServletRegistrationBean   给应用注册Servlet、Filter....
    public WebMvcAutoConfigurationAdapter(ResourceProperties resourceProperties, WebMvcProperties mvcProperties,
                ListableBeanFactory beanFactory, ObjectProvider<HttpMessageConverters> messageConvertersProvider,
                ObjectProvider<ResourceHandlerRegistrationCustomizer> resourceHandlerRegistrationCustomizerProvider,
                ObjectProvider<DispatcherServletPath> dispatcherServletPath,
                ObjectProvider<ServletRegistrationBean<?>> servletRegistrations) {
            this.resourceProperties = resourceProperties;
            this.mvcProperties = mvcProperties;
            this.beanFactory = beanFactory;
            this.messageConvertersProvider = messageConvertersProvider;
            this.resourceHandlerRegistrationCustomizer = resourceHandlerRegistrationCustomizerProvider.getIfAvailable();
            this.dispatcherServletPath = dispatcherServletPath;
            this.servletRegistrations = servletRegistrations;
        }
```

2. 资源处理的默认规则

3. 欢迎页的处理规则
4. faivcon

### 2.2 请求参数处理

### 2.2.1、请求映射

### 2.2.2、普通参数与基本注解

1. 常用注解
   @PathVariable, @RequestHeader, @RequestParam, @CookieValue, @ModelAttribute, @MatriVariable, @RequestBody

```java
@PathVariable // 获取 url 路径变量(id, username)的值
@RequestHeader // 获取请求的Header的值
@RequestParam // 获取 url 的参数(age, inters)的值
@CookieValue // 获取 Cookie 的值
@ModelAttribute // 获取request域属性的值
    // /car/3/owner/lisi?age=18&inters=basketball&inters=game
    @GetMapping("/car/{id}/owner/{username}")
    public Map<String, Object> getCar(@PathVariable("id") Integer id,
                                      @PathVariable("username") String name, //
                                      @PathVariable Map<String, String> pv,
                                      @RequestHeader("User-Agent") String userAgent,
                                      @RequestHeader Map<String, String> rh,
                                      @RequestParam("age") Integer age,
                                      @RequestParam("inters") List<String> inters,
                                      @RequestParam Map<String,String> rp,
                                      @CookieValue("Idea-b83d5636") String idea,
                                      @CookieValue("testcookie") Cookie cookie) {
        Map<String,Object> map = new HashMap<>();
        map.put("PV_Id", id);
        map.put("PV_Username", name);
        map.put("PV_Map", pv);
        map.put("RH_UserAgent", userAgent);
        map.put("RH_Map", rh);
        map.put("RP_age", age);
        map.put("RP_inters", inters);
        map.put("RP_Map", rp);
        map.put("CV_idea", idea);
        map.put("Cookie", cookie);
        return map;
    }

// 1.需要开启矩阵变量的配置（在Configuration类中配置）
    @Bean
    public WebMvcConfigurer webMvcConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void configurePathMatch(PathMatchConfigurer configurer) {
                UrlPathHelper urlPathHelper = new UrlPathHelper();
                urlPathHelper.setRemoveSemicolonContent(false);
                configurer.setUrlPathHelper(urlPathHelper);
            }
        };
    }
@MatriVariable // 2.获取矩阵变量的值。(面试题：禁用cookie后如何传输sessionId)
    // /boss/1;age=20/2;age=10
    @GetMapping("/boss/{bossId}/{empId}")
    public Map boss(@MatrixVariable(value = "age", pathVar = "bossId") Integer bossAge,
                    @MatrixVariable(value = "age", pathVar = "empId") Integer empAge) {
        Map<String, Object> map = new HashMap<>();
        map.put("bossAge", bossAge);
        map.put("empAge", empAge);
        return map;
    }

@RequestBody // 获取请求体（只有POST请求才有）的值
    @PostMapping("/save")
    public Map postMethod(@RequestBody String content) {
        Map<String, Object> map = new HashMap<>();
        map.put("RequestBody", content);
        return map;
    }
```

- 原理：

2. Servlet API:
   WebRequest, ServletRequest, MultipartRequest, HttpSession、javax.servlet.http.PushBuilder, Principal, InputStream, Reader, HttpMethod, Locale, TimeZone, Zoneld

- ServletRequestMethodArgumentResolver 可以处理以上的部分参数

```java
@Override
public boolean supportsParameter(MethodParameter parameter) {
	Class<?> paramType = parameter.getParameterType();
	return (WebRequest.class.isAssignableFrom(paramType) ||
		ServletRequest.class.isAssignableFrom(paramType) ||
		MultipartRequest.class.isAssignableFrom(paramType) ||
		HttpSession.class.isAssignableFrom(paramType) ||
		(pushBuilder != null && pushBuilder.isAssignableFrom(paramType)) ||
		Principal.class.isAssignableFrom(paramType) ||
		InputStream.class.isAssignableFrom(paramType) ||
		Reader.class.isAssignableFrom(paramType) ||
		HttpMethod.class == paramType ||
		Locale.class == paramType ||
		TimeZone.class == paramType ||
		ZoneId.class == paramType);
}
```

3. 复杂参数
   **Map**, **Model**, Errors/BindingResult, **RedirectAttributes**, **ServletResponse**, SessionStatus, UriComponentsBuilder, ServletUriComponentsBuilder

- map, model里面的数据会被放在 request 的请求域 request.setAttribute
- RedirectAttributes 是重定向携带数据
- ServletResponse 拿到原生的Response能干什么

4. 自定义对象参数
   可以自动类型与格式化，可以级联封装。

---

## 3、数据访问

---

## 4、单元测试

---

## 5、指标监控

---

## 6、原来解析

---

# SpringBoot统一返回信息格式

## 1. 创建枚举类

```java
package com.example.demo2.v1.dto;

/**
 * @author jxh
 * 状态码和描述信息
 */
public enum RHttpStatusEnum {

    /*** 通用部分 100 - 599***/
    // 成功
    SUCCESS(200, "success"),
    // 重定向
    REDIRECT(301, "redirect"),
    // 资源未找到
    NOT_FOUND(404, "not found"),
    // 服务器错误
    SERVER_ERROR(500,"server error"),
    // 服务器忙
    SERVER_BUSY(503,"服务器正忙，请稍后再试!"),

    /*** 这里可以根据不同模块用不同的区级分开错误码，例如:  ***/

    // 1000～1999 区间表示周报模块错误
    DIARIES_ERROR(1999, "未知错误，请联系管理员");
    // 2000～2999 区间表示任务模块错误

    private final int code;
    private final String msg;

    RHttpStatusEnum(Integer code, String message) {
        this.code = code;
        this.msg = message;
    }

    public int getCode() {
        return code;
    }
    public String getMessage() {
        return msg;
    }
}

```

---


## 2. 创建自定义异常类

```java
package com.example.demo2.v1.dto.exception;

import com.example.demo2.v1.dto.RHttpStatusEnum;

/**
 * 自定义异常类
 */
public class DiariesException extends RuntimeException {
    private static final long serialVersionUID = 132719492029L;

    private RHttpStatusEnum rHttpStatusEnum;

    public DiariesException(RHttpStatusEnum rHttpStatusEnum) {
        super("errorCode："+rHttpStatusEnum.getCode()+"; errorMsg："+ rHttpStatusEnum.getMessage());
        this.rHttpStatusEnum = rHttpStatusEnum;
    }

    public RHttpStatusEnum getrHttpStatusEnum() {
        return rHttpStatusEnum;
    }
}
```

---

## 3. 创建统一返回格式类

```java
package com.example.demo2.v1.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

/**
 * REST API 返回结果
 * @author hjxstart
 * @since 2021/8/1
 */

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class R {

    /**
     * 标识返回状态
     */
    private Integer code;

    /**
     * 返回的成功或失败的一个消息
     */
    private  String msg;

    /**
     * 返回的数据类型，为什么用Ojbect,因为在开发中返回的结构的数据类型是不确定的
     * 后续可以考虑使用：泛型来解决
     */
    private Object data;

    /**
     * 自定义构造函数
     */
    private R(Integer code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    /**
     * 成功返回无数据
     */
    public static R ok() {
        return new R(RHttpStatusEnum.SUCCESS.getCode(), RHttpStatusEnum.SUCCESS.getMessage(), "");
    }

    /**
     * 成功返回带数据
     */
    public static R ok(Object data) {
        return new R(RHttpStatusEnum.SUCCESS.getCode(), RHttpStatusEnum.SUCCESS.getMessage(), data);
    }

    /**
     * 失败返回无数据
     */
    public static R error(RHttpStatusEnum rHttpStatusEnum) {
        return new R(rHttpStatusEnum.getCode(), rHttpStatusEnum.getMessage());
    }

    /**
     * 失败返回带数据
     */
    public static R error(RHttpStatusEnum rHttpStatusEnum, Object data) {
        return new R(rHttpStatusEnum.getCode(), rHttpStatusEnum.getMessage(), data);
    }
}

```
---


## 4. 创建异常处理类

```java
package com.example.demo2.v1.dto;


import com.example.demo2.v1.dto.exception.DiariesException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Arrays;

/**
 * @author jxh
 */
@RestControllerAdvice("com.example.demo2.v1.controller")
public class ControllerExceptionAdvice {

    final static Logger LOG = LoggerFactory.getLogger(ControllerExceptionAdvice.class);

    @ExceptionHandler(DiariesException.class)
    public Object exceptionHandler(DiariesException e) {
        LOG.error("errorMsg：" + e.getMessage() + "，errorClass: " + Arrays.stream(e.getStackTrace()).findFirst() + "，errorTime: " + System.currentTimeMillis());
        return e;
    }

    @ExceptionHandler(Exception.class)
    public Object exceptionHandler(Exception e) {
        LOG.error("", e);
        return e;
    }
}

```

---


## 5. 创建统一返回格式处理类

```java
package com.example.demo2.v1.dto;

import com.example.demo2.v1.dto.exception.DiariesException;
import com.example.demo2.v1.util.JsonUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

/**
 * 对返回结果处理，统一返回格式。
 */
@Slf4j
@ControllerAdvice(basePackages = "com.example.demo2.v1")
public class ResultResponseHandler implements ResponseBodyAdvice<Object> {

    /**
     * 是否对返回结果进行处理
     * @param methodParameter 方法的参数
     * @param aClass 类
     * @return true
     */
    @Override
    public boolean supports(MethodParameter methodParameter, Class<? extends HttpMessageConverter<?>> aClass) {
        return true;
    }

    @Override
    public Object beforeBodyWrite(Object o, MethodParameter methodParameter, MediaType mediaType, Class<? extends HttpMessageConverter<?>> aClass, ServerHttpRequest serverHttpRequest, ServerHttpResponse serverHttpResponse) {

        /**
         * 日报异常返回处理
         */
        if (o instanceof DiariesException) {
            return R.error(((DiariesException) o).getrHttpStatusEnum(), "1" + System.currentTimeMillis());
        }
        /**
         * 通用异常返回类型
         */
        if (o instanceof Exception) {
            return R.error(RHttpStatusEnum.SERVER_ERROR);
        }
        /**
         * 因为如果返回是string的话默认会调用string的处理器直接返回，所以要进行处理
         */
        if (o instanceof String) {
            return JsonUtil.obj2String(R.ok(o));
        }
        /**
         * 正常返回
         */
        return R.ok(o);
    }
}
```

----

# 1. 统一返回格式

1. 定义枚举类型

```java
public enum RHttpStatusEnum {
    /**
     * 成功
     */
    SUCCESS(200, "success"),
    ERROR(-1, "error");

    private final int code;
    private final String message;

    RHttpStatusEnum(Integer code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }
    public String getMessage() {
        return message;
    }
}
```

2. 定义 dto

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
public class R{

    /**
     * 标识返回状态
     */
    private Integer code;
    /**
     * 返回的成功或失败的一个消息
     */
    private  String message;

    /**
     * 返回的数据类型，为什么用Ojbect,因为在开发中返回的结构的数据类型是不确定的
     * 后续可以考虑使用：泛型来解决
     */
    private Object data;

    /**
     * 成功返回无数据
     */
    public static R ok() {
        return new R(RHttpStatusEnum.SUCCESS.getCode(), RHttpStatusEnum.SUCCESS.getMessage(), "");
    }

    /**
     * 成功返回带数据
     */
    public static R ok(Object data) {
        return new R(RHttpStatusEnum.SUCCESS.getCode(), RHttpStatusEnum.SUCCESS.getMessage(), data);
    }

    /**
     * 失败返回
     */
    public static R error(RHttpStatusEnum rHttpStatusEnum,Integer code) {
        return new R(rHttpStatusEnum.getCode(), rHttpStatusEnum.getMessage(), "");
    }
}
```

3. 定义全局处理

```java
/**
 * 对返回结果处理，统一返回格式。
 */
@ControllerAdvice(basePackages = "com.fh.java.internalsystemjava")
public class ResultResponseHandler implements ResponseBodyAdvice<Object> {
    /**
     * 是否支持advice功能， true 是支持 false是不支持
     * @param methodParameter
     * @param aClass
     * @return
     */
    @Override
    public boolean supports(MethodParameter methodParameter, Class<? extends HttpMessageConverter<?>> aClass) {
        return true;
    }

    /**
     *
     * @param o controller方法的返回值
     * @param methodParameter
     * @param mediaType
     * @param aClass
     * @param serverHttpRequest
     * @param serverHttpResponse
     * @return
     */
    @Override
    public Object beforeBodyWrite(Object o, MethodParameter methodParameter, MediaType mediaType, Class<? extends HttpMessageConverter<?>> aClass, ServerHttpRequest serverHttpRequest, ServerHttpResponse serverHttpResponse) {
        /**
         * 因为如果返回是string的话默认会调用string的处理器直接返回，所以要进行处理
         */
        if (o instanceof String) {
            return JsonUtil.obj2String(R.ok(o));
        }
        return R.ok(o);
    }
}
```

4. 只要在controller返回正常的数据即可。全局处理会自动加上code和messgae.


---

## 2. 全局异常处理
