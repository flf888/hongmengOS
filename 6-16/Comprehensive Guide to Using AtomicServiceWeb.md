
# Comprehensive Guide to Using AtomicServiceWeb

### I. Overall Overview

AtomicServiceWeb is an enhanced version of the Web component designed to enable more efficient and feature-rich web interactions in specific scenarios. Its usage differs from the standard Web component in certain interfaces and properties, requiring developers to follow new specifications.

### II. Parameter Passing

1. **Passing Parameters via src**
   - **Use Case**: Passing login parameters obtained from native pages to H5 pages during authentication scenarios.
   - **Format**: Append parameters to the URL in the `src` property, e.g., `src = `https://xx.com/login?authcode=${authcode}``.
   - **Example**:
     - In `login.ets`:
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
        // Logic to create login request and obtain authorization code
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
     - In `login.html` (retrieving parameters):
```html
<!DOCTYPE html>
<html>
<style>/* Styles unchanged */</style>
<body>
<h1>H5 Page</h1>
<button onclick="getUrlParams()">Get AuthorizationCode</button>
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

2. **Passing Parameters via Routing**
   - **Use Case**: Passing parameters when H5 pages navigate to native pages (e.g., account linking, real-name authentication).
   - **Format**: Use `has.router.pushPath('LoginPage','xxxxx')` where `LoginPage` is the target page.
   - **Example**:
     - In `login.html` (sending parameters):
```html
<!DOCTYPE html>
<html>
<style>/* Styles unchanged */</style>
<body>
<h1>H5 Page</h1>
<button onclick="pushPath('LoginPage', 'xxxxx')">Pass Parameters</button>
<script src="../dist/asweb-sdk.umd.js"></script>
<script>
    function pushPath(name, param) {
        has.navPathStack.pushPath({
            name: name,
            param: param,
            callback: (err, res) => console.log('pushPath result')
        });
    }
</script>
</body>
</html>
```
     - In `LoginPage.ets` (receiving parameters):
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
                    Text(`Received parameters: ${this.param}`)
                }.width('100%')
            } else {
                AtomicServiceWeb({
                    src: this.src,
                    navPathStack: this.navPathStack,
                    controller: this.controller
                })
            }
        }.onReady((context: NavDestinationContext) => {
            this.navPathStack = context.pathStack;
            this.param = context.pathInfo?.param as string
        })
    }
}
```
     - Routing setup in `MainPage.ets`:
```typescript
@Entry
@Component
struct MainPage {
    navPathStack: NavPathStack = new NavPathStack();
    @Builder
    NavPathStackComponent(name: string, page: string, param?: object): void {
        Button(name).onClick(() => {
            this.navPathStack.pushPath({ name: page, param: param });
        })
    }
    build() {
        Navigation(this.navPathStack) {
            Column() {
                this.NavPathStackComponent('LoginPage', 'LoginPage')
            }
        }.title('XXX')
    }
}
```
     - Add route to `route_map.json`:
```json
{
    "name": "LoginPage",
    "pageSourceFile": "src/main/ets/pages/LoginPage.ets",
    "buildFunction": "AtomicServiceWebPageBuilder"
}
```

### III. Migration of Common Interfaces/Properties

1. **controller**
   - **Usage**: Replace with `AtomicServiceWebController`
   - **Example**:
```typescript
@State controller: AtomicServiceWebController = new AtomicServiceWebController();
```

2. **javaScriptAccess**
   - **Migration**: Default value is `true`, no need to explicitly set.

3. **domStorageAccess**
   - **Migration**: Default value is `true`, no need to explicitly set.

4. **mixedMode**
   - **Migration**: Can be set to modes like `MixedMode.All`
   - **Example**:
```typescript
@State mixedMode: MixedMode = MixedMode.All;
AtomicServiceWeb({ mixedMode: this.mixedMode })
```

5. **darkMode**
   - **Migration**: Can be set to modes like `WebDarkMode.On`
   - **Example**:
```typescript
@State mode: WebDarkMode = WebDarkMode.On;
AtomicServiceWeb({ darkMode: this.mode })
```

6. **forceDarkAccess**
   - **Migration**: Set `true`/`false` to control forced dark mode
   - **Example**:
```typescript
@State access: boolean = true;
AtomicServiceWeb({ forceDarkAccess: this.access })
```

7. **fileAccess**
   - **Migration**: 
     - Default value is `false` in AtomicServiceWeb
     - Only read access to `/data/storage/el1/bundle/entry/resources/resfile` via `file` protocol
     - `$rawfile()` paths remain unaffected
     - **Remove custom configuration code**

8. **onlineImageAccess & imageAccess**
   - **Migration**: 
     - Default value is `True` in AtomicServiceWeb
     - **Remove custom configuration code**

9. **geolocationAccess**
   - **Migration**: 
     - No longer supported
     - In H5 pages, use `has.location.getLocation()` instead

---

This translation maintains:
1. All technical terminology (AtomicServiceWeb, H5, ETS, etc.)
2. Exact code syntax and structure
3. Section hierarchy and numbering
4. Component names and API references
5. Natural technical English flow
6. Important warnings and migration instructions in bold
