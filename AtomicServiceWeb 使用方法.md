# HarmonyOS next之AtomicServiceWeb 使用方法全解析

### 一、整体概述

AtomicServiceWeb 是对 Web 组件的升级，用于在特定场景下实现更高效和功能丰富的网页交互。它在一些接口和属性的使用上与 Web 组件有所不同，需要开发者按照新的规范进行操作。

### 二、参数传递

1. 通过 src 传递参数

   - **适用场景**：例如在登录认证场景中，将元服务原生页面获取的登录参数传递给 H5 页面。

   - **传参格式**：在设置`src`属性时，将参数添加到 URL 中，如`src = `https://xx.com/login?authcode=${authcode}``，其中`authcode`是要传递的参数。

   - 示例代码

     ：

     - 在`login.ets`中：

```typescript
import { authentication } from '@kit.AccountKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
@Entry
@Component
struct LoginPage {
    @State authorizationCode: string = '';
    @State src: ResourceStr = 'resource://rawfile/login.html';
    @State controller: AtomicServiceWebController = new AtomicServiceWebController();
    navPathStack: NavPathStack = new NavPathStack();
    async getAuthorizationCode() {
        // 创建登录请求并获取授权码的逻辑
    }
    async aboutToAppear() {
        await this.getAuthorizationCode();
    }
    build() {
        NavDestination() {
            if (this.authorizationCode) {
                AtomicServiceWeb({
                    src: this.src + `?AuthorizationCode=${this.authorizationCode}`,
                    navPathStack: this.navPathStack,
                    controller: this.controller
                })
            }
        }
           .onReady((context: NavDestinationContext) => {
                this.navPathStack = context.pathStack;
            })
    }
}
@Builder
export function AtomicServiceWebPageBuilder(name: string, param: Object) {
    LoginPage()
}
```

- 在`login.html`中，可以通过`window.location.href`获取 URL 中的参数：

```html
<!DOCTYPE html>
<html>
<style>
    body {
        padding-left: 30px;
    }
    h1 {
        font-size: 100px;
    }
   .button {
        font-size: 80px;
        margin: 8px 0px;
        padding: 8px 15px;
        border-radius: 10px;
        color: #fff;
        background-color: #007bff;
        border-color: #007bff;
        border: 1px solid transparent;
    }
   .button_error {
        color: #fff;
        background-color: #dc3545;
        border-color: #dc3545;
    }
</style>
<body>
<h1>H5 Page</h1>
<br/>
<button type="button" class="button" onclick="getUrlParams()">获取AuthorizationCode参数</button>
<p id="demo"></p>
<script src="../dist/asweb-sdk.umd.js"></script>
<script>
    function getUrlParams() {
        const params = {};
        const url = window.location.href;
        const urlObj = new URL(url);
        for (const [key, value] of urlObj.searchParams.entries()) {
            params[key] = value;
            document.getElementById("demo").innerHTML = params[key];
        }
        return params;
    }
</script>
</body>
</html>
```

1. 通过路由传参

   - **适用场景**：常见于 H5 跳转原生页面实现账号关联、调用原生实名认证等能力时传递参数。

   - **传参格式**：使用`has.router.pushPath('LoginPage','xxxxx')`，其中`LoginPage`是目标页面，`xxxxx`是要传递的参数。

   - 示例代码

     ：

     - 在`login.html`中：

```html
<!DOCTYPE html>
<html>
<meta charset="utf-8">
<style>
    body {
        padding-left: 30px;
    }
    h1 {
        font-size: 100px;
    }
   .button {
        font-size: 80px;
        margin: 8px 0px;
        padding: 8px 15px;
        border-radius: 10px;
        color: #fff;
        background-color: #007bff;
        border-color: #007bff;
        border: 1px solid transparent;
    }
   .button_error {
        color: #fff;
        background-color: #dc3545;
        border-color: #dc3545;
    }
</style>
<body>
<h1>H5 Page</h1>
<br/>
<button type="button" class="button" onclick="pushPath('LoginPage', 'xxxxx')">H5传递参数</button>
<p id="demo"></p>
<script src="../dist/asweb-sdk.umd.js"></script>
<script>
    function pushPath(name, param, animated, onPop) {
        has.navPathStack.pushPath({
            name: name,
            param: param,
            animated: animated,
            onPop: onPop,
            callback: (err, res) => commonCallback('pushPath', err, res)
        });
    }
    let onPop = event => {
        consoleLog('pushPath onPop event=' + JSON.stringify(event));
    };
</script>
</body>
</html>
```

- 在`LoginPage.ets`中接收参数：

