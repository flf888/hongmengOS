# HarmonyOS next之简易APP 应用续接时获取数据

前言：

应用接续，指当用户在一个设备上操作某个应用时，可以在另一个设备的同一个应用中快速切换，并无缝衔接上一个设备的应用体验。

比如在用户使用过程中，使用情景发生了变化，之前使用的设备不再适合继续当前任务，或者周围有更合适的设备，此时用户可以选择使用新的设备来继续当前的任务。接续完成后，之前设备的应用可退出或保留，用户可以将注意力集中在被拉起的设备上，继续执行任务。

附上官网文档链接 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/app-continuation-V5

### （1）设备必须满足

双端设备需要登录同一华为账号。
双端设备需要打开 Wi-Fi 和蓝牙开关。
应用接续只能在同应用（UIAbility）之间触发，双端设备都需要有该应用。

### （2）在 module.json5 文件的 abilities 中，将 continuable 标签配置为“true”

### （3）数据交互

在 EntryAbility 的 onCreate 钩子函数中初始化应用续接，此处示例为续接登录态

```js
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    initContinuable(want, () => {
      this.context.restoreWindowStage(new LocalStorage());
    });
}
// 初始化续接函数
initContinuable(want: Want, callBack: Function) {
	// want.parameters 接收到发起方传入的参数
    if (want.parameters) {
	  // 标识是否是应用续接启动的
      let is_continuable = want.parameters['is_continuable'] || 0;
	  // 获取传入的登录态
      let access_token = want.parameters['access_token'] + '' || '';
      // 是否为游客登录
      let is_guest = want.parameters['is_guest'] || 0;
	  // 如果是应用续接，走登录初始化流程
      if (is_continuable == 1) {
        UserCacheManager.setLoginToken(access_token);
        if (is_guest == 1) {
          UserCacheManager.updateGuestStatus(true);
        } else {
          UserCacheManager.updateGuestStatus(false);
        }
        Utils.getUserInfo();
        callBack();
      }
    }
}
```

在发起应用续接时，发起方会触发在 EntryAbility 的 onContinue 钩子函数，在此处将要转移的数据准备

```js
onContinue(wantParam: Record<string, Object>) {
    // 调用异步代码会导致续集方拿不到数据2024.10.10
    // 迁移数据保存
    preContinuable(wantParam);
	// AGREE：表示同意。
	// REJECT：表示拒绝，如应用在onContinue中异常可以直接REJECT。
    return AbilityConstant.OnContinueResult.AGREE;
}
// 准备数据迁移
preContinuable(wantParam: Record<string, Object>) {
    let is_continuable = 1;
    let access_token = UserCacheManager.getLoginToken();
    // 是否为游客登录
    let is_guest = UserCacheManager.isGuestLogin() ? 1 : 0;
    if (is_continuable) {
      // 将要迁移的数据保存在wantParam的自定义字段中;
      wantParam["access_token"] = access_token;
      wantParam["is_continuable"] = is_continuable;
      wantParam["is_guest"] = is_guest;
    }
}
```

在续接方触发EntryAbility 的 onCreate 钩子函数时就能拿到这些数据，并作出处理
