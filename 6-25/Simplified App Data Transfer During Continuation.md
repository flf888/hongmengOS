# Simplified App Data Transfer During Continuation

## Introduction

Application Continuation allows users to seamlessly switch between devices while maintaining the same application experience. For example, when a user's context changes (e.g., moving to a more suitable device), they can transfer their current task to a new device. After continuation, the original device's application can exit or remain while the user focuses on the new device.

Official documentation:

### (1) Device Requirements

- Both devices must be logged into the same Huawei account
- Both devices must have Wi-Fi and Bluetooth enabled
- Both devices must have the same application installed
- Continuation only works between the same UIAbility

### (2) Configuration

In `module.json5`, set the `continuable` tag to `true` for the ability:

```
"abilities": [
  {
    "name": "EntryAbility",
    "continuable": true,
    // ... other configs
  }
]
```

### (3) Data Transfer Implementation

#### Receiving Device (Target)

In `EntryAbility.onCreate`, initialize continuation and handle transferred data (e.g., login status):

```
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  initContinuable(want, () => {
    this.context.restoreWindowStage(new LocalStorage());
  });
}

// Initialize continuation
initContinuable(want: Want, callBack: Function) {
  if (want.parameters) {
    // Check if launched via continuation
    let is_continuable = want.parameters['is_continuable'] || 0;
    
    // Get transferred login data
    let access_token = want.parameters['access_token'] + '' || '';
    let is_guest = want.parameters['is_guest'] || 0;
    
    if (is_continuable == 1) {
      // Process login data
      UserCacheManager.setLoginToken(access_token);
      UserCacheManager.updateGuestStatus(is_guest == 1);
      
      // Fetch user info and restore UI
      Utils.getUserInfo();
      callBack();
    }
  }
}
```

#### Sending Device (Source)

In `EntryAbility.onContinue`, prepare data for transfer:

```
onContinue(wantParam: Record<string, Object>) {
  // Prepare data for transfer
  preContinuable(wantParam);
  
  // Return AGREE to allow continuation
  return AbilityConstant.OnContinueResult.AGREE;
}

// Prepare transfer data
preContinuable(wantParam: Record<string, Object>) {
  // Set continuation flag
  wantParam["is_continuable"] = 1;
  
  // Add login credentials
  wantParam["access_token"] = UserCacheManager.getLoginToken();
  wantParam["is_guest"] = UserCacheManager.isGuestLogin() ? 1 : 0;
}
```

### Key Notes

1. **Synchronous Operations**: All operations in `onContinue` must be synchronous. Asynchronous code may prevent data transfer.
2. **Data Packaging**: Transfer only essential data (e.g., authentication tokens) rather than full application state.
3. **Error Handling**: Return `REJECT` in `onContinue` if continuation isn't possible due to errors or invalid state.

This implementation ensures a seamless transition between devices by transferring minimal essential data while maintaining user authentication state.