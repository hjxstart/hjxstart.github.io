---
title: Vue
categories: 开发
tags:
date: 2021-06-23 10:48:20
---

# 第一章 CDN开发上
## 1.1、开发环境介绍
```bash
$ node --version
v14.15.1
$ npm --version
7.17.0
$ vue --version
@vue/cli 4.5.13
```

---

## 1.2、CDN方式使用Vue
```html
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.js"></script>
```
---

## 1.3、vue-app的基本结构
### 1.3.1、HTML代码
```html
<div id="app">
  {{ message }}
</div>
```
### 1.3.2、JS代码
```js
var app = new Vue({
  el: '#app', // 将 Vue 应用会将其挂载到一个 DOM 元素上（#app）
  data: {
    message: 'Hello Vue!'
  }
})
```
---
### 1.4、好玩的Vue语法
#### 1.4.1、HTML代码
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <script src="https://cdn.jsdelivr.net/npm/vue@2.6.14/dist/vue.js"></script>
    <link rel="stylesheet" href="./styles.css" />
    <title>Vue CND</title>
</head>
<body>
    <div id="vue-bind">
        <p>hello {{ name }}</p> <!-- 绑定data中的数据 -->
        <p>{{ greet('night') }}</p> <!-- 绑定方法中返回的数据 -->
        <p v-html="websiteTag"></p> <!-- 绑定一个html标签 -->
        <p><input type="text" :value="name" /></p> <!-- 省略的绑定方式 -->
    </div>
    <div id="vue-events">
	<!-- click event -->
        <button @click="age++">add a year</button>
        <button v-on:click="age--">subtract a year</button>
        <button @dblclick="add(10)">add 10 year</button> <!-- 点击两次 -->
        <button v-on:dblclick="subtract(10)">subtract 10 year</button> <!-- 点击两次 -->
        <p>我的年龄是: {{ age }}</p>
        <!-- mousemove event -->
        <div id="canvas" @click="updateXY">{{x}}, {{y}}</div>
        <!-- 事件修饰符 -->
        <a @click.prevent="handleClick()" href="www.baidu.com">百度</a> <!-- 阻止默认事件 -->
    </div>
    <div id="vue-key">
        <label>姓名</label>
        <input type="text" v-on:keyup="logName" />
        <input type="text" v-on:keydown.enter="logName" /> <!-- 键盘按enter 触发-->
        <label>年龄</label>
        <input type="text" v-on:keyup="logAge" />
        <input type="text" v-on:keyup.alt.enter="logAge" /> <!-- 键盘同时按 alt 和 enter 触发 -->
    </div>
    <div id="vue-model">
        <!-- 双向数据绑定支持的标签 input, select, textarea。因为需要有输入输出才是双向数据绑定 -->
        <label>姓名</label>
        <input type="text" v-model.lazy="name" /><br/> <!-- .lazy懒加载 -->
        <span>输入的内容是: {{ name }}</span><br />
        <label>年龄</label>
        <input type="text" v-model="age" ><br/>
        <span>输入的年龄是: {{ age }}</span>
    </div>
    <div id="vue-ref">
        <!--  ref="name"绑定在元素中，在js中使用$refs.name可以访问该绑定的元素-->
        <label>姓名</label>
        <input type="text" ref="name" @keyup="getName" />
        <span>{{name}}</span>
        <label>年龄</label>
        <input type="text" ref="age" @keyup="getAge" />
        <span>{{age}}</span>
    </div>
</body>
<script src="./app.js"></script>
</html>
```
#### 1.4.2、JS代码
```js
// 实例化 vue 对象
new Vue({
    el: "#vue-app", // element
    data() {
        return {
            name: "hjxstart",
            wechat: 27732357,
            websiteTag: '<a href="https://www.taobao.com">taobao</a>'
        }
    },
    methods: {
        greet(time) {
            return `Good ${time} ${this.name}`;
        }
    },
})

new Vue({
    el: "#vue-events",
    data() {
        return {
            age: 30,
            x: 0,
            y: 0,
        };
    },
    methods: {
        add(inc) {
            this.age += inc;
        },
        subtract(dec) {
            this.age -= dec;
        },
        updateXY(event) {
            console.log(event);
            this.x = event.offsetX;
            this.y = event.offsetY;
        },
        handleClick() {
            alert("hello");
        }
    }
})

