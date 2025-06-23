
# HarmonyOS Next Preferences Usage Guide

HarmonyOS Next's Preferences (`@ohos.data.preferences`) provides a lightweight data persistence solution for applications, storing data as key-value pairs with support for numeric, string, boolean, and array types. Below is a detailed usage guide:

## 1. Importing Modules and Understanding Constants

1. **Import Module**  
   Import the Preferences module using:
   ```javascript
   import { preferences } from '@kit.ArkData';
   ```

2. **Constant Definitions**  
   - `MAX_KEY_LENGTH`: Maximum key length (1024 bytes)  
   - `MAX_VALUE_LENGTH`: Maximum value length (16 * 1024 * 1024 bytes)

## 2. Obtaining Preferences Instances

1. **Basic Method (API Version 9+)**  
   Use `getPreferences(context, name, callback)` or `getPreferences(context, name)` with:
   - Application context (e.g., `featureAbility.getContext()` for FA model or `this.context` in Stage model UIAbility)
   - Instance name
   - Optional asynchronous callback (`callback` or `Promise`)

   Example (FA model):

       ```javascript
       import { featureAbility } from '@kit.AbilityKit';
       import { BusinessError } from '@kit.BasicServicesKit';
    
       let context = featureAbility.getContext();
       let dataPreferences: preferences.Preferences | null = null;
       preferences.getPreferences(context, 'myStore', (err: BusinessError, val: preferences.Preferences) => {
     if (err) {
       console.error("Failed to get preferences. code=" + err.code + ", message=" + err.message);
       return;
     }
     dataPreferences = val;
     console.info("Succeeded in getting preferences.");
       });
   ```

2. **Advanced Method with Options (API Version 10+)**  
   - `getPreferences(context, options, callback)` / `getPreferences(context, options)`:  
     Pass configuration object (e.g., `{ name:'myStore' }`) with enhanced error handling
   - `getPreferencesSync(context, options)` (API Version 10+):  
     Synchronously obtains instance (note potential performance impact)

## 3. Deleting Preferences Instances

1. **Basic Deletion (API Version 11+)**  
   Use `deletePreferences(context, name, callback)` or `deletePreferences(context, name)` to:
   - Delete instance and persistent file
   - Handle via asynchronous callback (`callback` or `Promise`)
   - Set instance to `null` after deletion
   - Cannot run concurrently with other preference operations

2. **Advanced Deletion with Options (API Version 10+)**  
   `deletePreferences(context, options, callback)` / `deletePreferences(context, options)`:  
   - Handles additional error cases (e.g., `Only supported in stage mode`, `Invalid data group id`)

## 4. Removing Instances from Cache

**Cache Removal (API Version 11+)**  
Use `removePreferencesFromCache(context, name, callback)` or `removePreferencesFromCache(context, name)` to:
- Remove specified instance from cache
- Subsequent accesses reload from persistent storage
- Handle via asynchronous callback
- Set instance to `null` after removal
- Process relevant error codes

