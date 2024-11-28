# 鸿蒙Flutter环境相关问题

**建议使用的开发工具版本**

flutter 3.7.12-ohos 版本

1. python3.8 - python3.11
2. java17
3. node18
4. ohpm1.6+
5. HamonyOS SDK api11
6. Xcode14.3



**断网环境 flutter pub get 执行失败**

解决方案：
加上 --offline 参数，完整命令 `flutter pub get --offline`



**mac环境release版本的应用编译失败**

报错日志：

```log
ProcessPackageException: ProcessException: Found candidates, but lacked sufficient permissions to excute "/Users/xxx/ohos/src/out/ohos_release_arm64/clang_arm4/dart".
  Command: /Users/xxx/ohos/src/out/ohos_release_arm64/clang_arm4/dart
```

解决方案：添加执行权限

```sh
chmod -R +x /Users/xxx/ohos/src/out/ohos_release_arm64/*
```

mac环境可能还需要手动点击 src/out/ohos_release_arm64/clang_arm64 目录下的 `dart` 和 `gen_snapshot`，并在「设置->隐私与安全->安全性」中允许程序运行。



**flutter从Windows复制到linux或mac环境后无法运行**

报错日志：

```log
curl: (3) Illegal characters found in URL
xxx/flutter_flutter/bin/internal/update_dart_sdk.sh: line 156: return: can only return from a function or sourced script
curl: (3) Illegal characters found in URL
```

问题分析：Windows上的换行符和linux/mac不一致导致的。

解决方案：

```sh
# 将文件 target_file 中的换行符由 CRLF（\r\n）替换为 LF（\n）
sed -i "s/\r//" target_file
# 将 bin/dart、bin/*.sh 和 bin/internal/*.version 中的换行符换位LF
cd flutter
## linux环境执行
sed -i "s/\r//" bin/dart $(find bin -name "*.sh") $(find bin -name "*.version")
## mac环境执行
sed -i "" "s/\r//" bin/dart $(find bin -name "*.sh") $(find bin -name "*.version")
```



**~/.npmrc 的配置**

```sh
registry=https://repo.huaweicloud.com/repository/npm/
@ohos:registry=https://repo.harmonyos.com/npm/
strict-ssl=false
# 设置代理
# http_proxy=http://user:password@host:8080
# https_proxy=http://user:password@host:8080
```



**~/.ohpmrc 的配置**

```sh
registry=https://repo.harmonyos.com/ohpm/
strict_ssl=false
# 设置代理
# http_proxy=http://user:password@host:8080
# https_proxy=http://user:password@host:8080
```



**模拟器运行默认计数器应用闪退**

问题分析:

- FloatingActionButton 在模拟器上不支持，需要在 lib/main.dart 中注释 FloatingActionButton 后再运行到模拟器上。
- [模拟器与真机的差异](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-emulator-specification-0000001839876358-V5)



iosGeneratedPluginRegistrant.m Module not found

问题分析：pubspec.yaml 中新增了flutter插件，但是 Podfile 中没有新增插件相关的pod引用。

解决方案：`rm ios/podfile && flutter clean && flutter run -d <ios_device>`

参考链接：[GeneratedPluginRegistrant.m Module not found](https://github.com/flutter/flutter/issues/43986)



【Windows】 flutter doctor -v 无反应

现象： 配置好环境变量后，执行flutter doctor -v没有反应

原因： 可能是没有配置好代理

解决：
- 在系统环境变量中配置http_proxy, https_proxy, no_proxy环境变量
- http_proxy参考deveco代理配置
- https_proxy可以等于http_proxy
- no_proxy参考deveco代理配置外，还需要添加
     - localhost
     - ::1
     - 127.0.0.1     

执行结果有Flutter和HarmonyOS（表明基础环境配置正确，这两个平台均被支持）
![error](https://p.ipic.vip/1slii5.png)