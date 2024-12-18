# 鸿蒙 next 实现知识点列表的重复布局

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





## 3.知识点列表的重复布局,手机端为每行一列，平板端为每行3列。

```JavaScript
 GridRow({
            gutter: Utils.getVp(23)
          }) {
            ForEach(this.knowledgeDataList, (item: KnowledgeItem, tempIndex) => {
               // 通过配置元素在不同断点下占的列数，实现不同的布局效果
              GridCol({ span: { sm: 12, md: 6, lg: 4 } }) {
                KnowledgeListItemLayout({ knowledgeInfo: item, level: 0 });
              }
            })
          }
```

