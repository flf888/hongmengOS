# Implementing Flutter Plugin Support for HarmonyOS

## Problem Statement

Flutter Plugins primarily serve as bridges to native code, enabling access to native system SDKs like camera, photo gallery selection, file pickers, etc.

Currently, plugins on [pub.dev](https://pub.dev/) lack HarmonyOS support. Although the OpenHarmony SIG has started supporting some popular third-party plugins (e.g., [gitee.com/openharmony-sig](https://gitee.com/openharmony-sig)), many plugins remain unsupported due to prioritization or timing constraints. This creates a need for developers to add HarmonyOS support to existing plugins when required in projects.

## Environment Setup (macOS M2 Example)

### Download HarmonyOS-compatible Flutter

1. Clone the HarmonyOS Flutter repository:
   `git clone https://gitee.com/openharmony-sig/flutter_flutter.git`
2. Switch to the `dev` branch:
   `git checkout -b dev origin/dev`
3. Configure environment variables to point to this Flutter version

**Recommended:** Use [fvm](https://fvm.app/) for version management:

1. Clone into fvm's versions directory:
   `git clone https://gitee.com/openharmony-sig/flutter_flutter.git ~/.fvm/versions/3.7.12-ohos`
2. Switch versions:
   `fvm global 3.7.12-ohos`

### Download HarmonyOS Dev Tools

Download [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/) (latest version recommended, e.g., 5.0.3.502)

**Environment Variables Configuration:**

```
export TOOL_HOME=/Applications/DevEco-Studio.app/Contents
export DEVECO_SDK_HOME=$TOOL_HOME/sdk
export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH
export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH
export PATH=$TOOL_HOME/tools/node/bin:$PATH
```

## Adding HarmonyOS Support to Existing Plugins

Using `image_gallery_saver` (saves images to photo gallery) as an example:

### Step 1: Fork the Plugin

Fork the original plugin repository to your account (e.g., [zingwin/image_gallery_saver](https://github.com/zingwin/image_gallery_saver))

### Step 2: Clone Locally

```
git clone https://github.com/your-username/image_gallery_saver.git
```

### Step 3: Add OHOS Platform Support

**Recommended Approach:**

1. Create a temporary plugin:
   `flutter create -t plugin --platforms ohos,ios,android temp_plugin`
2. Copy the generated `ohos` directory into your plugin:
   `cp -r temp_plugin/ohos image_gallery_saver/`

### Step 4: Modify pubspec.yaml

Add HarmonyOS configuration:

```
ohos:
  package: com.example.image_gallery_saver
  pluginClass: ImageGallerySaverPlugin
```

Ensure `pluginClass` matches your implementation file path:
`image_gallery_saver/ohos/src/main/ets/components/plugin/ImageGallerySaverPlugin.ets`

### Step 5: Install Dependencies

Run `flutter pub get` in the plugin root directory

### Step 6: Develop OHOS Code

1. Open `example/ohos` in DevEco Studio
2. Implement native methods in:
   `oh_modules/@your-plugin/.../ImageGallerySaverPlugin.ets`
3. Sync changes to the main plugin directory:
   `cp *.ets /path/to/image_gallery_saver/ohos/src/main/ets/components/plugin/`

**Critical:**

- Keep `MethodChannel` names consistent between Dart and OHOS code

- Implement plugin methods:

  ```
  static saveImage(Uint8List imageBytes, {int quality=80, String? name})
  static saveFile(String file, {String? name})
  ```

### Step 7: Test and Push

1. Test with HarmonyOS device/emulator:
   `flutter run -d <device_id>`
2. Push changes to your fork:
   `git push origin main`

### Step 8: Use in Projects

Reference your modified plugin:

```
dependencies:
  image_gallery_saver:
    git:
      url: https://github.com/your-username/image_gallery_saver.git
      ref: main
```

## Summary

This workflow enables adding HarmonyOS support to existing Flutter plugins by:

1. Forking and cloning the plugin
2. Generating OHOS platform structure
3. Implementing native HarmonyOS functionality
4. Maintaining MethodChannel consistency
5. Testing and integrating into projects

With these steps, developers can extend plugin compatibility to HarmonyOS, addressing gaps in official support while maintaining cross-platform functionality.