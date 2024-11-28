# harmony_fluwx 集成微信服务（2）

fluwx 链接：https://gitee.com/almost777/fluwx



## 接入功能

- 分享图片，文本，音乐，视频等。支持分享到会话，朋友圈以及收藏.
- 微信支付.
- 在微信登录时，获取Auth Code.
- 拉起小程序.
- 订阅消息.
- 打开微信.
- 从微信标签打开应用


####  初始化


注册 WxAPI

    registerWxApi(appId: "wxd930ea5d5a228f5f",universalLink: "https://your.univerallink.com/link/");

## 登录

`sendWeChatAuth`的目的是为了获取code，拿到了code才能进行微信登录，可以通过[官方文档](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/WeChat_Login/Development_Guide.html)查看具体流程。

    
     sendWeChatAuth(scope: "snsapi_userinfo", state: "wechat_sdk_demo_test");
    

> 为什么不支持获取用户信息？获取用户信息应该后端来做，即使没有后端，你也可以在dart层自己实现.

## 从H5启动app
Fluwx 支持从`<wx-open-launch-app>`启动你的app, 并且支持传递`extInfo`给你的app.
对于Android来说,你要在`AndroidManifest.xml`中给你的`Activity`加上一个标签:

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


与此同时，你还需要在需要在application中加上`<meta-data>`,把你的appId放进去:

    
    <meta-data
    android:name="weChatAppId"
    android:value="12345678" />



如果你想把`extInfo`传给Flutter, 你要在`MainActivity`加上如下代码:

      override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    //If you didn't configure WxAPI, add the following code
    WXAPiHandler.setupWxApi("wxd930ea5d5a258f4f",this)
    //Get Ext-Info from Intent.
    FluwxRequestHandler.handleRequestInfoFromIntent(intent)
    }

如果你想自定义你的调用逻辑, 你需要在application中加上`<meta-data>`:

    <meta-data
    android:name="handleWeChatRequestByFluwx"
    android:value="false" />

然后, 自己实现 `FluwxRequestHandler.customOnReqDelegate`.

## 兼容Android 11
请在你的应用的`AndroidManifest.xml`中添加以下queries:

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


## IOS
请在你的`AppDelegate`中主动注册`WXApi`
    
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //向微信注册
    [[FluwxDelegate defaultManager] registerWxAPI:@"" universalLink:@""];
    return YES;
    }


> 如你想主动获取从网页传进来的值 ，请主动调用`fluwx.getExtMsg()`。









