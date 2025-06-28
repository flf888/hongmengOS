# HarmonyOS Flutter: Simulator Development and Debugging Steps

**Development computer must be an M-series chip (ARM architecture) Mac computer**
Currently, Flutter HarmonyOS development **does not support X86 architecture simulators** and requires an **ARM architecture simulator**.



**Create a Project**

After setting up the development environment, create a project using:

```bash
flutter create --platforms ohos ohos_app
```



## Add HarmonyOS Support to Existing Projects

```bash
flutter create --platforms ohos .
```



**Signing Configuration**

1. Open the `ohos` directory (HarmonyOS project) in DevEco.
2. Navigate to `File → Project Structure...`, select `Signing Configs`, check **Automatically generate signature**, then click **Sign In** with your Huawei account.



```bash
> hvigor WARN: The current module 'ohos' has dependency which is not installed at its oh-package.json5.
> hvigor Finished :entry:init... after 1 ms
> hvigor Finished ::init... after 1 ms

Process finished with exit code 0
```



**Create a Simulator**

1.Open **Device Manager** in DevEco (dropdown next to the run button).

![img](https:////upload-images.jianshu.io/upload_images/11424067-daa6a20f736cd36e.png?imageMogr2/auto-orient/strip|imageView2/2/w/1094)

image.png

2.Click **+ New Emulator** in the bottom-right corner.

- If images are not downloaded, click the download button first.
- After downloading, proceed to create the emulator.

![img](https:////upload-images.jianshu.io/upload_images/11424067-c37e9de24eff4350.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200)

image.png

3.Start the newly created emulator.



**Run the Flutter Project**

1. Ensure the simulator device (e.g., `127.0.0.1:5555(ohos-arm64)`) appears in VSCode’s device list.
2. Run the Flutter project as usual.



**Troubleshooting**



### 1. App Crashes on Startup

- **X86 Simulators**: Delete `FloatingActionButton` in `main.dart`.
- **Impeller Rendering Issues**:
  Create `ohos/entry/src/main/resources/rawfile/buildinfo.json5` with:



```json
{
   "string": [
      {
         "name": "enable_impeller",
         "value": "true"
      }
   ]
}
```



### 2. Simulator Not Visible in VSCode

- Restart DevEco or VSCode.
- Ensure the `ohos` directory is open in DevEco.

### 3. Incorrect Flutter Version with FVM

1. Configure FVM in VSCode’s `settings.json`:



```json
{
  "dart.flutterSdkPath": ".fvm/versions/custom_3.22.0"
}
```

```json
{
  "flutter": "custom_3.22.0"
}
```

2. Verify Flutter version:



```bash
Flutter 3.22.0-ohos • channel oh-3.22.0 • https://gitee.com/harmonycommando_flutter/flutter.git
Framework • revision 85630b0330 (13 天前) • 2024-10-26 02:39:47 +0000
Engine • revision f6344b75dc
Tools • Dart 3.4.0 • DevTools 2.34.1
```

3.3 Disable global Flutter configuration in `~/.zshrc` or `~/.bash_profile`.



```bash
#export PATH="/Users/zacksleo/flutter/bin:$PATH"
```