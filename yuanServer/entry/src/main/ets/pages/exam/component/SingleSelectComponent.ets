import Utils from '../../../common/utils/Utils';
import ExamAnswerComponent from './ExamAnswerComponent';
import { QuesRichText } from './QuesRichText';
import { ExamItem, MyLogItem, OptionItem } from '../bean/ExamItem';
import { StyleColor, StyleRes } from '../utils/StyleRes';
import { CustomIcon, CustomIconType } from '../../../view/CustomIcon';
import { LogUtil } from '../../../common/utils/LogUtil';
import { NewExamQuickUtils } from '../utils/NewExamQuickType';


@Component
@Preview
export default struct SingleSelectComponent {
  parentSelectCallBack?: Function;
  materialSelectCallBack?: Function;
  @State userAnswer: string = ""; // 用户答案
  @State answer: string = ""; // 正确答案
  @ObjectLink @Watch("onUpdateExamItem") examItem: ExamItem;
  @State showAnswer: boolean = false;
  @Consume questionMakingMode: boolean;
  @Consume isDoPaper: boolean;
  @Consume makeTime: number;
  @Consume scaleTextStyle: number;
  @Consume lightMode: boolean;

  aboutToAppear() {

    // this.richName = this.examItem.name;

    if (this.examItem.type == 1) {
      this.examItem.options = [
        new OptionItem({
          key: "A",
          value: "对",
          name: "",
          select: "",
        }),
        new OptionItem({
          key: "B",
          value: "错",
          name: "",
          select: "",
        })
      ];
    }


    this.onUpdateExamItem()

  }

  onUpdateExamItem() {
    // LogUtil.info("onUpdateExamItem.answer_show:" + this.examItem.answer_show)
    this.answer = this.examItem.answer ?? '';
    if (this.examItem.my_log) {
      this.userAnswer = this.examItem.my_log.user_answer ?? '';
    }

    if (this.judegeShowAnswer()) {
      this.getUserAnswer()
      this.judegeIsRight()
      this.changeShowAnswer(true);
    } else {
      this.changeShowAnswer(false);
    }

  }

  judegeShowAnswer() {
    if (this.examItem.answer_show == 1) {
      return true;
    }
    // 背题模式且有答案也显示解析
    if (!this.questionMakingMode && this.userAnswer) {
      return true;
    }
    return false;
  }

  changeShowAnswer(value: boolean) {
    this.showAnswer = value;
    this.examItem.answer_show = value ? 1 : 0;
  }

  getUserAnswer() {

    if (this.examItem.my_log) {
      if (this.examItem.type == 1) {
        // 判断题
        let tmpUserAnswer = NewExamQuickUtils.replaceJudgeAnswerToCn(this.userAnswer);

        this.examItem.my_log.user_answer = tmpUserAnswer;
        this.userAnswer = tmpUserAnswer;

        LogUtil.info(`run getUserAnswer type==1 tmpUserAnswer:${tmpUserAnswer}`)
      } else {
        // 单选题
        this.examItem.my_log.user_answer = this.userAnswer;
      }
    }


  }

  judegeIsRight() {
    if (this.examItem.my_log) {
      let isRight = 0;
      let trueAnswer = this.examItem.answer;
      if (this.examItem.type == 1) {
        // 判断题
        trueAnswer = NewExamQuickUtils.replaceJudgeAnswerToCn(trueAnswer);
      }

      LogUtil.info("judegeIsRight:" + JSON.stringify({
        userAnswer: this.userAnswer,
        trueAnswer: trueAnswer
      }))

      if (this.userAnswer == trueAnswer) {
        isRight = 1;
      }

      this.examItem.my_log.is_right = isRight;
    }

  }

  build() {
    Column() {
      Text(`${this.examItem.type_name}`)
        .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))// .fontSize(Utils.getVp(31))
        .fontSize(15 * this.scaleTextStyle)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: Utils.getVp(38), top: Utils.getVp(38), bottom: Utils.getVp(21) })
      // 题干
      Column() {
        QuesRichText({
          richContent: this.examItem.name,
          fontSize: 18,
          fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
        })

      }
      .width('100%')
      .padding({ left: Utils.getVp(38), right: Utils.getVp(38) })
      .alignItems(HorizontalAlign.Start)

      Column() {
        ForEach(this.examItem.options, (item: OptionItem) => {
          SingleSelectOption({
            userAnswer: this.userAnswer,
            answer: this.answer,
            showAnswer: this.showAnswer,
            item: item,
            type: this.examItem.type,
            checkCallBack: (_: undefined) => {

              this.getUserAnswer()
              this.judegeIsRight()

              // NewExamQuickUtils.calcDoQuesTime(this.examItem)


              if (this.questionMakingMode) {
                // 练习模式跳转下一题
                if (this.materialSelectCallBack) {
                  this.materialSelectCallBack()
                } else if (this.parentSelectCallBack) {
                  this.parentSelectCallBack()
                }

                LogUtil.info("this.examItem.my_log.is_right:" + this.examItem.my_log.is_right)
              } else {
                // 背题模式显示答案
                this.changeShowAnswer(true)
              }

            }
          })
        })
      }
      .margin({ top: Utils.getVp(30) })
      .width('100%')

      if (this.showAnswer) {
        Column() {
          ExamAnswerComponent({ examItem: this.examItem })
        }
      }
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .padding({
      bottom: 4
    })
    // .height('100%')
  }
}

