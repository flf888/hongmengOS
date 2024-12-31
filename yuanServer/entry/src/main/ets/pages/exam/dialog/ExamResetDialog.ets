// xxx.ets
import Utils from '../../../common/utils/Utils'

@Preview
@CustomDialog
export struct ExamResetDialog {
  controller: CustomDialogController
  clearFunc?: Function;

  build() {
    Column() {
      Row() {
        Image(Utils.getImgPath('iconsvg/008close.svg'))
          .width(Utils.getVp(92))
          .height(Utils.getVp(46))
          .fillColor('#ffBEC2D1')
          .padding({ left: Utils.getVp(23), right: Utils.getVp(23) })
          .onClick(() => {
            this.controller.close();
          })
      }.width('100%').height(Utils.getVp(61)).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.End)

      Text("重新作答")
        .fontColor($r('app.color.blodTextColor'))
        .fontSize(Utils.getVp(35))
        .fontWeight(FontWeight.Bold)

      Text("请确认是否清空当前答题卡")
        .fontColor($r('app.color.subTextColor'))
        .fontSize(Utils.getVp(29))
        .margin({ top: Utils.getVp(56) })

      Text("全部作答数据？")
        .fontColor($r('app.color.subTextColor'))
        .fontSize(Utils.getVp(29))
        .margin({ top: Utils.getVp(21) })

      Row() {

        Button('确认清空', { type: ButtonType.Capsule, stateEffect: false })
          .linearGradient({
            direction: GradientDirection.Left, // 渐变方向
            repeating: false, // 渐变颜色是否重复
            colors: [["#E7EAF0", 0], ["#E7EAF0", 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .fontColor("#465069")
          .backgroundColor(Color.Transparent)
          .width(Utils.getVp(275))
          .height(Utils.getVp(84))
          .margin({ left: Utils.getVp(38) })
          .onClick(() => {
            this.clearFunc?.()
            this.controller.close();
          })

        Button('取消', { type: ButtonType.Capsule, stateEffect: false })
          .linearGradient({
            direction: GradientDirection.Left, // 渐变方向
            repeating: false, // 渐变颜色是否重复
            colors: [["#4D5C70", 0], ["#191B27", 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .backgroundColor(Color.Transparent)
          .width(Utils.getVp(275))
          .height(Utils.getVp(84))
          .margin({ left: Utils.getVp(23) })
          .onClick(() => {
            this.controller.close();
          })

      }.margin({ top: Utils.getVp(61) })

    }
    .backgroundColor(Color.White)
    .width(Utils.getVp(651))
    .height(Utils.getVp(415))
    .borderRadius(Utils.getVp(31))
  }
}