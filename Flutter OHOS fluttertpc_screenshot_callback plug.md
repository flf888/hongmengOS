# Screenshot Callback

System Screenshot Detection

#### Important Notes

- **Android Requirements**: Storage permissions are required for proper functionality  
- **Device Validation**: Requires physical device testing for screenshot verification  

#### Flutter Implementation Considerations

When overriding `didChangeAppLifecycleState` in Flutter:  
- On Samsung devices, side-edge screenshots trigger the `resumed` lifecycle state  
- Implement screenshot handling accordingly:

    ```dart
    case AppLifecycleState.resumed: // App visible (foreground)
      _screenshotCallback.startScreenshot();
      break;
      
    case AppLifecycleState.paused: // App not visible (background)
      _screenshotCallback.stopScreenshot();
      break;
    ```

#### HarmonyOS Implementation Code

#### Screenshot Listener
    ```typescript
    /**
     * Sets screenshot detection listener
     *
     * @param listener Callback handler
     */
    setListener(listener: OnScreenShotListener | null) {
      this.mListener = listener
    }
    
    private onCallback: Callback<photoAccessHelper.ChangeData> = (changeData) => {
      if (changeData && 
      changeData.type == photoAccessHelper.NotifyType.NOTIFY_ADD && 
      changeData.uris) {
      
    Log.i(TAG, `Detected screenshot: ${changeData.uris}`);
    
    for (let photo of changeData.uris) {
      if (photo && photo.indexOf(SCREENSHOT_PREFIX) > 0) {
    this.mListener && this.mListener.onShot(photo)
    break
      }
    }
      }
    }
    ```

#### Start Screenshot Detection
    ```typescript
    /**
     * Enables screenshot detection
     *
     * @param windowClass Window context
     */
    async startListen(windowClass: window.Window | null): Promise<void> {
      if (!windowClass) {
    Log.w(TAG, "startListen: Window context missing")
    return
      }
      
      Log.i(TAG, "Starting screenshot detection")
      
      abilityAccessCtrl.createAtManager()
    .requestPermissionsFromUser(this.uiAbility?.context, 
    ['ohos.permission.READ_IMAGEVIDEO'], 
    async (err: BusinessError, data: PermissionRequestResult) => {
      if (err) {
    Log.e(TAG, `Permission request failed: ${JSON.stringify(err)}`);
    this.mListener && this.mListener.onScreenCapturedWithDeniedPermission()
      } else {
    Log.i(TAG, `Permission granted: ${data?.permissions?.toString()}}`);
    this.phAccessHelper?.registerChange(
      photoAccessHelper.DefaultChangeUri.DEFAULT_PHOTO_URI, 
      true, 
      this.onCallback
    );
      }
    });
    }
    ```

#### Stop Screenshot Detection
    ```typescript
    /**
     * Disables screenshot detection
     */
    stopListen(): void {
      Log.i(TAG, "Stopping screenshot detection")
      this.phAccessHelper?.unRegisterChange(
    photoAccessHelper.DefaultChangeUri.DEFAULT_PHOTO_URI, 
    this.onCallback
      );
    }
    ```