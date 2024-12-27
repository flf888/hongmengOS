import Utils from "../common/utils/Utils"

@Component
@Preview
export default struct EmptyLayout {
  //图片配置
  imageRe: string = Utils.getImgPath('media/fire_empty_bg.png')
  imgWidth: number = 135
  imgHeight: number = 150

  //提示文字配置
  warnTxt: string = '暂无数据'
  warnTxtColor?: Color
  warnTxtFontSize: number = 14

  //按钮样式
  warnBtTxt: string = ''
  warnBtTxtFontSize: number = 15
  warnBtWidth: number = 196
  warnBtHeight: number = 44
  warnBtTextColor: Color = Color.White
  tapFunc?: Function

  build() {
    Column(){
      Image(this.imageRe)
        .height(this.imgHeight)
        .width(this.imgWidth)
      Text(this.warnTxt)
        .fontSize(this.warnTxtFontSize)
        .fontColor(this.warnTxtColor != null ? this.warnTxtColor : $r('app.color.auxiliaryTextColor'))
        .margin({ top: 15 })
      if(this.warnBtTxt != ''){
        Button(this.warnBtTxt != '' ? this.warnBtTxt :  '重新加载')
          .width(this.warnBtWidth)
          .height(this.warnBtHeight)
          .margin({top: 40})
          .fontSize(this.warnBtTxtFontSize)
          .fontColor(this.warnBtTextColor)
          .backgroundColor(Color.Transparent)
          .fontWeight(700)
          .stateEffect(false)
          .linearGradient({
            direction: GradientDirection.Left, // 渐变方向
            repeating: false, // 渐变颜色是否重复
            colors: [[0x4D5C70, 0], [0x191B27, 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .onClick(()=>{
            this.tapFunc?.();
          })
      }

    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .height(500)
  }
}