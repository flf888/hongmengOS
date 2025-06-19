# Setting Up Flutter Development Environment for HarmonyOS

### 1. Environment Setup

1. Install

    

   DevEco Studio NEXT IDE

   - Must be the NEXT version (current latest is Beta3)
   - Requires login before downloading
   - Simulator creation requires developer verification/approval (typically takes ~2 hours)
   - Select Windows/macOS version matching your OS
   - Installation is straightforward (follow default steps)
   - Note: New version includes built-in node/ohpm environments

**Mac Installation (Recommended)**
Environment variable configuration:

```
# Flutter Mirror
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# HarmonyOS SDK
export TOOL_HOME=/Applications/DevEco-Studio.app/Contents/
export DEVECO_SDK_HOME=$TOOL_HOME/sdk
export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH
export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH
export PATH=$TOOL_HOME/tools/node/bin:$PATH
```

**Windows Installation**
User variables:

```
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
PUB_HOSTED_URL=https://pub.flutter-io.cn
DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk
```

PATH additions:

```
C:\Program Files\Huawei\DevEco Studio\tools\ohpm\bin
C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin
C:\Program Files\Huawei\DevEco Studio\tools\node
```

**Managing Multiple Flutter Versions**
Use FVM (Flutter Version Manager):

1. Install [FVM](https://fvm.app/)
2. Install official Flutter version:
   `fvm install 3.22.0`
3. Install custom HarmonyOS version:

```
cd ~/fvm/versions/3.22.0
git clone -b dev https://gitee.com/openharmony-sig/flutter_flutter.git custom_3.7.12
```

1. Use specific SDK in projects:
   `fvm use custom_3.7.12`

### 2. Creating and Running Projects

1. Verify environment setup:
   `flutter doctor -v`
   Expected output:

```
[✓] HarmonyOS toolchain - develop for HarmonyOS devices
    • OpenHarmony Sdk at [PATH], available api versions has [12:default]
    • Ohpm version 5.0.8-rc.1
    • Node version v18.20.1
    • Hvigorw binary at [PATH]/hvigorw
```

Note: Errors indicate PATH misconfiguration

**2. Create Flutter Project**
Option 1 (OHOS only):
`flutter create --platforms ohos <projectName>`

Option 2 (All platforms):
`flutter create <projectName>`

Essential first step:
`cd <projectName> && flutter build hap --debug`

**3. Run on HarmonyOS Device**
Option 1: Via Flutter CLI

```
flutter devices
flutter run --debug -d <deviceId>
```

Option 2: Manual HAP installation

```
flutter build hap --debug
hdc -t <deviceId> install <hap-path>
```

Option 3: Using DevEco Studio

1. Enable signing:
   File > Project Structure > Signing Configs > Auto-generate signature
2. Emulator note:
   Current emulators only support x86 architecture, while Flutter requires ARM64 - use real devices instead

### 3. Building Projects

**Debug Build:**

```
flutter build hap --debug
```

For custom engines:
`flutter build hap --debug --local-engine=<engine-path>`
Note: Copy flutter.har to engine directory if missing

**Release Build:**

```
flutter build hap --release
# Or
flutter build hap
```

For custom engines:
`flutter build hap --release --local-engine=<engine-path>`

### Troubleshooting

**Common Error:**
`Error: Unable to find git in your PATH`
Solution:
`git config --global --add safe.directory '*'`

### References

- [Flutter Documentation](https://docs.flutter.cn/)
- [HarmonyOS Next Documentation](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/application-dev-guide-V5)
