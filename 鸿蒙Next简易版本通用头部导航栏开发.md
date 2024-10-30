# 鸿蒙Next简易版本通用头部导航栏开发



在日常页面开发中，我们每个页面都会有一个头部用于展示返回按钮和显示页面信息。如果没个页面都重复写太过于繁琐以及标准不好统一。因此，我们需要一个通用的头部组件。

### 步骤一

新建一个ArkTs File页面，使用@Component装饰器创建一个名为NavBar的自定义组件

```js
// 自定义工具库
import Utils from "../../../common/utils/Utils";

@Component
  // 通用头部
export struct NavBar {
  build() {
  }
}
```

### 步骤二

父组件想要能够使用我们的NavBar组件，组件内部就需要使用**@Prop**接收父组件传来的参数。

这里我们通常会用到title，以显示页面信息，同时附上title显示对应ui

```js
// 自定义工具库
import Utils from "../../../common/utils/Utils";

@Component
  // 通用头部
export struct NavBar {
  @Prop title: string = ''; // 标题
  @Prop backImg: string = ''; // 可以选择的自定义返回按钮图标
  @Prop bgColor: string = '#FFFFFF'; // NavBar自定义背景颜色
  @Prop customBack?: () => void; // 自定义返回函数
  @Prop mode: string = 'center'; // left center 标题文字位置

  build() {
      Row() {
          // 最左边内容，返回按钮
          Row() {
              Image(this.backImg || Utils.getImgPath('home/adult_page_back_black.png'))
                  .width(Utils.getVp(48))
                  .height(Utils.getVp(48))
                  .objectFit(ImageFit.Cover)
          }
          .onClick(() => {
              // 传递了返回函数就使用
              if (this.customBack) {
                  this.customBack()
              } else {
                  router.back();
              }
          })

          // title显示
          Row() {
              Text(this.title)
                  .fontColor('#191B27')
                  .fontSize(Utils.getVp(33))
                  .fontWeight(FontWeight.Bold)
                  .textAlign(this.mode == 'center' ? TextAlign.Center : TextAlign.Start)
                  .width('100%')
          }
          .margin({
              left: this.mode == 'center' ? 0 : Utils.getVp(20),
          })
          // 占满剩余内容
          .flexShrink(1)
          .height('100%')
      }
      .width('100%')
      .padding({
          left: Utils.getVp(32),
          right: Utils.getVp(32),
      })
      .height(Utils.getVp(88))
      .backgroundColor(this.bgColor)
  }
}
```

父组件中使用

```js
import { NavBar } from './component/NavBar';

@Entry
@Component
struct Father {
    build() {
        Column() {
            NavBar({
                title: '我是一个标题',
                mode: 'center',
            })
        }
        .width('100%')
    	.height('100%')
    }
}
```

如果想要将标题放在靠左边，则可以将父组件里面的mode传参改为left

```js
import { NavBar } from './component/NavBar';

@Entry
@Component
struct Father {
    build() {
        Column() {
            NavBar({
                title: '我是一个标题',
                mode: 'left',
            })
        }
        .width('100%')
    	.height('100%')
    }
}
```

其余参数可以根据需求传递，也可以根据不同需求扩展Prop字段

### 总结

做一个简易版的通用头部需要使用**@Component**装饰器创建一个组件

在组件上预设好ui，使用**@Prop**填充，在父组件调用时传入即可