# HarmonyOS Next: Developing Custom Features Based on @xwf/image_preview (V1.0.1)

**Library Link**: https://ohpm.openharmony.cn/#/cn/detail/@xwf%2Fimage_preview/v/1.0.1

------

## Background

We leverage the `@xwf/image_preview` library for image preview with gesture zooming. However, we need to display previews in a **modal popup** instead of navigating to a new page. Attempts to use the `ImageItemView` component failed due to its dependency on `@Consumer`, and we required single-click background dismissal (not grayscale mode switching). Thus, we forked and modified this version for our needs.

------

## Using `MyImageItemView` Component

1. 

   Rename Components

   :

   - `ImageItemView` → `MyImageItemView`
   - `ImagePreview` → `MyImagePreview`

2. **Remove `@Consumer` Code**:
    Delete dependency injection code from `MyImageItemView`.

3. **Add `onSingleClickBg` Event**:
    Implement a callback for background clicks.

------

## Full Code for `MyImagePreview`

```
import { CommonConstants } from '../constants/CommonConstants';
import { ImagePreviewOption, ImageType } from '../model/ImagePreviewOption';
import { MyImageItemView } from './MyImageItemView';

@Component
export struct MyImagePreview {
  // Image data
  option: ImagePreviewOption = { images: [], index: 0 };
  // Indicator style
  indicator: DotIndicator | DigitIndicator | boolean = new DotIndicator()
    .color(Color.Gray)
    .selectedColor(Color.Blue);
  // Page index change listener
  onChange: (index: number) => void = () => {};
  onSingleClickBg?: () => void;

  private DISPLAY_COUNT: number = 1;
  private MIN_SCALE: number = 0.75;
  @State private opacityList: number[] = [];
  @State private scaleList: number[] = [];
  @State private translateList: number[] = [];
  @State private zIndexList: number[] = [];
  @State private bgc: Color = Color.Black;

  aboutToAppear(): void {
    for (let i = 0; i < this.option.images.length; i++) {
      this.opacityList.push(1.0);
      this.scaleList.push(1.0);
      this.translateList.push(0.0);
      this.zIndexList.push(0);
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
            .zIndex(this.zIndexList[index]);
        });
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .width(CommonConstants.THOUSANDTH_1000)
      .height(CommonConstants.THOUSANDTH_1000)
      .loop(false)
      .indicator(
        this.option.images.length > 1
          ? this.indicator
          : false
      )
      .displayCount(this.DISPLAY_COUNT, true)
      .index(this.option.index)
      .customContentTransition({
        // Timeout for removing pages from the render tree
        timeout: 1000,
        // Custom transition animation
        transition: (proxy: SwiperContentTransitionProxy) => {
          if (
            proxy.position <= proxy.index % this.DISPLAY_COUNT ||
            proxy.position >= this.DISPLAY_COUNT + proxy.index % this.DISPLAY_COUNT
          ) {
            // Reset properties for pages outside the viewport
            this.opacityList[proxy.index] = 1.0;
            this.scaleList[proxy.index] = 1.0;
            this.translateList[proxy.index] = 0.0;
            this.zIndexList[proxy.index] = 0;
          } else {
            // Animate adjacent pages into view
            if (proxy.index % this.DISPLAY_COUNT === 0) {
              this.opacityList[proxy.index] = 1 - proxy.position / this.DISPLAY_COUNT;
              this.scaleList[proxy.index] = this.MIN_SCALE +
                (1 - this.MIN_SCALE) * (1 - proxy.position / this.DISPLAY_COUNT);
              this.translateList[proxy.index] = -proxy.position * proxy.mainAxisLength +
                (1 - this.scaleList[proxy.index]) * proxy.mainAxisLength / 2.0;
            } else {
              this.opacityList[proxy.index] = 1 - (proxy.position - 1) / this.DISPLAY_COUNT;
              this.scaleList[proxy.index] = this.MIN_SCALE +
                (1 - this.MIN_SCALE) * (1 - (proxy.position - 1) / this.DISPLAY_COUNT);
              this.translateList[proxy.index] = -(proxy.position - 1) * proxy.mainAxisLength -
                (1 - this.scaleList[proxy.index]) * proxy.mainAxisLength / 2.0;
            }
            this.zIndexList[proxy.index] = -1;
          }
        },
      })
      .onChange((index) => {
        this.onChange(index);
      });
      // Additional event listeners can be added here
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor(this.bgc)
    .width(CommonConstants.THOUSANDTH_1000)
    .height(CommonConstants.THOUSANDTH_1000);
  }
}
```

------

## Key Notes

1. **Customization Focus**:
   - Modified gesture handling and animation logic.
   - Removed grayscale mode and implemented single-click dismissal.
2. **Technical Details**:
   - Uses `Swiper` for image carousel management.
   - Implements custom transition animations via `customContentTransition`.
3. **Dependencies**:
   - Requires `@xwf/image_preview` V1.0.1 (modified locally).

------

Let me know if you need further refinements or additional context!
