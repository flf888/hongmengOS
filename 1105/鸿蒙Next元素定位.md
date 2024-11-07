# 鸿蒙Next元素定位

### 前言：

在鸿蒙next中，子元素想要相对于父元素定位会使用到**.opsition()**这个属性,用法如下：

```js
@Entry
@Component
struct PositionExample1 {
  build() {
    Column() {
        Row() {
            
        }
        .position({x: 50, y: 50})
    }
    .width('100%')
    .height('100%')
  }
}
```

这样就使得子元素相对于父元素的左边50的距离和右边50的距离定位。

有时候，我们希望子元素靠近右边定位，即相对于右边来确定其位置。但难题在于，不同设备的屏幕宽高各不相同。那么，怎样确保子元素能在我们期望的位置呢？

在此，我们提出了一个解决方案。考虑到设备的多样性，这个方案会综合多种因素。它可能会涉及到对不同设备类型的识别，以及根据设备屏幕尺寸范围设定相应的定位规则。通过这种方式，无论在大屏幕的电脑显示器，还是小屏幕的移动设备上，都能让子元素精准地定位在距离右边较近的理想位置，保障设计效果的一致性和准确性。

### 如下：

官网文档链接：https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-universal-attributes-location-V5#position

我们通过使用 LocalizedEdges 类型实现定位。它以父组件的四边为依据来确定位置，并且还支持镜像模式呢。在实际应用中，这种定位方式有着广泛的用途。比如在置顶显示相关的设计中，或者是悬浮按钮的布局场景里，当这些组件需要在父容器内保持位置固定时，LocalizedEdges 类型就能发挥重要作用。它能精准地确定这些组件的位置，保证无论在何种情况下，都能符合设计预期，为用户带来良好的视觉体验和操作体验。

举一个相对于右下角定位的栗子：

```js
@Entry
@Component
struct PositionExample1 {
  build() {
    Column() {
        Row() {
            
        }
        // bottom 相对底边的偏移量。  end 相对于屏幕右边定位
        .position(bottom: { value: 20, unit: 2 }, end: { value: 20, unit: 2 })
    }
    .width('100%')
    .height('100%')
  }
}
```

以上就是本期全部内容
