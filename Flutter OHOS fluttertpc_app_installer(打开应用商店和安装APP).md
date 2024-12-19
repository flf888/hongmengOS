# fluttertpc_app_installer

打开应用商店和安装APP

## 用法
		

    String androidAppId = '';
    String iOSAppId = '';
	String ohosAppId = '';
    
    AppInstaller.goStore(androidAppId, iOSAppId, ohosAppId);
		

    AppInstaller.installApk('/sdcard/apk/app-debug.apk');
  
  

#### 鸿蒙OS代码

### 获取app包名

         getAppPackageName(appId: String): String {
    let appPackageName: String = appId;
    if (appPackageName == null || appPackageName == '') {
      bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then(bundleInfo => {
    appPackageName = bundleInfo.name;
    console.info("AppInstallerOhosPlugin appPackageName is then  " + appPackageName);
      });
    }
    return appPackageName;
      }



### 打开市场

        /**
       * open appstore
       * */
      goAppStore(appId: String, result: MethodResult) {
    if (appId == null) {
      console.info("AppInstallerOhosPlugin appPackageName is null  ");
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
      console.info('AppInstallerOhosPlugin',
    `loadProduct onError.code is ${error.code}, message is ${error.message}`);
      result.success(false);
    }
      });
      result.success(true);
    } catch (err) {
      console.info('AppInstallerOhosPlugin', `loadProduct failed.code is ${err.code}, message is ${err.message}`);
      result.success(false);
    }
      }

### 安装app

      installApp(appSrc: String) {
    //1.get permissions
    try {
      let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
      atManager.requestPermissionsFromUser(getContext(this), ['ohos.permission.ENTERPRISE_INSTALL_BUNDLE'])
    .then(async (permission) => {
      // if (permission.authResults[0] !== 0) {
      //   return
      // }
      this.startInstallApp(appSrc);
    });
    } catch (err) {
      console.info('AppInstallerOhosPlugin',
    `Permission application failed.code is ${err.code}, message is ${err.message}`);
    }
      }


      startInstallApp(appSrc: String) {
    //2.to install
    let bundleId: String = this.getAppPackageName('');
    let wantTemp: Want = {
      bundleName: bundleId.toString(),
      abilityName: 'EntryAbility',
    };
    let hapFilePaths: Array<string> = [appSrc?.toString()];
    
    installBundle.install(wantTemp, hapFilePaths).then(() => {
      console.info('AppInstallerOhosPlugin Succeeded in installing bundles.');
    }).catch((err: BusinessError) => {
      console.error(`AppInstallerOhosPlugin Failed to install bundles. Code is ${err.code}, message is ${err.message}`);
    });
      }


