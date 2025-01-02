# HarmonyOS next之Flutter与鸿蒙三方库ohos的适配
HarmonyOS next之Flutter与鸿蒙三方库ohos的适配
### 一、前期准备

- flutter开发环境
- 调下载待适配的三方插件（官方插件库地址https://pub.dev/）

```
备注：
原生插件目录：
lib： 是对接dart端代码的入口，由此文件接收到参数后，通过channel将数据发送到原生端；
android：安卓端代码实现目录；
ios：ios原生端实现目录；
example： 一个依赖于该插件的Flutter应用程序，来说明如何使用它；
README.md：介绍包的文件；
CHANGELOG.md： 记录每个版本中的更改；
LICENSE： 包含软件包许可条款的文件。
```

### 二、创建插件的ohos模块

官网下载path_provider 2.1.0源码（https://pub-web.flutter-io.cn/packages/path_provider/versions/2.1.0）

```
命令：`flutter create --platforms ohos,android,ios --org <org> <appName>`

步骤：

1）用Android Studio打开刚刚下载好的插件；

2）打开Terminal，cd到插件目录下；

3）执行命令`flutter create --platforms ohos path_provider_ohos` 创建一个ohos平台的flutter模块。

4）在插件根目录得到path_provider_ohos （可以将path_provider_ohos目录下的.dart_tool和.ldea文件删除。）
```

### 三、ohos插件dart调整和pubspec.yaml文件配置调整

```
lib目录dart代码：

可直接复制path_provider_android目录下lib的dart代码和pubspec.yaml文件进行修改；

dart代码基本不需要修改，只需要将android字样改为ohos。
```

```
name: path_provider_ohos
description: Ohos implementation of the path_provider plugin.
repository: https://gitee.com/openharmony-sig/flutter_packages/tree/master/packages/path_provider/path_provider_ohos
issue_tracker: https://gitee.com/openharmony-sig/flutter_packages/issues
version: 2.2.1

environment:
  sdk: ">=2.18.0 <4.0.0"
  flutter: ">=3.3.0"

flutter:
  plugin:
    implements: path_provider
    platforms:
      ohos:
        package: io.flutter.plugins.pathprovider
        pluginClass: PathProviderPlugin
        dartPluginClass: PathProviderOhos

dependencies:
  flutter:
    sdk: flutter
  path_provider_platform_interface: ^2.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  pigeon: ^9.2.4
  test: ^1.16.0
```

### 四、编写ohos插件的原生ets模块

```
1）用DevEco Studio打开path_provider_oho下的ohos项目

2）新建一个名称为path_provider的静态模块：

在DevEco Studio左上角点击`Flie > New > Module > Static Library > Next` ；

module name填写为`path_provider`,其他选项为默认，点击Finish，完成创建。

3）删除entry以及其他多余目录：

entry目录（entry是用来写应用的，现在是要写插件，此处已不需要，应该删除）；

将`path_provider > src > main > ets`目录下的文件全部删除(此处是一些模板代码可删除)。
```

```
修改flutter相关配置文件：

1）在path_provider目录内的oh-package.json5添加libs/flutter.har 依赖：

{
  "name": "path_provider",
  "version": "1.0.0",
  "description": "Please describe the basic information." ,
  "main": "Index.ets",
  "author": "",
  "license": "Apache-2.0",
  "dependencies": {
    "@ohos/flutter_ohos": "file:libs/flutter.har"  //此处为添加的依赖
  }
}

2）将path_provider目录外侧的oh-package.json5的dependencies中的flutter.har依赖删除：

{
  "name": "path_provider_ohos",
  "version": "1.0.0",
  "description": "Please describe the basic information.",
  "main": "",
  "author": "",
  "license": "",
  "dependencies": {
  },
  "devDependencies": {
    "@ohos/hypium": "1.0.6"
  },
}

3）在path_provider目录下添加flutter.har
```

```
编写ets代码

主要业务逻辑参考android 继承PathProviderApi实现FlutterPlugin
```

```
修改index文件

import PathProviderPlugin from './src/main/ets/io/flutter/plugins/pathprovider/PathProviderPlugin'

export default PathProviderPlugin
```

### 五、生成har包

```
写完代码，改完配置文件后，即可打har包：

打包工具：DevEco Studio

打包步骤：1、鼠标定位到path_provider目录；2、点击DevEco Studio中的Build；3、点击Make Module 'pathprovider'选项；4、等待打包完成。

预期结果：

在`path_provider > build > default > outputs `中有path_proivider.har生成，即为打har包成功。
```

### 六、编写example

```
1.cd 到path_provider_ohos目录下 ；

命令：`flutter create --platforms ohos example`

工具：Android Studio

2.复制`path_provider_android\example\lib`下的main.dart代码，替换`path_provider_ohos\example\lib`下的main.dart代码。

3.修改example pubspec.yaml文件

#仅作参考
name: path_provider_example
description: Demonstrates how to use the path_provider plugin.
publish_to: none

environment:
  sdk: ">=2.18.0 <4.0.0"
  flutter: ">=3.3.0"

dependencies:
  flutter:
    sdk: flutter
  path_provider:
    path: ../../path_provider
  path_provider_platform_interface: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

### 七、运行example

```
1.用 `Deveco Studio` 打开三方库的 `example > ohos` 目录；

单击 `File > Project Structure > Project > Signing Configs` 界面勾选 `Automatically generate signature`，等待自动签名完成即可，单击 `OK`；



2.cd到`path_provider_ohos\example > ohos`目录，使用下列指令运行：

`flutter pub get`

`flutter run -d <device-id>`
```



