##  HarmonyOS next之Flutter和OpenHarmony通信pigeon库的具体接入和用法

**Pigeon**

Pigeon 是一个代码生成器工具，用于使 Flutter 和宿主平台之间的通信类型安全、更轻松、更快捷.

引入pigeon库，在pubspec.yaml中dev_dependencies新增配置：

```
dev_dependencies:
 pigeon:
   git:
     url: "https://gitee.com/openharmony-sig/flutter_packages.git"
     path: "packages/pigeon"
```

项目根目录运行`flutter pub get`；



**定义接口**

创建pigeons/message.dart(lib同级目录创建)

```c
import 'package:pigeon/pigeon.dart';

// #docregion config
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  cppOptions: CppOptions(namespace: 'pigeon_example'),
  cppHeaderOut: 'windows/runner/messages.g.h',
  cppSourceOut: 'windows/runner/messages.g.cpp',
  kotlinOut:
      'android/app/src/main/kotlin/dev/flutter/pigeon_example_app/Messages.g.kt',
  kotlinOptions: KotlinOptions(),
  javaOut: 'android/app/src/main/java/io/flutter/plugins/Messages.java',
  javaOptions: JavaOptions(),
  swiftOut: 'ios/Runner/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  objcHeaderOut: 'macos/Runner/messages.g.h',
  objcSourceOut: 'macos/Runner/messages.g.m',
  // Set this to a unique prefix for your plugin or application, per Objective-C naming conventions.
  objcOptions: ObjcOptions(prefix: 'PGN'),
  copyrightHeader: 'pigeons/copyright.txt',
  dartPackageName: 'pigeon_example_package',
  arkTSOut: 'ohos/entry/src/main/ets/plugins/Messages.ets',
  arkTSOptions: ArkTSOptions(),
))
// #enddocregion config

// This file and ./messages_test.dart must be identical below this line.

// #docregion host-definitions
enum Code { one, two }

class MessageData {
  MessageData({required this.code, required this.data});
  String? name;
  String? description;
  Code code;
  Map<String?, String?> data;
}

@HostApi()
abstract class ExampleHostApi {
  String getHostLanguage();

  // These annotations create more idiomatic naming of methods in Objc and Swift.
  @ObjCSelector('addNumber:toNumber:')
  @SwiftFunction('add(_:to:)')
  int add(int a, int b);

  @async
  bool sendMessage(MessageData message);
}
// #enddocregion host-definitions

// #docregion flutter-definitions
@FlutterApi()
abstract class MessageFlutterApi {
  String flutterMethod(String? aString);
}
// #enddo
```

项目根目录运行`flutter pub run pigeon --input <dart通信模型文件路径> --arkts_out <arkts平台方法代码输出文件路径，示例./ohos/entry/src/main/ets/xxx.ets>`

 **OpenHarmony使用**

```

import {
  FlutterPlugin,
  FlutterPluginBinding
} from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
import { ExampleHostApi, MessageData, Result } from './Messages';

class HostApiImp extends ExampleHostApi {
  getHostLanguage(): string {
    return 'ArkTS';
  }

  add(a: number, b: number): number {
    return a + b;
  }

  sendMessage(message: MessageData, result: Result<boolean>) {
    console.log("收到消息：" + message.getName());
  }
}

export default class MessagePlugin implements FlutterPlugin {

  constructor() {
  }

  getUniqueClassName(): string {
    return 'MessagePlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding) {
    ExampleHostApi.setup(binding.getBinaryMessenger(), new HostApiImp());
  }

  onDetachedFromEngine(binding: FlutterPluginBinding) {
    //ExampleHostApi.setup(binding.getBinaryMessenger(), null);
  }
}
```

**flutter 使用**

```
class _ExampleFlutterApi implements MessageFlutterApi {
  @override
  String flutterMethod(String? aString) {
    return aString ?? '';
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ExampleHostApi _hostApi = ExampleHostApi();
  String? _hostCallResult;

  // #docregion main-dart
  final ExampleHostApi _api = ExampleHostApi();

  /// Calls host method `add` with provided arguments.
  Future<int> add(int a, int b) async {
    try {
      return await _api.add(a, b);
    } catch (e) {
      // handle error.
      return 0;
    }
  }

  /// Sends message through host api using `MessageData` class
  /// and api `sendMessage` method.
  Future<bool> sendMessage(String messageText) {
    final MessageData message = MessageData(
      code: Code.one,
      data: <String?, String?>{'header': 'this is a header'},
      description: 'uri text',
    );
    try {
      return _api.sendMessage(message);
    } catch (e) {
      // handle error.
      return Future<bool>(() => true);
    }
  }
  // #enddocregion main-dart

  @override
  void initState() {
    super.initState();
    _hostApi.getHostLanguage().then((String response) {
      setState(() {
        _hostCallResult = 'Hello from $response!';
      });
    }).onError<PlatformException>((PlatformException error, StackTrace _) {
      setState(() {
        _hostCallResult = 'Failed to get host language: ${error.message}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _hostCallResult ?? 'Waiting for host language...',
            ),
            if (_hostCallResult == null) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```
