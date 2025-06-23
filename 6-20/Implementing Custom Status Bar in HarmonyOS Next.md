# Implementing Custom Status Bar in HarmonyOS Next

## 1. Enable Immersive Layout in App Entry

Set up full-screen mode to customize status bar and navigation indicator:

```
static setStatusBar(sysBarProps?: window.SystemBarProperties) {
  const windowClass = AppUtil.getMainWindow();
  
  // Enable immersive layout
  windowClass.setWindowLayoutFullScreen(true)
    .then(() => {
      windowClass.setWindowBackgroundColor('#FFFFFF');
    })
    .catch((error: BusinessError) => {
      LogUtil.error(`Fullscreen error: ${error.code} - ${error.message}`);
    });

  // Apply custom system bar properties
  if (sysBarProps) {
    windowClass.setWindowSystemBarProperties(sysBarProps)
      .catch((error: BusinessError) => {
        LogUtil.error(`System bar error: ${error.code} - ${error.message}`);
      });
  }
}
```

## 2. Get Status Bar and Navigation Indicator Heights

```
/**
 * Get status bar height in vp units
 */
static getStatusBarHeight(): number {
  try {
    const windowClass = AppUtil.getMainWindow();
    const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    return AppUtil.px2vp(avoidArea.topRect.height);
  } catch (err) {
    LogUtil.error(err);
    return 0;
  }
}

/**
 * Get navigation indicator height in vp units
 */
static getNavigationIndicatorHeight(): number {
  try {
    const windowClass = AppUtil.getMainWindow();
    const avoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    return AppUtil.px2vp(avoidArea.bottomRect.height);
  } catch (err) {
    LogUtil.error(err);
    return 0;
  }
}
```

## 3. Custom Status Bar and Navigation Indicator Components

### StatusBar Component:

```
@Component
export struct StatusBar {
  @State statusBarHeight: number = 0;
  @Prop bgColor: ResourceColor = $r('app.color.mainBgColor');

  aboutToAppear(): void {
    this.statusBarHeight = AppUtil.getStatusBarHeight();
  }

  build() {
    Row()
      .width('100%')
      .height(this.statusBarHeight)
      .backgroundColor(this.bgColor)
  }
}
```

### NavigationIndicator Component:

```
@Component
export struct NavigationIndicator {
  @State indicatorHeight: number = 0;
  @Prop bgColor: ResourceColor = $r('app.color.mainBgColor');

  aboutToAppear(): void {
    this.indicatorHeight = AppUtil.getNavigationIndicatorHeight();
  }

  build() {
    Row()
      .width('100%')
      .height(this.indicatorHeight)
      .backgroundColor(this.bgColor)
  }
}
```

## 4. Implement Custom TopAppBar with StatusBar

```
@Component
export struct TopAppBar {
  @Prop title: string = '';
  @Prop backImg: string = '';
  @Prop customBack?: () => void;
  @Prop bgColor: ResourceColor = '#FFFFFF';
  @Prop mode: string = 'center'; // Title position: 'left' or 'center'
  @BuilderParam rightBuilderParam?: () => void;
  @BuilderParam centerBuilderParam: () => void;

  build() {
    Column() {
      // Custom status bar
      StatusBar({ bgColor: this.bgColor })
      
      // App bar content
      Row() {
        // Back button
        Row()
          .padding(8)
          .onClick(() => {
            this.customBack ? this.customBack() : Utils.routeBack();
          })
          .child(
            Image(this.backImg || Utils.getImgPath('back_icon.png'))
              .size({ width: 48, height: 48 })
              .objectFit(ImageFit.Cover)
          )
        
        // Title area
        Row()
          .margin({ left: this.mode === 'center' ? 0 : 20 })
          .flexShrink(1)
          .height('100%')
          .child(
            this.title 
              ? Text(this.title)
                  .fontColor($r('app.color.boldTextColor'))
                  .fontSize(33)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(this.mode === 'center' ? TextAlign.Center : TextAlign.Start)
              : this.centerBuilderParam()
          )
        
        // Right actions
        Row()
          .size({ width: 48, height: 48 })
          .justifyContent(FlexAlign.Center)
          .child(this.rightBuilderParam?.())
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .height(88)
      .backgroundColor(this.bgColor)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
  }
}
```

### Usage in Page:

```
@Entry
@Component
struct HomePage {
  build() {
    Column() {
      TopAppBar({
        title: 'My Application',
        bgColor: Color.Blue,
        mode: 'center'
      })
      
      // Page content
      Text('Main Content')
        .flexGrow(1)
    }
    .height('100%')
  }
}
```

### Key Features:

1. **Full Customization**: Complete control over status bar appearance
2. **Dynamic Height**: Automatically adapts to different device configurations
3. **Flexible Layout**: Supports both centered and left-aligned titles
4. **Custom Actions**: Slot-based right action area
5. **Theme Support**: Seamless integration with resource colors
6. **Back Button Handling**: Built-in navigation with override capability

This implementation provides a fully customizable app bar solution that works consistently across HarmonyOS devices while maintaining the platform's design principles.
