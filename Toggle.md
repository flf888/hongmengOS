# Toggle 组件的简易使用

Toggle 组件在 HarmonyOS 应用开发中用于提供多种样式的开关功能，如勾选框、状态按钮和开关样式，以下是其简易使用方法：

### 1. 组件引入与基本结构

- 首先，确保项目支持 API Version 8 及以上版本，因为 Toggle 组件从该版本开始支持。在需要使用 Toggle 组件的`.ets`文件中，进行组件的引入和使用。例如：

```typescript
@Entry
@Component
struct ToggleExample {
  build() {
    Column({ space: 10 }) {
      // 这里开始放置Toggle组件相关代码
    }.width('100%').padding(24)
  }
}
```

### 2. 设置开关样式

- 使用`Toggle`函数创建组件实例，并通过`type`参数设置样式，可选项有`ToggleType.Checkbox`（单选框样式）、`ToggleType.Button`（状态按钮样式，有子组件时显示文本内容）、`ToggleType.Switch`（开关样式）。例如：

```typescript
Toggle({ type: ToggleType.Switch, isOn: false })
```

这里创建了一个默认关闭的开关样式 Toggle 组件。

### 3. 样式定制

- **背景颜色**：使用`selectedColor`属性设置组件打开状态的背景颜色。例如：

```typescript
.selectedColor('#007DFF')
```

- **滑块颜色（仅 Switch 类型）**：通过`switchPointColor`属性可以指定 Switch 类型的圆形滑块颜色，如：

```typescript
.switchPointColor('#FFFFFF')
```

- **Switch 样式细节（API 12 及以上）**：从 API 12 开始，可以使用`switchStyle`属性进一步定制 Switch 类型的样式，包括圆形滑块半径（`pointRadius`）、关闭状态背景颜色（`unselectedColor`）、滑块颜色（`pointColor`）和滑轨圆角（`trackBorderRadius`）。例如：

```typescript
.switchStyle({
  pointRadius: 15,
  trackBorderRadius: 10,
  pointColor: '#D2B48C',
  unselectedColor: Color.Pink
})
```

### 4. 事件处理

- 使用`onChange`事件来监听开关状态的切换。当开关状态改变时，会触发传入的回调函数，回调函数接收一个布尔值参数`isOn`，表示开关的当前状态（`true`为打开，`false`为关闭）。例如：

```typescript
.onChange((isOn: boolean ) => {
  console.info('Component status:' + isOn)
})
```

### 5. 特殊情况（自定义样式，API 12 及以上）

- 如果需要更高级的自定义样式，可以实现`ContentModifier`接口来定制 Toggle 内容区。例如创建一个自定义类`MySwitchStyle`实现该接口，在`applyContent`方法中返回自定义的组件构建函数，然后通过`contentModifier`属性应用到 Toggle 组件上。如示例中的代码实现了通过按钮切换圆形颜色的功能：

```typescript
class MySwitchStyle implements ContentModifier<ToggleConfiguration> {
  // 自定义类的实现
}

Toggle({ type: ToggleType.Switch})
 .enabled(true)
 .contentModifier(new MySwitchStyle(Color.Yellow, '灯'))
 .onChange((isOn: boolean) => {
    console.info('Switch Log:' + isOn)
  })
```

通过以上步骤，开发者可以在 HarmonyOS 应用中灵活运用 Toggle 组件，满足不同场景下的开关功能需求，并实现个性化的样式定制和交互逻辑。