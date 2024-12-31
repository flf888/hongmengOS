import Utils from '../../common/utils/Utils'
import router from '@ohos.router'
import { PageState } from '../../common/constants/Constants';
import LoadingLayout from '../../view/LoadingLayout';
import { ExamItem, ExplanCardItem } from './bean/ExamItem';
import { CustomIcon, CustomIconType } from '../../view/CustomIcon';
import { NewExamQuickType, NewExamQuickUtils } from './utils/NewExamQuickType';
import { PreviewType, QuickTestMainPageParams } from './types/QuickTest';
import { LogUtil } from '../../common/utils/LogUtil';
import ToastUtils from '../../common/utils/ToastUtils';
import TopNavBar from '../../view/TopNavBar';
import { AppUtil } from '../../common/utils/AppUtil';
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';


export interface ExamPaperDetailsResultPageParams {
  paper_id: number;
  paper_index: number
  subject_index: number
}

interface GoParseParams {
  type: PreviewType,
  numberItem?: ExamItem
}

export interface UserPaperResultInfo {
  paper_name: string
  right_percent: string
  commit_at: string
  user_score: number
  score: number
}

@Extend(Text)
function CardItemText() {
  .fontSize(20)
  .fontWeight(FontWeight.Medium)
  .textAlign(TextAlign.Center)
  .margin({ top: 20 })
  .width(40)
  .height(40)
  .borderRadius('50%')
}


/**
 * 试卷结果页-只有做试卷模式才会进入该页
 */
@Entry
@Component
struct ExamPaperDetailsResultPage {
  @State titleBg: boolean = false;
  @State pageState: number = PageState.Loading;
  routeParams: ExamPaperDetailsResultPageParams = {
    paper_id: 0,
    paper_index: 0,
    subject_index: 0
  }; //外部传递过来的参数
  @State userPaperInfo: UserPaperResultInfo = {
    paper_name: '',
    right_percent: '',
    commit_at: '',
    user_score: 0,
    score: 0,
  }
  @State testList: ExplanCardItem[] = [];
  @State jumpLock: boolean = false; // 是否在跳转页面

  aboutToAppear() {
    this.routeParams = router.getParams() as ExamPaperDetailsResultPageParams;

  }

  onPageShow(): void {
    this.getPaperResult();
  }

  /**
   * 获取考试结果
   */
  getPaperResult() {
    JsonDataUtils.paperResult(this.routeParams.paper_index, this.routeParams.subject_index).then((value => {
      if (value['code'] == 200) {
        this.userPaperInfo = value['data']['user_paper_info'];
        this.getExamScoreCard();
      } else {
        this.pageState = PageState.Fail;
      }

    })).then(() => {

    })
  }

  getExamScoreCard() {

    JsonDataUtils.paperQuestionList(this.routeParams.paper_index, this.routeParams.subject_index).then((value => {
      if (value['code'] == 200) {
        let examList = NewExamQuickUtils.toExamItemList(value['data']['data'] ?? [], true);
        const expList = NewExamQuickUtils.parseExpList(examList);
        const cardList = NewExamQuickUtils.parsePaperCard(expList);
        this.testList = cardList;

      }
      this.pageState = PageState.Success;
    })).then(() => {

    })
  }

