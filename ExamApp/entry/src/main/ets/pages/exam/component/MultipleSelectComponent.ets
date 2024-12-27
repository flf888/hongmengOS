import Utils from '../../../common/utils/Utils';
import ExamAnswerComponent from './ExamAnswerComponent';
import { QuesRichText } from './QuesRichText';
import { ExamItem, MyLogItem, OptionItem } from '../bean/ExamItem';
import { CustomIcon, CustomIconType } from '../../../view/CustomIcon';
import { StyleColor, StyleRes } from '../utils/StyleRes';
import { NewExamQuickUtils } from '../utils/NewExamQuickType';

@Component
@Preview
export default struct MultipleSelectComponent {
  @Consume lightMode: boolean;
  @ObjectLink @Watch("onUpdateExamItem") examItem: ExamItem;
  @State checkOptionList: OptionItem[] = [];
  parentSelectCallBack?: Function;
  materialSelectCallBack?: Function;
  @State showAnswer: boolean = false;
  @State answer: string = ""; // 正确答案
  @State userAnswer: string = "";
  @Consume questionMakingMode: boolean;
  @Consume isDoPaper: boolean;
  @Consume makeTime: number;

  aboutToAppear() {

    this.answer = this.examItem.answer ?? '';

    this.getUserAnswer()

    this.onUpdateExamItem()

  }

  onUpdateExamItem() {
    if (this.judegeShowAnswer()) {
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
    if (this.examItem.my_log) { //初始化用户选中答案

      let userAnswer: string = '';
      if (this.examItem.my_log.user_answer) {
        userAnswer = this.examItem.my_log.user_answer;
      }

      this.checkOptionList = [];
      if (userAnswer) {
        let optionList = this.examItem.options;
        for (let i = 0; i < optionList.length; i++) {
          let optionItem = optionList[i];
          if (userAnswer.includes(optionItem.key)) {
            this.checkOptionList.push(optionItem);
          }
        }
      }

      this.userAnswer = userAnswer;
    }
  }

  judegeIsRight() {
    let answer = this.getCheckOptions();
    let isRight = 0;
    let trueAnswer = `${this.examItem.answer}`;
    if (this.testAnswer(trueAnswer, answer)) {
      isRight = 1;
    }

    if (this.examItem.my_log) {
      console.log("run answer", answer)
      this.examItem.my_log.user_answer = answer;
      this.examItem.my_log.is_right = isRight;
    }
  }

  testAnswer(answer: string, user_answer: string) {
    let arr = user_answer.split(',');
    let len = answer.length;
    let count = 0;
    for (const item of arr) {
      if (answer.indexOf(item) != -1) {
        count++;
      }
    }
    return (count == len) && (arr.length == len);
  }

  build() {
    Column() {
      Text(`${this.examItem.type_name}`)
        .fontColor($r('app.color.blodTextColor'))
        .fontSize(Utils.getVp(31))
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: Utils.getVp(38), top: Utils.getVp(38), bottom: Utils.getVp(21) })
        .onClick(() => {
          let optionList = this.examItem.options;
          for (let i = 0; i < optionList.length; i++) {
            let item = optionList[i];
            console.log("数组的值：" + item.name);
            console.log("数组的值：" + item.select);
          }
        })

      // 题干
      Column() {
        QuesRichText({
          // richTextOption: this.rich_name_option,
          richContent: this.examItem.name,
          fontSize: 18,
          fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
        })
      }
      .width('100%').padding({ left: Utils.getVp(38), right: Utils.getVp(38) }).alignItems(HorizontalAlign.Start)

      Column() {
        ForEach(this.examItem.options, (item: OptionItem) => {
          MultipleSelectOption({
            checkOptionList: this.checkOptionList,
            answer: this.answer,
            userAnswer: this.userAnswer,
            showAnswer: this.showAnswer,
            item: item,
            checkCallBack: () => {
              this.judegeIsRight()


            }
          })
        })

        if (!this.showAnswer) {
          Button('提交答案', { type: ButtonType.Capsule, stateEffect: false })
            .linearGradient({
              direction: GradientDirection.Left, // 渐变方向
              repeating: false, // 渐变颜色是否重复
              colors: this.checkOptionList.length > 0 ? [[0xff05C7FF, 0], [0xff0082FF, 1]] :
                [[$r('app.color.auxiliaryTextColor'), 0],
                  [$r('app.color.auxiliaryTextColor'), 1]] // 数组末尾元素占比小于1时满足重复着色效果
            })
            .backgroundColor(Color.Transparent)
            .width(Utils.getVp(305))
            .height(Utils.getVp(84))
            .margin({ top: Utils.getVp(64) })
            .onClick(() => {
              // NewExamQuickUtils.calcDoQuesTime(this.examItem)

              if (this.questionMakingMode) {
                if (this.materialSelectCallBack) {
                  this.materialSelectCallBack()
                } else if (this.parentSelectCallBack) {
                  this.parentSelectCallBack()
                }

              } else {
                if (this.examItem.my_log && this.examItem.my_log.user_answer) {
                  this.userAnswer = this.examItem.my_log.user_answer;
                }
                this.changeShowAnswer(true)
              }
            })
        }

      }
      .margin({ top: Utils.getVp(30) })
      .width('100%')

      if (this.showAnswer) {
        Column() {
          ExamAnswerComponent({ examItem: this.examItem })
        }
      }
    }
    .padding({
      bottom: 4
    })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)

    // .height('100%')
  }

  /**
   * 获取当前答案选项的合并项目
   * @returns
   */
  getCheckOptions() {
    let checkOptionString = '';
    for (let index = 0; index < this.checkOptionList.length; index++) {
      let checkOptionItem = this.checkOptionList[index];
      if (index == 0) {
        checkOptionString = checkOptionItem.key;
      } else {
        checkOptionString = `${checkOptionString},${checkOptionItem.key}`;
      }
    }

    return checkOptionString;
  }
}

