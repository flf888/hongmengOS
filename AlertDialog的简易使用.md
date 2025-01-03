# HarmonyOS next之警告弹窗（AlertDialog）使用文档

## 一、概述

警告弹窗（AlertDialog）用于向用户显示重要信息或获取用户的确认反馈。它从 API Version 7 开始支持，在元服务中从 API version 11 开始支持，其功能依赖 UI 的执行上下文，不可在 UI 上下文不明确的地方使用（从 API version 10 开始，可通过 UIContext 中的 showAlertDialog 明确 UI 执行上下文）。

## 二、使用步骤

### （一）获取 UIContext 实例（推荐）

为避免实例不明确的问题，建议使用`getUIContext`获取 UIContext 实例，并使用`showAlertDialog`调用绑定实例的`AlertDialog.show()`。例如：

```typescript
this.getUIContext().showAlertDialog(/*AlertDialog参数*/);
```

### （二）定义弹窗参数

1. 基本参数
   - `title`（可选，ResourceStr 类型）：弹窗标题。
   - `subtitle`（可选，从 API version 10 开始支持，ResourceStr 类型）：弹窗副标题。
   - `message`（必填，ResourceStr 类型）：弹窗内容。
   - `autoCancel`（可选，boolean 类型，默认值为 true）：点击遮障层时是否关闭弹窗。
   - `alignment`（可选，DialogAlignment 枚举类型，默认值为 DialogAlignment.Default）：弹窗在竖直方向上的对齐方式。
   - `offset`（可选，默认值为 {dx: 0, dy: 0}）：弹窗相对 alignment 所在位置的偏移量。
   - `gridCount`（可选，number 类型，默认值为 4）：弹窗容器宽度所占用栅格数。
   - `maskRect`（可选，从 API version 10 开始支持，Rectangle 类型，默认值为 {x: 0, y: 0, width: '100%', height: '100%'}）：弹窗遮蔽层区域，在遮蔽层区域内的事件不透传，在遮蔽层区域外的事件透传（showInSubWindow 为 true 时，maskRect 不生效）。
   - `showInSubWindow`（可选，从 API version 11 开始支持，boolean 类型，默认值为 false）：某弹框需要显示在主窗口之外时，是否在子窗口显示此弹窗。
   - `isModal`（可选，从 API version 11 开始支持，boolean 类型，默认值为 true）：弹窗是否为模态窗口，模态窗口有蒙层，非模态窗口无蒙层。
   - `backgroundColor`（可选，从 API version 12 开始支持，ResourceColor 类型，默认值为 Color.Transparent）：弹窗背板颜色（设置了非透明色时，backgroundBlurStyle 需设为 BlurStyle.NONE）。
   - `backgroundBlurStyle`（可选，从 API version 12 开始支持，BlurStyle 类型，默认值为 BlurStyle.COMPONENT_ULTRA_THICK）：弹窗背板模糊材质（设置为 BlurStyle.NONE 可关闭背景虚化，设置了非 NONE 值时，不要设置 backgroundColor）。
   - `onWillDismiss`（可选，从 API version 12 开始支持，Callback<DismissDialogAction>类型）：交互式关闭回调函数，可根据回调中的 reason 选择是否能关闭弹窗（当前不支持 CLOSE_BUTTON 枚举值，且在 onWillDismiss 回调中不能再做 onWillDismiss 拦截）。
   - `cornerRadius`（可选，从 API version 12 开始支持，可设置背板的圆角半径，默认值为 {topLeft: '32vp', topRight: '32vp', bottomLeft: '32vp', bottomRight: '32vp'}）：圆角大小受组件尺寸限制，最大值为组件宽或高的一半，若值为负，则按默认值处理，也支持百分比参数方式。
   - `transition`（可选，从 API version 12 开始支持，设置弹窗显示和退出的过渡效果）。
   - `width`（可选，从 API version 12 开始支持，设置弹窗背板的宽度，默认最大值为 400vp，支持百分比参数方式）。
   - `height`（可选，从 API version 12 开始支持，设置弹窗背板的高度，默认最大值为 0.9 *（窗口高度 - 安全区域），支持百分比参数方式）。
   - `borderWidth`（可选，从 API version 12 开始支持，可分别设置 4 个边框宽度，默认值为 0，支持百分比参数方式）。
   - `borderColor`（可选，从 API version 12 开始支持，设置弹窗背板的边框颜色，默认值为 Color.Black，需和 borderWidth 一起使用）。
   - `borderStyle`（可选，从 API version 12 开始支持，设置弹窗背板的边框样式，默认值为 BorderStyle.Solid，需和 borderWidth 一起使用）。
   - `shadow`（可选，从 API version 12 开始支持，设置弹窗背板的阴影）。
   - `textStyle`（可选，从 API version 12 开始支持，设置弹窗 message 内容的文本样式）。