@Component
struct SingleSelectOption {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = 'md'
  @Link userAnswer: string;
  @Link answer: string;
  @Link showAnswer: boolean;
  @State item: OptionItem = new OptionItem({
    key: '',
    value: '',
    name: '',
    select: '',
  });
  type: number = 0;
  checkCallBack?: Function;
  @Consume lightMode: boolean;
  @State richValue: string = '';
  @Consume questionMakingMode: boolean;

  aboutToAppear(): void {


    this.richValue = this.item.value;
  }

  build() {
    if (this.showAnswer) {
      if (this.isRight()) {
        this.rightBuilder()
      } else {
        if (this.isSelect()) {
          this.errBuilder()
        } else {
          this.normalBuilder()
        }
      }
    } else {
      Row() {
        Text(`${this.item.key}`)
          .fontColor(this.isSelect() ? Color.White : $r('app.color.auxiliaryTextColor'))
          .fontSize(Utils.getVp(29))
          .width(Utils.getVp(42))
          .height(Utils.getVp(42))
          .textAlign(TextAlign.Center)
          .backgroundColor(this.isSelect() ? $r('app.color.mainColor') : Color.Transparent)
          .borderRadius(Utils.getVp(21))

        // 选项
        Column() {
          QuesRichText({
            // richTextOption: this.rich_value_option,
            richContent: this.richValue,
            fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
          })
        }
        .margin({ left: Utils.getVp(25) })
        .alignItems(HorizontalAlign.Start)

        // 遮罩层，为了兼容富文本组件点击事件不冒泡
        Column()
          .width('100%')
          .height('100%')
          .position({ x: Utils.getVp(-25), y: Utils.getVp(-36) })
          .zIndex(1)
          .onClick(() => {
            this.userAnswer = this.item.key;
            if (this.checkCallBack != null) {
              this.checkCallBack(this.item);
            }
          })
      }
      .width(
        335
      )
      // .height(Utils.getVp(106))
      .backgroundColor(this.isSelect() ? $r('app.color.ellipticalBackgroundColor') :
      $r('app.color.toBeActivatedTextColorPercentTen'))
      .borderRadius(Utils.getVp(24))
      .margin({ top: Utils.getVp(15), left: Utils.getVp(38), right: Utils.getVp(38) })
      .padding({
        top: Utils.getVp(36),
        bottom: Utils.getVp(36),
        left: Utils.getVp(25),
        right: Utils.getVp(50)
      })
      .onClick(() => {
        this.userAnswer = this.item.key;
        if (this.checkCallBack != null) {
          this.checkCallBack(this.item);
        }
      })
    }

  }

  @Builder
  normalBuilder() {
    Row() {
      Text(`${this.item.key}`)
        .fontColor($r('app.color.auxiliaryTextColor'))
        .fontSize(Utils.getVp(29))
        .width(Utils.getVp(42))
        .height(Utils.getVp(42))
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
        .borderRadius(Utils.getVp(21))

      // 选项
      Column() {
        QuesRichText({
          // richTextOption: this.rich_value_option,
          richContent: this.richValue,
          fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
        })
      }
      .margin({ left: Utils.getVp(25) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(335)
    .backgroundColor(this.isSelect() ? $r('app.color.ellipticalBackgroundColor') :
    $r('app.color.toBeActivatedTextColorPercentTen'))
    .borderRadius(Utils.getVp(24))
    .margin({ top: Utils.getVp(15), left: Utils.getVp(38), right: Utils.getVp(38) })
    .padding({
      top: Utils.getVp(36),
      bottom: Utils.getVp(36),
      left: Utils.getVp(25),
      right: Utils.getVp(50)
    })
  }

  @Builder
  rightBuilder() {
    Row() {
      CustomIcon({
        iconType: CustomIconType.ico_choose_on,
        iconSize: 21,
        iconColor: '#ff00C19A'
      })
      // 选项
      Column() {
        QuesRichText({
          // richTextOption: this.rich_value_option,
          richContent: this.richValue,
          fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
        })
      }
      .margin({ left: Utils.getVp(25) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(335)
    .backgroundColor("#338af4dc")
    .borderRadius(Utils.getVp(24))
    .margin({ top: Utils.getVp(15), left: Utils.getVp(38), right: Utils.getVp(38) })
    .padding({
      top: Utils.getVp(36),
      bottom: Utils.getVp(36),
      left: Utils.getVp(25),
      right: Utils.getVp(50)
    })
  }

  @Builder
  errBuilder() {
    Row() {

      CustomIcon({
        iconType: CustomIconType.icon_wrong,
        iconSize: 21,
        iconColor: '#ffFF3E3E'
      })

      // 选项
      Column() {
        QuesRichText({
          richContent: this.richValue,
          fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
        })
      }
      .margin({ left: Utils.getVp(25) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(335)
    .backgroundColor("#33ff3e3e")
    .borderRadius(Utils.getVp(24))
    .margin({ top: Utils.getVp(15), left: Utils.getVp(38), right: Utils.getVp(38) })
    .padding({
      top: Utils.getVp(36),
      bottom: Utils.getVp(36),
      left: Utils.getVp(25),
      right: Utils.getVp(50)
    })
  }

  /**
   * 判断对错
   * @returns
   */
  isRight() {
    if (this.type == 1) { //判断题
      if (this.item.value == this.answer) {
        return true;
      }
    } else {
      if (this.item.key == this.answer) {
        return true;
      }
    }

    return false;
  }

  /**
   * 判断是否选择
   * @returns
   */
  isSelect() {
    if (this.type == 1) { //判断题
      if (this.item.value == this.userAnswer) {
        return true;
      }
    } else {
      if (this.userAnswer == this.item.key) {
        return true;
      }
    }

    return false;
  }
}