@Component
struct MultipleSelectOption {
  @Link checkOptionList: OptionItem[];
  @Link answer: string;
  @Link userAnswer: string;
  @Link showAnswer: boolean;
  @State item: OptionItem = new OptionItem({
    key: '',
    value: '',
    name: '',
    select: ''
  });
  checkCallBack?: Function;
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
        if (this.isSelectAnswer()) {
          this.errBuilder()
        } else {
          this.normalBuilder()
        }
      }
    } else {
      Row() {
        Text(this.item.key)
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
            richContent: this.richValue,
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
            if (this.isSelect()) {
              this.checkOptionList = this.checkOptionList.filter(item => item.key != this.item.key);
            } else {
              this.checkOptionList.push(this.item);
            }
            this.checkCallBack?.();
          })
      }
      .width(335)
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
        if (this.isSelect()) {
          this.checkOptionList = this.checkOptionList.filter(item => item.key != this.item.key);
        } else {
          this.checkOptionList.push(this.item);
        }
        this.checkCallBack?.();
      })
    }
  }

  @Builder
  normalBuilder() {
    Row() {
      Text(this.item.key)
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
          richContent: this.richValue,
        })
      }
      .margin({ left: Utils.getVp(25) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(Utils.getVp(644))
    // .height(Utils.getVp(106))
    .backgroundColor($r('app.color.toBeActivatedTextColorPercentTen'))
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
      Stack({ alignContent: Alignment.Top }) {
        CustomIcon({
          iconType: CustomIconType.ico_choose_on,
          iconSize: 21,
          iconColor: '#ff00C19A'
        })

        if (this.isShowLouXuan() && !this.isSelectAnswer()) {
          Image(Utils.getImgPath('exam/exam_multi_no.png'))
            .width(Utils.getVp(58))
            .height(Utils.getVp(36))
            .margin({ top: Utils.getVp(-28), right: Utils.getVp(8) })
        }
      }.width(Utils.getVp(42))
      .height(Utils.getVp(42))

      // 选项
      Column() {

        QuesRichText({
          richContent: this.richValue,
        })
      }
      .margin({ left: Utils.getVp(25) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(Utils.getVp(644))
    // .height(Utils.getVp(106))
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
        })
      }
      .margin({ left: Utils.getVp(25) })
      .alignItems(HorizontalAlign.Start)
    }
    .width(Utils.getVp(644))
    // .height(Utils.getVp(106))
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
    if (this.answer.indexOf(this.item.key) > -1) {
      return true;
    }
    return false;
  }

  isShowLouXuan() {
    // 当前选择的答案有正确答案时才有漏选

    const answerArr = this.answer.split("");
    const userAnswerArr = this.userAnswer.split("");

    console.log('run isShowLouXuan', this.answer, this.userAnswer)

    if (Utils.arraysIntersect(answerArr, userAnswerArr)) {
      return true;
    } else {
      return false;
    }

  }

  isSelectAnswer() {
    if (this.userAnswer.indexOf(this.item.key) > -1) {
      return true;
    }
    return false;
  }

  isSelect() {
    if (this.checkOptionList.some(item => item.key === this.item.key)) {
      return true;
    }
    return false;
  }
}