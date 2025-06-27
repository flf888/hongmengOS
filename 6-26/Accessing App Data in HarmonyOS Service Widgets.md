# Accessing App Data in HarmonyOS Service Widgets

### (1) Creating a Service Widget

After creating an ArkTS-based widget, the project will generate the following widget-related files:

- Widget lifecycle management file (`EntryFormAbility.ets`)
- Widget UI file (`WidgetCard.ets`)
- Widget configuration file (`form_config.json`)

### (2) Configuring module.json5

Reference documentation for fields:

```
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

### (3) Widget-Specific Configuration

Configuration resides in `resources/base/profile/form_config.json`.
Reference documentation for fields:

### (4) UI Development and Parameter Handling

Widget UI code is located in `ets/widget/`. Parameter reception logic:

```
let storageUpdateByMsg = new LocalStorage();

@Entry(storageUpdateByMsg)
@Component
struct WidgetCard {
  @LocalStorageProp('diffExamDay') diffExamDay: number = -1;
}
```

### (5) Widget Lifecycle and Data Passing

- Initialization logic in `EntryFormAbility.onAddForm` (e.g., passing widget ID to WidgetCard)
- Updates handled in `onUpdateForm` hook

### (6) Accessing App Data During Widget Initialization

#### 6.1 Notifying App to Update Widget Data

```
postCardAction(this, {
  action: "call",
  abilityName: "EntryAbility",
  params: {
    method: "upDiffExamDay",
    formId: this.formId,
  },
});
```

**Timing Issue Solution:**
Monitor `formId` changes instead of using `aboutToAppear()`:

```
@LocalStorageProp('formId') @Watch('updateFormId') formId:string = '';

updateFormId() {
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

#### 6.2 App-Side Data Handling

In `EntryAbility.onCreate`:

```
onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
  this.callee.on('upDiffExamDay', upDiffExamDayCall);
}

const upDiffExamDayCall = (data: rpc.MessageSequence): MyParcelable => {
  let params: Record<string, string> = JSON.parse(data.readString());
  if (params.formId) {
    PreferencesUtil.putSync('formId', params.formId)
    const diffExamDay = UserCacheManager.getDiffExamDay();
    
    diffExamDay === -1 
      ? getHomePageData(params.formId) // Fetch data if unavailable
      : Utils.updateDiffExamDay(params.formId); // Update widget directly
  }
  return new MyParcelable(1, 'success');
};
```

**Updating Widget Data:**

```
// Import required modules
import { formBindingData, formProvider } from '@kit.FormKit';

updateDiffExamDay(formId: string) {
  const diffExamDay = UserCacheManager.getDiffExamDay();
  let formMsg = formBindingData.createFormBindingData({
    'diffExamDay': diffExamDay
  });

  formProvider.updateForm(formId, formMsg)
    .then(() => console.log('Update success'))
    .catch((error) => console.error('Update failed:', error));
}
```
