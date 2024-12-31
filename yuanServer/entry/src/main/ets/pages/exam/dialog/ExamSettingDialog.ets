// xxx.ets
import Utils from '../../../common/utils/Utils'
import ToastUtils from '../../../common/utils/ToastUtils';

@Preview
@CustomDialog
export struct ExamSettingDialog {
  controller: CustomDialogController
  @State checkIndex: number = 0;
  @State checkModeIndex: number = 0;
  @State checkFontIndex: number = 1;
  @State isParse: boolean = false;
  @Consume writeMode: boolean;

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
      }.width('100%').height(Utils.getVp(92)).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.End)

      if (!this.isParse) {
        Row() {
          Column() {
            Text("练习")
              .fontColor(this.writeMode ? $r('app.color.mainColor') : $r('app.color.subTextColor'))
              .fontSize(Utils.getVp(31))
              .fontWeight(FontWeight.Medium)
            Text("按组答完交卷后查看练习报告、答案解析")
              .fontColor(this.writeMode ? $r('app.color.mainColor') : $r('app.color.subTextColor'))
              .fontSize(Utils.getVp(23))
              .margin({ top: Utils.getVp(15) })
          }
          .width(Utils.getVp(310))
          .height(Utils.getVp(144))
          .backgroundColor(this.writeMode ? '#1f0080ff' : '#ffffffFF')
          .borderRadius(Utils.getVp(31))
          .border({ width: Utils.getVp(3), color: this.writeMode ? '#ff0080ff' : Color.Transparent })
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .margin({ left: Utils.getVp(38) })
          .padding({ left: Utils.getVp(23), right: Utils.getVp(23) })
          .shadow({ radius: 16, color: '#0f000000' })
          .onClick(() => {
            this.writeMode = true;
          })

          Column() {
            Text("背题")
              .fontColor(!this.writeMode ? $r('app.color.mainColor') : $r('app.color.subTextColor'))
              .fontSize(Utils.getVp(31))
              .fontWeight(FontWeight.Medium)
            Text("无需交卷，可直接显示答案和解析")
              .fontColor(!this.writeMode ? $r('app.color.mainColor') : $r('app.color.subTextColor'))
              .fontSize(Utils.getVp(23))
              .margin({ top: Utils.getVp(15) })
          }
          .width(Utils.getVp(310))
          .height(Utils.getVp(144))
          .backgroundColor(!this.writeMode ? '#1f0080ff' : '#ffffffFF')
          .borderRadius(Utils.getVp(31))
          .border({
            width: !this.writeMode ? Utils.getVp(3) : 0,
            color: !this.writeMode ? '#ff0080ff' : Color.Transparent
          })
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .margin({ left: Utils.getVp(23) })
          .padding({ left: Utils.getVp(23), right: Utils.getVp(23) })
          .shadow({ radius: 16, color: '#0f000000' })
          .onClick(() => {
            this.writeMode = false;
          })
        }.width('100%').height(Utils.getVp(144))

        Row() {
          Text("清空答题记录")
            .fontColor($r('app.color.blodTextColor'))
            .fontSize(Utils.getVp(27))
            .fontWeight(FontWeight.Medium)

          Blank()

          Image(Utils.getImgPath('iconsvg/005arrow_more.svg'))
            .width(Utils.getVp(38))
            .height(Utils.getVp(38))
            .fillColor($r('app.color.auxiliaryTextColor'))
        }
        .width('100%')
        .height(Utils.getVp(123))
        .alignItems(VerticalAlign.Center)
        .padding({ left: Utils.getVp(38), right: Utils.getVp(38) })
        .onClick(() => {
          ToastUtils.showToast("当前测验不能清空，请稍后重试..")
        })

        Divider()
          .color('#999FB5')
          .strokeWidth(Utils.getVp(1))
          .padding({ left: Utils.getVp(38), right: Utils.getVp(38) })

      }

      Row() {
        Text("主题选择")
          .fontColor($r('app.color.blodTextColor'))
          .fontSize(Utils.getVp(27))
          .fontWeight(FontWeight.Medium)

        Blank()

        Column() {
          Image(Utils.getImgPath('iconsvg/015mode_night.svg'))
            .width(Utils.getVp(38))
            .height(Utils.getVp(38))
            .fillColor(this.checkModeIndex == 0 ? Color.White : $r('app.color.blodTextColor'))

          Text("夜间")
            .fontColor(this.checkModeIndex == 0 ? Color.White : $r('app.color.blodTextColor'))
            .fontSize(Utils.getVp(27))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })

        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(Utils.getVp(142))
        .height(Utils.getVp(100))
        .borderRadius(Utils.getVp(15))
        .backgroundColor(this.checkModeIndex == 0 ? $r('app.color.mainColor') : '#1abec2d1')
        .onClick(() => {
          this.checkModeIndex = 0;
        })


        Column() {
          Image(Utils.getImgPath('iconsvg/014mode_bright.svg'))
            .width(Utils.getVp(38))
            .height(Utils.getVp(38))
            .fillColor(this.checkModeIndex == 1 ? Color.White : $r('app.color.blodTextColor'))

          Text("日间")
            .fontColor(this.checkModeIndex == 1 ? Color.White : $r('app.color.blodTextColor'))
            .fontSize(Utils.getVp(27))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })
        }
        .margin({ left: Utils.getVp(23) })
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(Utils.getVp(142))
        .height(Utils.getVp(100))
        .borderRadius(Utils.getVp(15))
        .backgroundColor(this.checkModeIndex == 1 ? $r('app.color.mainColor') : '#1abec2d1')
        .onClick(() => {
          this.checkModeIndex = 1;
        })
      }
      .margin({ top: Utils.getVp(25) })
      .width('100%')
      .height(Utils.getVp(123))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Utils.getVp(38), right: Utils.getVp(38) })


      Row() {
        Text("字体大小")
          .fontColor($r('app.color.blodTextColor'))
          .fontSize(Utils.getVp(27))
          .fontWeight(FontWeight.Medium)

        Blank()

        Column() {

          Text("A")
            .fontColor(this.checkFontIndex == 0 ? $r('app.color.blodTextColor') : $r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(23))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })

          Text("小号")
            .fontColor(this.checkFontIndex == 0 ? $r('app.color.blodTextColor') : $r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(27))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(Utils.getVp(100))
        .height(Utils.getVp(100))
        .onClick(() => {
          this.checkFontIndex = 0;
        })

        Column() {

          Text("A")
            .fontColor(this.checkFontIndex == 1 ? $r('app.color.blodTextColor') : $r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(31))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })

          Text("中号")
            .fontColor(this.checkFontIndex == 1 ? $r('app.color.blodTextColor') : $r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(27))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(Utils.getVp(100))
        .height(Utils.getVp(100))
        .onClick(() => {
          this.checkFontIndex = 1;
        })

        Column() {

          Text("A")
            .fontColor(this.checkFontIndex == 2 ? $r('app.color.blodTextColor') : $r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(35))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })

          Text("大号")
            .fontColor(this.checkFontIndex == 2 ? $r('app.color.blodTextColor') : $r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(27))
            .fontWeight(FontWeight.Medium)
            .margin({ top: Utils.getVp(10) })
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width(Utils.getVp(100))
        .height(Utils.getVp(100))
        .onClick(() => {
          this.checkFontIndex = 2;
        })
      }
      .width('100%')
      .height(Utils.getVp(123))
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: Utils.getVp(38), right: Utils.getVp(38) })

    }
    .backgroundColor(Color.White)
    .borderRadius({ topLeft: Utils.getVp(32), topRight: Utils.getVp(32) })
    .padding({ bottom: Utils.getVp(25) })
  }
}