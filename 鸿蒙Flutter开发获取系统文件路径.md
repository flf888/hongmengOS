# Flutter+鸿蒙NEXT开发获取系统文件路径

在具体的开发过程中,有时需要获取临时目录、文档目录等需求.本文具体讲解怎么在Flutter中可以利用path_provider插件来完成此项工作，OpenHarmony SIG组织对该插件做了鸿蒙NEXT系统的适配，接下来将详细讲解如何利用path_provider插件来获取系统文件路径。

**在引用的项目中，pubspec.yaml中dependencies新增配置：**

```
dependencies:
  path_provider:
    git:
      url: "https://gitee.com/openharmony-sig/flutter_packages.git"
      path: "packages/path_provider/path_provider"
```

项目根目录运行`flutter pub get`；（ohos/entry/oh-package.json5会自动添加如下相关插件har依赖）

```
{
  "name": "entry",
  "version": "1.0.0",
  "description": "Please describe the basic information.",
  "main": "",
  "author": "",
  "license": "",
  "dependencies": {
    "@ohos/flutter_ohos": "file:../har/flutter.har",
    "integration_test": "file:../har/integration_test.har",
    "path_provider_ohos": "file:../har/path_provider_ohos.har"
  }
}

```

**导入path_provider插件**

在需要使用path_provider插件的dart文件中，使用下面的代码导入插件：

```
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
```



**获取系统路径一些基本使用:**

```
	final PathProviderPlatform provider = PathProviderPlatform.instance;
	Future<String?>? _tempDirectory;
  Future<String?>? _appSupportDirectory;
  Future<String?>? _appDocumentsDirectory;
  Future<String?>? _appCacheDirectory;
  Future<String?>? _externalDocumentsDirectory;
  Future<List<String>?>? _externalStorageDirectories;
  Future<List<String>?>? _externalCacheDirectories;
  Future<String?>? _downloadsDirectory;
  
  
  void _requestTempDirectory() {
    setState(() {
      _tempDirectory = provider.getTemporaryPath();
    });
  }
  
  void _requestAppDocumentsDirectory() {
    setState(() {
      _appDocumentsDirectory = provider.getApplicationDocumentsPath();
    });
  }

	void _requestAppSupportDirectory() {
    setState(() {
      _appSupportDirectory = provider.getApplicationSupportPath();
    });
  }

  void _requestAppCacheDirectory() {
    setState(() {
      _appCacheDirectory = provider.getApplicationCachePath();
    });
  }

  void _requestExternalStorageDirectory() {
    setState(() {
      _externalDocumentsDirectory = provider.getExternalStoragePath();
    });
  }

  void _requestExternalStorageDirectories(StorageDirectory type) {
    setState(() {
      _externalStorageDirectories =
          provider.getExternalStoragePaths(type: type);
    });
  }

  void _requestExternalCacheDirectories() {
    setState(() {
      _externalCacheDirectories = provider.getExternalCachePaths();
    });
  }

  void _requestDownloadsDirectory() {
    setState(() {
      _downloadsDirectory = provider.getDownloadsPath();
    });
  }

```

以上就是Flutter+鸿蒙NEXT开发获取系统文件路径具体实现.