## 一.  HarmonyOS next之Flutter开发鸿蒙，终端一体化

### 1.flutter鸿蒙一体化介绍

Flutter 作为一个跨平台的UI框架，其主要目的是让开发者能够用一套代码库来构建iOS、Android以及其他平台（如Web、Windows、macOS等）的应用程序。对于HarmonyOS，虽然它本身不是Flutter的目标平台之一，但由于Flutter的灵活性以及其底层引擎的能力，理论上可以进行一些调整来使Flutter应用能够运行在HarmonyOS上。目前，华为已经为开发者提供了一种方式来使Flutter应用能够在HarmonyOS设备上运行。    

Flutter Engine是Flutter的核心渲染引擎，它允许开发者将Flutter嵌入到非Flutter环境中。HarmonyOS可以通过集成Flutter Engine来支持Flutter应用。这意味着开发者可以创建原生的HarmonyOS应用程序，并在其中嵌入Flutter组件。目前已经有开源engine支持harmonyOS
https://gitee.com/openharmony-sig/flutter_flutter/tree/dev/ 当前项目已经支持Linux、Mac、Windows环境下使用。

### 2.鸿蒙版Flutter环境搭建指导


#### 

#### 2.1、环境准备


1.1 官方下载地址鸿蒙开发套件官方下载地址：[https://developer.huawei.com/consumer/cn/download/](https://developer.huawei.com/consumer/cn/download/)

```
注意事项：
（1）目前支持操作系统Linux、Mac、Windows环境下使用
（2）mac系统在终端输入"uname -m"判断系统架构选择对应的开发组件套
   如果输出结果是 x86_64，则表示你的系统是x86-64架构
   如果输出结果是 arm64，则表示你的系统是arm64架构
```


#### 2.2、下载清单

（1）根据自身所用电脑系统下载对应最新版DevEco Studio

![](D:\work\hormonyMD\img.png)

（2）若无鸿蒙真机，需在DevEco Studio中下载模拟器模拟器下载和安装步骤见：
2.2 安装模拟器
（3）下载鸿蒙版flutter项目地址：

```
https://gitee.com/openharmony-sig/flutter_flutter
```

通过代码工具下载仓库代码并指定dev或master分支，dev不断在更新相比master拥有更多功能


```
1 git clone https://gitee.com/openharmony-sig/flutter_flutter.git
2 git checkout -b dev origin/dev
```


（4）下载FlutterEngine构建产物（非必选项）
Flutter工程构建依赖ohos_debug_unopt_arm64与ohos_release_arm64
FlutterTools指令运行参数中添加--local-engine字段来指定下载的engine：--local-engine=src/out/<engine产物目录\> ，若不使用--local-engine来指定engine，默认使用云端最新版engine。 使用示例：flutter build hap [--local-engine=/Users/admin/Documents/flutter_engine/src/out/ohos_debug_unopt_arm64]
下载编译产物engine本地路径必须带上src/out目录; 解压后，存放到一个目录(engine本地路径必须需带上src/out目录)：如：/Users/admin/Documents/flutter_engine/src/out


#### 2.3、鸿蒙开发环境的前置环境依赖

* 由于鸿蒙系统sdk存在java环境依赖，在oracle官网或openjdk官网下载jdk 17环境，并进行相应配置

* 执行如下命令，检查JDK安装结果，安装成功后进行后续操作


```
java -version
```

>*到这里我们所需要的软件基本准备完成了，接下来我们需要配置开发环境。*
