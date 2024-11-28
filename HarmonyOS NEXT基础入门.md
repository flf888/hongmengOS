## 基础入门

### 储存

鸿蒙应用提供多种数据存储方式，包括：

- **Preferences**：轻量级数据存储，适用于简单键值对。
- **SQLite**：关系型数据库，适用于结构化数据存储。
- **文件存储**：通过文件系统直接存储数据。

### 数组

数组是一组有序的数据集合，可以通过索引访问每个元素。

```javascript
let numbers = [1, 2, 3, 4, 5];
console.log(numbers[0]); // 输出 1
```

### 函数的使用与写法

函数是封装了一段代码，用于完成特定任务的独立单元。

```javascript
function greet(name) {
    return "Hello, " + name;
}
console.log(greet("Alice")); // 输出 Hello, Alice
```

#### 箭头函数

箭头函数提供了一种更简洁的函数写法。

```javascript
const greet = (name) => "Hello, " + name;
console.log(greet("Bob")); // 输出 Hello, Bob
```

### 接口

接口用于定义对象的行为，确保实现接口的类遵循特定的规范。

```typescript
interface Person {
    name: string;
    age: number;
    greet(): string;
}
 
class Employee implements Person {
    name: string;
    age: number;
    constructor(name: string, age: number) {
        this.name = name;
        this.age = age;
    }
    greet(): string {
        return "Hello, I am " + this.name;
    }
}
```

### 对象与对象方法

对象是属性和方法的集合。

```javascript
let person = {
    name: "Charlie",
    age: 30,
    greet: function() {
        return "Hello, " + this.name;
    }
};
console.log(person.greet()); // 输出 Hello, Charlie
```

### 联合类型

联合类型表示一个值可以是几种类型中的一种。

```typescript
let age: number | string;
age = 25;
age = "twenty-five";
```

### 枚举

枚举用于定义一组命名的常量。

```typescript
enum Direction {
    Up,
    Down,
    Left,
    Right
}
let direction: Direction = Direction.Up;
```

------

## 界面开发思路与布局

### 组件属性与方法

鸿蒙开发提供了丰富的UI组件，每个组件都有特定的属性和方法。

- **属性**：用于设置组件的外观和行为。
- **方法**：用于执行组件的操作。

### 文本颜色与文字溢出

- **文本颜色**：通过`text-color`属性设置。
- **文字溢出**：通过`text-overflow`属性控制，如`ellipsis`表示截断并显示省略号。

### 图片组件

使用`<image>`标签添加图片。

```html
html复制代码

<image src="path/to/image.png" width="100" height="100"></image>
```

### 输入框

使用`<input>`标签创建输入框。

```html
html复制代码

<input type="text" placeholder="Enter text here"></input>
```

### SVG图标

支持直接嵌入SVG代码或使用`<image>`标签加载SVG文件。

```html
<svg width="100" height="100">
    <circle cx="50" cy="50" r="40" stroke="black" stroke-width="3" fill="red" />
</svg>
```

### 布局元素

布局元素用于组织和管理UI组件的位置和大小。

#### 外边距

通过`margin`属性设置外边距。

```css
.container {
    margin: 10px;
}
```

#### 边框

通过`border`属性设置边框。

```css
.box {
    border: 1px solid black;
}
```

#### 特殊形状的圆角

通过`border-radius`属性设置圆角。

```css
.rounded {
    border-radius: 20px;
}
```

### 背景

- **属性**：可以设置背景颜色、图片等。
- **定位**：通过`background-position`属性设置背景图片的位置。
- **尺寸大小**：通过`background-size`属性设置背景图片的尺寸。

```css
.background {
    background-color: #f0f0f0;
    background-image: url('path/to/image.png');
    background-position: center;
    background-size: cover;
}
```

### 线性布局主轴对齐方式

线性布局（Linear Layout）可以通过`justify-content`和`align-items`属性控制主轴和交叉轴的对齐方式。

```css
.linear-layout {
    display: flex;
    justify-content: center; /* 主轴对齐方式：居中 */
    align-items: center;    /* 交叉轴对齐方式：居中 */
}
```