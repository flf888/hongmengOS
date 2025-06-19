# harmony_fluwx: Integrating WeChat Services (Part 2)

fluwx GitHub Repository: https://gitee.com/almost777/fluwx

## Integrated Features

- Share images, text, music, videos, etc. Supports sharing to chats, moments, and favorites
- WeChat Pay
- Obtain Auth Code during WeChat login
- Launch Mini Programs
- Subscribe to messages
- Open WeChat directly
- Launch app from WeChat tags

#### Initialization

Register WxAPI:

    ```dart
    registerWxApi(appId: "wxd930ea5d5a228f5f", universalLink: "https://your.univerallink.com/link/");
    ```

## Login

The purpose of `sendWeChatAuth` is to obtain the authorization code (code) required for WeChat login. Refer to the [official documentation](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html) for the complete workflow.

    ```dart
    sendWeChatAuth(scope: "snsapi_userinfo", state: "wechat_sdk_demo_test");
    ```

> Why isn't user information retrieval supported?  
> User information retrieval should be handled by the backend. Even without a backend, you can implement this functionality directly in your Dart code.

## Launching App from H5
Fluwx supports launching your app from `<wx-open-launch-app>` tags in H5 pages, with support for passing `extInfo` to your app.

**For Android:** Add the following intent filters to your `AndroidManifest.xml`:

    ```xml
    <intent-filter>
    <action android:name="${applicationId}.FlutterActivity" />
    <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
    
    <intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <data
    android:host="${applicationId}"
    android:path="/"
    android:scheme="wechatextmsg" />
    </intent-filter>
    ```

Additionally, add the following meta-data tag with your App ID:

    ```xml
    <meta-data
    android:name="weChatAppId"
    android:value="12345678" />
    ```

To pass `extInfo` to Flutter, add this code to your `MainActivity`:

    ```kotlin
    override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    // If you didn't configure WxAPI, add the following code
    WXAPiHandler.setupWxApi("wxd930ea5d5a258f4f", this)
    // Get Ext-Info from Intent
    FluwxRequestHandler.handleRequestInfoFromIntent(intent)
    }
    ```

For custom implementation logic, add this meta-data tag:
    
    ```xml
    <meta-data
    android:name="handleWeChatRequestByFluwx"
    android:value="false" />
    ```

Then implement your custom logic in `FluwxRequestHandler.customOnReqDelegate`.

## Android 11 Compatibility
Add the following queries to your app's `AndroidManifest.xml`:

    ```xml
    <queries>
    <intent>
    <action android:name="${applicationId}.FlutterActivity" />
    </intent>
    <intent>
    <action android:name="android.intent.action.VIEW" />
    <data
    android:host="${applicationId}"
    android:path="/"
    android:scheme="wechatextmsg" />
    </intent>
    </queries>
    ```

## iOS Implementation
In your `AppDelegate`, actively register `WXApi`:

    ```objective-c
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register with WeChat
    [[FluwxDelegate defaultManager] registerWxAPI:@"" universalLink:@""];
    return YES;
    }
    ```

> To actively retrieve values passed from web pages, call `fluwx.getExtMsg()` in your code.