### RSA Key Encapsulation

```
// Encrypt data using AES encryption
async encrypt(input: string): Promise<string> {
  const options: huks.HuksOptions = {
    properties: this.getAesEncryptProperties(), // Get encryption configuration
    inData: StringToUint8Array(input) // Convert input string to Uint8Array
  };
  try {
    // Initialize encryption session
    let huksSessionHandle: huks.HuksSessionHandle = await huks.initSession(this.keyAlias, options);
    let handle: number = huksSessionHandle.handle;
    // Finalize encryption and retrieve ciphertext
    let huksReturnResult: huks.HuksReturnResult = await huks.finishSession(handle, options);
    let cipherData: Uint8Array = huksReturnResult.outData as Uint8Array;
    return Uint8ArrayToString(cipherData); // Convert ciphertext to string
  } catch (err) {
    Log.e(TAG, `Encryption failed: ${JSON.stringify(err)}`);
  }
  return '';
}

// Decrypt data using AES decryption
async decrypt(input: string): Promise<string> {
  const options: huks.HuksOptions = {
    properties: this.getAesDecryptProperties(), // Get decryption configuration
    inData: StringToUint8Array(input) // Convert input string to Uint8Array
  };
  try {
    // Initialize decryption session
    let huksSessionHandle: huks.HuksSessionHandle = await huks.initSession(this.keyAlias, options);
    let handle: number = huksSessionHandle.handle;
    // Finalize decryption and retrieve plaintext
    let huksReturnResult: huks.HuksReturnResult = await huks.finishSession(handle, options);
    let cipherData: Uint8Array = huksReturnResult.outData as Uint8Array;
    return Uint8ArrayToString(cipherData); // Convert plaintext to string
  } catch (err) {
    Log.e(TAG, `Decryption failed: ${JSON.stringify(err)}`);
  }
  return '';
}
```

------

### Secure Storage Operations

```
// Store encrypted value in Keychain/Keystore
put(result: MethodResult, key: string, value: string) {
  this.encryptor?.encrypt(value).then((encryptedValue) => {
    if (encryptedValue) {
      const data = StringToUint8Array(encryptedValue);
      this.preferences?.put(key, data); // Store encrypted data
      this.preferences?.flush(); // Ensure data persistence
    }
  }).finally(() => {
    result.success(null); // Return success status
  });
}

// Retrieve and decrypt stored value
get(result: MethodResult, key: string) {
  if (this.preferences) {
    this.preferences.get(key, null).then(async (encryptedValue) => {
      if (encryptedValue) {
        try {
          const data = Uint8ArrayToString(encryptedValue as Uint8Array);
          const decryptedValue = await this.encryptor?.decrypt(data); // Decrypt data
          result.success(decryptedValue); // Return decrypted value
        } catch (err) {
          result.error(this.resultErrorName, err?.message, err); // Handle decryption errors
        }
      } else {
        result.success(null); // Return null if no value found
      }
    });
  } else {
    result.success(null); // Return null if storage unavailable
  }
}

// Remove stored value
remove(result: MethodResult, key: string) {
  this.preferences?.delete(key).then(() => {
    this.preferences?.flush(); // Ensure deletion persistence
  }).finally(() => {
    result.success(null); // Return success status
  });
}

// Clear all stored values
clear(result: MethodResult) {
  this.preferences?.clear().then(() => {
    this.preferences?.flush(); // Ensure cache clearance
  }).finally(() => {
    result.success(null); // Return success status
  });
}

// Flush pending changes to storage
flush() {
  try {
    let promise = this.preferences?.flush();
    promise?.then(() => {
      Log.i(TAG, "Flush operation succeeded.");
    }).catch((err: ESObject) => {
      Log.w(TAG, `Flush failed: ${JSON.stringify(err)}`);
    });
  } catch (err) {
    Log.w(TAG, `Flush failed: ${JSON.stringify(err)}`);
  }
}
```

------

### Key Notes

1. **Encryption Workflow**:
   - Uses Huawei KeyStore (Huks) for AES encryption/decryption
   - Converts strings to `Uint8Array` for secure storage
2. **Storage Abstraction**:
   - Relies on Flutter `MethodResult` for cross-platform communication
   - Implements `flush()` to ensure data persistence
3. **Error Handling**:
   - Catches and logs exceptions during crypto operations
   - Returns `null`/empty strings for invalid inputs
