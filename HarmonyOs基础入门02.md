## 一、条件语句

### 1. if 分支语句

- **多分枝情况**：通过`if`、`else if`和`else`可以构建多分枝的条件判断。例如，判断一个数的大小范围：

```java
int num = 15;
if (num < 10) {
    System.out.println("小于 10");
} else if (num < 20) {
    System.out.println("在 10 到 20 之间");
} else {
    System.out.println("大于等于 20");
}
```

### 2. switch 多分枝

- 适用于多个等值情况的判断，如根据星期数输出相应信息：

```java
int day = 2;
switch (day) {
    case 1:
        System.out.println("星期一");
        break;
    case 2:
        System.out.println("星期二");
        break;
    // 其他情况...
    default:
        System.out.println("无效的星期数");
}
```

### 3. 三元条件表达式

- 语法为`条件?表达式 1:表达式 2`，例如求两个数中的较大值：

```java
int a = 5, b = 3;
int max = (a > b)? a : b;
System.out.println("较大值为：" + max);
```

## 二、循环语句 - while 语句

- 当条件为真时，循环执行代码块，如下是计算 1 到 10 的累加：

```java
int sum = 0, i = 1;
while (i <= 10) {
    sum += i;
    i++;
}
System.out.println("1 到 10 的累加和为：" + sum);
```

## 三、数据结构与渲染

### 1. 对象数组

- 可存储多个对象，如创建一个简单的`Student`对象数组：

```java
class Student {
    String name;
    int age;
}
Student[] students = new Student[3];
students[0] = new Student();
students[0].name = "张三";
students[0].age = 20;
```

### 2. forEach 渲染 Badge

```java
class Badge {
    String text;
    public void render() {
        System.out.println("渲染徽章：" + text);
    }
}
Badge[] badges = {new Badge(), new Badge()};
badges[0].text = "徽章 1";
badges[1].text = "徽章 2";
badges.forEach(Badge::render);
```

## 四、布局 - grid 布局（以下是类似 CSS 的示例代码，假设 HarmonyOS Next 有类似的布局概念）

```css
.container {
    display: grid;
    grid-template-columns: 100px 100px; /* 两列，每列宽 100px */
    grid-template-rows: 50px 50px; /* 两行，每行高 50px */
}
.item {
    background-color: lightblue;
    border: 1px solid gray;
}
```

## 五、编程特性

### 1. 条件渲染（以下是类似 JavaScript 的示例代码，用于说明原理）

```html
<!DOCTYPE html>
<html>

<body>

    <div id="app">
        <!-- 根据条件渲染不同内容 -->
        <p v-if="showMessage">这是一条根据条件显示的消息。</p>
    </div>

    <script>
        var app = new Vue({
            el: '#app',
            data: {
                showMessage: true
            }
        });
    </script>
</body>

</html>
```

### 2. 动态渲染（以下是类似 React 的示例代码，用于说明原理）

```jsx
import React, { useState } from 'react';
import ReactDOM from 'react-dom';

function App() {
    const [count, setCount] = useState(0);
    return (
        <div>
            <p>当前计数：{count}</p>
            <button onClick={() => setCount(count + 1)}>增加计数</button>
        </div>
    );
}

ReactDOM.render(<App />, document.getElementById('root'));
```

## 六、UI 相关

### 1. 遮罩（以下是类似 CSS 的代码示例）

```css
.mask {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5); /* 半透明黑色 */
    z-index: 999;
}
```

### 2. 显影（以下是类似 CSS 动画的示例，假设是元素逐渐显示效果）

```css
.fade-in {
    animation: fadeIn 2s ease-in-out;
}

@keyframes fadeIn {
    from {
        opacity: 0;
    }
    to {
        opacity: 1;
    }
}
```

### 3. swiper 轮播

- 实现图片或内容的循环切换展示，提高用户浏览体验。

## 七、样式 - @Extend@Styles@Builder 样式



- 用于定制组件样式，满足个性化 UI 设计需求。

## 八、容器 - 滚动容器



- 当内容超出容器大小时，提供滚动功能方便查看全部内容。