import Utils from '../../../common/utils/Utils';
import { ExamItem } from '../bean/ExamItem';
import { CustomIcon, CustomIconType } from '../../../view/CustomIcon';
import { StyleColor, StyleRes } from '../utils/StyleRes';
import { QuesRichText } from './QuesRichText';
import { QuickTestMainPageParams } from '../types/QuickTest';
import { MyButton } from '../../../view/MyButton';

@Extend(Column)
function AnswerCard(lightMode: boolean) {
  .backgroundColor(StyleRes.getStyleColor(StyleColor.cardBgColor, lightMode))
  .borderRadius(16)
  .shadow({ radius: 16, color: '#0f000000' })
  .width(331)
  .padding({
    bottom: 21,
    left: 18,
    right: 18
  })
  .margin({
    top: 20
  })
}

@Extend(Row)
function AnswerCardTop() {
  .height(44) // 16 + 18 + 10 = 44
  .justifyContent(FlexAlign.SpaceBetween)
  .width('100%')
}

@Component
@Preview
export default struct ExamSubjectAnswerComponent {
  // openEditImageDialog?: () => void
  @Consume lightMode: boolean;
  @Consume routeParams: QuickTestMainPageParams;
  @Consume isDoPaper: boolean;
  @Consume isParse: boolean;
  @Consume scaleTextStyle: number;
  @ObjectLink examItem: ExamItem;
  @State knowList: Record<string, string>[] = [];
  @State isExpandedAnswer: boolean = true;
  @State isExpandedUserAnswer: boolean = true;
  @State sliderScore: number = 0; // 滑动评分的值

  aboutToAppear() {
    // 默认分数选择最大值
    this.sliderScore = this.examItem.score;
  }

  build() {
    Column() {

      Column() {
        Row() {
          Row() {
            Text("参考答案")
              .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
              .fontSize(16 * this.scaleTextStyle)
              .fontWeight(FontWeight.Bold)

            CustomIcon({
              iconType: this.isExpandedAnswer ? CustomIconType.ico_arrow_up : CustomIconType.ico_arrow_down,
              iconSize: 21,
              iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
            })
              .margin({
                left: 15
              })
          }

        }
        .AnswerCardTop()
        .onClick(() => {
          this.isExpandedAnswer = !this.isExpandedAnswer
        })

        if (this.isExpandedAnswer) {
          // 参考答案
          Column() {
            QuesRichText({
              richContent: this.examItem.answer,
              fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode)
            })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

      }
      .AnswerCard(this.lightMode)

      Column() {
        Row() {
          Row() {
            Text("我的答案")
              .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
              .fontSize(16 * this.scaleTextStyle)
              .fontWeight(FontWeight.Bold)

            CustomIcon({
              iconType: this.isExpandedUserAnswer ? CustomIconType.ico_arrow_up : CustomIconType.ico_arrow_down,
              iconSize: 21,
              iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
            })
              .margin({
                left: 15
              })
          }


          Row() {
            if (this.isDoPaper && this.isParse) {
              if (this.examItem.grade == -1) {
                Text('待评分')
                  .fontSize(12 * this.scaleTextStyle)
                  .fontColor($r("app.color.mainColor"))
              } else {
                Text() {
                  Span('评分：')
                    .fontSize(12 * this.scaleTextStyle)
                    .fontColor($r("app.color.mainColor"))

                  Span(this.examItem.grade + '')
                    .fontSize(12 * this.scaleTextStyle)
                    .fontColor($r("app.color.mainColor"))

                }

              }
            }


          }
        }
        .AnswerCardTop()
        .onClick(() => {
          this.isExpandedUserAnswer = !this.isExpandedUserAnswer
        })

        if (this.isExpandedUserAnswer) {
          // 我的答案
          Column() {
            QuesRichText({
              richContent: this.examItem.my_log.user_answer,
              fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode)
            })

          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          if (this.isDoPaper && this.isParse && this.examItem.grade == -1) {
            // 评分
            Column() {
              Row() {
                Text('评分：')
                  .fontSize($r('app.float.textBase'))
                  .fontColor($r('app.color.subTextColor'))
                Text(`(总分值：${this.examItem.score})`)
                  .fontSize($r('app.float.textBase'))
                  .fontColor($r('app.color.auxiliaryTextColor'))
              }
              .width('100%')
              .margin({
                bottom: 15
              })

              Row() {
                Row() {
                  Slider({
                    value: this.sliderScore,
                    step: 0.5,
                    style: SliderStyle.OutSet,
                    max: this.examItem.score
                  })
                    .blockColor('#FF0080FF')
                    .trackColor('#1ABEC2D1')
                    .selectedColor('#FF05C7FF')
                    .showTips(true, this.sliderScore + '')
                    .onChange((value) => {
                      this.sliderScore = value;
                    })

                }
                .width(218)
                .height(8)


                MyButton({
                  btnText: '提交'
                })
                  .margin({
                    left: 26
                  })
                  .onClick(() => {
                  })

              }
              .width('100%')
            }
            .width('100%')
            .margin({
              top: 22
            })
          }

        }

      }
      .AnswerCard(this.lightMode)

      if (this.examItem.analysis) {
        Text("解析")
          .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding({ left: Utils.getVp(44) })
          .margin({ top: Utils.getVp(50) })
        // 解析
        Column() {
          QuesRichText({
            richContent: this.examItem.analysis,
            fontSize: 14,
            fontColor: StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode)
          })
        }
        .width('100%')
        .padding({ left: Utils.getVp(44), right: Utils.getVp(44) })
        .margin({ top: Utils.getVp(30) })
        .alignItems(HorizontalAlign.Start)
      }

      if (this.knowList.length > 0) {
        Column() {
          Divider()
            .color("#F7F8FB")
            .width('100%')
            .height(Utils.getVp(15))
            .vertical(false)
            .strokeWidth(Utils.getVp(15))

          Text("知识点")
            .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .padding({ left: Utils.getVp(44) })
            .margin({ top: Utils.getVp(50) })

          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            ForEach(this.knowList, (item: Record<string, string>) => {
              Text(item['name'])
                .fontSize(13)
                .fontColor($r('app.color.mainColor'))
                .backgroundColor($r('app.color.shallowTwoMainColor'))
                .padding({
                  left: Utils.getVp(23),
                  right: Utils.getVp(23),
                  top: Utils.getVp(12),
                  bottom: Utils.getVp(12)
                })
                .margin({ left: Utils.getVp(23), top: Utils.getVp(23) })
                .borderRadius(Utils.getVp(8))
            })
          }.margin({ left: Utils.getVp(21), right: Utils.getVp(44) })

        }.margin({ top: Utils.getVp(40) }).padding({ bottom: Utils.getVp(30) })
      }
    }
    .padding({
      bottom: 20
    })
  }
}