import Utils from '../../../common/utils/Utils';
import { ExamItem } from '../bean/ExamItem';
import { StyleColor, StyleRes } from '../utils/StyleRes';
import { QuesRichText } from './QuesRichText';

@Component
@Preview
export default struct ExamAnswerComponent {
  @Consume lightMode: boolean;
  @Consume scaleTextStyle: number;
  @ObjectLink examItem: ExamItem;
  @State isRight: number = 0;
  @State userAnswerList: Record<string, string>[] = [];

  aboutToAppear() {
    if (this.examItem.my_log) {
      this.isRight = this.examItem.my_log.is_right ?? 1;
    }

    let userAnswer: string = `${this.examItem.my_log.user_answer ?? ''}`;
    let answer: string = `${this.examItem.answer ?? ''}`;
    if (userAnswer) {
      if (this.examItem.type == 3) { //多选题
        let tmpList: string[] = userAnswer.split(',');
        for (let index = 0; index < tmpList.length; index++) {
          let tmpString = tmpList[index];
          if (answer.indexOf(tmpString) > -1) {
            this.userAnswerList.push({ 'userAnswer': `${tmpString}`, 'color': '#ff09C69E' })
          } else {
            this.userAnswerList.push({ 'userAnswer': `${tmpString}`, 'color': '#ffFF0C00' })
          }
        }

      } else {
        if (answer.indexOf(userAnswer) > -1) {
          this.userAnswerList.push({
            'userAnswer': `${this.examItem.my_log.user_answer}`,
            'color': '#ff09C69E'
          })

        } else {
          this.userAnswerList.push({
            'userAnswer': `${this.examItem.my_log.user_answer}`,
            'color': '#ffFF0C00'
          })

        }
      }
    } else {
      this.userAnswerList.push({ 'userAnswer': `未作答`, 'color': '#ffFF0C00' })
    }


  }

  build() {
    Column() {
      Column() {
        Row() {
          Column() {
            Text(`${this.examItem.answer ?? ''}`)
              .fontColor("#ff09C69E")
              .fontSize(16 * this.scaleTextStyle)

            Text("正确答案")
              .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
              .fontSize(14 * this.scaleTextStyle)
              .margin({ top: Utils.getVp(21) })
          }.width(Utils.getVp(321))
          .height(Utils.getVp(171))
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)

          Divider()
            .color("#E7EAF0")
            .width(Utils.getVp(1))
            .height(Utils.getVp(72))
            .vertical(true)
            .strokeWidth(Utils.getVp(1))

          Stack({ alignContent: Alignment.TopStart }) {
            Column() {
              Text() {
                ForEach(this.userAnswerList, (item: Record<string, string>, index) => {
                  Span(`${item['userAnswer']}`).fontColor(`${item['color']}`).fontSize(16 * this.scaleTextStyle)
                })
              }


              Text("我的答案")
                .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
                .fontSize(14 * this.scaleTextStyle)
                .margin({ top: Utils.getVp(21) })
            }.width(Utils.getVp(321))
            .height(Utils.getVp(171))
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)

          }.width(Utils.getVp(321))
          .height(Utils.getVp(171))

        }.width(Utils.getVp(643))
        .height(Utils.getVp(171))
      }
      .width(335)
      .backgroundColor(StyleRes.getStyleColor(StyleColor.cardBgColor, this.lightMode))
      .borderRadius(Utils.getVp(23))
      .margin({ top: Utils.getVp(40), bottom: 2 })
      .shadow({ radius: 16, color: '#0f000000' })

      if (this.examItem.analysis) {
        Text("解析")
          .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
          .fontSize(16 * this.scaleTextStyle)
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
    }
    .width('100%')
  }
}