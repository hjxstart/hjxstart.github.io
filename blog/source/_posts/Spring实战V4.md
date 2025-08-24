---
title: Spring实战(第四版)
categories: 读书
tags:
date: 2021-04-25 18:38:03
---

## 1.装配Bean
1. 创建应用对象之间协作关系的行为通常称为装配(Wiring)，这也是依赖注入(DI)的本质。
2. Spring提供了三种主要的装配机制：在XML中进行显示配置；在Java中进行显示配置；隐式的bean发现机制和自动装配。

---

### 1.1自动装配Bean
#### 使用步骤
1. 使用（@Component）告知Spring要为这个类创建bean;
2. 使用（@Autowired）告知Spring要为这个类注入依赖;
3. 创建Config类，使用（@ComponentScan）自动扫描与配置类相同的包及其子包;
4. 也可以使用XML来启动组件自动扫描。
```XML
<context:component-scan base-package="包路径">
```
--- 

#### 为组件扫描的bean命名
1. Spring应用上下文中所有的bean都会给定一个ID。默认为类名的第一个字母变为小写，例如clasName;
2. 使用 @Component 自定义 bean ID（@Component("idName")）**推荐使用**;
3. 使用 @Named 自定义 bean ID（@Named("idName")）。

---

#### 设置组件扫描的基础包
1. 可以通过指定value来扫描特定的包，例如(@ComponentScan("package.name"));
2. 可以通过basePackage属性进行配置基础包，例如(@ComponentScan("base.package.name"))或者(@ComponentScan("package1", "package2"));

---

#### 通过为bean添加注解实现自动装配
自动装配就是让Spring自动满足bean依赖的一种方法，在满足依赖过程中，会在Spring应用上下文中寻找匹配某个bean需求的其他bean。为了声明要进行自动装配，可以使用@AutoWired 或 @Inject注解。
1. 应用范围：构造器、Setter方法;
2. 没有匹配的bean异常：可以设置@Autowired(required=false);
