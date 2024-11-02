# Flutter插件支持鸿蒙系统实践

## 问题

Flutter Plugin主要用来桥接原生代码，调用原生系统SDK， 比如拍照，选择相册，文件选择等。

目前 [pub.dev/]中的插件，都没有对鸿蒙系统的支持，不过鸿蒙现在也做了部分常用第三方插件的支持(例如：[gitee.com/openharmony…] 如果鸿蒙官方做了，我们可以直接使用，但是会存在不少插件，鸿蒙官方来不及做或者优先级比较低，但是我们的项目中又需要，这就要求我们要学会在已有插件的基础上新增支持鸿蒙系统原生代码。

## 搭建环境(macOS M2为例)

### 下载鸿蒙支持的`Flutter`


下载结束之后切换到`dev`分支；鸿蒙针对Flutter的支持，是在基于的官方Flutter版本3.7.12上修改的，总体来说，这个版本稳定性比较高。然后就是配置Flutter命令行环境变量，把Flutter命令行指向鸿蒙支持的Flutter版本。保证在终端可以正常执行`flutter doctor -v`命令。

当然更加建议使用[fvm]来管理`Flutter`版本，可以把鸿蒙支持的Flutter版本代码git clone到`fvm`管理目录的`versions`文件夹下，并`flutter_flutter`改名为`3.7.12-ohos`

![](https://p.ipic.vip/76vgq7.png)

这样就可以直接使用`fvm global 3.7.12-ohos` 命令在切换本地不同的Flutter版本了

![](https://p.ipic.vip/679v4q.png)

### 下载鸿蒙开发工具和配置环境变量

资源地址：[developer.huawei.com/consumer/cn…]

我这边目前下载的`DevEco Studio`版本是`5.0.3.502`, 大家可以下载最新版本就行。

commandline-tools(可选):` commandline-tools-mac-arm64-5.0.3.404.zip`， 最新的DevEco开发工具内部其实已经包含了commandline-tools工具集

配置环境变量

`export TOOL_HOME=/Applications/DevEco-Studio.app/Contents # mac环境 export DEVECO_SDK_HOME=$TOOL_HOME/sdk # command-line-tools/sdk export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH # command-line-tools/ohpm/bin export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH # command-line-tools/hvigor/bin export PATH=$TOOL_HOME/tools/node/bin:$PATH # command-line-tools/tool/node/bin`



## 如何在已有插件中新增鸿蒙系统支持

举一个例子，在Flutter中，我们想把图片保存到相册，一般会到这个库`image_gallery_saver`，现在我们期望这个库也支持在鸿蒙系统中把图片保存到相册中。

我这边建议使用以下步骤

#### fork源码

fork一下源码，fork结束之后，代码就到自己账号下的仓库中，我操作结束之后的[地址]。

![](https://p.ipic.vip/ge9szr.png)

#### clone到本地

`git clone  https://github.com/zingwin/image_gallery_saver`

#### 新增ohos插件

执行以下命令(不推荐)，表明在已存在的插件中新增鸿蒙系统。

`flutter create -t plugin *--platforms ohos*`

但是有些项目可能改过名或者以下配置，执行失败也没有关系，而且个人也不太建议按照以上方式新增插件，因为他会给iOS和Android也生成部分代码，以及插件接口代码，对之前的插件项目有一定程度的干扰，不嫌麻烦的话，直接删除也行。



【**`推荐`**】更推荐的做法是在一个空目录执行创建插件命令

`flutter create -t plugin *--platforms ohos,ios,android image_gallery_saver*`

上面的命令会生成一个全新的插件，里面包含了`iOS`,`android`, `ohos`文件夹，代表插件支持的平台原生代码。然后把生成两个的`ohos`文件夹复制到原项目（第2步）中对应的目录，一定别搞错了。

![](https://p.ipic.vip/gwcj7s.png)

#### 修改pubspes.yaml文件

使用`Android Studio`打开第二步中clone的项目。双击`pubspes.yaml`文件。

![6](https://p.ipic.vip/nj7743.png)

新增`ohos`插件支持。其中的`package`可以同`android`的`package`,

`pluginClass`: 不要填错了。一般情况都是这个目录中可以找到（`image_gallery_saver``/ohos/src/main/ets/components/plugin/ImageGallerySaverPlugin.ets`）。

```c
ohos:
  package: com.example.image_gallery_saver
  pluginClass: ImageGallerySaverPlugin
```

![7](https://p.ipic.vip/nma4h1.png)

#### 执行`Flutter pub get`

接下来，就可以执行`flutter pub get`，成功之后链接鸿蒙模拟器或者鸿蒙系统真机执行`flutter run`进行调试了

#### 准备鸿蒙插件代码

接下来使用`DevEco`打开`example/ohos`下面的鸿蒙项目。

进入`oh_modules`目录下，找到刚生产的插件原生代码，目前可以在这编辑代码，但是记住，这个目前每次`flutter run`都会重新生成，请确保编辑的代码及时同步到`image_gallery_saver``/ohos/src/main/ets/components/plugin/`目录中，不然可能会变成消失的代码。

因为`oh_modules`目录下面得代码就鸿蒙项目存放第三方模块的目录，`flutter run`每次执行都会覆盖这里面的代码。

比如我目前写完代码，会使用以下命令把代码自动复制到插件的真实目录

```c
 cp *.ets /个人目录前缀/image_gallery_saver/ohos/src/main/ets/components/plugin/

```

相信在未来的版本中，鸿蒙官方会解决这个问题。

![8](https://p.ipic.vip/qah9ut.png)

上图中我们可以看到生成到的鸿蒙插件代码，并且在插件中还实现了`getPlatformVersion`默认方法。

![9](https://p.ipic.vip/rkz3j5.png)

另外一个细节，请确保鸿蒙插件中的`MethodChannel`和`Flutter`侧中的`MethodChannel`字符串一致。

![10](https://p.ipic.vip/c3602p.png)

#### 开始编写插件代码

查看`image_gallery_saver/lib/image_gallery_saver.dart`

发现这个插件就两个方法

```c
static FutureOr<dynamic> saveImage(Uint8List imageBytes,
    {int quality = 80,
    String? name,
    bool isReturnImagePathOfIOS = false})
    
static Future saveFile(String file,
    {String? name, bool isReturnPathOfIOS = false})    

```

我们参考其他平台，取插件接口参数，然后做相应的逻辑

![4B944353-D767-45D6-BE9F-33DD0A2F9311](https://p.ipic.vip/7d5cxe.png)

#### git push

修改完之后，把代码push到自己的git仓库

#### 使用插件

把`image_gallery_saver`这个库，指向我们自己的地址即可，就是第1步fork之后的地址。

```flutter
image_gallery_saver:
  git:
    url: https://gitee.com/openharmony-sig/flutter_flutter.git
    ref: 431cf6867ba533770292f2e42305e58a8474b0ae
```

## 总结

以上就是在已有Flutter插件中新增鸿蒙系统支持的大致流程。