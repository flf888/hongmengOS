#  HarmonyOS next之flutter鸿蒙项目初体验

### 1.基础的环境变量配置

```
# flutter 基础环境配置

export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 拉取下来的flutter_flutter/bin目录

export PATH=/Users/admin/ohos/flutter_flutter/bin:$PATH

# HamonyOS SDK 环境配置

export TOOL_HOME=/Applications/DevEco-Studio.app/Contents # mac环境
export DEVECO_SDK_HOME=$TOOL_HOME/sdk # command-line-tools/sdk
export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH # command-line-tools/ohpm/bin
export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH # command-line-tools/hvigor/bin
export PATH=$TOOL_HOME/tools/node/bin:$PATH # command-line-tools/tool/node/bin
export HDC_HOME=$TOOL_HOME/sdk/HarmonyOS-NEXT-DB1/openharmony/toolchains # hdc指令（可选）

# 可选配置项(使用Android Studio 或者 Visual Studio Code调试时需要配置此项，jdk版本为17.0.12)

JAVA_HOME=/Users/admin/Documents/JDK/jdk-17.0.12.jdk/Contents/Home
PATH=$JAVA_HOME/bin:$PATH:.
export JAVA_HOME
export PATH

# 可选配置项（防止由于flutter鸿蒙版的git下载地址环境变量不匹配，影响后续的flutter项目创建）

export FLUTTER_GIT_URL=https://gitee.com/openharmony-sig/flutter_flutter.git

# 非必选配置项（若command-line-tools目录下的tool文件里存在node环境，则无需配置，若无则可进行如下单独配置）

# export NODE_HOME=/Users/admin/node/node-18.14.1

# export PATH=$PATH:$NODE_HOME/bin
```

```
注意：上面是mac配置环境 

如果是mac请记得 source ~/.bash_profile

如果是windows 请配置在环境变量里面
```



### 2.检查本地环境

运行```flutter doctor -v```检查环境变量配置是否正确，Futter与OpenHarmony应都为ok标识，若两处提示缺少环境，按提示补上相应环境即可。



![doctor1](https://raw.githubusercontent.com/shaolongmin/typoraImg/main/doctor1.png?token=ABIIT5VBEK7LJTGGIWJNGHTHEHKLE)

### 3.创建flutter工程

创建工程与编译命令，编译产物在${projectName}/ohos/entry/build/default/outputs/default/entry-default-signed.hap下

```
# 创建工程 方式一 该方式只创建了ohos平台

flutter create --platforms ohos <projectName> 

# 创建工程 方式二 该方式创建了android,ios,ohos三个平台

flutter create  <projectName> 

# 进入工程根目录编译hap包

flutter build hap --debug
```

### 4.项目签名

直接使用DevEco Studio 打开 使用软件签名即可

### 5.直接真机测试运行

```
使用DevEco Studio 查看设备真机是否链接，如果链接直接启动即可。
```

```
注意：如果没有真机需要使用模拟器，可参观官方文档配置
```

​                            
