import router from '@ohos.router'
import Utils from '../../common/utils/Utils'
import LoadingLayout from '../../view/LoadingLayout';
import { ExamSettingDialog } from './dialog/ExamSettingDialog';
import { PreferencesUtil } from '../../common/utils/PreferencesUtil';
import { BreakPointType } from '../../common/utils/breakpointsystem';
import { ExamItem } from './bean/ExamItem';
import { CustomIcon, CustomIconType } from '../../view/CustomIcon';
import { StyleColor, StyleImage, StyleRes } from './utils/StyleRes';
import { StyleFit } from './utils/StyleFit';
import { MiddlePageParams, GoParseParams, QuickTestMainPageParams, NewExamType } from './types/QuickTest';
import { NewExamQuickType, NewExamQuickUtils } from './utils/NewExamQuickType';
import { LogUtil } from '../../common/utils/LogUtil';
import TopNavBar from '../../view/TopNavBar';
import { NavigationIndicator } from '../../view/NavigationIndicator';
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';
import { Color } from '../../library/myrich/common/types';
import { ExamStorageUtils } from './utils/ExamStorageUtils';


@Entry
@Component
struct ExamMiddleResultPage {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = 'md'
  examSettingDialogController?: CustomDialogController; //设置弹窗
  private allData: Record<string, string | number> = {};
  @State hasNext: number = 0;
  @Provide questionMakingMode: boolean = true;
  @Provide scaleTextStyle: number = 1;
  @Provide lightMode: boolean = true; //true 日间模式 false 夜间模式
  @State isLoading: boolean = true;
  @State expList: ExamItem[] = [];
  @State commitAt: string = '';
  @State typeDesc: string = '';
  @State rightPercent: string = '';
  @State total: number = 0;
  @State rightNum: number = 0;
  @Provide routeParams: QuickTestMainPageParams = {
    req_type: NewExamQuickType.examIntelligenceQuick,

  };
  @State isDoPaper: boolean = false; //true 代表做试卷
  @State jumpLock: boolean = false; // 是否在跳转页面

  aboutToAppear() {

    this.questionMakingMode = StyleFit.getQuestionMakingMode();
    this.lightMode = StyleFit.getLightMode();
    this.scaleTextStyle = StyleFit.getScaleTextStyle();

    let params = router.getParams() as MiddlePageParams;
    this.routeParams = params.routeParams;

    this.isDoPaper = NewExamQuickUtils.isDoPaper(this.routeParams.req_type);

    this.initData();
    console.log("run aboutToAppear ExamMiddleResultPage")
    PreferencesUtil.putSync("isRefresh", "1")

  }

  aboutToDisappear() {
  }

  initData() {
    // { 'group_id': this.routeParams.group_id ?? 0 }
    JsonDataUtils.groupResult(this.routeParams.subject_index ?? 0, this.routeParams.knowledge_index ?? 0,
      this.routeParams.new_exam_type ?? "smart_test").then((value) => {
      if (value['code'] == 200) {
        const examList = NewExamQuickUtils.toExamItemList(value['data']['question'], this.isDoPaper);
        // const examList: ExamItem[] = value['data']['question'];
        const expList = NewExamQuickUtils.parseExpList(examList);
        this.expList = expList;
        LogUtil.info("this.expList:" + JSON.stringify(this.expList))

        this.hasNext = value['data']['has_next']
        this.total = value['data']['total']
        this.rightNum = value['data']['right_num']
        this.rightPercent = value['data']['right_percent']
        this.commitAt = value['data']['commit_at']
        this.typeDesc = value['data']['type_desc']

      }
      this.isLoading = false;
    });
  }

