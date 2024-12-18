



# 鸿蒙 next实现页签栏平板端适配



## 1.在应用启动时通过 `updateBreakpoint`获取当前窗口尺寸断点

```JavaScript
// 根据当前窗口尺寸更新断点
  private updateBreakpoint(windowWidth: number): void {
    // 拿到当前窗口对象获取当前所在displayId 注释该代码原因: 会在真机平板中报错
    // let displayId = this.windowObj?.getWindowProperties().displayId
    try {
      // 将长度的单位由px换算为vp
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels

      console.log('run get windowWidthVp', windowWidthVp)
      let newBp: string = ''
      if (windowWidthVp < 600) {
        newBp = 'sm'
      } else if (windowWidthVp < 840) { // 840
        newBp = 'md'
      } else {
        newBp = 'lg'
      }

      if (this.curBp !== newBp) {
        this.curBp = newBp
        // 使用状态变量记录当前断点值
        AppStorage.setOrCreate('currentBreakpoint', this.curBp)
      }
    } catch (err) {
      console.log("getDisplayByIdSync failed err" + err.code)
    }
  }
```



## 2.实现通用的断点工具类

```JavaScript
declare interface BreakPointTypeOption<T> {
  sm?: T
  md?: T
  lg?: T
}

/**
 * 媒体查询（mediaquery）
 * 响应式设计的核心
 */
export class BreakPointType<T> {
  options: ESObject

  constructor(option: BreakPointTypeOption<T>) {
    this.options = option
  }

  getValue(currentBreakPoint: string): T {
    return this.options[currentBreakPoint] as T
  }
}
```



### 3.实现手机端页签栏在底部，平板端页签栏在左边:

```JavaScript
Tabs({
        barPosition: new BreakPointType({
          sm: BarPosition.End,
          md: BarPosition.End,
          lg: BarPosition.Start
        }).getValue(this.currentBreakpoint),
        index: 0,
        controller: this.controller
      }) {
        ForEach(tabbarList, (item: TabbarItem, index) => {
          TabContent() {
            if (Utils.isSoutiXiaApp()) {
              // 搜题侠
              this.questionsTabContent(index)
            } else {
              // 基础版
              this.defaultTabContent(index)
            }

          }.tabBar(this.TabBuilder(index))
        })
      }
      .scrollable(false)
      .backgroundColor($r('app.color.mainBgColor'))
      .vertical(new BreakPointType({ sm: false, md: false, lg: true }).getValue(this.currentBreakpoint))
      .barWidth(new BreakPointType({ sm: '100%', md: '100%', lg: Utils.getVp(94) }).getValue(this.currentBreakpoint))
      .barHeight(new BreakPointType({
        sm: Utils.getVp(94),
        md: Utils.getVp(94),
        lg: '100%'
      }).getValue(this.currentBreakpoint))
```

