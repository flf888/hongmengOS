// xxx.ets
import { AppUtil } from '../../../common/utils/AppUtil';
import { LogUtil } from '../../../common/utils/LogUtil';
import Utils from '../../../common/utils/Utils'
import { CustomIcon, CustomIconType } from '../../../view/CustomIcon';
import { ExamItem, ExplanCardItem } from '../bean/ExamItem';
import { NewExamQuickUtils } from '../utils/NewExamQuickType';
import { StyleColor, StyleRes } from '../utils/StyleRes';


type ClickNumFunc = (item: ExamItem) => void;

@Preview
@CustomDialog
export struct ExamBottomMenuDialog {
  controller: CustomDialogController
  @Prop isParse: boolean = false; // 是否显示解析
  @Prop questionsTotal: number;
  @Consume examList: ExamItem[]; //数据源
  @Consume currentIndex: number; //当前坐标
  @Consume isDoPaper: boolean;
  @Consume lightMode: boolean;
  @Consume questionMakingMode: boolean;
  @ObjectLink curExamItem: ExamItem;
  clickNumFunc?: ClickNumFunc;
  commitFunc?: Function;
  resetFunc?: Function;
  private cardList: ExplanCardItem[] = [];

  aboutToAppear() {
    const expList = NewExamQuickUtils.parseExpList(this.examList)
    if (this.isDoPaper) {
      // 做试卷
      this.cardList = NewExamQuickUtils.parsePaperCard(expList);
    } else {
      this.cardList = NewExamQuickUtils.parseExamCard(expList);
    }

    LogUtil.info("run ExamBottomMenuDialog this.cardList:" + JSON.stringify(this.cardList))

  }

  build() {
    Column() {
      Row() {

        CustomIcon({
          iconType: CustomIconType.icon_answer,
          iconSize: 19,
          iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
        })

        Text("答题卡")
          .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
          .fontSize(Utils.getVp(31))
          .fontWeight(FontWeight.Bold)
          .margin({ left: Utils.getVp(12) })
        Text(`${NewExamQuickUtils.getCurMainNumber(this.curExamItem)}`)
          .fontColor($r('app.color.mainColor'))
          .fontSize(Utils.getVp(31))
          .margin({ left: Utils.getVp(12) })
        Text(`/${this.questionsTotal}`)
          .fontColor(StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode))
          .fontSize(Utils.getVp(31))

        Blank()

        Text('')
          .width(Utils.getVp(14))
          .height(Utils.getVp(14))
          .backgroundColor($r('app.color.mainColor'))
          .borderRadius(Utils.getVp(7))
        Text("已答")
          .fontColor($r('app.color.auxiliaryTextColor'))
          .fontSize(Utils.getVp(23))
          .margin({ left: Utils.getVp(4) })

        Text('')
          .width(Utils.getVp(14))
          .height(Utils.getVp(14))
          .borderRadius(Utils.getVp(7))
          .margin({ left: Utils.getVp(30) })
          .border({ width: Utils.getVp(3), color: '#ccbec2d1' })
        Text("未答")
          .fontColor($r('app.color.auxiliaryTextColor'))
          .fontSize(Utils.getVp(23))
          .margin({ left: Utils.getVp(4) })

      }.width('100%').height(Utils.getVp(96)).padding({ left: Utils.getVp(42), right: Utils.getVp(38) })

      Scroll() {
        Column() {
          ForEach(this.cardList, (item: ExplanCardItem) => {
            Column() {
              Text(`${item.type_name}`)
                .fontColor(StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode))
                .fontSize(Utils.getVp(27))
                .width('100%')
                .backgroundColor('#1abec2d1')
                .height(Utils.getVp(58))
                .padding({ left: Utils.getVp(38) })
              GridRow({
                columns: 5,
                direction: GridRowDirection.Row
              }) {
                ForEach(item.list, (numberItem: ExamItem) => {
                  GridCol() {
                    this.getItemBuilder(numberItem)
                  }
                })
              }.padding({ left: Utils.getVp(30), right: Utils.getVp(30), bottom: Utils.getVp(38) })
            }
          })
        }
      }.height('100%').flexShrink(1)

      // 不是解析模式并且是做题模式才有交卷按钮
      if (!this.isParse && this.questionMakingMode == true) {
        Row() {
          // Column() {
          //   CustomIcon({
          //     iconType: CustomIconType.ico_restart,
          //     iconSize: 19,
          //     iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
          //   })
          //
          //   Text("重新作答")
          //     .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
          //     .fontSize(Utils.getVp(21))
          //     .margin({ top: Utils.getVp(8) })
          // }
          // .alignItems(HorizontalAlign.Center)
          // .justifyContent(FlexAlign.Center)
          // .width(Utils.getVp(215))
          // .height(Utils.getVp(119))
          // .onClick(() => {
          //   this.resetFunc?.();
          //   this.controller.close();
          // })

          Button('交卷', { type: ButtonType.Capsule, stateEffect: false })
            .linearGradient({
              direction: GradientDirection.Left, // 渐变方向
              repeating: false, // 渐变颜色是否重复
              colors: [[0xff05C7FF, 0], [0xff0082FF, 1]] // 数组末尾元素占比小于1时满足重复着色效果
            })
            .backgroundColor(Color.Transparent)
            .width(Utils.getVp(467))
            .height(Utils.getVp(84))
            .onClick(() => {
              this.commitFunc?.();
              this.controller.close();
            })

        }.width('100%').height(Utils.getVp(119)).alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)
      }

    }
    .backgroundColor(StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode))
    .borderRadius({ topLeft: 16, topRight: 16 })
    .padding({ bottom: AppUtil.getNavigationIndicatorHeight() })
    .height(380)
  }

  @Builder
  getItemBuilder(numberItem: ExamItem) {
    Row() {
      if (numberItem.my_log.user_answer) {
        // 已做
        Text(`${numberItem.main_number + 1}`)
          .fontColor($r('app.color.mainColor'))
          .fontSize(Utils.getVp(38))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width(Utils.getVp(78))
          .height(Utils.getVp(78))
          .borderRadius(Utils.getVp(39))
          .backgroundColor("#1f0080ff")
          .onClick(() => {
            this.clickNumFunc?.(numberItem);
            this.controller.close();
          })
      } else {
        // 未做
        Text(`${numberItem.main_number + 1}`)
          .fontColor($r('app.color.subTextColor'))
          .fontSize(Utils.getVp(38))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .width(Utils.getVp(78))
          .height(Utils.getVp(78))
          .borderRadius(Utils.getVp(39))
          .border({ width: Utils.getVp(1), color: '#ccbec2d1' })
          .onClick(() => {
            this.clickNumFunc?.(numberItem);
            this.controller.close();
          })
      }
      if (numberItem.my_log.is_flag == 1) {
        CustomIcon({
          iconType: CustomIconType.icon_mark_on,
          iconSize: 20,
          iconColor: '#FFFF0C00'
        })
          .position({
            right: -5,
            top: -8
          })
      }

    }.width(Utils.getVp(78))
    .height(Utils.getVp(78))
    .margin({ top: Utils.getVp(38) })

  }
}