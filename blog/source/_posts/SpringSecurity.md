---
title: SpringSecurity
categories: 后端
tags:
  - Java
  - Spring
date: 2021-07-19 20:58:25
---

### 第一章 dome

1. pom.xml

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
```

2. controller 

```
@RestController
@RequestMapping("/test")
public class TestController {

    @GetMapping("hello")
    public String hello() {
        return "hello security";
    }
}
```

3. 运行项目即可

---

### 第二章 概念

#### 2.1 过滤器

1. FilterSecurityInterceptor 方法级过滤器
2. ExceptionTranslationFilter 异常过滤器
3. UsernamePasswordAuthenticationFilter 对/login的post请求做拦截，校验表单中用户名，密码。


#### 2.2 过滤器加载

1. 加载过程：DelegatingFilterProxy -> initDelegate -> targetBeanName -> FilterChainProxy -> doFilterInternal -> List<Filter>(存放要加载的过滤器)

#### 2.3 两个重要接口

1. UserDetailsService 接口，查询数据接口

- 自定义一个类继承 UsernamePasswordAuthenticationFilter
- 重写 attemptAuthentication 方法，得到用户名和密码做校验，查数据库需要单独去写，就需要写到 UserDetailsService接口中。
- 重写 successfulAuthentication 方法，验证成功调用该方法
- 重写 unsuccessfulAuthentication 方法，验证失败调用该方法
- 自定义一个类实现 UserDetailsService接口，编写查询数据过程，返回User对象，这个User对象是安全框架提供的对象


2. PasswordEncoder 接口，对用户和密码加密的接口

---

### 第三章 认证和授权

#### 3.1 认证

#### 3.1.1 设置用户名和密码,三者选其一

1. 方法一：配置文件 application.properties

```properties
# 方式一：设置用户名和密码
spring.security.user.name=admin
spring.security.user.password=hadoop
```


2. 方式二：配置类 

```java
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        // 对密码加密接口，可以不加密
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        String passwd = passwordEncoder.encode("hadoop");
        // 设置用户名，密码，角色
        auth.inMemoryAuthentication().withUser("hjxstart").password(passwd).roles("");
    }

    /**
     * 加密需要用到 PasswordEncoder这个对象
     */
    @Bean
    PasswordEncoder passwd() {
        return new BCryptPasswordEncoder();
    }
}
```


3. 方式三：自定义编写实现类 UserDetailsService

- 第一步：创建一个配置类，设置使用那个 userDetailsService 实现类；
- 第二步：编写实现类，返回User对象，User对象有用户名密码和操作对象
- 代码
```java
@Service("userDetailsService") // 自定义Service名字
public class MyUserDetailsService implements UserDetailsService {

    @Autowired
    private UsersMapper usersMapper;

    @Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {
        /**
         * 1.1调用userMapper方法查询数据库，得到 用户名， 密码， 权限
         */
        // 根据用户名查询数据库
        QueryWrapper<Users> wrapper = new QueryWrapper<>();
        wrapper.eq("username", s);
        Users users = usersMapper.selectOne(wrapper);
        // 判断:数据库没有用户名，认证失败
        if (users == null) {
            throw new UsernameNotFoundException("用户名不存在！");
        }

        /**
         * 1.2 返回一个冲数据库查询出来的 User(用户名，密码，权限集合)对象
         */
        // 定义一个权限列表
        List<GrantedAuthority> auths = AuthorityUtils.commaSeparatedStringToAuthorityList("role");
        return new User(users.getUsername(), new BCryptPasswordEncoder().encode(users.getPassword()), auths);
    }
}
```


#### 3.2 授权

---

### 第四章 


#### 4.1 自定义登录页面 & 不需要认证也可以访问

1. 自定义 config

```java
@Configuration
public class SecurityConfigTest extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 登录页面设置.登录访问路径(Controller).登录成功之后跳着的路径
        http.formLogin().loginPage("/login.html").loginProcessingUrl("/user/login").defaultSuccessUrl("/test/index").permitAll()
                // 那些路径需要认证，那些不需要认证才可以访问.访问这些路径可以直接访问不需要认证
                .and().authorizeRequests().antMatchers("/", "/test/hello", "/user/login").permitAll()
                // 所有请求都可以访问.关闭csrf防护
                .anyRequest().authenticated().and().csrf().disable();
    }
}

