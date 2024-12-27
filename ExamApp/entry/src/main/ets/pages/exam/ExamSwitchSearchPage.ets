
@Extend(Text)
function textStyle() {
  .width('25%')
  .height(35)
  .fontSize(16)
  .textAlign(TextAlign.Center)
  .backgroundColor(0xAFEEEE)
}

@Entry
@Component
@Preview
  //考试选择搜索
struct ExamSwitchSearchPage {
  // 列表数据
  @State array: Array<string> = ['1', '2', '3', '4', '5', '6', '7', '8', '9']
  // key:索引,value:y轴位置
  private mapOffsetY: Map<number, number> = new Map()
  // 移动的index
  @State moveIndex: number = -2
  // 移动的偏移量
  @State moveOffsetY: number = 0
  // 按下时自身顶点y轴位置
  private downSelfY = 0
  // 按下时距屏幕的y轴位置
  private downScreenY = 0

  build() {
    Column() {
      ForEach(this.array, (item: string, index) => {
        Text('内容' + item)
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontColor(Color.White)
          .borderRadius(10)
          .margin({ bottom: 10 })
          .textAlign(TextAlign.Center)
          .zIndex(this.moveIndex === index ? 1 : 0)
          .position({
            x: this.moveIndex === index ? 5 : 0,
            y: this.moveIndex === index ? this.moveOffsetY : this.mapOffsetY.get(index)
          })
          .animation({ duration: this.moveIndex === index ? 0 : 100 })
          .backgroundColor(this.moveIndex === index ? '#14a063' : '#18BF74')
          .onTouch((event: TouchEvent) => this.onTouchEvent(event, index))
          .onAreaChange((oldValue: Area, newValue: Area) => {
            if (this.mapOffsetY.size !== this.array.length) {
              // 记录每个item的y坐标
              console.info(`index = ${index} ${JSON.stringify(newValue)}`)
              const height = Number.parseInt(newValue.height.toString())
              this.mapOffsetY.set(index, 10 + (index * 10) + index * height)
              // 更新页面，才能让position起作用
              this.moveIndex = -1
            }
          })
      }, (item: string) => item)
    }.width('100%')
    .height('100%')
    .padding(10)
  }

  onTouchEvent(event: TouchEvent, index: number) {
    switch (event.type) {
    // 手指按下
      case TouchType.Down: {
        // 更新当前移动的index
        this.moveIndex = index
        // 按下时自身顶点y轴位置
        this.downSelfY = event.touches[0].y
        // 按下时距屏幕的y轴位置
        this.downScreenY = event.touches[0].windowY
        // 更改偏移量
        this.moveOffsetY = this.downScreenY - this.downSelfY - 5
      }
        break;
    // 手指移动
      case TouchType.Move: {
        // 距离屏幕y坐标
        const screenY = event.touches[0].windowY
        // 更改偏移量
        this.moveOffsetY = screenY - this.downSelfY - 5
        // 第一位，不能上移
        if (this.moveIndex === 0 && this.moveOffsetY < 0) {
          this.moveOffsetY = 0
          return
        }
        // 最后一位，不能下移
        if (this.moveIndex === this.array.length - 1 &&
          this.moveOffsetY > (this.mapOffsetY.get(this.moveIndex) as number)) {
          this.moveOffsetY = this.mapOffsetY.get(this.moveIndex) as number
          return
        }
        // 向下拖动
        if (screenY - this.downScreenY > 25) {
          // 交换满足条件的两个item内容
          const tempOffsetY = this.array[this.moveIndex+1]
          this.array[this.moveIndex+1] = this.array[this.moveIndex]
          this.array[this.moveIndex] = tempOffsetY
          // 更新按下的y坐标
          this.downScreenY += 60
          // 更新移动的索引，触发页面的更新
          this.moveIndex++
        }
        // 向上拖动
        if (screenY - this.downScreenY < -35) {
          const tempOffsetY = this.array[this.moveIndex-1]
          this.array[this.moveIndex-1] = this.array[this.moveIndex]
          this.array[this.moveIndex] = tempOffsetY
          this.downScreenY -= 60
          this.moveIndex--
        }
      }
        break
      case TouchType.Up: // 手指抬起
        this.moveIndex = -1
        break
      default:
        break;
    }
  }
}