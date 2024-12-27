import Utils from "../common/utils/Utils"

@Component
@Preview
export default struct FailLayout {
  reloadFunc?: Function
  imageRes: string = Utils.getImgPath('media/fire_icon_no_network.png')
  warnText: string = '网络失败'
  btnText: string = '重新加载'

  build() {
    Column(){
      Image(this.imageRes)
        .height(135)
        .width(150)
      Text(this.warnText)
        .fontSize(14)
        .fontColor($r('app.color.auxiliaryTextColor'))
        .margin({ top: 15 })
      Button(this.btnText)
        .width(196)
        .height(44)
        .margin({top: 40})
        .fontSize(15)
        .fontColor(Color.White)
        .backgroundColor(Color.Transparent)
        .stateEffect(false)
        .linearGradient({
          direction: GradientDirection.Left, // 渐变方向
          repeating: false, // 渐变颜色是否重复
          colors: [[0x4D5C70, 0], [0x191B27, 1]] // 数组末尾元素占比小于1时满足重复着色效果
        })
        .onClick(()=>{
          this.reloadFunc?.();
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .height('100%')
  }
}