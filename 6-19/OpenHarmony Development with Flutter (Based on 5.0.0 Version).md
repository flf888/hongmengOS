# OpenHarmony Development with Flutter (Based on 5.0.0 Version)

Original Repository Source: https://github.com/flutter/flutter

## 1. Repository Description

	```
	This repository provides compatibility extensions for the Flutter SDK on the OpenHarmony platform, supporting compilation and building of OpenHarmony applications using Flutter Tools commands in IDEs or terminals.
	```

## 2. Environment Dependencies

	```sh
	Prerequisites:
	1. Flutter Tools commands are supported on Linux, Mac, and Windows
	2. On Windows, the Flutter project and dependent plugin projects must be on the same disk
	
	Basic Environment Setup:
	1. Configure HarmonyOS SDK and environment variables
	2. Use API12 and Deveco Studio 5.0
	3. Download JDK17 and configure environment variables
	 # Windows environment
	 JAVA_HOME = <JAVA_HOME path>
	 PATH=%JAVA_HOME%\bin
	 
	4. Environment variables:
	# Windows environment
	 TOOL_HOME = D:\devecostudio-windows\DevEco Studio
	 DEVECO_SDK_HOME=%TOOL_HOME%\sdk
	 PATH=%TOOL_HOME%\tools\ohpm\bin
	 PATH=%TOOL_HOME%\tools\hvigor\bin
	 PATH=%TOOL_HOME%\tools\node
	 
	5. Clone repository: 
	   git clone https://gitee.com/openharmonysig/flutter_flutter.git (select dev or master branch)
	   Configure environment variables (reference Flutter environment variable setup)
	
	6. Configure all environment variables (on Windows, set in 'Edit System Environment Variables') as shown below (replace user and paths with actual values):
	```

## 3. Building Installation Packages

	```sh
	1. Run `flutter doctor -v` to verify environment configuration. Both Flutter and OpenHarmony should show "ok". If missing environments are reported, add them as prompted.
	
	2. Create project:
	   flutter create --platforms ohos <projectName>
	
	3. Compile HAP package. Output location: 
	   <projectName>/ohos/entry/build/default/outputs/default/entry-default-signed.hap
	   
	   # Navigate to project root directory to compile
	   # Example: flutter build hap [--target-platform ohos-arm64] --release
	   flutter build hap --release
	```

## 4. Installation

	```json
	Install application after discovering real device via `flutter devices`, then install to HarmonyOS phone.
	
	Method 1: Navigate to build output directory and install:
	   hdc -t <deviceId> install <hap file path>
	
	Method 2: Navigate to project directory and run directly on HarmonyOS phone:
	   flutter run --debug -d <deviceId>
	
	Build app package command:
	   # Example: flutter build app --release
	   flutter build app --release
	```

## 5. Common Issues

### 1. Hvigor Error: BUILD unable to find "DEVECO_SDK_HOME" in the environment path

	```
	Solution: Configure environment variable DEVECO_SDK_HOME pointing to the SDK directory
	```

### 2. Hvigor depends on the npmrc file configure the npmrc file

	```
	Reason: Missing .npmrc file
	Solution: Create the file in C:\Users\<username> directory with Huawei npm repository addresses
	```

### 3. 404 GET https://registry.npm.js.org/xxxx not found

	```
	Solution: Configure npm repositories in .npmrc file
	```

### 4. No Hmos SDK found. Try setting the HOS_SDK_HOME environment variable

	```
	Solution: Configure OpenHarmony SDK path:
	   # Point to DevEco Studio SDK directory
	   flutter config --ohos-sdk=/Applications/DevEco-Studio.app/Contents/sdk
	   (Replace path with your DevEco Studio installation path)
	```