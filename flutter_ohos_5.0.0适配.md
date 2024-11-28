# ohos开发鸿蒙（基于5.0.0版本）

原始仓来源：https://github.com/flutter/flutter

## 1.仓库说明

```
本仓库是基于Flutter SDK对于OpenHarmony平台的兼容拓展，可支持IDE或者终端使用Flutter Tools指令编译和构建OpenHarmony应用程序。
```



## 2. 环境依赖

```sh
说明：
1.Flutter Tools指令目前已支持在Linux、Mac和Windows下使用。
2.Windows环境下flutter工程和依赖的插件工程需要在同一个磁盘。

基础环境配置：
1.配置HarmonyOS SDK和环境变量
2.API12, deveco-studio-5.0
3.下载jdk17并配置环境变量
 # windows环境
 JAVA_HOME = <JAVA_HOME path>
 PATH=%JAVA_HOME%\bin
 
4. 环境变量
# windows环境
 TOOL_HOME = D:\devecostudio-windows\DevEco Studio
 DEVECO_SDK_HOME=%TOOL_HOME%\sdk
 PATH=%TOOL_HOME%\tools\ohpm\bin
 PATH=%TOOL_HOME%\tools\hvigor\bin
 PATH=%TOOL_HOME%\tools\node
 
 
5. 通过代码工具下载当前仓库代码git clone https://gitee.com/openharmonysig/flutter_flutter.git，指定dev或master分支，并配置环境 （参考flutter环境变量配置）

6. 上述所有环境变量的配置（Windows下环境变量配置请在‘编辑系统环境变量’中设置），可参考下面的示例（其中user和具体代码路径请替换成实际路径）：

```



### 3. 构建安装包

```sh
1.运行 flutter doctor -v 检查环境变量配置是否正确，Futter与OpenHarmony应都为ok标识，若两处提示缺少环境，按提示补上相应环境即可。

2. 创建工程
flutter create --platforms ohos <projectName>

3.编译hap包，编译产物在<projectName>/ohos/entry/build/default/outputs/default/entry-default-signed.hap下。

 # 进入工程根目录编译
 # 示例：flutter build hap [--target-platform ohos-arm64] --release
 flutter build hap --release
```



### 4. 安装

```json
安装应用，通过flutter devices指令发现真机设备之后，然后安装到鸿蒙手机中。

方式一：进入编译产物目录，然后安装到鸿蒙手机中
hdc -t <deviceId> install <hap file path>

方式二：进入项目目录，直接运行安装到鸿蒙手机中
flutter run --debug -d <deviceId>

构建app包命令：
# 示例：flutter build app --release
 flutter build app --release
```



### 5.常见异常

1.Hvigor Error : BUILD unable to find “DEVECO_SDK_HOME” in the environment path

```
我们需要再系统环境变量中配置以下这个环境变量：DEVECO_SDK_HOME 指向sdk目录
```

2.Hvigor depends on the npmrc file configure the npmrc file

```
原因： `是没有配置.npmrc文件`
**解决方案：需要该文件存在C盘当前用户目录（示例：C:\Users\issuser）下创建这个文件， 文件的内容是华为npm仓库的地址**
```

3.404 GET https://registry.npm.js.org/xxxx not found

```
**解决方案：**
需要再.npmrc文件中配置下npm的仓库：
```

4.No Hmos SDK found. Try setting the HOS_SDK_HOME environment variable

```
解决方案：
这时候我们需要执行下flutter项目中的ohos的SDK

\# 指向DevEco-Studio下的sdk目录 flutter config --ohos-sdk=/Applications/DevEco-Studio.app/Contents/sdk(mac电脑上DevEco Studio的sdk路径)
```

