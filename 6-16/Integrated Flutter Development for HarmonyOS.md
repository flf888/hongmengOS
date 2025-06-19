

## Integrated Flutter Development for HarmonyOS

>### 1.1 Flutter-HarmonyOS Integration Overview
>
>Flutter is a cross-platform UI framework designed to enable developers to build applications for iOS, Android, and other platforms (Web, Windows, macOS, etc.) using a single codebase. While HarmonyOS isn't natively supported by Flutter, its flexibility and underlying engine capabilities allow for adaptations to run Flutter applications on HarmonyOS devices. Huawei has provided developers with solutions to enable Flutter applications on HarmonyOS devices.
>
>The Flutter Engine serves as the core rendering engine, allowing developers to embed Flutter components in non-Flutter environments. HarmonyOS supports Flutter applications by integrating this engine, enabling developers to create native HarmonyOS applications with embedded Flutter components. An open-source engine supporting HarmonyOS is available at:
>
>This project currently supports Linux, macOS, and Windows environments.
>
>### 1.2 HarmonyOS Flutter Environment Setup Guide
>
>#### 2.1 Environment Preparation
>
>1. Download the HarmonyOS development suite from the official site:
>   https://developer.huawei.com/consumer/cn/download/
>
>**Important Notes:**
>(1) Currently supports Linux, macOS, and Windows operating systems
>(2) For macOS systems, determine your architecture using `uname -m` in Terminal:
>
>- `x86_64` indicates x86-64 architecture
>- `arm64` indicates ARM64 architecture
>
>#### 2.2 Download Requirements
>
>(1) Download the latest DevEco Studio version matching your OS:
>
>(2) If you don't have a HarmonyOS device, install the emulator in DevEco Studio
>
>(3) Download the HarmonyOS-compatible Flutter repository:
>
>```
>https://gitee.com/openharmony-sig/flutter_flutter
>```
>
>Clone the repository and switch to the dev or master branch (dev has more frequent updates):
>
>```
>git clone https://gitee.com/openharmony-sig/flutter_flutter.git
>git checkout -b dev origin/dev
>```
>
>(4) Download FlutterEngine Build Artifacts (Optional)
>Flutter projects require `ohos_debug_unopt_arm64` and `ohos_release_arm64`. Use the `--local-engine` parameter to specify a local engine path:
>`flutter build hap [--local-engine=/path/to/engine/src/out/ohos_debug_unopt_arm64]`
>Note: The engine path must include `src/out` directory (e.g., `/Users/admin/Documents/flutter_engine/src/out`)
>
>#### 2.3 Prerequisite Environment Dependencies
>
>- HarmonyOS SDK requires JDK 17. Download from Oracle or OpenJDK and configure properly
>- Verify JDK installation with:
>
>```
>java -version
>```
>
>> *With these preparations complete, we can proceed to configure the development environment.*