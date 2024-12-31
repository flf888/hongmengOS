@Component
export struct MyButton {
  @Prop btnText: string = "";
  @Prop btnWidth: Length = 56;
  @Prop btnHeight: Length = 26;
  @Prop btnColor: Color = Color.White;
  @Prop btnFontSize: number = 13;
  @Prop btnRadius: number = 13;
  @Prop btnLinearGradientDirection: GradientDirection = GradientDirection.Left;
  @Prop btnLinearGradientColor: Array<[
    ResourceColor,
    number
  ]> = [['#05C7FF', 0], ['#0082FF', 1]];

  build() {
    Row() {
      Text(this.btnText)
        .fontSize(this.btnFontSize)
        .fontColor(this.btnColor)
    }
    .width(this.btnWidth)
    .height(this.btnHeight)
    .borderRadius(this.btnRadius)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .linearGradient({
      direction: this.btnLinearGradientDirection, // 渐变方向
      repeating: false, // 渐变颜色是否重复
      colors: this.btnLinearGradientColor// 数组末尾元素占比小于1时满足重复着色效果
    })
  }
}