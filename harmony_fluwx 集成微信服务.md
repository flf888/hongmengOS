# harmony_fluwx 集成微信服务

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

## 基础知识

### 微信回调

实际上，像`shareToWeChat` or `payWithWeChat`这种的函数，底层上是调用了原生SDK的`sendRequest`方法，所以他们的返回结果意义不大，他们的返回结果仅仅是`sendRequest`的返回值。
为了获取真实的回调，你应该这样做：


      fluwx.weChatResponseEventHandler.listen((res) {
    if (res is fluwx.WeChatPaymentResponse) {
      // do something here
    }
      });


> 笔记: 如果你的 `errCode = -1`, 那请阅读微信官方文档，因为-1的原因数不胜数.

### 图片

有四种内置 `WeChatImage`:


      WeChatImage.network(String source, {String suffix});
      WeChatImage.file(File source, {String suffix = ".jpeg"});
      WeChatImage.asset(String source, {String suffix});
      WeChatImage.binary(Uint8List source, {String suffix = ".jpeg"});


其中， `suffix` 优先级最高, 如果`suffix`是空白的，`fluwx` 将会尝试从文件路径中读取后缀.

在分享图片的功能，图片不能超过`10M`.如果图片被用作`thumbnail` 或 `hdImagePath`，`Fluwx` 会对 `WeChatImage` 进行压缩,  
否则不会压缩. 但是，最好还是自己压缩，因为不保证`fluwx`压缩效果。

## 分享
简单:
    
     shareToWeChat(WeChatShareTextModel("source text", scene: WeChatScene.SESSION));
绝大部分分享可以分享到会话，朋友圈，收藏（小程序目前只能分享到会话）。默认分享到会话。


    ///[WeChatScene.SESSION]会话
    ///[WeChatScene.TIMELINE]朋友圈
    ///[WeChatScene.FAVORITE]收藏
    enum WeChatScene {
      SESSION,
      TIMELINE,
      FAVORITE
      }


支持的分享各类:

- WeChatShareTextModel
- WeChatShareMiniProgramModel
- WeChatShareImageModel
- WeChatShareMusicModel
- WeChatShareVideoModel
- WeChatShareWebPageModel
- WeChatShareFileModel

## 支付

调用支付方法很简单，但想成功并不简单：


    payWithWeChat(
    appId: result['appid'],
    partnerId: result['partnerid'],
    prepayId: result['prepayid'],
    packageValue: result['package'],
    nonceStr: result['noncestr'],
    timeStamp: result['timestamp'],
    sign: result['sign'],
      );


## iOS 支付

* 配置`URL Schemes` ，内容为应用的`AppID`, 可以登录微信开放平台查看。编辑`ios/Runner/Info.plist`


      <key>CFBundleURLSchemes</key>
      <array>
    <string>wx84cxxxxxx</string>
      </array>


* 配置`LSApplicationQueriesSchemes`

  ![image-20210523140138835](https://syxoss.oss-cn-hangzhou.aliyuncs.com/Text/image-20210523140138835.png)

* 使用

  ```dart
  await fluwx.registerWxApi(
            appId: "wx84cfexxxxxx",
            universalLink: "https://www.xxxx.cn/app/");
  
  fluwx.payWithWeChat(
    appId: result['appid'],
    partnerId: result['partnerid'],
    prepayId: result['prepayid'],
    packageValue: result['package'],
    nonceStr: result['noncestr'],
    timeStamp: result['timestamp'],
    sign: result['sign'],
  )
  ```

  

## 安卓支付

* 登录[微信开放平台](https://open.weixin.qq.com/cgi-bin/index?t=home/index&lang=zh_CN&token=f3443bb5b660c02dbbc86fb324adce3239e5ab22),填写相关信息

![image-20210523132928727](https://syxoss.oss-cn-hangzhou.aliyuncs.com/Text/image-20210523132928727.png)

* 根据`应用包名`生成`应用签名` [点击这里下载应用签名工具](https://developers.weixin.qq.com/doc/oplatform/Downloads/Android_Resource.html), 安装好签名工具后，输入应用包名就可以生成应用签名了

![image-20210523133551034](https://syxoss.oss-cn-hangzhou.aliyuncs.com/Text/image-20210523133551034.png)


* 使用


      // 注册
      await fluwx.registerWxApi(
    appId: "wx84cxxxxxx",
    universalLink: "https://www.xxxx.cn/app/");
      
      // 监听支付结果
      fluwx.weChatResponseEventHandler.listen((event) async {
    print(event.errCode);
      	// 支付成功  
    if (event.errCode == 0) {
    }
    // 关闭弹窗
      });





