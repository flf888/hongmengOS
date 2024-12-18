# fluttertpc_device_util

鸿蒙设备工具类

#### Flutter代码调用

- 创建通道
	`static const MethodChannel _channel = const MethodChannel('device_util');`
- 获取version name

>       /// The version name of this application
>       static Future<Stringget versionName async {
>     final String version = await _channel.invokeMethod('getVersionName');
>     return version;
>       }


- 获取version code

>       /// The version code name of this application
>       static Future<Stringget versionCode async {
>     final String version = await _channel.invokeMethod('getVersionCode');
>     return version;
>       }

- 打开手机的网络设置页面

>     	  /// Open the phone's network settings page
>       static Future<NullopenNetworkSettingPage() async {
>     await _channel.invokeMethod('launchNoNetwork');
>       }

- 打开手机设置页面

 >      /// Open the settings page of the currently running application
>       static Future<NullopenApplicationSettingPage() async {
>     await _channel.invokeMethod('systemSettingPage');
>       }

- 获取手机信息

>     	 static Future<Map<String, String>get getChannelInfo async {
>     final Map<String, StringchannelInfo =
>     Map<String, String>.from(await _channel.invokeMethod('getChannelInfo'));
>     return channelInfo;
>       }

- 终止当前应用程序进程并退出

>     	  /// Kill the current application process and exit (Only supports Android)
>       static Future<NullkillApp() async {
>     await _channel.invokeMethod('killApp');
>       }





####鸿蒙OS代码

	    export class Utils {
      /**
       * 获取系统版本
       *
       * @return 系统版本
       */
      public static getDeviceBuildInfo(): string {
    return deviceInfo.osFullName
      }
    
      /**
       * 获取app信息
       *
       * @return BundleInfo
       */
      public static getAppBundleInfo(): Promise<bundleManager.BundleInfo> {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    return bundleManager.getBundleInfoForSelf(bundleFlags)
      }
    
      /**
       * 渠道（鸿蒙固定写华为商店）
       *
       * @return 渠道
       */
      public static getChannelInfo(): Map<string, string> {
    const channelInfo = new Map<string, string>()
    channelInfo.set("first_install_channel", "Huawei Store For Harmony")
    channelInfo.set("current_install_channel", "Huawei Store For Harmony")
    return channelInfo
      }
    
      /**
       * 跳转系统设置
       *
       * @param uiAbility 上下文
       */
      public static jumpToSettings(uiAbility: UIAbility | null): void {
    if (!uiAbility) {
      Log.i(TAG, "jumpToSettings context empty")
      return
    }
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
    }
    uiAbility.context.startAbility(want).then(() => {
    }).catch((err: BusinessError) => {
      Log.e(TAG, "jumpToSettings: " + err)
    })
      }
    
      /**
       * 跳转系统网络设置
       *
       * @param uiAbility 上下文
       */
      public static jumpToWifiSettings(uiAbility: UIAbility | null): void {
    if (!uiAbility) {
      Log.i(TAG, "jumpToWifiSettings context empty")
      return
    }
    let want: Want = {
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'wifi_entry'
    }
    uiAbility.context.startAbility(want).then(() => {
    }).catch((err: BusinessError) => {
      Log.e(TAG, "jumpToWifiSettings: " + err)
    })
      }
    
      /**
       * 跳转应用市场
       *
       * @param uiAbility 上下文
       */
      public static async jumpToMarket(uiAbility: UIAbility | null): Promise<void> {
    if (!uiAbility) {
      Log.i(TAG, "jumpToMarket context empty")
      return
    }
    let bundleInfo: bundleManager.BundleInfo = await Utils.getAppBundleInfo()
    let bundleName: string | undefined = bundleInfo?.name
    if (!bundleName) {
      Log.e(TAG, "jumpToMarket: get bundlename failed")
      return
    }
    let want: Want = {
      parameters: {
    // 此处填入要加载的应用包名，例如： bundleName: "com.huawei.hmsapp.appgallery"
    bundleName: bundleName
      }
    }
    productViewManager.loadProduct(uiAbility.context, want, {
      onError: (error: BusinessError) => {
    Log.e(TAG, "jumpToMarket: " + error)
      }
    });
      }
    
      /**
       * 杀进程
       */
      public static killApp(): void {
    Log.i(TAG, "killApp")
    let pro = new process.ProcessManager()
    pro.exit(0)
      }
    }