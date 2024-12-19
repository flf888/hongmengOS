# `ColumnSplit`是 HarmonyOS 中的一个组件，用于将子组件纵向布局，并在每个子组件之间插入横向分割线。以下是其简易使用说明：

### 1. 支持版本与基本功能

- 从 API Version 7 开始支持，用于纵向布局子组件并插入分割线，分割线位置根据子组件高度计算。初始化后动态修改子组件高度不生效，但可通过拖动分割线改变子组件高度（受子组件最大最小高度限制）。

### 2. 子组件

- `ColumnSplit`可以包含子组件，如`Text`等。在示例中，`ColumnSplit`包含了多个`Text`组件，每个`Text`组件作为一个子项纵向排列。

### 3. 接口与属性

- **`ColumnSplit()`接口**：是创建`ColumnSplit`组件的构造函数。从 API version 11 开始支持在元服务中使用，需要系统能力`SystemCapability.ArkUI.ArkUI.Full`。
- **`resizeable`属性**：用于设置分割线是否可拖拽。通过`resizeable(value: boolean)`方法设置，`value`为`true`时分割线可拖动，`false`为不可拖动，默认值为`false`。例如在示例中，`.resizeable(true)`设置了分割线可拖动。
- **`divider`属性（API 10+）**：用于设置分割线的`margin`。通过`divider(value: ColumnSplitDividerStyle | null)`方法设置，默认值为`null`，即分割线上下`margin`为 0。`ColumnSplitDividerStyle`对象可设置分割线与其上方子组件（`startMargin`）和下方子组件（`endMargin`）的距离，两者默认值均为 0。

### 4. 使用示例

以下是一个简单的`ColumnSplit`使用示例：

```typescript
// xxx.ets
@Entry
@Component
struct ColumnSplitExample {
  build() {
    Column(){
      // 提示文本
      Text('The secant line can be dragged').fontSize(9).fontColor(0xCCCCCC).width('90%')
      ColumnSplit() {
        // 子组件1
        Text('1').width('100%').height(50).backgroundColor(0xF5DEB3).textAlign(TextAlign.Center)
        // 子组件2
        Text('2').width('100%').height(50).backgroundColor(0xD2B48C).textAlign(TextAlign.Center)
        // 子组件3
        Text('3').width('100%').height(50).backgroundColor(0xF5DEB3).textAlign(TextAlign.Center)
        // 子组件4
        Text('4').width('100%').height(50).backgroundColor(0xD2B48C).textAlign(TextAlign.Center)
        // 子组件5
        Text('5').width('100%').height(50).backgroundColor(0xF5DEB3).textAlign(TextAlign.Center)
      }
      // 设置组件边框宽度
     .borderWidth(1)
      // 设置分割线可拖动
     .resizeable(true) 
      // 设置组件宽度和高度
     .width('90%').height('60%')
    }.width('100%')
  }
}
```

在上述示例中，首先创建了一个`Column`组件，在其中添加了一个提示文本和一个`ColumnSplit`组件。`ColumnSplit`组件包含了 5 个`Text`子组件，每个子组件设置了不同的背景色、宽度、高度和文本对齐方式。通过设置`resizeable(true)`使分割线可拖动，`borderWidth(1)`设置了`ColumnSplit`组件的边框宽度，`width('90%').height('60%')`设置了`ColumnSplit`组件的宽度和高度。

注意事项：

- 初始化后动态修改`margin`、`border`、`padding`通用属性导致子组件尺寸大于相邻分割线间距时，不支持拖动分割线改变子组件高度。
- 支持`clip`、`margin`等通用属性，`clip`不设置时默认值为`true`。