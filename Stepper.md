# Stepper 组件简易使用教程

在 HarmonyOS 应用开发中，Stepper 组件为引导用户按步骤完成任务提供了便捷的导航方式。以下是其简易使用步骤：

### 1. 组件引入与基本设置

- **版本要求**：Stepper 组件从 API Version 8 开始支持，使用前需确保项目环境满足该版本要求。
- **创建 Stepper 实例**：在代码中引入 Stepper 组件，通过`Stepper({index: 当前步骤索引值})`来创建一个 Stepper 实例，其中`index`参数用于设置当前显示的步骤项索引，默认值为 0，且从 API version 10 开始支持双向绑定变量，方便在步骤切换时更新状态。

### 2. 构建步骤内容

- **添加 StepperItem 子组件**：Stepper 仅能包含子组件 StepperItem，每个 StepperItem 代表一个步骤页面。例如：

```typescript
StepperItem() {
    Column() {
        Text('Page One')
        Button('change status:' + this.firstState)
           .onClick(() => {
                // 按钮点击处理逻辑，如切换状态
            })
    }.itemStyle()
}
```

- **设置步骤内容样式**：可以通过自定义函数（如`itemStyle`和`itemTextStyle`）来设置步骤内容的样式，包括宽度、高度、背景颜色、文字颜色、字体大小等，使步骤页面呈现出美观且一致的风格。

### 3. 配置步骤导航

- **定义导航标签**：在每个 StepperItem 中，使用`nextLabel`定义下一步按钮的文字，使用`prevLabel`（可选）定义上一步按钮的文字。如：`.nextLabel('Next').prevLabel('Previous')`。
- **设置步骤状态**：通过`status`属性为每个 StepperItem 设置状态，可选值有`Normal`（正常）、`Skip`（跳过）、`Disabled`（禁用）、`Waiting`（等待），以控制步骤的可操作性和显示效果。例如：`.status(this.secondState)`，并通过按钮点击等操作来动态改变状态。

### 4. 处理事件回调

- 步骤切换事件

  ：

  - `onChange`：当点击`prevLabel`或`nextLabel`切换步骤时触发，回调函数中可获取切换前的步骤索引`prevIndex`和切换后的步骤索引`index`，方便更新当前步骤索引变量，如`this.currentIndex = index`。
  - `onPrevious`：点击`prevLabel`切换上一步骤时触发，可获取当前步骤索引和上一步骤索引，用于执行上一步相关逻辑。
  - `onNext`：点击`nextLabel`切换下一步骤时触发（非最后一步且状态为`Normal`），同样可获取当前和下一步骤索引，执行下一步相关操作。

- 特殊情况事件

  ：

  - `onFinish`：当点击最后一个 StepperItem 的`nextLabel`且其状态为`Normal`时触发，可在此处理完成任务后的逻辑，如路由跳转等。
  - `onSkip`：当当前 StepperItem 状态为`Skip`且`nextLabel`被点击时触发，可用于处理跳过步骤后的逻辑，如动态修改 Stepper 的`index`值跳转到指定步骤页。

通过以上步骤，开发者可以在 HarmonyOS 应用中创建出具有清晰步骤导航和交互功能的用户界面，提升用户完成任务的体验和效率。