new Vue({
    el: "#vue-key",
    data() {
        return {
            
        }
    },
    methods: {
        logName() {
            console.log("正在输入名字");
        },
        logAge() {
            console.log("正在输入年龄");
        }
    }
})

new Vue({
    el: "#vue-model",
    data() {
        return {
            name: ' ',
            age: 32
        }
    },
    methods: {
        
    },
})

new Vue({
    el: "#vue-ref",
    data() {
        return {
            name: '',
            age: 32
        }
    },
    methods: {
        getName() {
            this.name = this.$refs.name.value;
        },
        getAge() {
            this.age = this.$refs.age.value;
        }
    },
})
```
1.4.3、Css代码
```css
#canvas {
  width: 600px;
  padding: 200px 20px;
  text-align: center;
  border: 1px solid #333;
}
```

---
# 第二章 CDN开发下
## 2.1、watch
**不建议生产环境使用，开发调试可以**。watch的用法如下
```js
new Vue({
    data() {
        return {
            name: '', // 1.需要在data中有声明
        }
    },
    watch: {
        name(val, ordVal) { // 2.在watch中的方法名为key_name;（新值，旧值）
        }
    }
})
```
---

## 2.2、computed
**用途：优化性能，用于计算频率高的场景，例如样式、搜索等**
1. 和watch、method的性能区别，computed只有在值发生变化的时候才触发。
2. computed的里面的每一个方法一定要有**return**。
3. computed的用法如下
```html
  <div id="vue-computed">
        <button @click="a++">Add to A </button>
        <button @click="b++">Add to B </button>
        <p>A - {{a}}</p>
        <p>B - {{b}}</p>
        <!-- methods -->
        <p>Age + A = {{addToA1()}}</p>
        <p>Age + B = {{addToB1()}}</p>
        <!-- computed, 因为是属性不可以加括号 -->
        <p>Age + A = {{ addToA2 }}</p>
        <p>Age + B = {{ addToB2 }}</p>
    </div>
```

```js
new Vue({
    el: "#vue-computed",
    data() {
        return {
            a: 0,
            b: 0,
            age: 18,
        }
    },
    methods: {
        addToA1() {
            console.log("addToA1");
            return this.age + this.a;
        },
        addToB1() {
            console.log("addToB1");
            return this.age + this.b;
        },
    },
    computed: {
        addToA2() {
            console.log("addToA2");
            return this.age + this.a;
        },
        addToB2() {
            console.log("addToB2");
            return this.age + this.b;
        },
    }
})
```
---

## 2.3、动态绑定Css
**使用computed动态绑定Css**
1. html代码
```html
    <div id="vue-css">
        <h1>动态绑定样式 两种方式</h1>
        <h2>示例1 属性绑定</h2>
        <div @click="mrChangeColor = !mrChangeColor" v-bind:class="{changeColor:mrChangeColor}">
            <span>Hello</span>
        </div>
        <h2>示例2 计算属性绑定</h2>
        <button @click="mrChangeColor = !mrChangeColor">ChangeColor</button>
        <button @click="changeLength = !changeLength">changeLength</button>
        <div  v-bind:class="compClasses">
            <span>Hello</span>
        </div>
    </div>
```
2. js代码
```js
new Vue({
    el: "#vue-css",
    data() {
        return {
            mrChangeColor: false,
            changeLength: false,
        }
    },
    computed: {
        compClasses() {
            return { changeColor: this.mrChangeColor, changeLength: this.changeLength }
        }
    }
})
```
3. css代码
```css
#vue-css span {
  background: red;
  display: inline-block;
  padding: 10px;
  color: #fff;
  margin: 10px 0;
}
#vue-css .changeColor span {
  background: green;
}
#vue-css .changeLength span:after {
  content: "hjxstart";
  margin-left: 10px;
}
```
---

## 2.4、if和show指令
**if调试内容是一行注释，show调试内容是标签并且有属性display: none**
1. 示例
```html
<div id="vue-if">
	<h1>v-if指令</h1>
        <button @click="error = !error">toggle</button>
        <button @click="success = !success">success</button>
        <p v-if="error">error:如果error=true，那么显示</p><!-- 调试不显示标签内容，只是一行注释 -->
        <p v-else-if="success">success: 如果error=false,success=true则显示</p>
        <p v-else>如果error和success都为假，那么显示</p>
        <h1>v-show指令</h1>
        <p v-show="error">网络连接错误 404</p><!-- 调试显示标签内容：display: none-->
        <p v-show="success">网络连接成功 200</p>
