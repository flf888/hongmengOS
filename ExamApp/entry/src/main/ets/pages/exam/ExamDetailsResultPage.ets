import Utils from '../../common/utils/Utils'
import router from '@ohos.router'
import { PageState } from '../../common/constants/Constants';
import ToastUtils from '../../common/utils/ToastUtils';
import LoadingLayout from '../../view/LoadingLayout';
import FailLayout from '../../view/FailLayout';
import { ExamItem, ExplanCardItem } from './bean/ExamItem';
import { GoParseParams, MiddlePageParams, NewExamType, QuickTestMainPageParams } from './types/QuickTest';
import { NewExamQuickType, NewExamQuickUtils } from './utils/NewExamQuickType';
import { AppUtil } from '../../common/utils/AppUtil';
import { CustomIcon, CustomIconType } from '../../view/CustomIcon';
import TopNavBar from '../../view/TopNavBar';
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';


@Entry
@Component
struct ExamDetailsResultPage {
  @State allData: Record<string, string | number> = {};
  @State cardList: ExplanCardItem[] = [];
  @State titleBg: boolean = false;
  @State pageState: PageState = PageState.Loading;
  @State routeParams: QuickTestMainPageParams = {
    req_type: NewExamQuickType.examIntelligenceQuick,
  };
  @State isDoPaper: boolean = false; //true 代表做试卷

  aboutToAppear(): void {
    let params = router.getParams() as MiddlePageParams;
    this.routeParams = params.routeParams;
    this.isDoPaper = NewExamQuickUtils.isDoPaper(this.routeParams.req_type);

    this.initData();
  }

  initData() {
    // { 'group_id': this.routeParams.group_id ?? "" }
    JsonDataUtils.groupResult(this.routeParams.subject_index ?? 0, this.routeParams.knowledge_index ?? 0,
      this.routeParams.new_exam_type ?? "smart_test").then(res => {
      if (res['code'] == 200) {
        this.pageState = PageState.Success;
        this.allData = res['data'];
        const examList = NewExamQuickUtils.toExamItemList(res['data']['question'], this.isDoPaper);
        const expList = NewExamQuickUtils.parseExpList(examList);
        this.cardList = NewExamQuickUtils.parseExamCard(expList);
      } else {
        this.pageState = PageState.Fail;
        ToastUtils.showToast(res['message'] ?? "请求失败");
      }
    }).catch((err: Error) => {
      this.pageState = PageState.Fail;
      ToastUtils.showToast("请求失败");
    })
  }

  build() {
    if (this.pageState == PageState.Loading) {
      LoadingLayout();
    } else if (this.pageState == PageState.Fail) {
      FailLayout({
        reloadFunc: () => {
          this.pageState = PageState.Loading
          this.initData();
        }
      });
    } else {
      Stack({ alignContent: Alignment.Top }) {
        Image(Utils.getImgPath('exam/exam_details_result_page_bg.png')).width('100%').height(Utils.getVp(753))
        Scroll() {
          Column() {
            Flex({ direction: FlexDirection.Row }) {
              Column() {
                Row() {
                  Text('练习类型:').fontColor(Color.White).fontSize(Utils.getVp(27)).width(Utils.getVp(130))
                  Text(this.allData['type_desc'] as string).fontColor(Color.White).fontSize(Utils.getVp(27))
                }

                Row() {
                  Text('交卷时间:').fontColor(Color.White).fontSize(Utils.getVp(27)).width(Utils.getVp(130))
                  Text(this.allData['commit_at'] as string).fontColor(Color.White).fontSize(Utils.getVp(27))
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
                  value: this.allData['right_num'] as number,
                  total: this.allData['total'] as number,
                  type: ProgressType.Ring
                })
                  .width(Utils.getVp(216))
                  .height(Utils.getVp(216))
                  .color(0xff00ffd8)
                  .backgroundColor(0XD94759f6)
                  .style({ strokeWidth: Utils.getVp(19) })
                  .rotate({ angle: 0 })

                Row() {
                  Text(this.allData['right_num'] + '')
                    .fontColor($r('app.color.blodTextColor'))
                    .fontSize(Utils.getVp(65))

                  Text('/' + this.allData['total'])
                    .fontColor($r('app.color.auxiliaryTextColor'))
                    .fontSize(Utils.getVp(35))
                    .margin({ top: Utils.getVp(8), left: Utils.getVp(10) })
                }.margin({ top: Utils.getVp(65) })

                Text(`答对`)
                  .fontColor($r('app.color.auxiliaryTextColor'))
                  .fontSize(Utils.getVp(23))
                  .margin({ top: Utils.getVp(132) })
              }
              .flexGrow(1)
              .width('100%')
            }.margin({
              top: 90 + AppUtil.getStatusBarHeight(),
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
                }.width('100%').height(Utils.getVp(96)).padding({ left: Utils.getVp(42), right: Utils.getVp(38) })


                ForEach(this.cardList, (item: ExplanCardItem) => {
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
                      ForEach(item.list, (numberItem: ExamItem) => {
                        GridCol() {
                          this.getItemBuilder(numberItem)
                        }
                      })
                    }.padding({ left: Utils.getVp(30), right: Utils.getVp(30), bottom: Utils.getVp(38) })
                  }
                })
              }.backgroundColor(Color.White).borderRadius(Utils.getVp(31))
            }.width('100%').padding({
              left: Utils.getVp(23),
              right: Utils.getVp(23),
            }).margin({
              top: Utils.getVp(80)
            })
          }
        }.onScroll((xOffset: number, yOffset: number) => {
          console.log("===>" + xOffset + ',,,, ' + yOffset)
          if (yOffset > 0) {
            this.titleBg = true;
          } else {
            this.titleBg = false;
          }
        })

        this.titleView()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(0XFFF7F8FB)
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
      NewExamQuickUtils.goParse({
        number: numberItem.parent_number,
        min_number: numberItem.son_number,
        check_error: 1
      }, this.routeParams);
    })

  }

  @Builder
  titleView() {
    TopNavBar({
      navTitle: '练习报告',
      bgColor: 'transparent'
    })
      .position({
        x: 0,
      })
      .zIndex(1000)
  }
}