# RowSplit 组件简易使用教程

RowSplit 组件在 HarmonyOS 应用开发中，可实现将子组件横向布局并在其间插入纵向分割线的功能，以下是其简易使用步骤：

### 1. 组件引入与基本设置

- **版本要求**：该组件从 API Version 7 开始支持，若要在元服务中使用，需 API version 11 及以上。确保项目环境满足相应版本要求。
- **创建组件实例**：在代码中引入 RowSplit 组件，通过`RowSplit()`创建一个 RowSplit 实例，如：

```typescript
RowSplit() {
    // 子组件放置在此处
}
```

### 2. 子组件添加与布局

- **添加子组件**：在 RowSplit 组件的大括号内添加需要横向布局的子组件，例如：

```typescript
RowSplit() {
    Text('1').width('10%').height(100).backgroundColor(0xF5DEB3).textAlign(TextAlign.Center)
    Text('2').width('10%').height(100).backgroundColor(0xD2B48C).textAlign(TextAlign.Center)
    Text('3').width('10%').height(100).backgroundColor(0xF5DEB3).textAlign(TextAlign.Center)
    Text('4').width('10%').height(100).backgroundColor(0xD2B48C).textAlign(TextAlign.Center)
    Text('5').width('10%').height(100).backgroundColor(0xF5DEB3).textAlign(TextAlign.Center)
}
```

这里添加了多个 Text 组件作为子组件，并设置了它们的宽度、高度、背景颜色和文本对齐方式等属性。

- **注意事项**：初始化时，分割线位置根据子组件的宽度计算，之后动态修改子组件宽度（除通过拖动分割线外）不生效，分割线位置保持不变。同时，若动态修改`margin`、`border`、`padding`等通用属性导致子组件宽度异常（大于相邻分割线间距），则不支持拖动分割线改变子组件宽度。

### 3. 分割线设置

- **可拖拽属性设置**：使用`resizeable`属性来设置分割线是否可拖拽，默认值为`false`。若要启用分割线拖拽功能，需将其设置为`true`，例如：

```typescript
RowSplit() {
    // 子组件...
}
.resizeable(true)
```

### 4. 组件样式调整

- **整体样式调整**：可像普通组件一样设置 RowSplit 组件的样式，如宽度、高度等。在上述示例中，设置了 RowSplit 组件的宽度为`'90%'`，高度为`100`，使其在父组件（如 Column）中占据一定的空间并显示合适的大小。
- **子组件样式调整**：除了设置宽度外，还可以对子组件的其他样式属性进行调整，如背景颜色、字体颜色、字体大小等，以满足不同的界面设计需求。

### 5. 与其他组件配合使用

- 通常，RowSplit 组件会嵌套在其他布局组件中，如 Column 组件，以实现更复杂的界面布局。例如：

```typescript
Column() {
    Text('The second line can be dragged').fontSize(9).fontColor(0xCCCCCC).width('90%')
    RowSplit() {
        // 子组件...
    }
   .resizeable(true)
   .width('90%').height(100)
}
.width('100%').margin({ top: 5 })
```

这里先在 Column 组件中添加了一个提示文本，然后放置了 RowSplit 组件，并设置了相关属性，通过 Column 组件的`width`和`margin`属性来控制整体的布局和间距。

通过以上步骤，开发者可以在 HarmonyOS 应用中方便地使用 RowSplit 组件来构建具有横向布局和分割线功能的用户界面，提升应用的交互性和视觉效果。