</div>
```

---
## 2.5、v-for指令
**遍历时，如果不需要外出容器，可以使用template标签作为遍历对象**
1. html代码
```html
<div id="vue-for"
	<template v-for="(character,index) in characters">
		<h6>index</h6>
		<p>character</p>
	</template>
</div>
```
2. js代码
```js
new Vue({
    el: "#vue-for",
    data() {
        return {
            characters: ["Vue", "Java", "MySQL", "Linux"],
        }
    },
})
```
---
## 2.6、注册全局组件

---
## 2.7、fetch请求

---
## 2.8、Axios请求

---
# 第三章 CLI脚手架

## 3.1、安装脚手架

---
## 3.2、组件属性传值和传引用

---
## 3.3、注册事件

---
## 3.4、生命函数钩子

---
## 3.5、slot插槽的使用

---
## 3.6、动态组件和缓存

---
# 第四章 路由+axios


# 饿了么app

## 1.环境搭建

### 2.项目创建步骤

1. 在当前路径下创建一个项目

```bash
# vue create .
```

2. 同意在当前文件夹下创建项目：y
3. 选择对应的版本：Manually select features
4. 空格选择要使用：choose vue version, Babel, Vuex, Router;
5. 回车选择2.X
6. 同意选择使用 Use history mode for router
7. 选择 package.json
8. 不保存：n
9. 调整一下项目文件的命名和位置：参考4.1项目说明
10. 项目启动命令：

```bash
npm run serve
```

### 3.功能实现过程

#### 3.1实现登陆模块


1. 创建 src/views/Login.vue, 代码如下所示

```vue
<template>
  <div class="login">
    Login
  </div>
</template>

<script>
export default {
  name: 'login',
  components: {
    
  }
}
</script>

<style>
.login {
    width: 100%;
    height: 100%;
    padding: 30px;
    box-sizing: border-box;
    background: #fff;
    text-align: center;
}
</style>
```

2. 设置当前路由 route.js 和 按需加载

```vue
{
    path: '/',
    name: 'Index',
    // component: Index
    component: () => import("./views/Index.vue")
  },
  {
    path: '/login',
    name: 'login',
    component: () => import("./views/Login.vue") // 按需加载
  }
```

3. 设置路由守卫，route.js

```vue
// 路由守卫
router.beforeEach((to, from, next) => {
  const isLogin = localStorage.ele_login ? true : false;
  if (to.path == '/login') {
    next();
  } else {
    // 是否在登陆状态下，如果是就正常跳转，否则返回到 login页面去
    isLogin ? next() : next("/login" )

  }
})

export default router
```

4.导入logo到 assets中，在 login中使用

```Vue
<template>
  <div class="login">
    <div class="logo">
        <img src="../assets/logo.jpeg" alt="my logo image">
    </div>
  </div>
</template>

<style>
.login {
    width: 100%;
    height: 100%;
    padding: 30px;
    box-sizing: border-box;
    background: #fff;
}
.logo {
    text-align: center;
}
.login img {
    width: 150px;
}
</style>
```

5.input组件封装，创建 components/InputGroup.vue

```vue
<template>
  <div class="text_group">
    <!-- 组件结构 -->

    <!-- 组件容器 -->
    <div class="input_group">
        <!-- 输入框， 获取输入框的值 -->
        <input 
          :type="type" 
          :name="name" 
          :placeholder="placeholder" 
          @input="$emit('input', $event.target.value)" 
        >
        <!-- 输入框后面的按钮， 绑定一个点击时间-->
        <button v-if="btnTitle" :disabled="disabled" @click="$emit('btnClick')">{{btnTitle}}</button>
        <!-- 错误提醒, error有值就显示错误信息 -->
        <div v-if="error" class="invalid-feedback">{{error}}</div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'inputGroup',
  props: { // 通过传入参数实现组件复用
      type: {
          type: String,
          default: "text"
      },
      value: String,
      placeholder: String, // 提示
      name: String,
      btnTitle: String, // 是否显示获取验证码按钮
      disabled: Boolean, // 判断是否可用状态
      error: String, // 错误提醒 
  },
  components: {
    
  }
}
</script>

