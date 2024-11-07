# 鸿蒙next页面滚动与回到顶部设置

### 前言：

在使用鸿蒙 next 构建页面代码时，常常会遭遇一个棘手的问题：屏幕无法容纳所有页面内容。我们期望达成的效果是，当页面超出屏幕范围时，能够通过向下滑动来显示剩余内容。然而，实际操作中却发现向下滑动毫无反应，这无疑给开发工作带来了阻碍。别担心，本文将为你提供一种行之有效的解决方案。当面对这种情况时，我们需要深入检查代码的布局设置和相关属性，查看是否存在限制滑动的参数。同时，要确认页面的滚动容器是否正确配置，是否赋予了其应有的滚动功能。只有对这些方面进行仔细排查和调整，才有可能让页面恢复正常的滑动显示功能，使我们的页面展示更加流畅和完整。

### 首先我们使用Scroll组件将页面占满

```js
@Entry
@Component
struct NestedScroll {
    build() {
        Scroll() {
            // 注意scroll里面只能有一个根元素，想要装多元素需要用一个元素包住
            Column() {
                // 主要内容
            }
            .width('100%')
        	.height('100%')
        }
        .width('100%')
        .height('100%')
    }
}
```

这样在页面上写的内容就能够滚动下滑了。

### 接下来是回到顶部

下滑了很多之后如何快速回到顶部呢？我们需要给Scroll一个控制器，举个栗子

```js
@Entry
@Component
struct NestedScroll {
    private scroller: Scroller = new Scroller()
    @State show_to_top: boolean = false; // 是否显示回到顶部
    
    build() {
        Column() {
            Scroll(this.scroller) {
                // 注意scroll里面只能有一个根元素，想要装多元素需要用一个元素包住
                Column() {
                    // 主要内容
                }
                .width('100%')
                .height('100%')
            }
            .width('100%')
            .height('100%')
            .onDidScroll(() => {
                // 滑动到一定距离时显示回到顶部按钮
                if (this.scroller.currentOffset().yOffset < 50) {
                    this.show_to_top = false;
                } else {
                    this.show_to_top = true;
                }
            })
            // 回到顶部
            if (this.show_to_top) {
                Column() {
                    Image(Utils.getImgPath('course/back_top.png'))
                        .height(80)
                        .width(80)
                        .onClick(() => {
                        	// 点击回到顶部
                        	this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
                    	})
                }
                .position({ bottom: { value: 85, unit: 1 }, end: { value: -5, unit: 1 } })
            }
        }
        .width('100%')
        .height('100%')
    }
}
```