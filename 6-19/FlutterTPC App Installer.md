# FlutterTPC App Installer

**Open App Store and Install Apps**

------

## Usage

```
String androidAppId = "";
String iOSAppId = "";
String ohosAppId = "";

AppInstaller.goStore(androidAppId, iOSAppId, ohosAppId);
AppInstaller.installApk('/sdcard/apk/app-debug.apk');
```

------

## HarmonyOS Code

### Get App Package Name

```
getAppPackageName(appId: string): string {
  let appPackageName: string = appId;
  if (appPackageName == null || appPackageName == "") {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then(bundleInfo => {
      appPackageName = bundleInfo.name;
      console.info("AppInstallerOhosPlugin appPackageName is then " + appPackageName);
    });
  }
  return appPackageName;
}
```

### Open App Market

```
/**
 * Open the app store
 */
goAppStore(appId: string, result: MethodResult) {
  if (appId == null) {
    console.info("AppInstallerOhosPlugin appPackageName is null");
    return;
  }
  try {
    const request: Want = {
      parameters: {
        bundleName: appId
      }
    };
    productViewManager.loadProduct(getContext(this) as common.UIAbilityContext, request, {
      onError: (error: BusinessError) => {
        console.info('AppInstallerOhosPlugin', `loadProduct onError.code: ${error.code}, message: ${error.message}`);
        result.success(false);
      }
    });
    result.success(true);
  } catch (err) {
    console.info('AppInstallerOhosPlugin', `loadProduct failed. code: ${err.code}, message: ${err.message}`);
    result.success(false);
  }
}
```

### Install App

```
installApp(appSrc: string) {
  // 1. Request permissions
  try {
    const atManager = abilityAccessCtrl.createAtManager();
    atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.ENTERPRISE_INSTALL_BUNDLE']).then(async (permission) => {
      // if (permission.authResults[0] !== 0) return;
      this.startInstallApp(appSrc);
    });
  } catch (err) {
    console.info('AppInstallerOhosPlugin', `Permission request failed. code: ${err.code}, message: ${err.message}`);
  }
}

startInstallApp(appSrc: string) {
  // 2. Install the app
  const bundleId: string = this.getAppPackageName('');
  const wantTemp: Want = {
    bundleName: bundleId.toString(),
    abilityName: 'EntryAbility'
  };
  const hapFilePaths: string[] = [appSrc];

  installBundle.install(wantTemp, hapFilePaths).then(() => {
    console.info('AppInstallerOhosPlugin Succeeded in installing bundles.');
  }).catch((err: BusinessError) => {
    console.error(`AppInstallerOhosPlugin Failed to install bundles. Code: ${err.code}, message: ${err.message}`);
  });
}
```

------

## Key Features

- **Cross-Platform Support**: Works for Android, iOS, and HarmonyOS.
- **Permission Handling**: Requests enterprise installation permissions dynamically.
- **Error Handling**: Provides detailed logs for debugging.