```typescript
import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
@Entry
@Component
struct LoginPage {
    @State src: ResourceStr = 'resource://rawfile/login.html';
    @State param: object | string = '';
    @State controller: AtomicServiceWebController = new AtomicServiceWebController();
    navPathStack: NavPathStack = new NavPathStack();
    build() {
        NavDestination() {
            if (this.param) {
                Column() {
                    Text(`接收H5页面传递参数：${this.param}`)
                }
                   .width('100%')
            } else {
                AtomicServiceWeb({
                    src: this.src,
                    navPathStack: this.navPathStack,
                    controller: this.controller
                })
            }
        }
           .onReady((context: NavDestinationContext) => {
                this.navPathStack = context.pathStack;
                this.param = context.pathInfo?.param as string
            })
    }
}
@Builder
export function AtomicServiceWebPageBuilder(name: string, param: Object) {
    LoginPage()
}
```

- 在`MainPage.ets`中创建路由跳转：

```typescript
@Entry
@Component
struct MainPage {
    navPathStack: NavPathStack = new NavPathStack();
    @Builder
    NavPathStackComponent(name: string, page: string, param?: object): void {
        Button(name)
           .type(ButtonType.Capsule)
           .width('60%')
           .margin({
                top: '50px'
            }).onClick(() => {
            this.navPathStack.pushPath({
                name: page,
                param: param
            });
        })
    }
    build() {
        Navigation(this.navPathStack) {
            Row() {
                Column() {
                    this.NavPathStackComponent('LoginPage', 'LoginPage')
                }.width('100%')
            }.height('100%')
        }.title('XXX')
    }
}
```

同时需要在`route_map.json`中添加对应路由：

```json
{
    "name": "LoginPage",
    "pageSourceFile": "src/main/ets/pages/LoginPage.ets",
    "buildFunction": "AtomicServiceWebPageBuilder",
    "data": {
        "description": "this is LoginPage"
    }
}
```

### 三、常用接口 / 属性迁移

1. controller
   - **使用说明**：使用`AtomicServiceWebController`替换原来的控制器。
   - **示例代码**：

```typescript
import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
@Entry
@Component
struct WebComponent {
    @State controller: AtomicServiceWebController = new AtomicServiceWebController();
    build() {
        Column() {
            AtomicServiceWeb({
                src: 'www.example.com',
                controller: this.controller
            })
        }
    }
}
```

1. javaScriptAccess
   - **使用说明**：默认值为`true`，无需单独设置。
2. domStorageAccess
   - **使用说明**：默认值为`true`，无需单独设置。
3. mixedMode
   - **使用说明**：可以设置为`MixedMode.All`等模式，示例如下：

```typescript
import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
@Entry
@Component
struct WebComponent {
    @State controller: AtomicServiceWebController = new AtomicServiceWebController();
    @State mixedMode: MixedMode = MixedMode.All;
    build() {
        Column() {
            AtomicServiceWeb({
                src: 'www.example.com',
                controller: this.controller,
                mixedMode: this.mixedMode
            })
        }
    }
}
```

1. darkMode
   - **使用说明**：可以设置为`WebDarkMode.On`等模式，示例如下：

```typescript
import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
@Entry
@Component
struct WebComponent {
    @State controller: AtomicServiceWebController = new AtomicServiceWebController();
    @State mode: WebDarkMode = WebDarkMode.On;
    build() {
        Column() {
            AtomicServiceWeb({
                src: 'www.example.com',
                controller: this.controller,
                darkMode: this.mode,
            })
        }
    }
}
```

1. forceDarkAccess
   - **使用说明**：设置为`true`或`false`来控制是否启用强制黑暗模式，示例如下：

```typescript
import { AtomicServiceWeb, AtomicServiceWebController } from '@kit.ArkUI';
@Entry
@Component
struct WebComponent {
    @State controller: AtomicServiceWebController = new AtomicServiceWebController();
    @State access: boolean = true;
    build() {
        Column() {
            AtomicServiceWeb({
                src: 'www.example.com',
                controller: this.controller,
                forceDarkAccess: this.access
            })
        }
    }
}
```

1. fileAccess
   - **使用说明**：在 AtomicServiceWeb 中默认值为`false`，仅只读资源目录`/data/storage/el1/bundle/entry/resources/resfile`里面的`file`协议资源可访问，`$rawfile(filepath/filename)`中`rawfile`路径的文件不受影响。升级后不再支持自定义该接口，需删除相关设置代码。
2. onlineImageAccess 和 imageAccess
   - **使用说明**：在 AtomicServiceWeb 中默认值为`True`，升级后不再支持自定义这两个接口，需删除相关设置代码。
3. geolocationAccess
   - **使用说明**：升级后不再支持该接口，在 H5 页面中可替换使用`has.location.getLocation()`。
