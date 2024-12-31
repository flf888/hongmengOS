import Utils from '../../../common/utils/Utils';
import { SubjectDialog } from '../dialog/SubjectDialog';
import ExamSubjectAnswerComponent from './ExamSubjectAnswerComponent';

import { QuesRichText } from './QuesRichText';
import { ExamItem, MyLogItem } from '../bean/ExamItem';
import { StyleColor, StyleRes } from '../utils/StyleRes';
import { LogUtil } from '../../../common/utils/LogUtil';
import { NewExamQuickUtils } from '../utils/NewExamQuickType';


@Component
@Preview
export default struct SubjectComponent {
  @Consume lightMode: boolean;
  @Consume scaleTextStyle: number;
  @ObjectLink @Watch("onUpdateExamItem") examItem: ExamItem;
  parentSelectCallBack?: Function;
  materialSelectCallBack?: Function;
  @State userAnswer: string = ''
  @State showAnswer: boolean = false;
  subjectDialogController?: CustomDialogController; //主观题
  editImageDialogController?: CustomDialogController; // 编辑图片弹窗
  @Consume questionMakingMode: boolean; //是否做题模式
  @Consume isDoPaper: boolean;
  @Consume makeTime: number;
  @State richName: string = "";
  @State uploadImgUri: string = "";

  aboutToAppear() {

    this.richName = this.examItem.name;

    this.getUserAnswer();

    this.onUpdateExamItem()
  }

  onUpdateExamItem() {
    if (this.judegeShowAnswer()) {
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
      this.userAnswer = this.examItem.my_log.user_answer ?? '';
    }
  }

  setUserAnswer() {
    let isRight = 1; //主观题全部当作正确
    if (this.examItem.my_log) {
      this.examItem.my_log.user_answer = this.userAnswer;
      this.examItem.my_log.is_right = isRight;
      LogUtil.info("setUserAnswer:" + JSON.stringify(this.examItem.my_log))
    }

  }

  build() {
    Column() {
      Text(`${this.examItem.type_name}`)
        .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
        .fontSize(15 * this.scaleTextStyle)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ top: Utils.getVp(38), bottom: Utils.getVp(21) })

      // 题干
      Column() {
        QuesRichText({
          richContent: this.richName,
          fontSize: 18,
          fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
        })
      }
      .width('100%').alignItems(HorizontalAlign.Start)

      Column() {

        if (!this.showAnswer) {
          Column() {
            Text(this.userAnswer ? this.userAnswer : '请输入答案')
              .fontColor(this.userAnswer ? StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode) :
              StyleRes.getStyleColor(StyleColor.toBeActivatedTextColor, this.lightMode))
              .padding({
                left: 18,
                top: 18,
                right: 18,
                bottom: 50
              })
              .width('100%')
              .onClick(() => {
                this.showSubjectDialog();
              })

            // Column() {
            //   if (this.uploadImgUri) {
            //     Image(this.uploadImgUri)
            //       .width(100)
            //       .margin({
            //         left: 17,
            //         bottom: 4
            //       })
            //       .onClick(() => {
            //         this.openEditImageDialog()
            //       })
            //   } else {
            //     Image(Utils.getImgPath('exam/upload_img_icon.png'))
            //       .width(20)
            //       .height(20)
            //       .margin({
            //         left: 17,
            //         bottom: 4
            //       })
            //       .onClick(() => {
            //       })
            //   }
            //   Image(Utils.getImgPath('exam/subject_quest_tip.png'))
            //     .width(335)
            //     .height(45)
            //
            // }
            // .width(335)
            // .alignItems(HorizontalAlign.Start)

          }
          .backgroundColor('#1abec2d1')
          .borderRadius(16)
          .width(335)
          .constraintSize({ minHeight: 203 }) // 158 + 45 = 203
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.SpaceBetween)

        }


        if (!this.showAnswer) {
          Button('提交答案', { type: ButtonType.Capsule, stateEffect: false })
            .linearGradient({
              direction: GradientDirection.Left, // 渐变方向
              repeating: false, // 渐变颜色是否重复
              colors: (this.userAnswer || this.uploadImgUri) ? [[0xff05C7FF, 0], [0xff0082FF, 1]] :
                [[$r('app.color.auxiliaryTextColor'), 0],
                  [$r('app.color.auxiliaryTextColor'), 1]] // 数组末尾元素占比小于1时满足重复着色效果
            })
            .backgroundColor(Color.Transparent)
            .width(Utils.getVp(305))
            .height(Utils.getVp(84))
            .margin({ top: Utils.getVp(64) })
            .onClick(() => {
              if (!this.userAnswer && !this.uploadImgUri) {
                return;
              }
              this.submitAnswer()

              if (this.questionMakingMode) {
                if (this.materialSelectCallBack) {
                  this.materialSelectCallBack()
                } else if (this.parentSelectCallBack) {
                  this.parentSelectCallBack()
                }
              } else {
                this.changeShowAnswer(true)
              }

            })
        }

        if (this.showAnswer) {
          Column() {
            ExamSubjectAnswerComponent({
              examItem: this.examItem,
            })
          }
        }
      }.margin({ top: Utils.getVp(30) })
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: Utils.getVp(38), right: Utils.getVp(38), bottom: 4
    })

  }

  submitAnswer() {

    this.setUserAnswer()

    // NewExamQuickUtils.calcDoQuesTime(this.examItem)

  }

  // openEditImageDialog(isCanEdit: boolean = true) {
  //   if (!this.editImageDialogController) {
  //     this.editImageDialogController = new CustomDialogController({
  //       builder: EditImageDialog({
  //         imgUri: this.uploadImgUri,
  //         isCanEdit: isCanEdit,
  //         onChangeImageUri: (imgUri) => {
  //           this.uploadImgUri = imgUri;
  //
  //           this.submitAnswer();
  //         }
  //       }),
  //       customStyle: true,
  //       maskColor: 'rgba(0, 0, 0, 0.6)',
  //       autoCancel: true
  //     })
  //   }
  //   this.editImageDialogController.open()
  // }

  // 输入答案弹窗
  showSubjectDialog() {
    if (this.subjectDialogController == undefined) {
      this.subjectDialogController = new CustomDialogController({
        builder: SubjectDialog({
          commitFunc: (inputAnswer: string) => {
            this.userAnswer = inputAnswer;
            this.submitAnswer();
          },
          defaultText: this.userAnswer
        }),
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: 0 },
        customStyle: true
      })
    }
    this.subjectDialogController.open()
  }
}