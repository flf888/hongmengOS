

# 鸿蒙 next 基于@xwf/image_preview(V1.0.1)开发自己的功能

@xwf/image_preview(V1.0.1)的链接为: [https://ohpm.openharmony.cn/#/cn/detail/@xwf%2Fimage_preview/v/1.0.1](https://ohpm.openharmony.cn/#/cn/detail/@xwf%2Fimage_preview/v/1.0.1)



## 前提背景

图片预览我们使用到了`@xwf/image_preview`库，用于预览图片可以进行手势放大，但是我们需要以弹窗的形式显示预览图片，而不是通过跳转页面的形式来显示预览图片。我们尝试使用 ImageItemView 组件但是发现报错，因为该组件使用到了 @Cousmer，并且我们需要单击预览的时候返回页面，而不是切换黑白模式。所以基于以上原因我们将该版本复制到自己的工程并进行修改。

## 使用MyImageItemView 组件

1. 复制代码后，将ImageItemView重命名为MyImageItemView，将ImagePreview重命名为MyImagePreview。

2. 将MyImageItemView 的@Cousume 的代码进行删除

3. 添加 onSingleClickBg 事件



## MyImagePreview 的完整代码:

```JavaScript
import { CommonConstants } from '../constants/CommonConstants';
import { ImagePreviewOption, ImageType } from '../model/ImagePreviewOption';
import { MyImageItemView } from './MyImageItemView';

@Component
export struct MyImagePreview {
  //图片数据
  option: ImagePreviewOption = { images: [], index: 0 }
  //指示器样式
  indicator: DotIndicator | DigitIndicator | boolean = new DotIndicator().color(Color.Gray).selectedColor(Color.Blue)
  //页标改变监听
  onChange: (index: number) => void = () => {
  }
  onSingleClickBg?: () => void
  private DISPLAY_COUNT: number = 1
  private MIN_SCALE: number = 0.75
  @State private opacityList: number[] = []
  @State private scaleList: number[] = []
  @State private translateList: number[] = []
  @State private zIndexList: number[] = []
  @State private bgc: Color = Color.Black;

  aboutToAppear(): void {


    for (let i = 0; i < this.option.images.length; i++) {
      this.opacityList.push(1.0)
      this.scaleList.push(1.0)
      this.translateList.push(0.0)
      this.zIndexList.push(0)
    }
  }

  build() {
    Stack() {
      Swiper() {
        ForEach(this.option.images, (image: ImageType, index: number) => {
          MyImageItemView({ url: image, onSingleClickBg: this.onSingleClickBg })
            .width(CommonConstants.THOUSANDTH_1000)
            .height(CommonConstants.THOUSANDTH_1000)
            .opacity(this.opacityList[index])
            .scale({ x: this.scaleList[index], y: this.scaleList[index] })
            .translate({ x: this.translateList[index] })
            .zIndex(this.zIndexList[index])
        })
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .width(CommonConstants.THOUSANDTH_1000)
      .height(CommonConstants.THOUSANDTH_1000)
      .loop(false)
      .indicator(this.option.images.length > 1 ? this.indicator : false)
      .displayCount(this.DISPLAY_COUNT, true)
      .index(this.option.index)
      .customContentTransition({
        // 页面移除视窗时超时1000ms下渲染树
        timeout: 1000,
        // 对视窗内所有页面逐帧回调transition，在回调中修改opacity、scale、translate、zIndex等属性值，实现自定义动画
        transition: (proxy: SwiperContentTransitionProxy) => {
          if (proxy.position <= proxy.index % this.DISPLAY_COUNT ||
            proxy.position >= this.DISPLAY_COUNT + proxy.index % this.DISPLAY_COUNT) {
            // 同组页面往左滑或往右完全滑出视窗外时，重置属性值
            this.opacityList[proxy.index] = 1.0
            this.scaleList[proxy.index] = 1.0
            this.translateList[proxy.index] = 0.0
            this.zIndexList[proxy.index] = 0
          } else {
            // 同组页面往右滑且未滑出视窗外时，对同组中左右两个页面，逐帧根据position修改属性值，实现两个页面往Swiper中间靠拢并透明缩放的自定义切换动画
            if (proxy.index % this.DISPLAY_COUNT === 0) {
              this.opacityList[proxy.index] = 1 - proxy.position / this.DISPLAY_COUNT
              this.scaleList[proxy.index] =
                this.MIN_SCALE + (1 - this.MIN_SCALE) * (1 - proxy.position / this.DISPLAY_COUNT)
              this.translateList[proxy.index] =
                -proxy.position * proxy.mainAxisLength + (1 - this.scaleList[proxy.index]) * proxy.mainAxisLength / 2.0
            } else {
              this.opacityList[proxy.index] = 1 - (proxy.position - 1) / this.DISPLAY_COUNT
              this.scaleList[proxy.index] =
                this.MIN_SCALE + (1 - this.MIN_SCALE) * (1 - (proxy.position - 1) / this.DISPLAY_COUNT)
              this.translateList[proxy.index] = -(proxy.position - 1) * proxy.mainAxisLength -
                (1 - this.scaleList[proxy.index]) * proxy.mainAxisLength / 2.0
            }
            this.zIndexList[proxy.index] = -1
          }
        }
      })
      .onChange((index) => {
        //this.option.index = index
        this.onChange(index)
      })

      // .onContentDidScroll((selectedIndex: number, index: number, position: number, mainAxisLength: number) => {
      //   // 监听Swiper页面滑动事件，在该回调中可以实现自定义导航点切换动画等
      //   //Logger.info("onContentDidScroll selectedIndex: " , selectedIndex + ", index: " + index + ", position: " + position + ", mainAxisLength: " + mainAxisLength)
      // })
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor(this.bgc)
    .width(CommonConstants.THOUSANDTH_1000)
    .height(CommonConstants.THOUSANDTH_1000)
  }
}
```





