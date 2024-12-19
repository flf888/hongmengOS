# 模态弹窗（ModelDialog）在 HarmonyOS 应用中提供了多种交互方式，以下是其简易使用方法：

### 1. 概述

- 模态状态下，用户只能操作当前弹窗，干扰性强。ArkUI 提供多种模态弹窗组件，包括 AlertDialog、CustomDialog、ActionSheet、Popup、Menu、ContextMenu 等，可根据不同场景选择使用。

### 2. 使用全局弹窗

- 定制组件

  ：

  - **AlertDialog**：用于提示重要信息、获取用户许可或提问，包含标题、信息文本、最多 3 个按钮等必选内容，还可添加输入框、icon、checkBox 和 HelpButton 等可选内容。例如：

```typescript
AlertDialog.show({
  title: 'title',
  subtitle: 'subtitle',
  message: 'text',
  autoCancel: true,
  alignment: DialogAlignment.Bottom,
  gridCount: 4,
  offset: { dx: 0, dy: -20 },
  primaryButton: {
    value: 'cancel',
    action: () => { console.info('Callback when the first button is clicked') }
  },
  secondaryButton: {
    enabled: true,
    defaultFocus: true,
    style: DialogButtonStyle.HIGHLIGHT,
    value: 'ok',
    action: () => { console.info('Callback when the second button is clicked') }
  }
})
```

- **ActionSheet**：适用于展示多个操作项的列表选择，包含标题、副标题、消息、确认按钮及多个操作项。例如：

```typescript
ActionSheet.show({
  title: 'ActionSheet title',
  subtitle: 'ActionSheet subtitle',
  message: 'message',
  autoCancel: true,
  confirm: {
    defaultFocus: true,
    value: 'Confirm button',
    action: () => { console.log('Get Alert Dialog handled') }
  },
  alignment: DialogAlignment.Bottom,
  offset: { dx: 0, dy: -10 },
  sheets: [
    { title: 'apples', action: () => { console.log('apples') } },
    { title: 'bananas', action: () => { console.log('bananas') } },
    { title: 'pears', action: () => { console.log('pears') } }
  ]
})
```

- **自定义组件（CustomDialog）**：开发者可自定义弹窗内容和样式，通过`promptAction.openCustomDialog`更方便实现。示例中自定义了一个包含文本输入框和确认、取消按钮的弹窗，用于修改文本内容。

### 3. 使用气泡 Popup

- 用于为指定组件提供信息提示，点击目标组件时弹出。通过`bindPopup`方法绑定，设置弹框内容、按钮及状态变化回调。例如：

```typescript
Button('PopupOptions')
 .onClick(() => { this.handlePopup =!this.handlePopup })
 .bindPopup(this.handlePopup, {
    message: 'This is a popup with PopupOptions',
    placementOnTop: true,
    showInSubWindow: false,
    primaryButton: { value: 'confirm', action: () => { this.handlePopup =!this.handlePopup; console.info('confirm Button click') } },
    secondaryButton: { value: 'cancel', action: () => { this.handlePopup =!this.handlePopup; console.info('cancel Button click') } },
    onStateChange: (e) => { console.info(JSON.stringify(e.isVisible)); if (!e.isVisible) { this.handlePopup = false } }
  })
 .position({ x: 100, y: 150 })
```

### 4. 使用菜单 Menu

- **bindMenu**：用于在非子窗场景展示用户可执行操作，无需预览图。通过`MenuItem`组件组合菜单内容，再用`bindMenu`绑定到组件上。例如：

```typescript
@Builder
MyMenu() {
  Menu() {
    MenuItem({ content: "菜单选项" });
    MenuItem({ content: "菜单选项" });
    MenuItem({ content: "菜单选项" });
    MenuItem({ content: "菜单选项" });
  }
}
Row() {
  Column() {
    Text('click to show menu').fontSize(50).fontWeight(FontWeight.Bold);
  }
 .bindMenu(this.MyMenu)
 .width('100%');
}
```

- **bindContextMenu**：用于需要预览图场景，只能在子窗中显示，内容包括菜单、预览图、蒙层，通常在长按桌面图标时使用。例如：

```typescript
Column() {
  Text('LongPress for menu');
}
.width('100%')
.margin({ top: 5 })
.bindContextMenu(this.MenuBuilder, ResponseType.LongPress, {
  placement: Placement.Left,
  preview: MenuPreviewMode.IMAGE
})
```

### 5. 超出应用界面

- 在 2in1 设备上，可通过`showInSubWindow`属性设置弹窗或气泡在子窗口中显示，实现超出主窗口效果，如`CustomDialog`示例中设置`showInSubWindow: true`。还可使用`bindContextMenu`为组件绑定菜单实现默认子窗口效果，长按或右键点击触发弹出菜单项，菜单项需自定义。