```

2. static目录下有login.html


#### 4.2 基于角色或权限进行访问控制 

1. hasAuthority 方法(单role控制，多个角色就不行)
- 如果当前的主体具有指定的权限，则返回 true, 否则返回 false
- 步骤一：在配置类设置当前访问地址有那些权限

```java
@Configuration
public class SecurityConfigTest extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        // 登录页面设置.登录访问路径(Controller).登录成功之后跳着的路径
        http.formLogin().loginPage("/login.html").loginProcessingUrl("/user/login").defaultSuccessUrl("/test/index").permitAll()
                // 那些路径需要认证，那些不需要认证才可以访问.访问这些路径可以直接访问不需要认证
                .and().authorizeRequests()
                    .antMatchers("/", "/test/hello", "/user/login").permitAll()

                    // 当前登录用户，只有具有 admins 权限才可以访问这个路径
                    .antMatchers("/test/index").hasAuthority("admins")

                    // 所有请求都可以访问.关闭csrf防护
                    .anyRequest().authenticated()
                .and().csrf().disable();
    }
}

```

- 步骤二：在UserDetailsService,把返回User对象设置权限

```java
@Service("userDetailsService") // 自定义Service名字
public class MyUserDetailsService implements UserDetailsService {

    @Autowired
    private UsersMapper usersMapper;

    @Override
    public UserDetails loadUserByUsername(String s) throws UsernameNotFoundException {
        /**
         * 1.1调用userMapper方法查询数据库，得到 用户名， 密码， 权限
         */
        // 根据用户名查询数据库
        QueryWrapper<Users> wrapper = new QueryWrapper<>();
        wrapper.eq("username", s);
        Users users = usersMapper.selectOne(wrapper);
        // 判断:数据库没有用户名，认证失败
        if (users == null) {
            throw new UsernameNotFoundException("用户名不存在！");
        }

        /**
         * 1.2 返回一个从数据库查询出来的 User(用户名，密码，权限集合)对象
         */
        // 定义一个权限列表
        List<GrantedAuthority> auths = AuthorityUtils.commaSeparatedStringToAuthorityList("admins，ROLE_sale");
        return new User(users.getUsername(), new BCryptPasswordEncoder().encode(users.getPassword()), auths);
    }
}
```

- 没有访问权限提示:(type=Forbidden,status=403)

2. hasAnyAuthority 方法 (多权限，多角色空)

- 如果当前的主体有任何提供的角色(给定的作为一个逗号的字符串列表)的话，返回true
- 步骤一
```java
// Configuration
.antMatchers("/test/index").hasAnyAuthority("admins,manager")
```

- 步骤二

```java
// Service
 List<GrantedAuthority> auths = AuthorityUtils.commaSeparatedStringToAuthorityList("admins");
```

3. hasRole 方法

- 如果当前祖逖具有指定的角色，则返回true, 否则出现403
- 步骤一

```java
// Configuration
.antMatchers("/test/index").hasRole("sale")
```

- 步骤二

```java
// Service //以ROLE_XXXXX
List<GrantedAuthority> auths = AuthorityUtils.commaSeparatedStringToAuthorityList("admins，ROLE_sale");
```

4. hasAnyRole 方法

- 表示用户具备任何一个条件都可以访问

- 修改配置文件

```java
// 角色权限控制方法四：hasAnyRole
.antMatchers("/test/index").hasAnyRole("admins,sale")
```

- 给用户添加角色

```java
// 定义一个权限列表
List<GrantedAuthority> auths = AuthorityUtils.commaSeparatedStringToAuthorityList("ROLE_admins,ROLE_sale");
return new User(users.getUsername(), new BCryptPasswordEncoder().encode(users.getPassword()), auths);
```

### 第五章

#### 5.1 自定义403没有权限访问页面

1. 在配置类进行配置就可以了

```java
// 配置没有权限访问跳转自定义页面
        http.exceptionHandling().accessDeniedPage("/unauth.html");
```

### 第六章 方法常用注解使用

#### 6.1 @EnableGlobalMethodSecurity(securedEnabled = true, prePostEnable=true)

1. 使用注解先要在启动类里面开启注解功能！

#### 6.2 @Secured 用户具有某个角色，可以访问方法

1. 步骤一：在启动类(配置类)开启注解 @EnableGlobalMethodSecurity(securedEnabled = true)


2. 步骤二：在controller的方法上面使用注解，设置角色

```java
    @Secured({"ROLE_sale", "ROLE_manager"})
    @GetMapping("update")
    public String update() {
        return "hello update";
    }
