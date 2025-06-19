# Common Issues in Flutter for HarmonyOS

### **Detecting HarmonyOS Platform in Dart Code**

```dart
import 'package:flutter/foundation.dart';

bool isOhos() {
  return defaultTargetPlatform == TargetPlatform.ohos;
}
```

------

### **Avoid Using `Platform.isOhos`**

**Problem**:
Using `Platform.isOhos` causes failures in:

- `flutter run`
- `flutter build har`
- `flutter attach`

**Example Code Causing Issues**:

```dart
if (Platform.isAndroid || Platform.isOhos) {
  print("test");
}
```

**Error Message**:![code1](https://p.ipic.vip/ihoa98.png)

**Solution**:
Replace `Platform.isOhos` with `defaultTargetPlatform == TargetPlatform.ohos`



### **Accessing Image Resources in Native HarmonyOS Code**

**Problem**:
When using `binding.getFlutterAssets().getAssetFilePathByName('xxxx')` in HarmonyOS native code, image resources from Flutter cannot be loaded via `Image(this.img)`.

**Solution**:
Use the following implementation to load images:

![code2](https://p.ipic.vip/beljy2.png)

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
**Q**: Does `let rawfile = await rmg.getRawFileContent(...)` trigger the build method? Why does execution jump to build when debugging?
**A**: The `getRawFileContent()` operation is asynchronous. During debugging, execution may proceed to the build method while waiting for the operation to complete - this is normal rendering behavior.
