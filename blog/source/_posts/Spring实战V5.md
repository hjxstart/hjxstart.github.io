---
title: Spring实战(第五版)
categories: 读书
tags:
  - Java
  - Spring
date: 2021-06-02 09:42:37
---

## 构建Spring步骤

1. 使用 Spring Initializr 创建初始的项目结构；

2. 编写控制器类处理针对主页的请求；

```Java
package tacos;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {
    @GetMapping("/")
    public String home() {
        return "home";
    }
}
```

3. 定义一个视图模版来渲染主页；

```Java
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Taco Cloud</title>
</head>
<body>
  <h1>Welcome to...</h1>
  <img th:src="@{/images/TacoCloud.png}" />
</body>
</html>
```

4. 编写了一个简单的测试类来验证工作符合预期。

```Java
package tacos;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;

@RunWith(SpringRunner.class)
@WebMvcTest(HomeController.class)   // <1>
public class HomeControllerTest {
    @Autowired
    private MockMvc mockMvc;   // <2>
    @Test
    public void testHomePage() throws Exception {
        mockMvc.perform(get("/"))    // <3>
                .andExpect(status().isOk())  // <4>
                .andExpect(view().name("home"))  // <5>
                .andExpect(content().string(           // <6>
                        containsString("Welcome to...")));
    }
}
```
