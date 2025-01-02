# HarmonyOS next之APP 服务卡片获取 APP 内数据

### （1）根据需要创建一个服务卡片，

ArkTS 卡片创建完成后，工程中会新增如下卡片相关文件：卡片生命周期管理文件（EntryFormAbility.ets）、卡片页面文件（WidgetCard.ets）和卡片配置文件（form_config.json）

### （2）在 module.json5 文件中配置，对应字段参考文档https:

//developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-ui-widget-configuration-V5

```json
"extensionAbilities": [
	{
		"name": "EntryFormAbility",
		"srcEntry": "./ets/entryformability/EntryFormAbility.ets",
		"label": "$string:EntryFormAbility_label",
        "description": "$string:EntryFormAbility_desc",
		"type": "form",
		"metadata": [
			{
				"name": "ohos.extension.form",
				"resource": "$profile:form_config"
			}
		]
	}
]
```

### （3）卡片的具体配置信息在开发视图的 resources/base/profile/目录下的 form_config.json，对应字段参考文档https:

//developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-ui-widget-configuration-V5

### （4）ui 开发卡片的 ui 代码在 ets 目录下的 widget 中，接收参数逻辑

```js
let storageUpdateByMsg = new LocalStorage();

@Entry(storageUpdateByMsg)
@Component
struct WidgetCard {
  @LocalStorageProp('diffExamDay') diffExamDay: number = -1;
}
```

### （5）卡片生命周期以及给卡片传递数据

在 EntryFormAbility 中的 onAddForm 写初始化逻辑，如获取卡片 id 传递给 WidgetCard 页面
触发卡片更新的时候就会触发 onUpdateForm 钩子函数，一般来说就用到这两个

### （6）在卡片初始化时获取 app 的相关数据

#### 1、在 WidgetCard 中调用函数 postCardAction 通知 app 根据 formid 更新卡片数据

```js
postCardAction(this, {
  action: "call",
  abilityName: "EntryAbility",
  params: {
    method: "upDiffExamDay",
    formId: this.formId,
  },
});
```

此时会有一个问题，直接在 WidgetCard 页面的 aboutToAppear()直接调用 postCardAction 方法通知 app 时，来不及获取到 formid，就导致
app 不能正确的将卡片数据更新到卡片上。
解决方案是给 WidgetCard 页面的 formid 设置一个初始值并监听它的变化，变化了再运行函数 postCardAction 通知 app，示例如下

```js
@LocalStorageProp('formId') @Watch('updataFormId') formId:string = '';
updataFormId() {
    console.log('调试formId变化', this.formId)
    // 卡片向app传参
    postCardAction(this, {
      action: 'call',
      abilityName: 'EntryAbility',
      params: {
        method: 'upDiffExamDay',
        formId: this.formId
      }
    });
}
```

#### 2、在 app 中接收并更新卡片数据

在 EntryAbility 的 onCreate 钩子函数中使用 callee 函数监听卡片动态并作出反应

```js
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.callee.on('upDiffExamDay', upDiffExamDayCall);
}

// 在收到call事件后会触发callee监听的方法
const upDiffExamDayCall = (data: rpc.MessageSequence): MyParcelable => {
  // 获取call事件中传递的所有参数
  let params: Record<string, string> = JSON.parse(data.readString());
  if (params.formId !== undefined) {
	// 将formId存入本地存储
    PreferencesUtil.putSync('formId', params.formId)
	// 获取考试剩余天数数据
    const diffExamDay = UserCacheManager.getDiffExamDay();
    if (diffExamDay == -1) {
	  // 没有数据获取数据再更新
      getHomePageData(params.formId);
    } else {
	  // 有数据直接触发更新
      Utils.updateDiffExamDay(params.formId);
    }
  }
  return new MyParcelable(CONST_NUMBER_1, 'aaa');
};
// 更新卡片数据
updateDiffExamDay(formId: string) {
	// 获取考试天数
    const diffExamDay = UserCacheManager.getDiffExamDay();
    let formMsg: formBindingData.FormBindingData =
      formBindingData.createFormBindingData({
        'diffExamDay': diffExamDay
    });
	// 引入 import { formBindingData, formProvider } from '@kit.FormKit';
	// 通过formId触发更新卡片数据
    formProvider.updateForm(formId, formMsg).then((data) => {
      console.log(`updateForm success. ${JSON.stringify(data)}`)
    }).catch((error: BusinessError) => {
      console.log(`updateForm failed: ${JSON.stringify(error)}`);
    });
}
```
