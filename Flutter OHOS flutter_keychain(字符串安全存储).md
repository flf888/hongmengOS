# flutter_keychain

一个支持通过 Keychain 和 Keystore 支持字符串安全存储的 Flutter 插件

如果您有其他类型想要存储，则需要序列化为 UTF-8 字符串。

## 使用

    import 'package:flutter_keychain/flutter_keychain.dart';
    ...
    
    // Get value
    var value = await FlutterKeychain.get(key: "key");
    
    // Put value
    await FlutterKeychain.put(key: "key", value: "value");
    
    // Remove item
    await FlutterKeychain.remove(key: "key");
    
    // Clear the secure store
    await FlutterKeychain.clear();


#### 鸿蒙OS代码

### RSA 密钥封装

>     async encrypt(input: string): Promise<string{
>     const options: huks.HuksOptions = {
>       properties: this.getAesEncryptProperties(),
>       inData: StringToUint8Array(input)
>     }
>     try {
>       let huksSessionHandle: huks.HuksSessionHandle = await huks.initSession(this.keyAlias, options)
>       let handle: number = huksSessionHandle.handle
>       let huksReturnResult: huks.HuksReturnResult = await huks.finishSession(handle, options)
>       let cipherData: Uint8Array = huksReturnResult.outData as Uint8Array
>       return Uint8ArrayToString(cipherData)
>     } catch (err) {
>       Log.e(TAG, "Failed to encrypt, err =" + JSON.stringify(err))
>     }
>     return ''
>       }
>     
>       async decrypt(input: string): Promise<string{
>     const options: huks.HuksOptions = {
>       properties: this.getAesDecryptProperties(),
>       inData: StringToUint8Array(input)
>     }
>     try {
>       let huksSessionHandle: huks.HuksSessionHandle = await huks.initSession(this.keyAlias, options)
>       let handle: number = huksSessionHandle.handle
>       let huksReturnResult: huks.HuksReturnResult = await huks.finishSession(handle, options)
>       let cipherData: Uint8Array = huksReturnResult.outData as Uint8Array
>       return Uint8ArrayToString(cipherData)
>     } catch (err) {
>       Log.e(TAG, "Failed to decrypt, err =" + JSON.stringify(err))
>     }
>     return ''
>       }


### 存储

    	  put(result: MethodResult, key: string, value: string) {
    this.encryptor?.encrypt(value).then((value) => {
      if (value) {
    const data = StringToUint8Array(value)
    this.preferences?.put(key, data)
    this.preferences?.flush()
      }
    }).finally(() => {
      result.success(null)
    })
      }
    
### 获取
	
    	  get(result: MethodResult, key: string) {
    if (this.preferences) {
      this.preferences.get(key, null).then(async (encryptedValue) => {
    if (encryptedValue) {
      try {
    const data = Uint8ArrayToString(encryptedValue as Uint8Array)
    let decryptValue = await this.encryptor?.decrypt(data)
    result.success(decryptValue)
      } catch (err) {
    result.error(this.resultErrorName, err?.message, err)
      }
    } else {
      result.success(null)
    }
      })
    } else {
      result.success(null)
    }
      }

### 移除
     
       remove(result: MethodResult, key: string) {
    this.preferences?.delete(key).then(() => {
      this.preferences?.flush()
    }).finally(() => {
      result.success(null)
    })
      }

### 清空

       clear(result: MethodResult) {
    this.preferences?.clear().then(() => {
      this.preferences?.flush()
    }).finally(() => {
      result.success(null)
    })
      }

### 刷新

       flush() {
    try {
      let promise = this.preferences?.flush();
      promise?.then(() => {
    Log.i(TAG, "Succeeded in flushing.");
      }).catch((err: ESObject) => {
    Log.w(TAG, "Failed to flush." + JSON.stringify(err));
      })
    } catch (err) {
      Log.w(TAG, "Failed to flush." + JSON.stringify(err));
    }
      }

