# 鸿蒙开发web组件开启深色模式与自定义 UserAgent



**设置深色模式**
ArkWeb 支持对前端页面进行深色模式配置。通过 darkMode() 接口可以配置不同的深色模式，默认关闭。当深色模式开启时，Web 将启用媒体查询 prefers-color-scheme 中网页所定义的深色样式，若网页未定义深色样式，则保持原状。

```typescript
@Entry
@Component
struct WebComponent {
  // ...
  @State mode: WebDarkMode = WebDarkMode.Auto;
  build() {
    Column() {
      // ...
      Web({
        // ...
        .darkMode(this.mode)
      })
    }
  }
}
```

通过 forceDarkAccess() 接口可将前端页面强制配置深色模式，强制深色模式无法保证所有颜色转换符合预期，且深色模式不跟随前端页面和系统。

```typescript
@Entry
@Component
struct WebComponent {
  // ...
  @State mode: WebDarkMode = WebDarkMode.On;
  @State access: boolean = true;
  build() {
    Column() {
      // ...
      Web({
        // ...
        .darkMode(this.mode)
        .forceDarkAccess(this.access)
      })
    }
  }
}
```

**设置 UserAgent**
从 API version 11 起，Web 组件基于 ArkWeb 的内核，默认 UserAgent 定义如下：

```typescript
Mozilla/5.0 ({deviceType}; {OSName} {OSVersion}) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 ArkWeb/{ArkWeb VersionCode} {Mobile}
```

建议通过 ArkWeb 关键字识别是否是 HarmonyOS 设备以及 web 内核是否为 ArkWeb，同时可以通过 deviceType 识别设备类型用于不同设备上的页面显示。

```typescript
@Entry
@Component
struct WebComponent {
  // ...
  build() {
    Column() {
      // ...
      Button('getUserAgent')
        .onClick(() => {
          try {
            let userAgent = this.controller.getUserAgent();
            console.log("userAgent: " + userAgent);
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      // ...
    }
  }
}
@Entry
@Component
struct WebComponent {
  // ...
  aboutToAppear(): void {
    webview.once('webInited', () => {
      try {
        // 应用侧用法示例，定制 UserAgent。
        this.ua = this.controller.getUserAgent() + 'xxx';
        this.controller.setCustomUserAgent(this.ua);
      } catch (error) {
        console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
      }
    });
  }
  build() {
    Column() {
      // ...
    }
  }
}
```

**使用隐私模式**
开发者在创建 Web 组件时，可以将可选参数 incognitoMode 设置为 'true'，来开启 Web 组件的隐私模式。当使用隐私模式时，浏览网页时的 cookies、 cache data 等数据不会保存在本地的持久化文件，当隐私模式的 Web 组件被销毁时，cookies、 cache data 等数据将不被记录下来。

```typescript
@Entry
@Component
struct WebComponent {
  // ...
  build() {
    Column() {
      // ...
      Web({
        // ...
        .incognitoMode(true)
      })
    }
  }
}
@Entry
@Component
struct WebComponent {
  // ...
  build() {
    Column() {
      // ...
      Button('isIncognitoMode')
        .onClick(() => {
          try {
            let result = this.controller.isIncognitoMode();
            console.log('isIncognitoMode' + result);
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      // ...
    }
  }
}
```

隐私模式提供了一系列接口，用于操作地理位置、Cookie 以及 Cache Data。

```typescript
@Entry
@Component
struct WebComponent {
  // ...
  build() {
    Column() {
      // ...
      Button('allowGeolocation')
        .onClick(() => {
          try {
            // allowGeolocation 第二个参数表示隐私模式（true）或非隐私模式（false）下，允许指定来源使用地理位置。
            webview.GeolocationPermissions.allowGeolocation(this.origin, true);
          } catch (error) {
            console.error(`ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          }
        })
      // ...
    }
  }
}
```

**使用运动和方向传感器**
Web 组件可以通过 W3C 标准协议接口对接运动和方向相关的传感器。开发者在使用该功能中的加速度、陀螺仪及设备运动事件接口时，需在配置文件中声明相应的传感器权限。

```typescript
@Entry
@Component
struct WebComponent {
  // ...
  aboutToAppear() {
    // ...
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.ACCELEROMETER', 'ohos.permission.GYROSCOPE'], (err: BusinessError, data: PermissionRequestResult) => {
        // ...
      });
    } catch (error) {
      // ...
    }
  }
  build() {
    Column() {
      // ...
      Web({
        // ...
        .onPermissionRequest((event) => {
          if (event) {
            // ...
          }
        })
        // ...
      })
    }
  }
}
```

**在新窗口中打开页面**
Web 组件提供了在新窗口打开页面的能力，开发者可以通过 multiWindowAccess() 接口来设置是否允许网页在新窗口打开。

```typescript
@Entry
@Component
struct WebComponent {
  // ...
  build() {
    Column() {
      // ...
      Button('createPort')
        .onClick(() => {
          try {
            // ...
          } catch (error) {
            // ...
          }
        })
      // ...
    }
  }
}
```