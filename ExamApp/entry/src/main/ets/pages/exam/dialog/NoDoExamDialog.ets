// xxx.ets
import Utils from '../../../common/utils/Utils'
import { CustomIcon, CustomIconType } from '../../../view/CustomIcon';
import { StyleColor, StyleRes } from '../utils/StyleRes';

//如果在 @CustomDialog使用 @Consume 概率情况下会发生闪退
@Preview
@CustomDialog
export struct NoDoExamDialog {
  controller: CustomDialogController
  doNumber: number = 0
  @Prop lightMode: boolean;
  @Prop questionsTotal: number;
  commitFunc?: Function;

  build() {
    Column() {
      Row() {
        CustomIcon({
          iconType: CustomIconType.ico_close,
          iconSize: 24,
          iconColor: $r('app.color.auxiliaryTextColor'),
        })
          .padding({
            left: 12,
            right: 12
          })
          .onClick(() => {
            this.controller.close();
          })

      }.width('100%').height(Utils.getVp(61)).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.End)

      Text("还没答完哦，确认交卷？")
        .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
        .fontSize(Utils.getVp(35))
        .fontWeight(FontWeight.Bold)

      Stack({ alignContent: Alignment.Top }) {

        Progress({ value: 100, total: 200, type: ProgressType.Ring })
          .width(Utils.getVp(280))
          .height(Utils.getVp(280))
          .color($r('app.color.separatorLineColor'))
          .backgroundColor(Color.Transparent)
          .style({ strokeWidth: 15 })
          .rotate({ angle: 270 })

        Progress({
          value: 100 * (this.doNumber) / this.questionsTotal,
          total: 200,
          type: ProgressType.Ring
        })
          .width(Utils.getVp(280))
          .height(Utils.getVp(280))
          .color($r('app.color.mainColor'))
          .backgroundColor(Color.Transparent)
          .style({ strokeWidth: 15 })
          .rotate({ angle: 270 })

        Row() {
          Text(`${this.questionsTotal - this.doNumber}`)
            .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
            .fontSize(Utils.getVp(65))

          Text('题')
            .fontColor($r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(35))
            .margin({ top: Utils.getVp(8), left: Utils.getVp(10) })
        }.margin({ top: Utils.getVp(60) })

        Text(`未答`)
          .fontColor($r('app.color.auxiliaryTextColor'))
          .fontSize(Utils.getVp(23))
          .margin({ top: Utils.getVp(140) })

        Row() {
          Button('确认', { type: ButtonType.Capsule, stateEffect: false })
            .fontColor("#465069")
            .backgroundColor($r('app.color.separatorLineColor'))
            .width(Utils.getVp(275))
            .height(Utils.getVp(84))
            .margin({ left: Utils.getVp(38) })
            .onClick(() => {
              this.controller.close();
              this.commitFunc?.();
            })

          Button('继续答题', { type: ButtonType.Capsule, stateEffect: false })
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
        }
        .width('100%')
        .margin({ top: Utils.getVp(230) })
      }
      .width('100%')
      .height(Utils.getVp(290))
      .margin({ top: Utils.getVp(40), bottom: Utils.getVp(40) }) // 设置strokeWidth进度条宽度为15.0vp
    }
    .backgroundColor(StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode))
    .width(Utils.getVp(651))
    .height(Utils.getVp(495))
    .borderRadius(Utils.getVp(31))
  }
}