
# flutter_console

A Flutter Console UI Component

#### Project Overview

A visualization component for displaying console output in Flutter applications. The console window appears at the top layer of the screen, designed for debugging and log output purposes.

#### Installation

[Installation Instructions](https://pub.dev/packages/flutter_console/install)

#### Basic Demo

    ```dart
    import 'package:flutter/material.dart';
    import 'dart:async';
    import 'package:flutter_console/flutter_console.dart';
    
    void main() {
      runApp(MyApp());
    }
    
    class MyApp extends StatefulWidget {
      @override
      _MyAppState createState() => _MyAppState();
    }
    
    class _MyAppState extends State<MyApp> {
      final navKey = GlobalKey<NavigatorState>();
    
      @override
      void initState() {
    super.initState();
      }
    
      @override
      Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      home: Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Console'),
    ),
    body: Center(
      child: GestureDetector(
    onTap: showLog,
    child: Container(
      height: 50,
      width: 100,
      color: Colors.purple,
      child: Center(
    child: Text(
      'show',
      style: TextStyle(color: Colors.white, fontSize: 18),
    ),
      ),
    ),
      ),
    ),
      ),
    );
      }
    
      void showLog() {
    ConsoleStream logStream = ConsoleStream();
    ConsoleOverlay().show(
      baseOverlay: navKey.currentState!.overlay!,
      contentStream: logStream,
      y: 300,
    );
    pushLog(logStream);
      }
    
      void pushLog(ConsoleStream cr) {
    cr.push('Show Log:' + DateTime.now().millisecondsSinceEpoch.toString());
    Future.delayed(const Duration(milliseconds: 1000), () {
      pushLog(cr);
    });
      }
    }
    ```

#### Feature Overview (Toolbar Icons from Left to Right)

- **Collapse Button**: Minimizes the console window to a small widget. Click to restore
- **Resize Button**: Allows vertical resizing of the console window
- **Clear Button**: Clears all current log entries
- **Close Button**: Closes the console window
- **Scroll-to-Bottom Button**: Automatically scrolls to the latest log entry

#### API Documentation

```dart
void show({
  required OverlayState baseOverlay,
  required ConsoleStream contentStream,
  double y = 200
})
```

- `baseOverlay`: The overlay layer for the console window. For consistent display across screens, use the navigator's overlay
- `contentStream`: Log channel. Use `contentStream.push()` to add new log entries
- `y`: Initial vertical position (Y-coordinate) of the window. Default: 200

#### HarmonyOS FlutterConsolePlugin.ets Implementation

    ```typescript
    /*
     * Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     * http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License.
     */
    
    import { FlutterPlugin, FlutterPluginBinding } from '@ohos/flutter_ohos/src/main/ets/embedding/engine/plugins/FlutterPlugin';
    import MethodChannel, { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
    import MethodCall from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodCall';
    import deviceInfo from '@ohos.deviceInfo';
    
    const TAG = "FlutterConsolePlugin";
    
    export class FlutterConsolePlugin implements FlutterPlugin, MethodCallHandler {
      private channel: MethodChannel | null = null;
    
      getUniqueClassName(): string {
    return "FlutterConsolePlugin";
      }
    
      onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_console");
    this.channel.setMethodCallHandler(this);
      }
    
      onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
      }
    
      onMethodCall(call: MethodCall, result: MethodResult): void {
    if (call.method == "getPlatformVersion") {
      result.success("HarmonyOS " + deviceInfo.buildVersion);
    } else {
      result.notImplemented();
    }
      }
    }
    ```
