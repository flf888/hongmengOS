# ohos开发 flutter_module



## 1.DevEco-Studio搭建原生工程

```
使用 [flutter_flutter](https://gitee.com/openharmony-sig/flutter_flutter)，配置相关的环境变量

使用 [flutter_engine](https://gitee.com/openharmony-sig/flutter_engine) 生成的engine产物
```



## 2.搭建flutter_module工程

```sh
# 1. 创建 flutter子模块工程
flutter create -t module my_flutter_module
# 2. 编译生成 flutter_module.har
cd my_flutter_module
flutter build har --debug
cd -
# 3. 复制 EntryAbility.ets 和 Index.ets 到 MyApplication 中
cp my_flutter_module/.ohos/entry/src/main/ets/entryability/EntryAbility.ets MyApplication/entry/src/main/ets/entryability/EntryAbility.ets
cp my_flutter_module/.ohos/entry/src/main/ets/pages/Index.ets MyApplication/entry/src/main/ets/pages/Index.ets
```



## ohos工程引用flutter

ohos工程引用flutter工程有两种使用方式

### 方式一：ohos工程 引用 har 文件

#### 1. 复制 har 文件

```sh
cp -r my_flutter_module/.ohos/har/* MyApplication/har/
```

### 2. 修改 MyApplication/oh-package.json5

```json
{
  // ...
  "dependencies": {
    "flutter_module": "har/flutter_module.har"
  },
  "overrides": {
    // 有冲突的依赖需要放到这里消除冲突
    "@ohos/flutter_ohos": "har/flutter.har",
    "plugin_xxx": "har/plugin_xxx.har"
  }
}
```

#### 3. 使用 Deveco Studio 配置 MyApplication 的签名

#### 4. 运行 MyApplication



### 方式二：ohos工程 直接引用 flutter_module 源码

#### 1. 复制 flutter_module 源码 和 flutter相关文件

```sh
cp -r my_flutter_module/.ohos/flutter_module MyApplication/
mkdir -p MyApplication/flutter_module/src/main/resources/rawfile
cp -r my_flutter_module/.ohos/flutter_module/src/main/resources/rawfile/flutter_assets MyApplication/flutter_module/src/main/resources/rawfile
cp my_flutter_module/.ohos/har/flutter.har MyApplication/har/flutter.har
```

#### 2. 修改 MyApplication/build-profile.json5

```json
{
  // ...
  "modules": [
    {
      "name": "entry",
      "srcPath": "./entry",
      "targets": [
        {
          "name": "default",
          "applyToProducts": [
            "default"
          ]
        }
      ]
    },
    // 以下为新增内容
    {
      "name": "flutter_module",
      "srcPath": "./flutter_module",
      "targets": [
        {
          "name": "default",
          "applyToProducts": [
            "default"
          ]
        }
      ]
    }
  ]
}
```

#### 3. 修改 MyApplication/oh-package.json5

```json
{
  // ...
  "dependencies": {
    "flutter_module": "./flutter_module",
    "@ohos/flutter_ohos": "./har/flutter.har"
  },
  "overrides": {
    "@ohos/flutter_ohos": "./har/flutter.har"
  }
}
```

#### 4. 使用 Deveco Studio 配置 MyApplication 的签名

#### 5. 运行 MyApplication
