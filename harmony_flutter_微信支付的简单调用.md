# harmony_flutter_微信支付的简单调用

### 一.配置鸿蒙应用信息

```
参考文档：https://pay.weixin.qq.com/doc/v3/merchant/4012073588#%E9%B8%BF%E8%92%99-SDK-%E8%B0%83%E7%94%A8%E8%AF%B4%E6%98%8E

关于「鸿蒙应用」中的 Bundle ID、Identifier、以及应用下载地址的提供的说明如下：
 1.Bundle ID 指的是鸿蒙应用的包名
 2.Identifier 指的是鸿蒙应用的 appIdentifier（应用的appId）
 
 
注意事项：
对于 App 已上架 Android 或iOS 应用市场的应用，千万别选择【未上架任何应用市场】，此选项意思是 Android、iOS 和鸿蒙都尚未上架应用市场，而未上架应用市场的应用使用微信能力则有如下的限制，因此开发者需谨慎操作...（具体参考文档操作）
```



##### 配置 sdk 依赖

```
{
2  "name": "demo",
3  "version": "1.0.0",
4  "description": "Please describe the basic information.",
5  "main": "",
6  "author": "",
7  "license": "",
8   "dependencies": {
9    "@tencent/wechat_open_sdk": "1.0.0"
10  }
11}
```



##### Ohos端调用

```
import * as wxopensdk from '@wechat/open_sdk';
2
3// WXApi 是第三方app和微信通信的openApi接口，其实例通过WXAPIFactory获取，需要传入应用申请到的AppID
4export const WXApi = wxopensdk.WXAPIFactory.createWXAPI(APP_ID)
5
6// WXApiEventHandler为微信数据的回调
7class WXApiEventHandlerImpl implements wxopensdk.WXApiEventHandler {
8  private onReqCallbacks: Map<OnWXReq, OnWXReq> = new Map
9  private onRespCallbacks: Map<OnWXResp, OnWXResp> = new Map
10
11  registerOnWXReqCallback(on: OnWXReq) {
12    this.onReqCallbacks.set(on, on)
13  }
14  unregisterOnWXReqCallback(on: OnWXReq) {
15    this.onReqCallbacks.delete(on)
16  }
17
18  registerOnWXRespCallback(on: OnWXResp) {
19    this.onRespCallbacks.set(on, on)
20  }
21  unregisterOnWXRespCallback(on: OnWXResp) {
22    this.onRespCallbacks.delete(on)
23  }
24
25  onReq(req: wxopensdk.BaseReq): void {
26    Log.i(kTag, "onReq:%s", JSON.stringify(req))
27    this.onReqCallbacks.forEach((on) => {
28      on(req)
29    })
30  }
31
32  onResp(resp: wxopensdk.BaseResp): void {
33    Log.i(kTag, "onResp:%s", JSON.stringify(resp))
34    this.onRespCallbacks.forEach((on) => {
35      on(resp)
36    })
37  }
38}
39export const WXEventHandler = new WXApiEventHandlerImpl
40
41//调用支付
42let req = new wxopensdk.PayReq
43req.appId = 'wxd930ea5d5a258f4f'//微信开放平台审核通过的移动应用AppID
44req.partnerId = '1900000109'//微信支付商户号
45req.prepayId = '1101000000140415649af9fc314aa427'//调用微信支付下单接口返回的支付交易会话ID
46req.packageValue = 'Sign=WXPay'//填写固定值Sign=WXPay
47req.nonceStr = '1101000000140429eb40476f8896f4c9'//随机字符串，不长于32位
48req.timeStamp = '1398746574'//时间戳
49req.sign = '7FFECB600D7157C5AA49810D2D8F28BC2811827B'//签名值
50// 向微信发送登录请求:
51//   context为ohos内置类，app间跳转需依赖该类，开发者可在Component中获取
52//   finished为跳转微信的结果：true表示跳转成功；false表示跳转失败，可能是因为微信未安装
53let finished = await this.wxApi.sendReq(context: common.UIAbilityContext, req)
54
55
56// 在EntryAbility中响应来自微信的回调
57export default class EntryAbility extends UIAbility {
58  onCreate(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
59    this.handleWeChatCallIfNeed(want)
60  }
61  
62  onNewWant(want: Want, _launchParam: AbilityConstant.LaunchParam): void {
63    this.handleWeChatCallIfNeed(want)
64  }
65
66  private handleWeChatCallIfNeed(want: Want) {
67    WXApi.handleWant(want, WXEventHandler)
68  }
69}
```



flutter建立自己的插件通道

1. 初始化微信支付
2. 调起微信支付

```
  Future<bool> registerWxApi(String appId) {
    return ExamOhosUtilsPlatform.instance.registerWxApi(appId);
  }

  Future<bool> payWithWeChat({
    String appId,
    String partnerId,
    String prepayId,
    String packageValue,
    String nonceStr,
    int timeStamp,
    String sign,
    String signType,
    String extData,
  }) {
    return ExamOhosUtilsPlatform.instance.payWithWeChat(
        appId: appId,
        partnerId: partnerId,
        prepayId: prepayId,
        packageValue: packageValue,
        nonceStr: nonceStr,
        timeStamp: timeStamp,
        sign: sign,
        signType: signType,
        extData: extData);
  }
}
```



##### 外部调用

```
ExamOhosUtils().payWithWeChat(
  appId: itemMap['appid'].toString(),
  partnerId: itemMap['partnerid'].toString(),
  prepayId: itemMap['prepayid'].toString(),
  packageValue: itemMap['package'].toString(),
  nonceStr: itemMap['noncestr'].toString(),
  timeStamp: int.parse(itemMap['timestamp']),
  sign: itemMap['sign'].toString(),
)
    .then((data) {
  print("---》$data");
});
```
