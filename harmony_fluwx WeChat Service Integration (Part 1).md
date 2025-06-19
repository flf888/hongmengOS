# harmony_fluwx WeChat Service Integration (Part 1)

fluwx link: 

### Integrated Features

- Share images, text, music, videos (supports chats, moments, favorites)
- WeChat Pay
- Obtain Auth Code during WeChat login
- Launch Mini Programs
- Subscribe to messages
- Open WeChat
- Open app from WeChat tags

##### Initialization

Register WxAPI:

```
registerWxApi(appId: "wxd930ea5d5a228f5f", universalLink: "https://your.univerallink.com/link/");
```

### Fundamentals

##### WeChat Callbacks

Methods like `shareToWeChat` or `payWithWeChat` call the native SDK's `sendRequest` method. Their return values only indicate whether the request was sent successfully. To get actual results:

```
fluwx.weChatResponseEventHandler.listen((res) {
  if (res is fluwx.WeChatPaymentResponse) {
    // Handle payment response
  }
});
```

> Note: If `errCode = -1`, consult WeChat's official documentation as -1 can indicate various errors.

##### Images

Four built-in `WeChatImage` types:

```
WeChatImage.network(String source, {String suffix});
WeChatImage.file(File source, {String suffix = ".jpeg"});
WeChatImage.asset(String source, {String suffix});
WeChatImage.binary(Uint8List source, {String suffix = ".jpeg"});
```

- `suffix` has highest priority. If empty, fluwx tries to extract from file path
- Image size limit: 10MB for sharing
- `Fluwx` compresses images used as `thumbnail` or `hdImagePath`
- Recommended to pre-compress images yourself

##### Sharing

Basic sharing:

```
shareToWeChat(WeChatShareTextModel("source text", scene: WeChatScene.SESSION));
```

Share targets:

```
///[WeChatScene.SESSION] Chat
///[WeChatScene.TIMELINE] Moments
///[WeChatScene.FAVORITE] Favorites
enum WeChatScene { SESSION, TIMELINE, FAVORITE }
```

Supported share types:

- WeChatShareTextModel
- WeChatShareMiniProgramModel (limited to chats)
- WeChatShareImageModel
- WeChatShareMusicModel
- WeChatShareVideoModel
- WeChatShareWebPageModel
- WeChatShareFileModel

### Payment

Simple invocation (success requires proper configuration):

```
payWithWeChat(
  appId: result['appid'],
  partnerId: result['partnerid'],
  prepayId: result['prepayid'],
  packageValue: result['package'],
  nonceStr: result['noncestr'],
  timeStamp: result['timestamp'],
  sign: result['sign'],
);
```

### iOS Payment Setup

1. Configure `URL Schemes` in `ios/Runner/Info.plist`:

```
<key>CFBundleURLSchemes</key>
<array>
  <string>wx84cxxxxxx</string> <!-- Your AppID -->
</array>
```

1. Configure `LSApplicationQueriesSchemes`
2. Implementation:

```
await fluwx.registerWxApi(
  appId: "wx84cfexxxxxx",
  universalLink: "https://www.xxxx.cn/app/");

fluwx.payWithWeChat(...); // With payment parameters
```

### Android Payment Setup

1. Register app at [WeChat Open Platform](https://open.weixin.qq.com/cgi-bin/index?t=home/index&lang=zh_CN&token=f3443bb5b660c02dbbc86fb324adce3239e5ab22)
2. Generate app signature using [signature tool](https://developers.weixin.qq.com/doc/oplatform/Downloads/Android_Resource.html)
3. Implementation:

```
// Register
await fluwx.registerWxApi(
  appId: "wx84cxxxxxx",
  universalLink: "https://www.xxxx.cn/app/");

// Handle payment response
fluwx.weChatResponseEventHandler.listen((event) async {
  if (event.errCode == 0) {
    // Payment successful
  }
  // Close dialogs/popups
});
```