```
3. 步骤三：在config添加角色

```java
List<GrantedAuthority> auths = AuthorityUtils.commaSeparatedStringToAuthorityList("ROLE_admins,ROLE_sale");
```

#### 6.3 @PreAuthorize 方法执行前

1. @PreAuthorize 注解适合进入方法前的权限验证；

2. 步骤一：在启动类(配置类)开启注解

```java
@EnableGlobalMethodSecurity(securedEnabled = true, prePostEnabled = true)
```

3. 步骤二：在方法添加注解 @preAuthorize

```java
    @GetMapping("update")
    //@Secured({"ROLE_sale","ROLE_manager"})
    @PreAuthorize("hasAnyAuthority('admins')")
    public String update() {
        return "hello update";
    }
```


#### 6.4 @PostAuthorize 方法执行后,返回值

1. @PostAuthorize 在方法执行完后验证
2. 步骤一：在启动类(配置类)添加注解

```java
@EnableGlobalMethodSecurity(securedEnabled = true, prePostEnabled = true)
```

3. 步骤二：在方法添加注解

```java

    @GetMapping("update")
    //@Secured({"ROLE_sale","ROLE_manager"})
    //@PreAuthorize("hasAnyAuthority('admins')")
    //@PostAuthorize("hasAnyAuthority('admins')") // 没有权限也可以执行方法
    public String update() {
        System.out.println("update.........");
        return "hello update";
    }
```



#### 6.5 @PostFilter 对方法返回数据进行过滤

1. @PostFilter 权限验证之后对数据进行过滤，留下用户名是admin1的数据
2. controller

```java
    @GetMapping("getAll")
    @PreAuthorize("hasAnyAuthority('admins')")
    @PostFilter("filterObject.username == 'admin1'") // 对返回对象的username进行过滤
    public List<Users> getAllUser() {
        ArrayList<Users> list = new ArrayList<>();
        list.add(new Users(11, "admin1", "hadoop"));
        list.add(new Users(21, "admin2", "hadoop"));
        System.out.println(list);
        return list;
    }
```

#### 6.6 @PreFilter 对 方法传入的参数做过滤

1. @PreFilter 进入控制器之前对数据进行过滤
2. 在controller中

```java

    @RequestMapping("getTestPreFilter")
    @PreAuthorize("hasRole('ROLE_admins')")
    @PreFilter(value = "filterObject.id%2==0")
    @ResponseBody
    public List<Users> getTestPreFilter(@RequestBody List<Users> list) {
        list.forEach(t -> {
            System.out.println(t.getId() + "\t" + t.getUsername());
        });
        return list;
    }
```

### 第7章 用户注销

#### 用户注销

1. 在配置类中添加退出映射地址

```java
// 退出，注销配置, 退出地址，退出后的跳转地址
        http.logout().logoutUrl("/logout").logoutSuccessUrl("/test/hello").permitAll();
```

2. 在成功页面添加超链接，写设置退出路径 success.html

```html
<h3>登录成功！</h3>
<a href="/logout">退出</a>

```

3. 登录成功之后，在成功页面点击退出，再去访问其他controller不能进行访问的

```java
        http.formLogin()
                .loginPage("/login.html")
                .loginProcessingUrl("/user/login")
                .defaultSuccessUrl("/success.html").permitAll()
```

### 第8章 自动登录 RemeberMeService

#### 8.1 原理


#### 8.2 实现

1. 创建表(可选)
2. 配置类，注入数据源，配置操作数据库对象

```java
    /**
     * 自动登录第二步:2.1
     * @param auth
     * @throws Exception
     */
    @Autowired
    private DataSource dataSource;

    /**
     * 自动登录第二步:2.2
     * @return
     */
    @Bean
    public PersistentTokenRepository persistentTokenRepository() {
        JdbcTokenRepositoryImpl jdbcTokenRepository = new JdbcTokenRepositoryImpl();
        jdbcTokenRepository.setDataSource(dataSource);
        // 自动生成表,这样就不用自己创建表类
        jdbcTokenRepository.setCreateTableOnStartup(true);
        return jdbcTokenRepository;
    }
```

3. 配置类中，配置自动登录

```java
.and().rememberMe().tokenRepository(persistentTokenRepository())
                    // 设置有效时长
                    .tokenValiditySeconds(60)
                    // 使用userDetailsService对象对数据库的操作
                    .userDetailsService(userDetailsService)
```

4. 在登录页面添加复选框

```html
<input type="checkbox" name="remember-me">自动登录
<br/>
```

### 第九章 CSRF

#### 9.1

```java
<input type="hidden" th:name="${_csrf.parameterName}" th:value="${_csrf.token}"/>
```

#### 9.2 开启CSRF 防护
