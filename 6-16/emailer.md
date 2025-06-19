### Check if Application is Installed

```
/**
 * Check if the application is installed
 * 
 * @param bundleName Package name
 * @returns Whether the application is installed
 */
private async hasInstalled(bundleName: string): Promise<boolean> {
  if (!bundleName) {
    Log.w(TAG, 'Package query failed: Bundle name is empty');
    return false;
  }
  let isInstalled: boolean = false;
  await packageBundle.hasInstalled({
    bundleName: bundleName,
    success: (data) => {
      Log.i(TAG, `Package installation result: ${data?.result}`);
      isInstalled = data?.result || false;
    },
    fail: (data: string, code) => {
      Log.w(TAG, `Failed to get package result: Code ${code}, Data: ${data}`);
      isInstalled = false;
    },
  });
  return isInstalled;
}
```

------

### Send Email

```
function sendEmail() {
  // Create intent for sending email
  const emailIntent = new ability.Intent();
  
  // Set action to trigger email client
  emailIntent.setAction('ohos.action.SEND');
  
  // Set data type to 'mailto:'
  emailIntent.setData('mailto:');
  
  // Configure email parameters
  emailIntent.setParameter('android.intent.extra.EMAIL', ['recipient@example.com']); // Recipients
  emailIntent.setParameter('android.intent.extra.SUBJECT', 'Test Email Subject'); // Subject
  emailIntent.setParameter('android.intent.extra.TEXT', 'This is a test email body.'); // Body
  
  // Start email client activity
  ability.startAbility({
    want: emailIntent
  }).then(() => {
    console.log('Email client launched successfully.');
  }).catch((error) => {
    console.error('Failed to launch email client:', error);
  });
}
```

------

### Key Notes

1. **Intent Actions**:
   - Uses `ohos.action.SEND` to trigger system email clients.
   - `mailto:` data type ensures email fields are pre-filled.
2. **Parameter Keys**:
   - `android.intent.extra.EMAIL`/`SUBJECT`/`TEXT` are standard Android intent extras compatible with HarmonyOS.
3. **Error Handling**:
   - Asynchronous operations use Promises with `success`/`fail` callbacks.
   - Logs detailed error messages for debugging.
