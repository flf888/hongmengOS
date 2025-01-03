# HarmonyOS next之border使用以及单独方向设置

以下是在相关开发环境中设置组件边框样式的详细介绍：

### 边框样式设置概述

从 API Version 7 开始支持组件边框样式设置，后续不同版本在不同应用场景（如 ArkTS 卡片、元服务）中有新的支持情况。

### border 接口

- **功能**：border (value: BorderOptions) 用于设置边框样式。它是统一边框样式设置接口。需要注意的是边框宽度默认值为 0，也就是不显示边框。从 API Version 9 开始，父节点的 border 显示在子节点内容之上。此接口在卡片能力方面，从 API version 9 开始支持在 ArkTS 卡片中使用，在元服务中从 API version 11 开始支持，系统能力要求为 SystemCapability.ArkUI.ArkUI.Full。

### borderStyle 接口

- **功能**：borderStyle (value: BorderStyle | EdgeStyles) 用于设置元素的边框线条样式。其默认值为 BorderStyle.Solid。在卡片能力方面，从 API version 9 开始支持在 ArkTS 卡片中使用，在元服务中从 API version 11 开始支持，需要系统具备 SystemCapability.ArkUI.ArkUI.Full 能力。

### borderWidth 接口

- **功能**：borderWidth (value: Length | EdgeWidths | LocalizedEdgeWidths) 用于设置边框的宽度。这里不支持百分比形式。在卡片能力方面，从 API version 9 开始支持在 ArkTS 卡片中使用，在元服务中从 API version 11 开始支持，系统能力要求为 SystemCapability.ArkUI.ArkUI.Full。

### borderColor 接口

- **功能**：borderColor (value: ResourceColor | EdgeColors | LocalizedEdgeColors) 用于设置边框的颜色，默认值为 Color.Black。在卡片能力方面，从 API version 9 开始支持在 ArkTS 卡片中使用，在元服务中从 API version 11 开始支持，系统能力要求为 SystemCapability.ArkUI.ArkUI.Full。

### borderRadius 接口

- **功能**：borderRadius (value: Length | BorderRadiuses | LocalizedBorderRadiuses) 用于设置边框的圆角。圆角大小受组件尺寸限制，最大值为组件宽或高的一半，并且支持百分比（依据组件宽度）。设置圆角后，可搭配.clip 属性进行裁剪，避免子组件超出组件自身。在卡片能力方面，从 API version 9 开始支持在 ArkTS 卡片中使用，在元服务中从 API version 11 开始支持，系统能力要求为 SystemCapability.ArkUI.ArkUI.Full。

这些接口为开发者在不同应用场景下设置组件边框样式提供了丰富的功能和灵活的控制。

### 单独边框方向设置代码如下

```js
Row().border({
    width: { bottom: 1 },
    color: { bottom: 'rgba(153, 159, 181, 0.15)' },
})
```