  build() {

    if (this.isLoading) {
      LoadingLayout();
    } else {
      Column() {
        TopNavBar({
          navTitle: ''
        })

        Row() {
          Text(this.typeDesc)
            .fontColor($r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(27))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .constraintSize({ maxWidth: Utils.getVp(500) })// 使用具体的宽度值
            .flexShrink(1) // 允许文本收缩

          Text(this.commitAt)
            .fontColor($r('app.color.auxiliaryTextColor'))
            .fontSize(Utils.getVp(27))
            .margin({ left: Utils.getVp(16) })
            .flexShrink(0) // 防止时间被压缩
        }
        .width('100%')
        .height(Utils.getVp(67))
        .backgroundColor($r('app.color.toBeActivatedTextColorPercentTen'))
        .padding({ left: Utils.getVp(38), right: Utils.getVp(25) })
        .justifyContent(FlexAlign.SpaceBetween)

        Scroll() {
          Column() {
            Column() {
              Text(`练习结果`).fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
                .fontSize(Utils.getVp(35))
                .fontWeight(FontWeight.Bold)
                .margin({ top: Utils.getVp(50) })

              Stack({ alignContent: Alignment.Top }) {

                Progress({ value: 100, total: 200, type: ProgressType.Ring })
                  .width(Utils.getVp(280))
                  .height(Utils.getVp(280))
                  .color("#ffe7eaf0")
                  .backgroundColor(Color.Transparent)
                  .style({ strokeWidth: 15 })
                  .rotate({ angle: 270 })

                Progress({ value: 100 * this.rightNum / this.total, total: 200, type: ProgressType.Ring })
                  .width(Utils.getVp(280))
                  .height(Utils.getVp(280))
                  .color("#ff26E7C6")
                  .backgroundColor(Color.Transparent)
                  .style({ strokeWidth: 15 })
                  .rotate({ angle: 270 })

                Image(StyleRes.getStyleImage(StyleImage.examMiddleTopBg, this.lightMode))
                  .width(Utils.getVp(186))
                  .height(Utils.getVp(73))
                  .objectFit(ImageFit.Cover)
                  .margin({ top: Utils.getVp(20), right: Utils.getVp(400) })

                Column() {
                  Text(this.rightPercent)
                    .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
                    .fontSize(Utils.getVp(21))
                  Text(`正确率`)
                    .fontColor($r('app.color.auxiliaryTextColor'))
                    .fontSize(Utils.getVp(21))
                    .margin({ top: Utils.getVp(5) })
                }.margin({ top: Utils.getVp(30), right: Utils.getVp(455) })

                Text(``)
                  .width(Utils.getVp(280))
                  .height(Utils.getVp(120))
                  .backgroundColor(StyleRes.getStyleColor(StyleColor.pageColor, this.lightMode))
                  .margin({ top: Utils.getVp(160) })
                  .textAlign(TextAlign.Center)

                Row() {
                  Text(`${this.rightNum}`)
                    .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
                    .fontSize(Utils.getVp(65))

                  Text('/' + this.total)
                    .fontColor($r('app.color.auxiliaryTextColor'))
                    .fontSize(Utils.getVp(35))
                    .margin({ top: Utils.getVp(8), left: Utils.getVp(10) })
                }.margin({ top: Utils.getVp(60) })

                Text(`答对`)
                  .fontColor($r('app.color.auxiliaryTextColor'))
                  .fontSize(Utils.getVp(23))
                  .margin({ top: Utils.getVp(140) })

              }
              // .width('100%')
              .height(Utils.getVp(280))
              .margin({ top: Utils.getVp(40) }) // 设置strokeWidth进度条宽度为15.0vp
            }

            Column() {
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

                  Blank()

                  Text('')
                    .width(Utils.getVp(14))
                    .height(Utils.getVp(14))
                    .backgroundColor(0XFF00C89F)
                    .borderRadius(Utils.getVp(7))
                  Text("答对")
                    .fontColor($r('app.color.auxiliaryTextColor'))
                    .fontSize(Utils.getVp(23))
                    .margin({ left: Utils.getVp(4) })

                  Text('')
                    .width(Utils.getVp(14))
                    .height(Utils.getVp(14))
                    .borderRadius(Utils.getVp(7))
                    .margin({ left: Utils.getVp(30) })
                    .backgroundColor(0XFFFF3E3E)
                  Text("答错")
                    .fontColor($r('app.color.auxiliaryTextColor'))
                    .fontSize(Utils.getVp(23))
                    .margin({ left: Utils.getVp(4) })

                  Text('')
                    .width(Utils.getVp(14))
                    .height(Utils.getVp(14))
                    .borderRadius(Utils.getVp(7))
                    .margin({ left: Utils.getVp(30) })
                    .border({ width: Utils.getVp(3), color: '#66bec2d1' })
                  Text("未答")
                    .fontColor($r('app.color.auxiliaryTextColor'))
                    .fontSize(Utils.getVp(23))
                    .margin({ left: Utils.getVp(4) })
                }
                .width('100%')
                .height(Utils.getVp(96))
                .padding({ left: Utils.getVp(42), right: Utils.getVp(38) })

                GridRow({
                  columns: 5,
                  direction: GridRowDirection.Row
                }) {
                  ForEach(this.expList, (numberItem: ExamItem) => {
                    GridCol() {
                      this.getItemBuilder(numberItem)
                    }
                  })
                }.padding({ left: Utils.getVp(30), right: Utils.getVp(30), bottom: Utils.getVp(38) })
              }
              .width(Utils.getVp(674))
              .backgroundColor(StyleRes.getStyleColor(StyleColor.cardBgColor, this.lightMode))
              .borderRadius(Utils.getVp(31))
              .shadow({ radius: 16, color: '#0f000000' })

              Row() {
                Row() {
                  CustomIcon({
                    iconType: CustomIconType.ico_restart,
                    iconSize: 19,
                    iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
                  })

                  Text('再练一次')
                    .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
                    .fontSize(Utils.getVp(27))
                    .fontWeight(600)
                    .margin({
                      left: Utils.getVp(15)
                    })
                }
                .width(Utils.getVp(321))
                .height(Utils.getVp(115))
                .backgroundColor(StyleRes.getStyleColor(StyleColor.cardBgColor, this.lightMode))
                .borderRadius(Utils.getVp(31))
                .justifyContent(FlexAlign.Center)
                .shadow({
                  radius: 23,
                  color: '#14000000',
                  offsetX: 0,
                  offsetY: 4
                })
                .onClick(() => {
                  this.practiceAgain()
                })

                Row() {

                  CustomIcon({
                    iconType: CustomIconType.icon_advice,
                    iconSize: 19,
                    iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
                  })

                  Text('详细练习报告')
                    .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
                    .fontSize(Utils.getVp(27))
                    .fontWeight(600)
                    .margin({
                      left: Utils.getVp(15)
                    })
                }
                .width(Utils.getVp(321))
                .height(Utils.getVp(115))
                .backgroundColor(StyleRes.getStyleColor(StyleColor.cardBgColor, this.lightMode))
                .borderRadius(Utils.getVp(31))
                .justifyContent(FlexAlign.Center)
                .shadow({
                  radius: 23,
                  color: '#14000000',
                  offsetX: 0,
                  offsetY: 4
                })
                .onClick(() => {
                  router.pushUrl({
                    url: "pages/exam/ExamDetailsResultPage",
                    params: {
                      // requestExamData: this.dataMap,
                      // groupId: this.groupId,
                      // requestType: this.requestType,
                      routeParams: this.routeParams
                    }
                  })
                })

              }.width(Utils.getVp(750)).margin({
                top: Utils.getVp(32)
              }).padding({
                left: Utils.getVp(24),
                right: Utils.getVp(24)
              })
              .justifyContent(FlexAlign.SpaceEvenly)
            }

          }
          .width('100%')
        }
        .height(new BreakPointType({
          sm: '',
          md: '',
          lg: Utils.getVp(700)

        }).getValue(this.currentBreakpoint))
        .flexGrow(1)

        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center
        }) {
          Column() {
            if (this.hasNext) {
              CustomIcon({
                iconType: CustomIconType.icon_next,
                iconSize: 19,
                iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
              })
              Text('下一组')
                .fontColor(StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode))
                .fontSize(Utils.getVp(21))
                .margin({
                  top: Utils.getVp(8)
                })
            }
          }
          .height(44)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width(this.hasNext ? 80 : 0)
          .onClick(() => {
            if (this.hasNext) {
              this.nextAction();
            } else {
              LogUtil.info("进入总结页面")
            }
          })

          Flex({ direction: FlexDirection.Row, justifyContent: this.hasNext ? FlexAlign.End : FlexAlign.Center }) {
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
                  NewExamQuickUtils.goParse({
                    check_error: 1
                  }, this.routeParams)
                })
            }
            .width(200)
            .height(44)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .padding({
              top: Utils.getVp(17),
              bottom: Utils.getVp(17),
            })
          }
          .width(this.hasNext ? 252 : '100%') // 126 * 2
          .height(44)
        }
        .width('100%')
        .height(62)
        .backgroundColor(StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode))

        NavigationIndicator({
          bgColor: StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode)
        })
      }
      .width('100%')
      .backgroundColor(StyleRes.getStyleColor(StyleColor.pageColor, this.lightMode))
      .constraintSize({
        minHeight: '100%'
      })

    }
  }

  @Builder
  getItemBuilder(numberItem: ExamItem) {
    Row() {
      if (numberItem.user_answer) { //已答
        Text(`${numberItem.main_number + 1}`)
          .fontColor(numberItem.is_right == 1 ? 0XFF00C89F : 0XFFFF3E3E)
          .fontSize(Utils.getVp(38))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .margin({ top: Utils.getVp(38) })
          .width(Utils.getVp(78))
          .height(Utils.getVp(78))
          .borderRadius(Utils.getVp(39))
          .backgroundColor(numberItem.is_right == 1 ? "#338AF4DC" : "#33FCA497")
      } else { //未答
        Text(`${numberItem.main_number + 1}`)
          .fontColor($r('app.color.subTextColor'))
          .fontSize(Utils.getVp(38))
          .fontWeight(FontWeight.Medium)
          .textAlign(TextAlign.Center)
          .margin({ top: Utils.getVp(38) })
          .width(Utils.getVp(78))
          .height(Utils.getVp(78))
          .borderRadius(Utils.getVp(39))
          .border({ width: Utils.getVp(1), color: '#ccbec2d1' })
      }
    }.onClick(() => {
      if(this.jumpLock) {
        return;
      }
      this.jumpLock = true;
      LogUtil.info(`MiddlePage numberItem ${numberItem.parent_number} ${numberItem.son_number}`)
      NewExamQuickUtils.goParse({
        check_error: 1,
        number: numberItem.parent_number,
        min_number: numberItem.son_number,
      }, this.routeParams)
      setTimeout(() => {
        this.jumpLock = false;
      }, 200)
    })

  }

  ///下一组
  nextAction() {
    let itemMap: QuickTestMainPageParams = {
      "req_type": this.routeParams.req_type,
      'new_exam_type': this.routeParams.new_exam_type,
      'is_next': 1,
    };
    NewExamQuickUtils.goNewQuickTestMainPage(itemMap, this.routeParams, true);
  }

  ///再练一次
  practiceAgain() {

    let itemMap: QuickTestMainPageParams = {
      "req_type": this.routeParams.req_type,
      'new_exam_type': this.routeParams.new_exam_type,
    };

    if (this.routeParams.new_exam_type == "smart_test") {
      ExamStorageUtils.smartTestAgain()
    } else if (this.routeParams.new_exam_type == "know_test") {
      ExamStorageUtils.knowTestAgain(
        this.routeParams.knowledge_id ?? 0,
        this.routeParams.subject_index ?? 0,
        this.routeParams.knowledge_index ?? 0
      )
    }


    NewExamQuickUtils.goNewQuickTestMainPage(itemMap, this.routeParams, true);
  }

  /**
   * 底部题目选项卡
   */
  openExamSettingDialog() {
    if (this.examSettingDialogController == undefined) {
      this.examSettingDialogController = new CustomDialogController({
        builder: ExamSettingDialog({
          isParse: NewExamQuickUtils.isParse(this.routeParams.req_type, this.routeParams.check_error)
        }),
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: 0 },
        // gridCount: 4,
        customStyle: true
      })
    }
    this.examSettingDialogController.open()
  }
}