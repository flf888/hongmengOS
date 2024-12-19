# FoldSplitContainer 组件简易使用教程

FoldSplitContainer 组件是 HarmonyOS 中用于实现折叠屏二分栏或三分栏布局的重要组件，能够有效适配折叠屏设备在不同状态下的界面展示需求。以下是其简易使用方法：

### 1. 引入与基本设置

- **版本要求**：该组件从 API Version 12 开始支持，确保项目的 HarmonyOS 版本满足此要求。
- **创建组件实例**：在代码中导入`FoldSplitContainer`，通过`FoldSplitContainer({...})`创建实例。例如：

```typescript
FoldSplitContainer({
    primary: () => {
        // 主要区域内容构建函数
    },
    secondary: () => {
        // 次要区域内容构建函数
    },
    extra: () => {
        // 扩展区域内容构建函数（可选）
    },
    expandedLayoutOptions: {
        // 展开态布局选项
    },
    hoverModeLayoutOptions: {
        // 悬停态布局选项
    },
    foldedLayoutOptions: {
        // 折叠态布局选项
    },
    animationOptions: null,  // 动画效果参数（可选）
    onHoverStatusChange: (status) => {
        // 悬停状态改变回调函数
    }
})
```

### 2. 区域内容构建

- **主要区域（primary）**：使用`@Builder`函数定义主要区域的内容，如：

```typescript
@Builder
privateRegion() {
    Text("Primary")
      .backgroundColor('rgba(255, 0, 0, 0.1)')
      .fontSize(28)
      .textAlign(TextAlign.Center)
      .height('100%')
      .width('100%')
}
```

然后在`FoldSplitContainer`的`primary`回调中调用该函数。

- **次要区域（secondary）**：与主要区域类似，通过`@Builder`定义内容并在`secondary`回调中使用。
- **扩展区域（extra）**：同样的方式构建内容，若不传入，则不会显示扩展区域。

### 3. 布局选项配置

- 展开态（expandedLayoutOptions）

  ：

  - `isExtraRegionPerpendicular`：设置扩展区域是否上下贯穿整个组件，默认值为`true`。
  - `verticalSplitRatio`：指定主要区域与次要区域的高度比例，默认值为`PresetSplitRatio.LAYOUT_1V1`（1:1 比例）。
  - `horizontalSplitRatio`：当有扩展区域时，设置主要区域与扩展区域的宽度比例，默认值为`PresetSplitRatio.LAYOUT_3V2`（3:2 比例）。
  - `extraRegionPosition`：当`isExtraRegionPerpendicular`为`false`时，确定扩展区域的位置（`top`或`bottom`），默认值为`ExtraRegionPosition.top`。

- 悬停态（hoverModeLayoutOptions）

  ：

  - `showExtraRegion`：控制在半折叠状态下是否显示扩展区域，默认值为`false`。
  - `horizontalSplitRatio`：同展开态中该参数含义，默认值`PresetSplitRatio.LAYOUT_3V2`。
  - `extraRegionPosition`：当`showExtraRegion`为`true`时，设置扩展区域位置，默认`ExtraRegionPosition.top`。注意设备悬停态时布局计算需考虑避让区域。

- 折叠态（foldedLayoutOptions）

  ：

  - `verticalSplitRatio`：设置主要区域与次要区域的高度比例，必填，默认`PresetSplitRatio.LAYOUT_1V1`。

### 4. 事件处理

- `onHoverStatusChange`：当折叠屏进入或退出悬停模式时触发该回调函数，可在函数中处理如界面更新、状态记录等操作，例如根据悬停状态改变某些元素的显示或隐藏。

通过以上步骤，开发者可以在 HarmonyOS 应用中灵活运用 FoldSplitContainer 组件，为折叠屏设备提供良好的用户体验和适配性。