# Flutter Environment Issues on HarmonyOS

**Recommended Development Tool Versions**

- Flutter 3.7.12-ohos
- Python 3.8 - 3.11
- Java 17
- Node 18
- ohpm 1.6+
- HarmonyOS SDK API 11
- Xcode 14.3

------

### **`flutter pub get` Fails in Offline Environments**

**Solution**: Use `--offline` flag:

```
flutter pub get --offline
```

------

### **Release Build Failure on macOS**

**Error Log**:

```
ProcessPackageException: ProcessException: Found candidates, but lacked sufficient permissions to execute "/Users/xxx/ohos/src/out/ohos_release_arm64/clang_arm4/dart".
```

**Solution**: Add execute permissions:

```
chmod -R +x /Users/xxx/ohos/src/out/ohos_release_arm64/*
```

**Additional macOS Steps**:

1. Manually run `dart` and `gen_snapshot` in `src/out/ohos_release_arm64/clang_arm64/`
2. Go to *System Settings → Privacy & Security → Security*
3. Allow execution of these programs

------

### **Flutter Fails After Copying from Windows to Linux/macOS**

**Error Log**:

```
curl: (3) Illegal characters found in URL
xxx/flutter_flutter/bin/internal/update_dart_sdk.sh: line 156: return: can only return from a function or sourced script
```

**Cause**: CRLF (Windows) vs LF (Unix) line ending mismatch

**Solution**:

```
# Linux:
sed -i "s/\r//" bin/dart $(find bin -name "*.sh") $(find bin -name "*.version")

# macOS:
sed -i "" "s/\r//" bin/dart $(find bin -name "*.sh") $(find bin -name "*.version")
```

------

### **~/.npmrc Configuration**

```
registry=https://repo.huaweicloud.com/repository/npm/
@ohos:registry=https://repo.harmonyos.com/npm/
strict-ssl=false
# Proxy example:
# http_proxy=http://user:password@host:8080
# https_proxy=http://user:password@host:8080
```

------

### **~/.ohpmrc Configuration**

```
registry=https://repo.harmonyos.com/ohpm/
strict_ssl=false
# Proxy example:
# http_proxy=http://user:password@host:8080
# https_proxy=http://user:password@host:8080
```

------

### **Emulator Crash with Default Counter App**

**Cause**:

- `FloatingActionButton` not supported in emulator
- [Emulator vs Real Device Differences](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-emulator-specification-0000001839876358-V5)

**Solution**: Comment out `FloatingActionButton` in `lib/main.dart`

------

### **iosGeneratedPluginRegistrant.m Module Not Found**

**Cause**: New Flutter plugins added without updating Podfile

**Solution**:

```
rm ios/Podfile && flutter clean && flutter run -d <ios_device>
```

Reference: [GeneratedPluginRegistrant.m Module not found](https://github.com/flutter/flutter/issues/43986)

------

### **`flutter doctor -v` Hangs on Windows**

**Symptoms**: No response after environment setup

**Cause**: Proxy misconfiguration

**Solution**: Configure system environment variables:

```
HTTP_PROXY=http://your-proxy:port
HTTPS_PROXY=http://your-proxy:port  # Can match HTTP_PROXY
NO_PROXY=localhost,::1,127.0.0.1,additional-domains
```

**Successful Output**: Shows both Flutter and HarmonyOS support![error](https://p.ipic.vip/1slii5.png)