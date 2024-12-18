# screenshot_callback

监听系统截图

#### 注意事项

- Android需要获取存储权限才能正常使用
- 需要真机才能验证截图

#### Flutter中使用注意

如果在flutter中重写 didChangeAppLifecycleState，其中在三星手机上，侧面截图功能会执行 resumed生命周期。

    case AppLifecycleState.resumed: // 应用程序可见，前台
    _screenshotCallback.startScreenshot();
    break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
    _screenshotCallback.stopScreenshot();
    break;


####鸿蒙OS代码

#### 截图监听
    
      /**
       * 截图监听
       *
       * @param listener listener
       */
      setListener(listener: OnScreenShotListener | null) {
    this.mListener = listener
      }
    
      private onCallback: Callback<photoAccessHelper.ChangeData> = (changeData) => {
    if (changeData && changeData.type == photoAccessHelper.NotifyType.NOTIFY_ADD && changeData.uris) {
      Log.i(TAG, `listen receive screenshot->${changeData.uris}`);
      for (let photo of changeData.uris) {
    if (photo && photo.indexOf(SCREENSHOT_PREFIX) > 0) {
      this.mListener && this.mListener.onShot(photo)
      break
    }
      }
    }
      }


#### 开启截图监听

      /**
       * 开启截图监听
       *
       * @param windowClass windowClass
       */
      async startListen(windowClass: window.Window | null): Promise<void> {
    if (!windowClass) {
      Log.w(TAG, "startListen window empty")
      return
    }
    Log.i(TAG, "startListen")
    abilityAccessCtrl.createAtManager()
      .requestPermissionsFromUser(this.uiAbility?.context, ['ohos.permission.READ_IMAGEVIDEO'], async (err: BusinessError, data: PermissionRequestResult) => {
    if (err) {
      Log.e(TAG, `requestPermissionsFromUser fail, err->${JSON.stringify(err)}`);
      this.mListener && this.mListener.onScreenCapturedWithDeniedPermission()
    } else {
      Log.i(TAG, `requestPermissionsFromUser succ->${data?.permissions?.toString()}}`);
      this.phAccessHelper?.registerChange(photoAccessHelper.DefaultChangeUri.DEFAULT_PHOTO_URI, true, this.onCallback);
    }
      });
      }


#### 停止截图监听

      /**
       * 停止截图监听
       */
      stopListen(): void {
    Log.i(TAG, "startListen")
    this.phAccessHelper?.unRegisterChange(photoAccessHelper.DefaultChangeUri.DEFAULT_PHOTO_URI, this.onCallback);
      }
    }
