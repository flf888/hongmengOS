# HarmonyOS next之鸿蒙开发：前端页面调用 ArkTS 函数全解析

## JavaScriptProxy：前端与 ArkTS 交互的桥梁

### （一）功能概述

JavaScriptProxy 是 ArkWeb 提供的强大机制，它就像一座桥梁，允许开发者将 ArkTS 对象注册到前端页面，进而实现在前端页面中无缝调用这些对象的函数。这一机制极大地拓展了鸿蒙应用开发中前端与应用侧的交互能力。

### （二）接口介绍

1. `javaScriptProxy()`接口
   - 在 Web 组件初始化阶段被调用，其主要作用是将指定对象注入到前端页面。此接口的调用时机较早，能够确保在页面加载初期就为前端提供必要的 ArkTS 对象支持。
2. `registerJavaScriptProxy()`接口
   - 在 Web 组件初始化完成后发挥作用，用于将对象注册到前端页面。它提供了一种在组件初始化后动态注册对象的方式，增加了应用的灵活性。

## 示例代码剖析：前端调用 ArkTS 函数实战

### （一）应用侧代码（ArkTS）解读

```typescript
import { webview } from '@kit.ArkWeb';
import { BusinessError } from '@kit.BasicServicesKit';

// 定义测试类testClass
class testClass {
  constructor() {}
  // 返回字符串的测试函数
  test(): string {
    return 'ArkTS Hello World!';
  }
  // 打印传入字符串的函数
  toString(param: string): void {
    console.log('Web Component toString' + param);
  }
}

// 定义Web组件
@Entry
@Component
struct WebComponent {
  webviewController: webview.WebviewController = new webview.WebviewController();
  // 声明并初始化需要注册到前端的testObj对象
  @State testObj: testClass = new testClass();

  build() {
    Column() {
      // 加载本地index.html页面的Web组件
      Web({ src: $rawfile('index.html'), controller: this.webviewController})
      // 使用javaScriptProxy接口将testObj对象注册到前端，设置相关属性
     .javaScriptProxy({
          object: this.testObj,
          name: "testObjName",
          methodList: ["test", "toString"],
          controller: this.webviewController,
          // 可选参数
          asyncMethodList: [],
          permission: '{"javascriptProxyPermission":{"urlPermissionList":[{"scheme":"resource","host":"rawfile","port":"","path":""},' +
                  '{"scheme":"e","host":"f","port":"g","path":"h"}],"methodList":[{"methodName":"test","urlPermissionList":' +
                  '[{"scheme":"https","host":"xxx.com","port":"","path":""},{"scheme":"resource","host":"rawfile","port":"","path":""}]},' +
                  '{"methodName":"test11","urlPermissionList":[{"scheme":"q","host":"r","port":"","path":"t"},' +
                  '{"scheme":"u","host":"v","port":"","path":""}]}]}}'
        })
    }
  }
}
```

