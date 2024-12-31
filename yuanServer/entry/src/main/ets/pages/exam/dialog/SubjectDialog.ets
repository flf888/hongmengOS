// xxx.ets
import { AppUtil } from '../../../common/utils/AppUtil';
import Utils from '../../../common/utils/Utils'

@Preview
@CustomDialog
export struct SubjectDialog {
  controller: CustomDialogController
  commitFunc?: Function;
  defaultText: string = ''
  @State text: string = ''
  @State isBig: boolean = false
  TextAreaController: TextAreaController = new TextAreaController()

  aboutToAppear(): void {
    this.text = this.defaultText;
  }

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Text()
          .width(Utils.getVp(46))
          .height(Utils.getVp(46))
          .margin({ left: Utils.getVp(31), right: Utils.getVp(31) })
        Text("编辑答案")
          .fontColor($r('app.color.blodTextColor'))
          .fontSize(Utils.getVp(35))
          .fontWeight(FontWeight.Bold)

        Image(Utils.getImgPath(this.isBig ? 'exam/subject_scale_small.png' : 'exam/subject_scale_big.png'))
          .width(Utils.getVp(46))
          .height(Utils.getVp(46))
          .margin({ left: Utils.getVp(31), right: Utils.getVp(31) })
          .onClick(() => {
            this.isBig = !this.isBig;
          })
      }.width('100%').height(Utils.getVp(84)).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween)

      Column() {
        TextArea({
          text: this.text,
          placeholder: '请输入答案',
          controller: this.TextAreaController
        })
          .height('100%')
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: Utils.getVp(31) })
          .caretColor(Color.Blue)
          .backgroundColor(Color.Transparent)
          .width(Utils.getVp(631))
          .fontSize(Utils.getVp(31))
          .fontColor($r('app.color.blodTextColor'))
          .defaultFocus(true)
          .onChange((value: string) => {
            this.text = value
          })
      }
      .width('100%')
      .height('100%')
      .margin({ top: Utils.getVp(40) })
      .flexShrink(1)

      Row() {
        Button('提交答案', { type: ButtonType.Capsule, stateEffect: false })
          .linearGradient({
            direction: GradientDirection.Left, // 渐变方向
            repeating: false, // 渐变颜色是否重复
            colors: [[0xff05C7FF, 0], [0xff0082FF, 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .backgroundColor(Color.Transparent)
          .width(Utils.getVp(631))
          .height(Utils.getVp(84))
          .onClick(() => {
            this.commitFunc?.(this.text);
            this.controller.close();
          })
      }
      .width('100%')
      .height(Utils.getVp(100))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: Utils.getVp(20), top: Utils.getVp(20) })
    }
    .backgroundColor(Color.White)
    .width(Utils.getVp(720))
    .height(this.isBig ? '100%' : Utils.getVp(426))
    .padding({
      top: this.isBig ? 80 : 0,
      bottom: this.isBig ? AppUtil.getNavigationIndicatorHeight() : 0
    })
  }
}