2. 按钮相关参数
   - 可以使用`AlertDialogParamWithConfirm`、`AlertDialogParamWithButtons`或`AlertDialogParamWithOptions`（从 API version 10 开始支持）来定义按钮相关参数。
   - `confirm`（`AlertDialogParamWithConfirm`中）：包含确认 Button 的使能状态（`enabled`，默认值为 true）、默认焦点（`defaultFocus`，默认值为 false）、按钮风格（`style`，默认值为 DialogButtonStyle.DEFAULT）、文本内容（`value`）、文本色（`fontColor`）、按钮背景色（`backgroundColor`）和点击回调（`action`）。
   - `primaryButton`和`secondaryButton`（`AlertDialogParamWithButtons`中）：与`confirm`类似，分别用于定义主要按钮和次要按钮的相关属性。
   - `buttons`（`AlertDialogParamWithOptions`中）：是一个`AlertDialogButtonOptions`数组，用于定义弹窗容器中的多个按钮，每个按钮包含使能状态（`enabled`，默认值为 true）、默认焦点（`defaultFocus`，默认值为 false）、风格样式（`style`，默认值为 DialogButtonStyle.DEFAULT）、文本内容（`value`，若为 null 则按钮不显示）、文本颜色（`fontColor`）、背景颜色（`backgroundColor`）和点击回调（`action`）等属性。同时，还可以设置`buttonDirection`（可选，DialogButtonDirection 枚举类型，默认值为 DialogButtonDirection.AUTO，用于指定按钮排布方向）。

### （三）显示弹窗

使用`AlertDialog.show`方法并传入定义好的参数来显示弹窗，例如：

```typescript
AlertDialog.show({
  title: 'title',
  message: 'text',
  autoCancel: true,
  alignment: DialogAlignment.Bottom,
  offset: { dx: 0, dy: -20 },
  gridCount: 3,
  confirm: {
    value: 'button',
    action: () => {
      console.info('Button-clicking callback');
    }
  },
  cancel: () => {
    console.info('Closed callbacks');
  },
  onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
    console.info("reason=" + JSON.stringify(dismissDialogAction.reason));
    console.log("dialog onWillDismiss");
    if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
      dismissDialogAction.dismiss();
    }
    if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
      dismissDialogAction.dismiss();
    }
  }
});
```

## 三、注意事项

1. 尽量按照推荐方式获取 UIContext 实例并显示弹窗，以确保功能正常。
2. 在设置按钮相关参数时，注意各属性的默认值和优先级，以及按钮响应的相关规则（如默认响应 Enter 键能力在 defaultFocus 为 true 时不生效等）。
3. 当设置背景相关属性（如 backgroundColor 和 backgroundBlurStyle）时，需遵循其相互制约的规则。
4. 对于弹窗的各种尺寸和位置相关参数（如 width、height、alignment、offset 等），根据实际需求合理设置，以达到理想的弹窗显示效果。
