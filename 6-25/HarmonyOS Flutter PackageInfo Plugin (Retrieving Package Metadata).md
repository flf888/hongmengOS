# HarmonyOS Flutter PackageInfo Plugin (Retrieving Package Metadata)

------

## I. MethodChannel Implementation

### 1. Flutter Code Implementation

**Creating a MethodChannel & Receiving Parameters**

```
static const MethodChannel _channel = MethodChannel('dev.fluttercommunity.plus/package_info');

// Fetch all package metadata
static Future<PackageInfo> fromPlatform() async {
  if (_fromPlatform != null) return _fromPlatform!;

  final platformData = await PackageInfoPlatform.instance.getAll();
  _fromPlatform = PackageInfo(
    appName: platformData.appName,
    packageName: platformData.packageName,
    version: platformData.version,
    buildNumber: platformData.buildNumber,
    buildSignature: platformData.buildSignature,
    installerStore: platformData.installerStore,
  );
  return _fromPlatform!;
}
```

------

### 2. OHOS Code Implementation

**Extending FlutterPlugin & Handling Method Calls**

```
import { bundleManager } from '@ohos.bundle';

const TAG: string = "PackageInfoPlugin";
const CHANNEL_NAME = "dev.fluttercommunity.plus/package_info";

export class PackageInfoPlugin implements FlutterPlugin, MethodCallHandler {
  private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;

  getUniqueClassName(): string {
    return "PackageInfoPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG, 'Attached to engine');
    this.applicationContext = binding.getApplicationContext();
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    Log.d(TAG, 'Detached from engine');
    this.applicationContext = null;
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      if (call.method === "getAll") {
        // Fetch package info using OHOS Bundle Manager
        const bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION |
                            bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO;
        const bundleManage = bundleManager.getBundleInfoForSelfSync(bundleFlags);
        const appInfo = bundleManage.appInfo;

        // Map metadata to Flutter-friendly format
        const infoMap: Map<string, string> = new Map();
        infoMap.set("appName", this.applicationContext?.resourceManager.getStringSync(appInfo.labelId) ?? '');
        infoMap.set("packageName", bundleManage.name);
        infoMap.set("version", bundleManage.versionName);
        infoMap.set("buildNumber", bundleManage.versionCode.toString());
        infoMap.set("buildSignature", bundleManage.signatureInfo.fingerprint ?? '');
        infoMap.set("installerStore", ""); // Placeholder for store info

        result.success(infoMap);
      } else {
        result.notImplemented();
      }
    } catch (err) {
      result.error("NAME_NOT_FOUND", err.message, null);
    }
  }
}
```

------

## II. Key Code Snippets & Explanations

### **Fetching Package Metadata**

```
// OHOS-side code snippet
const bundleManage = bundleManager.getBundleInfoForSelfSync(bundleFlags);
const appInfo = bundleManage.appInfo;

// Map OHOS metadata to Flutter structure
infoMap.set("packageName", bundleManage.name); // Package name (e.g., com.example.app)
infoMap.set("version", bundleManage.versionName); // Human-readable version (e.g., 1.0.0)
infoMap.set("buildNumber", bundleManage.versionCode.toString()); // Build identifier (e.g., 123)
```

### **Handling Errors**

```
catch (err) {
  Log.e(TAG, `Error fetching package info: ${err.message}`);
  result.error("PACKAGE_INFO_ERROR", err.message, null);
}
```

------

## III. Usage Example (Flutter Side)

```
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

Future<void> showPackageInfo(BuildContext context) async {
  final packageInfo = await FlutterContacts.fromPlatform();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Package Info'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('App Name: ${packageInfo.appName}'),
              Text('Package Name: ${packageInfo.packageName}'),
              Text('Version: ${packageInfo.version} (${packageInfo.buildNumber})'),
            ],
          ),
        ),
      );
    },
  );
}
```

------

## IV. Supported Metadata Fields

| Field            | Description                          | Example Value       |
| ---------------- | ------------------------------------ | ------------------- |
| `appName`        | Display name of the application      | "My App"            |
| `packageName`    | Unique package identifier            | "com.example.myapp" |
| `version`        | User-visible version string          | "1.2.3"             |
| `buildNumber`    | Internal build identifier            | "456"               |
| `buildSignature` | SHA-256 fingerprint of the signature | "ABC123..."         |

