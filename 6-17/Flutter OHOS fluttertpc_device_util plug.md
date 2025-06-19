# fluttertpc_device_util

HarmonyOS Device Utility Library

#### Flutter Code Implementation

- **Create Method Channel**
	```dart
	static const MethodChannel _channel = const MethodChannel('device_util');
	```

- **Get Version Name**
	```dart
	/// The version name of this application
	static Future<String> get versionName async {
	  final String version = await _channel.invokeMethod('getVersionName');
	  return version;
	}
	```

- **Get Version Code**
	```dart
	/// The version code of this application
	static Future<String> get versionCode async {
	  final String version = await _channel.invokeMethod('getVersionCode');
	  return version;
	}
	```

- **Open Network Settings Page**
	```dart
	/// Open the device's network settings page
	static Future<Null> openNetworkSettingPage() async {
	  await _channel.invokeMethod('launchNoNetwork');
	}
	```

- **Open Application Settings**
	```dart
	/// Open settings page for the current application
	static Future<Null> openApplicationSettingPage() async {
	  await _channel.invokeMethod('systemSettingPage');
	}
	```

- **Get Device Information**
	```dart
	static Future<Map<String, String>> get getChannelInfo async {
	  final Map<String, String> channelInfo =
	    Map<String, String>.from(await _channel.invokeMethod('getChannelInfo'));
	  return channelInfo;
	}
	```

- **Terminate Application**
	```dart
	/// Terminate current application process and exit
	static Future<Null> killApp() async {
	  await _channel.invokeMethod('killApp');
	}
	```

#### HarmonyOS Implementation Code

    ```typescript
    export class Utils {
      /**
       * Get system version information
       *
       * @return System version
       */
      public static getDeviceBuildInfo(): string {
    return deviceInfo.osFullName;
      }
    
      /**
       * Get application bundle information
       *
       * @return BundleInfo object
       */
      public static getAppBundleInfo(): Promise<bundleManager.BundleInfo> {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    return bundleManager.getBundleInfoForSelf(bundleFlags);
      }
    
      /**
       * Get channel information
       * (Hardcoded to Huawei AppGallery for HarmonyOS)
       *
       * @return Channel information map
       */
      public static getChannelInfo(): Map<string, string> {
    const channelInfo = new Map<string, string>();
    channelInfo.set("first_install_channel", "Huawei AppGallery For Harmony");
    channelInfo.set("current_install_channel", "Huawei AppGallery For Harmony");
    return channelInfo;
      }
    
      /**
       * Navigate to system settings
       *
       * @param uiAbility Current UIAbility context
       */
      public static jumpToSettings(uiAbility: UIAbility | null): void {
    if (!uiAbility) {
      Log.i(TAG, "jumpToSettings context empty");
      return;
    }
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
    };
    uiAbility.context.startAbility(want).catch((err: BusinessError) => {
      Log.e(TAG, "jumpToSettings error: " + err);
    });
      }
    
      /**
       * Navigate to Wi-Fi settings
       *
       * @param uiAbility Current UIAbility context
       */
      public static jumpToWifiSettings(uiAbility: UIAbility | null): void {
    if (!uiAbility) {
      Log.i(TAG, "jumpToWifiSettings context empty");
      return;
    }
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'wifi_entry'
    };
    uiAbility.context.startAbility(want).catch((err: BusinessError) => {
      Log.e(TAG, "jumpToWifiSettings error: " + err);
    });
      }
    
      /**
       * Navigate to app marketplace
       *
       * @param uiAbility Current UIAbility context
       */
      public static async jumpToMarket(uiAbility: UIAbility | null): Promise<void> {
    if (!uiAbility) {
      Log.i(TAG, "jumpToMarket context empty");
      return;
    }
    try {
      let bundleInfo: bundleManager.BundleInfo = await Utils.getAppBundleInfo();
      let bundleName: string | undefined = bundleInfo?.name;
      if (!bundleName) {
    Log.e(TAG, "jumpToMarket: get bundle name failed");
    return;
      }
      let want: Want = {
    parameters: { bundleName: bundleName }
      };
      productViewManager.loadProduct(uiAbility.context, want, {
    onError: (error: BusinessError) => {
      Log.e(TAG, "jumpToMarket error: " + error);
    }
      });
    } catch (error) {
      Log.e(TAG, "jumpToMarket exception: " + error);
    }
      }
    
      /**
       * Terminate application process
       */
      public static killApp(): void {
    Log.i(TAG, "Terminating application");
    let pro = new process.ProcessManager();
    pro.exit(0);
      }
    }
    ```
