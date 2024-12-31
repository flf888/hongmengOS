## 打包流程

1.改动 `hvigConfig.ts`的 APP_TYPE 与 更新`AppScopre/app.json5`中的版本号
2.点击 Build -> Build App 运行打包，打包文件输出在: `build/outputs/default/${apptype}.app`

## 添加新的产品流程

1. 在 根目录下的 `vest/`按照规则添加对应的图片。 （图片在线上后台的打包管理-logo字段, logo-y.png图片在共享文件中）
2. 在 根目录下的 `hvigConfig.ts` 中的变量`appBranchConfig`添加对应的证书配置. （证书在共享文件夹中）
3. 找到apptype对应的 oauthClientId (在线上后台的打包管理-华为推送-鸿蒙元服务-Client ID字段)
4. 找到apptype对应的 bundleId (在线上后台的打包管理-华为推送-鸿蒙元服务-APP ID字段)
5. 找到apptype对应的 appId (在线上后台的打包管理-华为推送-鸿蒙应用-APP ID字段), (appId字段是用于元服务跳转对应 app的)

## 页面一对多能力-平板布局参考

* https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/typical-layout-scenario-V5#%E9%A1%B5%E7%AD%BE%E6%A0%8F
* https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/typical-layout-scenario-V5#%E9%87%8D%E5%A4%8D%E5%B8%83%E5%B1%80

# 遇到的问题解决记录

1.debug模式运行的代码没问题但release模式下不行.

* 编辑器可能自动写入文件 obfuscation-rules.txt `-enable-property-obfuscation
  -enable-toplevel-obfuscation
  -enable-filename-obfuscation
  -enable-export-obfuscation` 导出release模式有问题.
  参考自: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/source-obfuscation-V5
* 把上面的四个配置删除即可解决.

2. 元服务不可以使用http域名

## 生成根证书流程

* 点击 `Build -> Generate key CSR -> New 按钮`
* `Key Store Path`:选择密钥库文件存储路径
* `Password`与`Confirm Password`的密码是 `jufeng123`
* 上面步骤会生成 `*.csr`与 `*.p12`文件，该文件需要通过鸿蒙后台去生成`*.cer`文件（-联系佳爷生成）

## 验证根证书是否正确 (用于排查是证书的问题还是打包脚本的问题)

1. 将根目录的 `hvigorfile.ts`里面的运行函数都注释调
2. 配置 `File -> Project Structers -> Singing Config`，并点击 Apply
3. 看是否可以打包成功，能打包成功说明证书没问题，打包不成功则证书有问题。