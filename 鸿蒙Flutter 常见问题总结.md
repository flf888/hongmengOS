# HarmonyOS next之鸿蒙Flutter 常见问题总结

**dart代码中判断当前平台是否是ohos**

```dart
import 'package:flutter/foundation.dart';

bool isOhos() {
  return defaultTargetPlatform == TargetPlatform.ohos;
}
```



**代码中存在Platform.isOhos会导致fluttn run、flutter build har、flutter attach失败**

问题现象：
如果flutter代码中存在Platform.isOhos，如下：

```
if (Platform.isAndroid || Platform.isOhos) {
  print("test");
}
```
会导致flutter run、flutter build har、 flutter attach（不指定本地引擎产物，依赖服务器的引擎产物）失败，
报错信息：
![code1](https://syxoss.oss-cn-hangzhou.aliyuncs.com/Text/ihoa98.png)

*解决方法*：
请将 Platform.isOhos 修改成 defaultTargetPlatform == TargetPlatform.ohos



**flutter鸿蒙原生端获取到图片资源**

问：在使用plugin时， 鸿蒙会返回这个类型的对象binding: FlutterPluginBinding，使用这个对象的binding.getFlutterAssets().getAssetFilePathByName('xxxx') 获取flutter代码库中的图片资源时，鸿蒙原生端无法获取到图片资源（鸿蒙端直接用Image(this.img)方法加载）。有什么别的方法能够获取到？

答：binding.getFlutterAssets().getAssetFilePathByName('xxxx')得到的是资源路径，加载原生图片资源可以参考以下实现

![code2](https://syxoss.oss-cn-hangzhou.aliyuncs.com/Text/beljy2.png)

```
import { image } from '@kit.ImageKit';
@Component
export struct DemoComponent {
  @Prop params: Params
  viewManager: DemoView = this.params.platformView as DemoView
  image?: string
  @State imageSource:image.ImageSource|null=null

  async aboutToAppear() {
    let args: HashMap<string, object | string> = this.viewManager.args as HashMap<string, object>
    this.image = args.get('src') as string
    let rmg = DemoPluginAssetPlugin.binding.getApplicationContext().  resourceManager;
    let rawfile = await rmg.getRawFileContent("flutter_assets/${this.image}");
    let buffer = rawfile.buffer.slice(0);
    this.imageSource = image.createImageSource(buffer);
  }

  build() {
    Column(){
      if(this.imageSource){
        Image(this.imageSource.createPixelMapSync())
      }
    }
  }
  
  // aboutToAppear(): void {
  // let args: HashMap<string, object | string> = this.viewManager.args as   HashMap<string, object>
  // this.image = args.get('src') as string
  // }
  
  // build() {
  // //todo 问题点
  // // Image(this.image)
  // Image(DemoPluginAssetPlugin.binding.getFlutterAssets().getAssetFilePathByName  (this.image))
  // // Image(DemoPluginAssetPlugin.binding.getFlutterAssets().  getAssetFilePathBySubpath(this.image))
  // }
}
```
问：let rawfile = await rmg.getRawFileContent("flutter_assets/"+this.image ); 这行代码会触发build方法么？ 为什么我打断点打到这一行，然后继续执行断点直接就到build方法了？

答：let rawfile = await rmg.getRawFileContent("flutter_assets/"+this.image );这行代码为耗时操作，debug时会暂不执行当前方法的剩余代码直到耗时操作返回结果，而进入build只是正常渲染流程
