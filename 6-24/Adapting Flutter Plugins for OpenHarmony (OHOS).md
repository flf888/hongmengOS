# Adapting Flutter Plugins for OpenHarmony (OHOS)

### 1. Preparation

- Flutter development environment
- Download the third-party plugin to be adapted (official plugin repository: )

```
Note:
Native plugin directory structure:
lib: Entry point for Dart-side code, sends data to native via channels
android: Android implementation code
ios: iOS implementation code
example: Demo Flutter application showing usage
README.md: Package introduction file
CHANGELOG.md: Record of version changes
LICENSE: License terms file
```

### 2. Create OHOS Module for Plugin

Download path_provider 2.1.0 source code ()

Command: `flutter create --platforms ohos,android,ios --org <org> <appName>`

Steps:

1. Open downloaded plugin in Android Studio
2. Navigate to plugin directory in Terminal
3. Execute: `flutter create --platforms ohos path_provider_ohos`
4. Delete unnecessary files (.dart_tool, .idea) from created path_provider_ohos directory

### 3. Adjust Dart Code and pubspec.yaml

```
lib directory:
Copy Dart code from path_provider_android/lib and replace "android" with "ohos"

pubspec.yaml configuration:
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

### 4. Develop Native ETS Module

```
1. Open path_provider_ohos in DevEco Studio
2. Create static module:
   File > New > Module > Static Library > Next
   Module name: path_provider > Finish
3. Clean directory:
   Delete entry directory
   Clear contents of path_provider/src/main/ets
Configure Flutter dependencies:
1. Add flutter.har dependency in path_provider/oh-package.json5:
{
  "name": "path_provider",
  "version": "1.0.0",
  "description": "Please describe the basic information." ,
  "main": "Index.ets",
  "author": "",
  "license": "Apache-2.0",
  "dependencies": {
    "@ohos/flutter_ohos": "file:libs/flutter.har"
  }
}

2. Remove flutter.har dependency from outer oh-package.json5:
{
  "name": "path_provider_ohos",
  "version": "1.0.0",
  "description": "Please describe the basic information.",
  "main": "",
  "author": "",
  "license": "",
  "dependencies": {},
  "devDependencies": {
    "@ohos/hypium": "1.0.6"
  },
}

3. Add flutter.har to path_provider directory
Implement ETS code:
- Reference Android implementation
- Inherit PathProviderApi and implement FlutterPlugin

Configure index.ets:
import PathProviderPlugin from './src/main/ets/io/flutter/plugins/pathprovider/PathProviderPlugin'
export default PathProviderPlugin
```

### 5. Generate HAR Package

```
Build steps in DevEco Studio:
1. Select path_provider module
2. Build > Make Module 'pathprovider'
3. Wait for completion

Expected result:
path_provider.har generated at:
path_provider/build/default/outputs/path_provider.har
```

### 6. Configure Example

```
1. Create example module:
   cd path_provider_ohos
   flutter create --platforms ohos example

2. Replace example code:
   Copy main.dart from path_provider_android/example/lib to 
   path_provider_ohos/example/lib

3. Update example pubspec.yaml:
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

### 7. Run Example

```
1. Open example/ohos in DevEco Studio:
   File > Project Structure > Project > Signing Configs
   Check "Automatically generate signature" > OK

2. Run from terminal:
   cd path_provider_ohos/example/ohos
   flutter pub get
   flutter run -d <device-id>
```
