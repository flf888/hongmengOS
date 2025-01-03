#  HarmonyOS next之harmony_flutter_amp 导入高德地图

flutter_harmony_amp 链接：https://gitee.com/appkf_admin/amap_flutter_location_ohos



## 接入功能

目前已接入 amap_flutter_location_ohos已经接入了updatePrivacyShow、updatePrivacyAgree、setApiKey、setLocationOption、startLocation、stopLocation、stopLocation、destroy 方法



####  初始化

````
1.高德地图隐私弹窗设置

```
AMapFlutterLocation.updatePrivacyAgree(true);
```

2.同意高德地图隐私协议

```
AMapFlutterLocation.updatePrivacyShow(true, true); 
```

3.初始化设置apikey 分别是 android ios ohos 

```
AMapFlutterLocation.setApiKey("androidkey",
        "iosKey", "ohosKey");
```

//初始化插件
final AMapFlutterLocation _locationPlugin = AMapFlutterLocation()
````



#### 获取位置信息和坐标

`````
1.注册监听器

```
_locationListener = _locationPlugin
        .onLocationChanged()
        .listen((Map<String, Object> result) {
      setState(() {
        _locationResult = result;
      });
    });
````


2.设置获取位置信息Option

```
     AMapLocationOption locationOption = AMapLocationOption();

    ///是否单次定位
    locationOption.onceLocation = false;

    ///是否需要返回逆地理信息
    locationOption.needAddress = true;

    ///逆地理信息的语言类型
    locationOption.geoLanguage = GeoLanguage.DEFAULT;

    locationOption.desiredLocationAccuracyAuthorizationMode =
        AMapLocationAccuracyAuthorizationMode.ReduceAccuracy;

    locationOption.fullAccuracyPurposeKey = "AMapLocationScene";

    ///设置Android端连续定位的定位间隔
    _locationPlugin.setLocationOption(locationOption);
```

3.获取位置信息

```
_locationPlugin.startLocation();
```

4.停止获取位置信息

```
_locationPlugin.stopLocation();
```

5.销毁位置管理器

```
_locationPlugin.destroy();
```



`````



#### Example验证

```
运行项目下的example 验证请求

本地flutter项目通过pub里面导入git方式加载进项目 

在pubspec.yaml中
  amap_flutter_location_ohos:
    git:
      url: https://gitee.com/appkf_admin/amap_flutter_location_ohos
      ref: main # 指定分支，如果不指定，gitee默认为main
```