<style scoped>
.input_group {
  border: 1px solid #ccc;
  border-radius: 4px;
  padding: 10px;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}
.input_group input {
  height: 100%;
  width: 60%;
  outline: none;
}
.input_group button {
  border: none;
  outline: none;
  background: #fff;
}
.input_group button[disabled] {
  color: #aaa;
}
.is-invalid {
  border: 1px solid red;
}
.invalid-feedback {
  color: red;
  padding-top: 5px;
}
</style>
```

6. 使用组件，在login.vue 的 script引用组件,在components{}注册组件，创建组件需要的data

```vue
<template>
  <div class="login">
    <div class="logo">
        <img src="../assets/logo.jpeg" alt="my logo image">
    </div>
    <!-- 手机号 -->
    <InputGroup type="number" v-model="phone" placeholder="手机号"
    :btnTitle="btnTitle" :disabled="disabled" :error="errors.phone"/>
    <!-- 验证码 -->
    <InputGroup type="number" v-model="verifyCode" placeholder="验证码"
    :error="errors.code"/>
    <!-- 用户服务协议 -->
    <div class="login_des">
      <p>
        新用户登陆即自动注册，表示已同意
        <span>《用户服务协议》</span>
      </p>
    </div>
    <!-- 登陆按钮 -->
    <div class="login_btn">
      <button>登录</button>
    </div>
  </div>
</template>

<script>
import InputGroup from "../components/InputGroup"
export default {
  name: 'login',
  data() {
    return {
      phone: "",
      verifyCode: "",
      errors: {}, // 有手机错误或者验证码错误
      btnTitle: "获取验证码",
      disabled: false
    }
  },
  components: {
    InputGroup
  }
}
</script>

<style>
.login {
    width: 100%;
    height: 100%;
    padding: 30px;
    box-sizing: border-box;
    background: #fff;
}
.logo {
    text-align: center;
}
.login img {
    width: 150px;
}

.login_des {
  color: #aaa;
  line-height: 22px;
}
.login_des span {
  color: #4d90fe;
}
.login_btn button {
  width: 100%;
  height: 40px;
  background-color: #48ca38;
  border-radius: 4px;
  color: white;
  font-size: 14px;
  border: none;
  outline: none;
}
</style>
```

### 4.其他说明

#### 4.1 调整项目文件的命名和位置

1. 删除 src/components/HelloWorld.Vue,
2. 删除 src/views/About.vue
3. 重命名并移动 src/store/index.js 为 src/store.js， 删除 src/store;
4. 重命名并移动 src/router/index.js 为 src/router.js， 删除 src/router;
5. 新建 public/css/reset.css, 拷贝 reset.css的代码过来，可以上网拷贝。
6. 修改 src/main.js 内容为

```Vue
import Vue from 'vue'
import App from './App.vue'
import router from './router.js'
import store from './store.js'

Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
```

7. 修改 router.js 的内容为

```Vue
import Vue from 'vue'
import VueRouter from 'vue-router'
import Index from './views/Index.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Index',
    component: Index
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
```

8. src/App.vue里面全部内容。

```Vue
<template>
  <div id="app">
    <router-view/>
  </div>
</template>
<script>
export default {
  name: 'App',
  components: { 
  }
}
</script> 
<style>
#app {
  width: 100%;
  height: 100%;
  font-size: 14px;
  background: #f1f1f1;
}
</style>
```

9. 重命名 src/views/Home.vue为Index.vue,修改其内容为

```Vue
<template>
  <div class="index">
    主页
  </div>
</template>
<script>
export default {
  name: 'Index',
  components: {  
  }
}
</script>
```

10. 在 public/index.html 引用 ./css/reset.css和修改部分内容

```html
<link rel="stylesheet" href="./css/reset.css">
    <style>
      html,body {
        width: 100%;
        height: 100%;
      }
    </style>
```