  build() {
    if (this.pageState == PageState.Success) {
      Stack({ alignContent: Alignment.Top }) {
        Image(Utils.getImgPath('exam/exam_paper_details_result_page_bg.png')).width('100%').height(Utils.getVp(753))
        Flex({ direction: FlexDirection.Column }) {
          Scroll() {
            Column() {
              Text(this.userPaperInfo.paper_name)
                .fontColor(Color.White)
                .fontSize(Utils.getVp(31))
                .width('100%')
                .padding({ left: Utils.getVp(48) })
                .margin({ top: Utils.getVp(200) })

              Flex({ direction: FlexDirection.Row }) {
                Column() {
                  Row() {
                    Text('正确率:').fontColor(Color.White).fontSize(Utils.getVp(27)).width(Utils.getVp(130))
                    Text(this.userPaperInfo.right_percent)
                      .fontColor(Color.White)
                      .fontSize(Utils.getVp(27))
                  }.alignItems(VerticalAlign.Top).margin({
                    top: Utils.getVp(32)
                  })

                  Row() {
                    Text('交卷时间:').fontColor(Color.White).fontSize(Utils.getVp(27)).width(Utils.getVp(130))
                    Text(this.userPaperInfo.commit_at)
                      .fontColor(Color.White)
                      .fontSize(Utils.getVp(27))
                  }.alignItems(VerticalAlign.Top).margin({
                    top: Utils.getVp(32)
                  })

                }.flexGrow(1).alignItems(HorizontalAlign.Start).padding({
                  left: Utils.getVp(48),
                  right: Utils.getVp(60)
                }).width('100%')

                Stack({ alignContent: Alignment.Top }) {
                  Text().width(Utils.getVp(216))
                    .height(Utils.getVp(216))
                    .backgroundColor(Color.White)
                    .borderRadius(Utils.getVp(108))

                  Progress({
                    value: this.userPaperInfo.user_score,
                    total: this.userPaperInfo.score,
                    type: ProgressType.Ring
                  })
                    .width(Utils.getVp(216))
                    .height(Utils.getVp(216))
                    .color("#ff00ffd8")
                    .backgroundColor("#ff7BB7EE")
                    .style({ strokeWidth: Utils.getVp(19) })
                    .rotate({ angle: 0 })

                  Row() {
                    Text(this.userPaperInfo.user_score + '')
                      .fontColor($r('app.color.blodTextColor'))
                      .fontSize(Utils.getVp(65))
                  }.margin({ top: Utils.getVp(65) })

                  Text(`总分 ${this.userPaperInfo.score}`)
                    .fontColor($r('app.color.auxiliaryTextColor'))
                    .fontSize(Utils.getVp(23))
                    .margin({ top: Utils.getVp(136) })
                }
                .flexGrow(1)
                .width('100%')
              }.margin({
                top: Utils.getVp(75),
              })
              .width('100%')

              Column() {
                Column() {
                  Row() {
                    CustomIcon({
                      iconType: CustomIconType.icon_answer,
                      iconSize: 19,
                      iconColor: $r('app.color.blodTextColor')
                    })

                    Text("答题卡")
                      .fontColor($r('app.color.blodTextColor'))
                      .fontSize(Utils.getVp(31))
                      .fontWeight(FontWeight.Bold)
                      .margin({ left: Utils.getVp(12) })

                    Blank()

                    Text('')
                      .width(Utils.getVp(14))
                      .height(Utils.getVp(14))
                      .backgroundColor("#00C89F")
                      .borderRadius(Utils.getVp(7))
                    Text("答对")
                      .fontColor($r('app.color.auxiliaryTextColor'))
                      .fontSize(Utils.getVp(23))
                      .margin({ left: Utils.getVp(4) })

                    Text('')
                      .width(Utils.getVp(14))
                      .height(Utils.getVp(14))
                      .backgroundColor("#ffFF3E3E")
                      .borderRadius(Utils.getVp(7))
                      .margin({ left: Utils.getVp(30) })
                    Text("答错")
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

                  ForEach(this.testList,
                    (item: ExplanCardItem) => {
                      Column() {
                        Text(item.type_name)
                          .fontColor($r('app.color.subTextColor'))
                          .fontSize(Utils.getVp(27))
                          .width('100%')
                          .backgroundColor('#1abec2d1')
                          .height(Utils.getVp(58))
                          .padding({ left: Utils.getVp(38) })
                        GridRow({
                          columns: 5,
                          direction: GridRowDirection.Row
                        }) {
                          ForEach(item.list,
                            (numberItem: ExamItem) => {
                              GridCol() {
                                this.getItemBuilder(numberItem)
                              }
                            })
                        }.padding({ left: Utils.getVp(30), right: Utils.getVp(30), bottom: Utils.getVp(38) })
                      }
                    })

                }
                .backgroundColor(Color.White)
                .borderRadius(Utils.getVp(31))
                .margin({ top: Utils.getVp(19) })
                .shadow({ radius: 16, color: '#0f000000' })
              }.width('100%').padding({
                left: Utils.getVp(23),
                right: Utils.getVp(23),
                bottom: Utils.getVp(60)
              }).margin({
                top: Utils.getVp(80)
              })
            }
          }.onScroll((xOffset: number, yOffset: number) => {
            if (yOffset > 0) {
              this.titleBg = true;
            } else {
              this.titleBg = false;
            }
          })
          .flexShrink(1)
          .height("100%")
          .scrollBar(BarState.Off)

          this.bottomView()
        }

        this.titleView()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(0XFFF7F8FB)
    } else {
      LoadingLayout()
    }

  }

  getAnswerRight(numberItem: ExamItem) {
    //-1 未答，0：答对，1：答错。
    let answer = false;
    let isRight = false;
    if (numberItem.my_log.user_answer) {
      answer = true;
    }

    if (numberItem.my_log.is_right) {
      isRight = true;
    }
    let result = answer ? (isRight ? 0 : 1) : -1;

    return result;
  }

  @Builder
  getItemBuilder(numberItem: ExamItem) {
    if (numberItem.type == 4 && (numberItem.my_log.user_answer)) {
      // 主观题评分样式
      if (numberItem.grade == -1) {
        // 待评分
        Stack({ alignContent: Alignment.TopEnd }) {
          Text(`${numberItem.main_number + 1}`)
            .CardItemText()
            .margin({
              top: 0
            })
            .fontColor(Color.White)
            .backgroundColor("#FF80BFFF")
            .onClick(() => {
              // 查看解析
              this.goParse({
                type: 0,
                numberItem: numberItem
              })
            })

          Row() {
          }
          .width(8)
          .height(8)
          .backgroundColor('#FFF95045')
          .borderRadius(6)
          .margin({
            right: 4
          })
        }
        .width(40)
        .height(40)
        .margin({ top: 20 })

      } else {
        // 已评分
        Text(`${numberItem.main_number + 1}`)
          .CardItemText()
          .fontColor(Color.White)
          .backgroundColor("#FF80BFFF")
          .onClick(() => {
            // 查看解析
            this.goParse({
              type: 0,
              numberItem: numberItem
            })
          })
      }

    } else {
      if (this.getAnswerRight(numberItem) == -1) {
        Text(`${numberItem.main_number + 1}`)
          .CardItemText()
          .fontColor($r('app.color.subTextColor'))
          .border({ width: Utils.getVp(1), color: '#ccbec2d1' })
          .onClick(() => {
            // 查看解析
            this.goParse({
              type: 0,
              numberItem: numberItem
            })
          })

      } else if (this.getAnswerRight(numberItem) == 0) {
        Text(`${numberItem.main_number + 1}`)
          .CardItemText()
          .fontColor("#ff00C89F")
          .backgroundColor("#338af4dc")
          .onClick(() => {
            // 查看解析
            this.goParse({
              type: 0,
              numberItem: numberItem
            })
          })
      } else {
        Text(`${numberItem.main_number + 1}`)
          .CardItemText()
          .fontColor("#ffFF3E3E")
          .backgroundColor("#33fca497")
          .onClick(() => {
            // 查看解析
            this.goParse({
              type: 0,
              numberItem: numberItem
            })
          })
      }

    }


  }

  @Builder
  bottomView() {
    Column() {
      Row() {
        Row() {
          Row() {
            Text('全部解析')
              .textAlign(TextAlign.Center)
              .height(Utils.getVp(84))
              .width('100%')
              .fontColor(Color.White)
              .borderRadius(21)
              .linearGradient({
                direction: GradientDirection.Left, // 渐变方向
                repeating: false, // 渐变颜色是否重复
                colors: [[0XFF4D5C70, 0], [0XFF191B27, 1]] // 数组末尾元素占比小于1时满足重复着色效果
              })
              .onClick(() => {
                // 全部解析
                this.goParse({
                  type: 0,

                })
              })
          }
          .flexGrow(1)
          .height(60)
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .padding({
            top: Utils.getVp(17),
            bottom: Utils.getVp(17),
          })
        }
        .width(300)
        .height(60)

      }
      .width('100%')
      .height(60 + AppUtil.getNavigationIndicatorHeight())
      .backgroundColor(Color.White)
      .justifyContent(FlexAlign.Center)
      .padding({
        bottom: AppUtil.getNavigationIndicatorHeight()
      })
    }
  }

  goParse(params: GoParseParams) {
    if(this.jumpLock) {
      return;
    }
    this.jumpLock = true;
    let itemMap: QuickTestMainPageParams = {
      preview_type: params.type,
      req_type: NewExamQuickType.examTestErrorOrAnalysis,
      paper_id: this.routeParams.paper_id,
      paper_index: this.routeParams.paper_index
    };
    if (params.numberItem) {
      itemMap.number = params.numberItem.parent_number;
      itemMap.min_number = params.numberItem.son_number;
    } else {
      // 全部解析
      itemMap.number = 0;
      itemMap.min_number = 0;
    }

    LogUtil.info("goParse:" + JSON.stringify(itemMap))

    router.pushUrl({ url: "pages/exam/QuickTestMainPage", params: itemMap })
    setTimeout(() => {
      this.jumpLock = false;
    }, 200)
  }

  @Builder
  titleView() {
    TopNavBar({
      navTitle: '',
      bgColor: 'transparent'
    })
      .position({
        x: 0
      })
  }
}