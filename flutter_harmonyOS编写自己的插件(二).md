# flutter_harmonyOS编写自己的插件(二)

### 一.做自己的支付宝插件回调和事件

1.Harmony OS官方文档地址

```
https://opendocs.alipay.com/open/0f71b5?pathHash=bedc38ba
```



## 1. 安装说明

[鸿蒙官方仓库-支付宝支付 SDK ](https://ohpm.openharmony.cn/#/cn/detail/@cashier_alipay%2Fcashiersdk)

```plain
ohpm install @cashier_alipay/cashiersdk
```

注意： SDK 版本 >= 15.8.27 版本需要配合支付宝 10.6.50+ 版本使用



### 2.1使用说明

在项目 entry 中的 module.json5 中配置

```json
"module": {
  ...
  "querySchemes": [
    "alipays"
  ],
```



### 2.2使用（使用router方式进行）

```
未安装支付宝 APP 是跳转 H5 支付，已安装支付宝 APP 会直接跳转 APP 支付

通过 router 跳转或者通过 navigation 跳转，只针对未安装支付宝 APP 时跳转 H5 的方式有差异
```

```
通过 router 进行跳转
new Pay().pay(orderInfo, true).then((result) => {
  let message =
    `resultStatus: ${result.get('resultStatus')} memo: ${result.get('memo')} result: ${result.get('result')}`;
  console.log(message);
}).catch((error: BusinessError) => {
  console.log(error.message);
});
```



#### 2.3 建立自己的通道

Ohos端

```
onMethodCall(call: MethodCall, result: MethodResult): void {
  console.log("onMethodCall==>" ,call.method);
  if (call.method == "getPlatformVersion") {
    //测试方法
    result.success("OpenHarmony ^ ^ ")
  } else if (call.method == "aliPayAuth") {
    //支付宝支付调用
    let contentOrder = call.args as string ;
    console.log("contentOrder==>" ,contentOrder);
    //ali支付
    new Pay().pay(contentOrder, true).then((payResult) => {
      let message =
        `resultStatus: ${payResult.get('resultStatus')} memo: ${payResult.get('memo')} result: ${payResult.get('result')}`;
      console.log("message==>",message);
      result.success(payResult)
    }).catch((error: BusinessError) => {
      console.log("error==>",error);
      const infoMap = new Map<string,string>();
      infoMap.set("resultStatus", "-1");
      result.success(infoMap)
    }).finally(() =>{
      console.log("finally==>","finally--->");
      const infoMap = new Map<string,string>();
      infoMap.set("resultStatus", "-1");
      result.success(infoMap)
    });
  }
 }
```



flutter端 使用

```
String orderInfoString = "" //后台返回的请求sign
ExamOhosUtils().aliPayAuth(orderInfoString).then((value) {
  //处理回到逻辑
 if (resultStatus == "9000") {
        //等于9000完成 付款 60001未付款
        Toast.toast(context, msg: "支付成功");
        // Utils.setLogoStorage(context);
        goToPaymentSuccess();
        //刷新答题卡数量
        eventBus.fire(RefreshUserCardEvent());
        print("---->>>>--->>>>_aliPayAuth=11111111");
      } else {
        _questionsOrderStatus(goodsId, type);
        Toast.toast(context, msg: "支付失败");
        print("---->>>>--->>>>_aliPayAuth=2222222222");
      }
}) ;
```
