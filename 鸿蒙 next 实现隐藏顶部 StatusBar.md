# 鸿蒙 next 实现隐藏顶部 StatusBar

在一些业务场景中需要用背景图片或者颜色去自定义顶部 StatusBar 的背景，但鸿蒙 next 中默认是不可以覆盖的，所以这里介绍实现隐藏顶部 StatusBar 的实现步骤。



## 1.在应用启动页中开启沉浸式布局。

开启沉浸式布局的效果就是会让你可以自定义顶部状态栏和底部的指示导航按钮，实现该功能代码如下:

```JavaScript
static setStatusBar(sysBarProps?: window.SystemBarProperties) {
    let windowClass = AppUtil.getMainWindow();
    // 开启沉浸式布局
    windowClass.setWindowLayoutFullScreen(true).then(() => {
      windowClass.setWindowBackgroundColor('#FFFFFF');
    }).catch((error: BusinessError) => {
      LogUtil.error(`setWindowLayoutFullScreen-异常 ~ code: ${error.code} -·- message: ${error.message}`);
    });

    if (sysBarProps) {
      windowClass.setWindowSystemBarProperties(sysBarProps).catch((error: BusinessError) => {
        LogUtil.error(`setWindowSystemBarProperties-异常 ~ code: ${error.code} -·- message: ${error.message}`);
      });
    }

  }
```



## 2.获取状态栏与底部导航按钮的高度

```JavaScript
 /**
   * 获取状态栏的高度，单位为vp。
   * @returns
   */
  static getStatusBarHeight(): number {
    try {
      let windowClass = AppUtil.getMainWindow();
      let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const height = avoidArea.topRect.height; // 单位 px
      return AppUtil.px2vp(height);
    } catch (err) {
      LogUtil.error(JSON.stringify(err));
      return 0;
    }
  }

  /**
   * 获取底部导航条的高度，单位为vp。
   * @returns
   */
  static getNavigationIndicatorHeight(): number {
    try {
      let windowClass = AppUtil.getMainWindow();
      let avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      const height = avoidArea.bottomRect.height; // 单位 px
      return AppUtil.px2vp(height);
    } catch (err) {
      LogUtil.error(JSON.stringify(err));
      return 0;
    }
  }
```



## 3.封装组件 StatusBar 与 NavigationIndicator



### StatusBar：

```JavaScript
import { AppUtil } from "../common/utils/AppUtil";


@Component
@Preview
export struct StatusBar {
  @State statusBarHeight: number = 0;
  @Prop bgColor: ResourceColor = $r('app.color.mainBgColor');

  aboutToAppear(): void {
    this.statusBarHeight = AppUtil.getStatusBarHeight();
    
  }

  build() {
    Row() {
    }
    .width('100%')
    .height(this.statusBarHeight)
    .backgroundColor(this.bgColor)
  }
}
```



### NavigationIndicator

```JavaScript
import { AppUtil } from "../common/utils/AppUtil";

@Component
@Preview
export struct NavigationIndicator {
  @State indicatorHeight: number = 0;
  @Prop bgColor: ResourceColor = $r('app.color.mainBgColor');

  aboutToAppear(): void {
    this.indicatorHeight = AppUtil.getNavigationIndicatorHeight();
  }

  build() {
    Row() {
    }
    .width('100%')
    .height(this.indicatorHeight)
    .backgroundColor(this.bgColor)
  }
}
```





## 4. 将StatusBar放到 TopAppBar 组件中:



```JavaScript
import Utils from '../common/utils/Utils'
import router from '@ohos.router'
import { StatusBar } from './StatusBar';

@Component
@Preview
export struct TopAppBar {
  @Prop title: string = ''
  @Prop backImg: string = '';
  @Prop customBack?: () => void;
  @Prop bgColor: ResourceColor = '#FFFFFF';
  @Prop mode: string = 'center'; // left center 标题文字位置
  @BuilderParam rightBuilderParam?: () => void;
  @BuilderParam centerBuilderParam: () => void;

  build() {
    Column() {
      StatusBar({
        bgColor: this.bgColor
      })
      Row() {
        Row() {
          Image(this.backImg || Utils.getImgPath('home/adult_page_back_black.png'))
            .width(Utils.getVp(48))
            .height(Utils.getVp(48))
            .objectFit(ImageFit.Cover)
        }
        .padding({
          left: 8,
          right: 8,
          top: 4,
          bottom: 4
        })
        .onClick(() => {
          if (this.customBack) {
            this.customBack()
          } else {
            Utils.routeBack();
          }
        })

        Row() {
          if (this.title == '') {
            if (this.centerBuilderParam) {
              // 不传title就使用插槽
              this.centerBuilderParam();
            }
          } else {
            Text(this.title)
              .fontColor($r('app.color.blodTextColor'))
              .fontSize(Utils.getVp(33))
              .fontWeight(FontWeight.Bold)
              .textAlign(this.mode == 'center' ? TextAlign.Center : TextAlign.Start)
              .width('100%')
          }
        }
        .margin({
          left: this.mode == 'center' ? 0 : Utils.getVp(20),
        })
        .flexShrink(1)
        .height('100%')

        Row() {
          // 插槽
          if (this.rightBuilderParam) {
            this.rightBuilderParam();
          }
        }
        .width(Utils.getVp(48))
        .height(Utils.getVp(48))
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({
        left: Utils.getVp(16),
        right: Utils.getVp(16),
      })
      .height(Utils.getVp(88))
      .backgroundColor(this.bgColor)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')

  }
}
```