### （二）前端页面代码（HTML）分析

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
<body>
<button type="button" onclick="callArkTS()">Click Me!</button>
<p id="demo"></p>
<script>
function callArkTS() {
    // 调用注册在前端的testObjName对象的test函数，并获取返回值
    let str = testObjName.test();
    document.getElementById("demo").innerHTML = str;
    console.info('ArkTS Hello World! :' + str);
    // 调用testObjName对象的toString函数，传入获取到的字符串
    testObjName.toString(str);
}
</script>
</body>
</html>
```

## 权限配置：守护应用安全防线

### （一）权限配置原理



在前端页面调用 ArkTS 函数的过程中，权限配置至关重要。它通过一个 JSON 字符串来定义，涵盖了对象级权限和方法级权限。对象级权限明确了哪些 URL 能够访问该对象的所有方法，而方法级权限则更加精细，指定了哪些 URL 可以访问对象的特定方法。这种细致的权限划分有助于有效防止恶意攻击，确保应用的安全性。

### （二）权限配置示例详解

```json
{
  "javascriptProxyPermission": {
"urlPermissionList": [
  {
    "scheme": "resource",    // 必须精确匹配，不能为空，用于指定资源类型
    "host": "rawfile",       // 必须精确匹配，不能为空，指定主机名
    "port": "",              // 精确匹配，为空时不检查端口
    "path": ""               // 前缀匹配，为空时不检查路径
  },
  {
    "scheme": "https",       // 精确匹配，不能为空
    "host": "xxx.com",       // 精确匹配，不能为空
    "port": "8080",          // 精确匹配，为空不检查
    "path": "a/b/c"          // 前缀匹配，为空不检查
  }
],
"methodList": [
  {
    "methodName": "test",
    "urlPermissionList": [   // 针对test方法的权限列表
      {
        "scheme": "https",   // 精确匹配，不能为空
        "host": "xxx.com",   // 精确匹配，不能为空
        "port": "",          // 精确匹配，为空不检查
        "path": ""           // 前缀匹配，为空不检查
      },
      {
        "scheme": "resource",// 精确匹配，不能为空
        "host": "rawfile",   // 精确匹配，不能为空
        "port": "",          // 精确匹配，为空不检查
        "path": ""           // 前缀匹配，为空不检查
      }
    ]
  },
  {
    "methodName": "test11",
    "urlPermissionList": [   // 针对test11方法的权限列表
      {
        "scheme": "q",       // 精确匹配，不能为空
        "host": "r",         // 精确匹配，不能为空
        "port": "",          // 精确匹配，为空不检查
        "path": "t"          // 前缀匹配，为空不检查
      },
      {
        "scheme": "u",       // 精确匹配，不能为空
        "host": "v",         // 精确匹配，不能为空
        "port": "",          // 精确匹配，为空不检查
        "path": ""           // 前缀匹配，为空不检查
      }
    ]
  }
]
  }
}
```

## 复杂类型传递：超越基础数据的交互

### （一）传递数组示例



在实际开发中，前端与 ArkTS 之间可能需要传递复杂数据类型。以下是传递数组的示例：

```typescript
class testClass {
  constructor() {}
  // 返回数字数组的函数
  test(): Array<number> {
    return [1, 2, 3, 4]
  }
  toString(param: string): void {
    console.log('Web Component toString' + param);
  }
}
```

### （二）传递对象示例



除了数组，对象的传递也十分常见：

```typescript
class student {
  name: string = '';
  age: string = '';
}

class testClass {
  constructor() {}
  // 返回student对象的函数
  test(): student {
    let st: student = { name: "jeck", age: "12" };
    return st;
  }
  toString(param: string): void {
    console.log('Web Component toString' + param);
  }
}
```

## Promise 场景：异步调用的解决方案

### （一）应用侧返回 Promise 示例



在异步操作场景下，JavaScriptProxy 同样表现出色。例如，以下是应用侧返回 Promise 的代码：

```typescript
class testClass {
  constructor() {}
  // 返回Promise的测试函数
  test(): Promise<string> {
    let p: Promise<string> = new Promise((resolve, reject) => {
      setTimeout(() => {
        console.log('执行完成');
        resolve('suc');
      }, 10000);
    });
    return p;
  }
  toString(param: string): void {
    console.log(" " + param);
  }
}
```

### （二）前端页面处理 Promise 示例



前端页面可以通过如下方式处理 Promise：

```javascript
function callArkTS() {
  testObjName.test().then((param)=>{testObjName.toString(param)}).catch((param)=>{testObjName.toString(param)})
}
```



综上所述，JavaScriptProxy 为鸿蒙开发中前端页面调用 ArkTS 函数提供了强大且灵活的支持。它不仅能够实现基础的函数调用，还在复杂类型传递和异步调用等方面表现优异，同时通过权限配置保障了应用的安全性，为开发者构建高效、安全的鸿蒙应用提供了有力保障。

提供一些具体的代码示例，展示如何在前端页面中调用ArkTS函数。

除了JavaScriptProxy，还有哪些方式可以实现前端与ArkTS的交互？

在实际开发中，使用前端调用ArkTS函数需要注意哪些问题？
