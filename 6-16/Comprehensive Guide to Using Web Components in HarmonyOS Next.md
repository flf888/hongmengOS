
# Comprehensive Guide to Using Web Components in HarmonyOS Next

The Web component in HarmonyOS Next provides developers with powerful webpage display capabilities, offering diverse usage methods that cover everything from basic loading to various functional settings.

### 1. Basic Usage
- **Creating a Web Component**: Create via the `Web` interface, e.g., `Web({src: 'www.example.com', controller: this.controller})`, where `src` specifies the webpage resource address, and `controller` controls the Web component. For online webpages, directly pass the target URL.
- **Using the Controller**: Starting from API Version 9, it is recommended to use `WebviewController`. Create a `WebviewController` instance during component construction to manage Web component operations like loading and refreshing.

### 2. Loading Different Types of Webpages
- **Online Webpages**: Pass the online webpage address directly to the `src` attribute of the `Web` component, e.g., `Web({src: 'www.example.com', controller: this.controller})`.
- **Local Webpages**:
  - **Via `$rawfile`**: Suitable for loading local resource files, e.g., `Web({src: $rawfile("index.html"), controller: this.controller})`.
  - **Via `resource` protocol**: Suitable for loading links with "#" routing, e.g., `Web({src: "resource://rawfile/index.html", controller: this.controller})`.
  - **Loading Local Resources in Sandbox Path**: First obtain the sandbox path via `GlobalContext`, then construct the file path for loading, e.g., 
    ```typescript
    let url = 'file://' + GlobalContext.getContext().getObject("filesDir") + '/index.html'; 
    Web({src: url, controller: this.controller})
    ```

### 3. Incognito Mode and Rendering Mode
- **Incognito Mode**: Set `incognitoMode` to `true` in the `Web` component to create an incognito-mode webview, e.g., `Web({src: 'www.example.com', controller: this.controller, incognitoMode: true})`.
- **Rendering Mode**: Starting from API Version 12, set the rendering method via the `renderMode` property. `RenderMode.ASYNC_RENDER` indicates self-rendering (default), and `RenderMode.SYNC_RENDER` indicates support for unified rendering capability, e.g., `Web({src: 'www.example.com', controller: this.controller, renderMode: RenderMode.SYNC_RENDER})`.

### 4. Shared Rendering Process
Set the `sharedRenderProcessToken` property. Web components with the same token will prioritize reusing the bound rendering process, e.g., `Web({src: 'www.example.com', controller: this.controller, sharedRenderProcessToken: "111"})`.

### 5. Permission Settings
- **DOM Storage API Permission**: Set using `domStorageAccess`. Disabled by default, e.g., `Web({src: 'www.example.com', controller: this.controller}).domStorageAccess(true)`.
- **File System Access Permission**: Set via `fileAccess`. Disabled by default starting from API Version 12, e.g., `Web({src: 'www.example.com', controller: this.controller}).fileAccess(true)`.
- **Image Resource Auto-load Permission**: Set using `imageAccess`. Allows auto-loading of images by default, e.g., `Web({src: 'www.example.com', controller: this.controller}).imageAccess(true)`.

### 6. JavaScript Object Injection
Inject JavaScript objects into the window object via `javaScriptProxy` for calling in webpages, e.g.:
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

### 7. Other Properties and Methods
The Web component also supports various universal properties (e.g., `aspectRatio`, `backgroundColor`) for styling and layout. It provides methods like `loadUrl` and `refresh` (some marked as deprecated) for dynamic operations. Developers must consider compatibility and version-specific changes (e.g., default property values altered in newer versions, deprecated methods replaced by newer ones) when using these features.

The Web component in HarmonyOS Next delivers comprehensive and flexible webpage handling capabilities. Developers can precisely configure and control its behavior to implement rich in-app webpage display and interaction functionalities based on specific requirements.
