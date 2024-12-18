# 鸿蒙 next 中 Web 的使用全解析

鸿蒙 next 中的 Web 组件为开发者提供了强大的网页显示能力，其使用方式丰富多样，涵盖了从基础加载到多种功能设置的诸多方面。

### 1. 基本使用

- **创建 Web 组件**：通过`Web`接口创建，如`Web({src: 'www.example.com', controller: this.controller})`，其中`src`指定网页资源地址，`controller`用于控制 Web 组件。例如加载在线网页时，直接传入目标网址即可。
- **控制器的使用**：从 API Version 9 开始，建议使用`WebviewController`。在组件构建中创建`WebviewController`实例，用于管理 Web 组件的操作，如加载、刷新等。

### 2. 加载不同类型网页

- **在线网页**：在`Web`组件的`src`属性中直接传入在线网页地址，如`Web({src: 'www.example.com', controller: this.controller})`。
- 本地网页
  - ** 通过$rawfile方式**：适用于加载本地资源文件，如`Web({src: $rawfile("index.html"), controller: this.controller})\`。
  - **通过 resources 协议**：适用于加载带有 "#" 路由的链接，如`Web({src: "resource://rawfile/index.html", controller: this.controller})`。
  - **加载沙箱路径下的本地资源文件**：先通过`GlobalContext`获取沙箱路径，再构建文件路径进行加载，如`let url = 'file://' + GlobalContext.getContext().getObject("filesDir") + '/index.html'; Web({src: url, controller: this.controller})`。

### 3. 隐私模式与渲染模式

- **隐私模式**：在`Web`组件中设置`incognitoMode`为`true`，可创建隐私模式的 webview，如`Web({src: 'www.example.com', controller: this.controller, incognitoMode: true})`。
- **渲染模式**：从 API Version 12 开始，可通过`renderMode`属性设置渲染方式，`RenderMode.ASYNC_RENDER`表示自渲染（默认值），`RenderMode.SYNC_RENDER`表示支持统一渲染能力，如`Web({src: 'www.example.com', controller: this.controller, renderMode: RenderMode.SYNC_RENDER})`。

### 4. 共享渲染进程

通过设置`sharedRenderProcessToken`属性，相同 token 的 Web 组件会优先尝试复用绑定的渲染进程，如`Web({src: 'www.example.com', controller: this.controller, sharedRenderProcessToken: "111"})`。

### 5. 权限设置

- **文档对象模型存储接口（DOM Storage API）权限**：使用`domStorageAccess`方法设置，默认未开启，如`Web({src: 'www.example.com', controller: this.controller}).domStorageAccess(true)`。
- **应用中文件系统的访问权限**：通过`fileAccess`方法设置，从 API version 12 开始默认不启用，如`Web({src: 'www.example.com', controller: this.controller}).fileAccess(true)`。
- **图片资源自动加载权限**：使用`imageAccess`方法，默认允许自动加载图片，如`Web({src: 'www.example.com', controller: this.controller}).imageAccess(true)`。

### 6. JavaScript 对象注入

通过`javaScriptProxy`方法将 JavaScript 对象注入到 window 对象中，以便在网页中调用，如：

```typescript
class TestObj {
    test(data1: string, data2: string, data3: string): string {
        console.log("data1:" + data1);
        console.log("data2:" + data2);
        console.log("data3:" + data3);
        return "AceString";
    }
    asyncTest(data: string): void {
        console.log("async data:" + data);
    }
    toString(): void {
        console.log('toString' + "interface instead.");
    }
}
@Entry
@Component
struct WebComponent {
    controller: webview.WebviewController = new webview.WebviewController();
    testObj = new TestObj();
    build() {
        Column() {
            Web({src: 'www.example.com', controller: this.controller})
              .javaScriptAccess(true)
              .javaScriptProxy({
                    object: this.testObj,
                    name: "objName"
                });
        }
    }
}
```

### 7. 其他属性和方法

Web 组件还支持多种通用属性，如`aspectRatio`、`backgroundColor`等，用于设置组件的样式和布局。同时，也提供了诸如`loadUrl`、`refresh`等方法（部分已被标记为过时）用于动态操作 Web 组件。在使用过程中，需注意属性和方法的兼容性以及版本差异带来的变化。例如，某些属性在特定版本后默认值发生改变，或者某些方法被新的方法所替代，开发者需要根据实际情况进行选择和调整。

鸿蒙 next 中的 Web 组件提供了全面且灵活的网页处理能力，开发者可以根据具体需求，精确地配置和控制 Web 组件的行为，实现丰富多样的应用内网页展示和交互功能。