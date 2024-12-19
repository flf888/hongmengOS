### Checkbox 的简易使用

Checkbox 是 HarmonyOS 中的多选框组件，用于表示某选项的打开或关闭状态。以下是其简易使用方法：

### 1. 引入与基本使用

在`.ets`文件中，通过`@Entry`和`@Component`装饰器定义组件，在`build`函数中创建`Checkbox`实例。例如：

```typescript
@Entry
@Component
struct CheckboxExample {
  build() {
    Flex({ justifyContent: FlexAlign.SpaceAround }) {
      Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
      .select(true)
      .selectedColor(0xed6f21)
      .shape(CheckBoxShape.CIRCLE)
      .onChange((value: boolean) => {
          console.info('Checkbox1 change is' + value)
        })
    }
  }
}
```

### 2. 常用属性

- **`select`**：设置多选框是否选中，支持双向绑定变量（API version 10 及以上），默认值为`false`。
- **`selectedColor`**：设置选中状态颜色，默认值为`$r('sys.color.ohos_id_color_text_primary_activated')`。
- **`unselectedColor`**（API version 10 及以上）：设置非选中状态边框颜色，默认值为`$r('sys.color.ohos_id_color_switch_outline_off')`。
- **`mark`**（API version 10 及以上）：设置内部图标样式，API version 12 及以上若设置了`indicatorBuilder`，则按其内容显示。
- **`shape`**（API version 11 及以上）：设置组件形状，可选值为`CheckBoxShape.CIRCLE`（圆形，默认）和`CheckBoxShape.ROUNDED_SQUARE`（圆角方形）。
- **`contentModifier`**（API version 12 及以上）：用于定制 CheckBox 内容区，需自定义类实现`ContentModifier`接口。

### 3. 事件处理

通过`onChange`事件监听选中状态变化，回调函数中会返回当前选中状态（`true`为选中，`false`为未选中）。例如：

```typescript
Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
.onChange((value: boolean) => {
  console.info('Checkbox1 change is' + value)
})
```

### 4. 示例场景

- **设置多选框形状**：可通过`shape`属性配置为圆形或圆角方形，如示例 1。
- **设置多选框颜色**：使用`selectedColor`、`unselectedColor`和`mark`等属性自定义颜色，如示例 2。
- **自定义多选框样式**：利用`contentModifier`属性（API version 12 及以上），结合自定义组件实现复杂样式，如示例 3 中创建了五边形复选框及选中状态变化时的不同显示效果。

总之，Checkbox 组件功能丰富，能满足多种场景下的多选框需求，开发者可根据实际情况灵活运用其属性和事件。