# HarmonyOS next之flutter开发适配鸿蒙之开发环境搭建
##### 第一：环境搭建
1.安装 [DevEco Studio NEXT IDE](https://developer.huawei.com/consumer/cn/deveco-studio/), 注意版本应该是 Next，当前最新的是 Beta3
.下载之前需要先登录，后面的模拟器创建还要开发者验证、审核啥的，好在审核进度还可以，我这边提交申请后差不多两个小时审核通过
.找到自己电脑系统匹配的版本下载，我的电脑是Window的就选择Window版本下载
.安装步骤比较简单，一步步next直到完成即可，新版本的工具已经集成node和ohpm等环境进去了，不用单独下载安装了
2.安装Git, 如果要同时适配安卓,需要安装Android Studio; 如果要适配ios,需要安装Xcode


**Mac 安装(推荐)**
环境变量配置
```c
# Flutter Mirror
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# HarmonyOS SDK
export TOOL_HOME=/Applications/DevEco-Studio.app/Contents/
export DEVECO_SDK_HOME=$TOOL_HOME/sdk # command-line-tools/sdk
export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH # command-line-tools/ohpm/bin
export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH # command-line-tools/hvigor/bin
export PATH=$TOOL_HOME/tools/node/bin:$PATH # command-line-tools/tool/node/bin
```

**Windows 安装**
配置用户变量
```c
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

PUB_HOSTED_URL=https://pub.flutter-io.cn

DEVECO_SDK_HOME=C:\Program Files\Huawei\DevEco Studio\sdk
```


**配置环境变量**
编辑 PATH，添加以下路径
```c
C:\Program Files\Huawei\DevEco Studio\tools\ohpm\bin
C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin
C:\Program Files\Huawei\DevEco Studio\tools\node
```

**管理多个 Flutter 版本**
如果在项目开发中，需要使用多个 Flutter 版本，可以考虑使用 fvm
1.安装 [FVM](地址:https://fvm.app/)
2.使用 fvm 官方 flutter 版本
fvm install 3.22.0
3.安装自定义鸿蒙版本，进入 fvm/version 目录，通常位于用户目录下，如 ~/fvm/versions/3.22.0, 拷贝仓库并重命名为 custom_x.y.z的名字
git clone -b dev https://gitee.com/openharmony-sig/flutter_flutter.git custom_3.7.12
4.在项目中使用单独的 flutter sdk 版本, 在项目目录中执行：
fvm use custom_3.7.12



##### 第二：创建运行项目
1. 检测flutter创建鸿蒙运用条件是否可以了
运行flutter doctor -v检查环境变量配置是否正确
```c
[✓] HarmonyOS toolchain - develop for HarmonyOS devices
    • OpenHarmony Sdk at E:\ohos\DevEcoStudio\sdk, available api versions has [12:default]
    • Ohpm version 5.0.8-rc.1    #如果这里报x错误，说明上面的`PATH变量添加值 %TOOL_HOME%\tools\ohpm\bin`添加的环境变量ohpm的路径配置有问题
    • Node version v18.20.1      #如果这里报x错误，类似PATH配置的node路径有问题
    • Hvigorw binary at E:\ohos\DevEcoStudio\tools\hvigor\bin\hvigorw   #如果这里报x错误，类似PATH配置的hvigor路径有问题
```

**2. 创建flutter项目**
创建工程 方式一 该方式只创建了ohos平台
flutter create --platforms ohos <projectName>
创建工程 方式二 该方式创建了android,ios,ohos三个平台
flutter create <projectName>
进入工程根目录编译hap包，创建完项目之后，要先执行这步build才能生成依赖，如果直接使用DevEcho Studio打开会报错找不到flutter.har依赖库flutter build hap --debug


**3. 运行flutter项目到鸿蒙next手机**
方式一：通过flutter devices指令发现真机设备之后，获取device-id，进入项目目录指定构建方式编译hap包并安装到鸿蒙手机中 flutter run --debug -d <deviceId>
```c
flutter devices
  flutter run --debug -d <deviceId>
```
方式二：进入工程根目录编译hap包,然后安装到鸿蒙手机中

```c
flutter build hap --debug
  hdc -t <deviceId> install <hap file path>    # 类似Android的adb安装：adb -s <deviceId> install <apk file path>
```

方式三：使用DevEcoStudio打开项目的ohos模块
1. File --> Project Structure --> Signing Configs --> 勾选Automatically generate signature --> Apply ,可以启用启动签名，第一次执行`flutter build hap`的时候也会提示到
2. 创建模拟器：Device Manager --> 进去根据提示可以插件模拟器，不过第一次创建还需要进行开发者验证以及审核。。。
3. 重点提示一下：创建的模拟器只有x86架构的，而这篇文章我们通过flutter_flutter构建的支持鸿蒙的flutter运用只支持arm64架构的，人家文档也说明了，所以啊其实创建模拟器对flutter应用也没啥用，#要真机运行


##### 第三：打包项目
**1. 打包测试包**
```c
flutter build hap --debug
```
如果需要指定engine的话，使用--local-engine参数
使用flutter build hap --debug --local-engine=E:\ohos\flutter_image\src\out\ohos_debug_unopt_arm64，会提示失败src\out\ohos_debug_unopt_arm64\flutter.har找不到
如果提示flutter.har找不到，那就是从项目目录下的ohos\har\flutter.har拷贝一份到src\out\ohos_debug_unopt_arm64目录下，然后再执行上一步就能成功

**2. 打包正式包**
```c
flutter build hap --release 或者 flutter build hap
```
如果需要指定engine的话，使用--local-engine参数
比如flutter build hap --release --local-engine=E:\ohos\flutter_image\src\out\ohos_release_arm64，会提示失败src\out\ohos_release_arm64\flutter.har找不到
如果提示flutter.har找不到，那就是从项目目录下的ohos\har\flutter.har拷贝一份到src\out\ohos_release_arm64目录下，然后再执行上一步就能成功



**常见问题**
1.运行 flutter doctor 出现 Error: Unable to find git in your PATH.
执行以下命令
```c
git config --global --add safe.directory '*'
```

**参考资料**
[Flutter中文文档](https://docs.flutter.cn/)
[Harmonyos Next 开发文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/application-dev-guide-V5)
