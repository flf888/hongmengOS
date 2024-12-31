import router from '@ohos.router'
import { PageState } from '../../common/constants/Constants';
import Utils from '../../common/utils/Utils'
import LoadingLayout from '../../view/LoadingLayout';
import ToastUtils from '../../common/utils/ToastUtils';
import { QuickTestMainPageParams } from './types/QuickTest';
import { NewExamQuickType } from './utils/NewExamQuickType';
import TopNavBar from '../../view/TopNavBar';
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';
import { ExamStorageUtils } from './utils/ExamStorageUtils';


interface questionTypeItem {
  type_name: string
  question_count: number
  score_sum: number
}

export  interface PaperInfo {
  name: string // 试卷名称
  time: number // 限时
  score: number // 满分
  last_progress: number
  question_count: number
  status: 0 | 1 | 2 // 0开始考试 1继续考试 2重新考试
  // user_paper_id: number
  paper_id: number
  question_type_data: questionTypeItem[]
  make_time: number
}

interface ExaminationPaperDetailPageParams {
  paper_id: number
  // plan_day_id?: number
  paper_index: number
  subject_index: number
}

@Entry
@Component
struct ExaminationPaperDetailPage {
  // @State pageState: number = PageState.Loading;
  @State dataInfo: PaperInfo = {
    name: '',
    time: 0,
    score: 0,
    question_type_data: [],
    last_progress: 0,
    question_count: 0,
    status: 0,
    // user_paper_id: 0,
    paper_id: 0,
    make_time: 0,
  };
  @State paper_id: number = 0;
  @State paper_index: number = 0;
  @State subject_index: number = 0;
  // @State plan_day_id: number = 0;

  aboutToAppear() {
    let params = router.getParams() as ExaminationPaperDetailPageParams;
    this.paper_id = params.paper_id;
    // this.plan_day_id = params.plan_day_id ?? 0;
    this.paper_index = params.paper_index;
    this.subject_index = params.subject_index;
    this.getExaminationPaperDetail();
  }

  /**
   * 获取试卷详情
   */
  getExaminationPaperDetail() {
    this.dataInfo = JsonDataUtils.paperIntro(this.paper_index, this.subject_index);
  }

  build() {
    Column() {
      // 头部
      TopNavBar();

      Stack({ alignContent: Alignment.TopStart }) {
        Image(Utils.getImgPath('exam/exam_detail_bg.png'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Text(`${this.dataInfo.name}`)
          .fontColor($r('app.color.blodTextColor'))
          .fontSize(22)
          .width(285)
          .lineHeight(30)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 54, top: 45 })

        Column() {
          Row() {
            Text("考试标准")
              .fontColor($r('app.color.auxiliaryTextColor'))
              .fontSize(Utils.getVp(27))
              .width(Utils.getVp(120))
              .textAlign(TextAlign.Start)
            Text(`限时${this.dataInfo.time as number / 60}分钟，满分${this.dataInfo.score}分`)
              .fontColor($r('app.color.blodTextColor'))
              .fontSize(Utils.getVp(27))
              .margin({ left: Utils.getVp(31) })
          }

          Row() {
            // 左边
            Column() {
              Text("题       型")
                .textAlign(TextAlign.Start)
                .fontColor($r('app.color.auxiliaryTextColor'))
                .fontSize(Utils.getVp(27))
                .width(Utils.getVp(120))
            }
            .height(170)

            // 右边
            Scroll() {
              Column() {
                ForEach(this.dataInfo.question_type_data,
                  (item: questionTypeItem, index) => {
                    Row() {
                      Text(`${item.type_name}`)
                        .fontColor($r('app.color.blodTextColor'))
                        .fontSize(Utils.getVp(27))
                        .margin({ left: Utils.getVp(31) })
                        .width(70)
                        .textAlign(TextAlign.Start)
                      Text(`${item.question_count}道`)
                        .fontColor($r('app.color.blodTextColor'))
                        .fontSize(Utils.getVp(27))
                        .textAlign(TextAlign.Start)
                        .margin({ left: Utils.getVp(31) })
                        .width(40)
                      Text(`${item.score_sum}分`)
                        .fontColor($r('app.color.blodTextColor'))
                        .fontSize(Utils.getVp(27))
                        .margin({ left: Utils.getVp(31) })
                    }.margin({ bottom: Utils.getVp(30) })
                  })
              }
            }
            .scrollBar(BarState.Off)
            // scroll对齐位置
            .align(Alignment.Top)
            .height(170)
          }
          .margin({ top: 16 })
        }
        .margin({ left: Utils.getVp(111), top: Utils.getVp(271), right: Utils.getVp(69) })
        .alignItems(HorizontalAlign.Start)

        Button('开始考试', { type: ButtonType.Capsule, stateEffect: false })
          .linearGradient({
            direction: GradientDirection.Left, // 渐变方向
            repeating: false, // 渐变颜色是否重复
            colors: [["#4D5C70", 0], ["#191B27", 1]] // 数组末尾元素占比小于1时满足重复着色效果
          })
          .fontColor("#FFE0C3")
          .fontSize(Utils.getVp(29))
          .backgroundColor(Color.Transparent)
          .width(273)
          .height(45)
          .margin({ top: 513, left: 51 })
          .onClick(() => {

            this.clickStartBtn()
          })


      }
      .width(375)
      .height(591)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.pageBg'))
  }

  @Builder
  RightBarBuilder() {
    Stack({ alignContent: Alignment.End }) {
      Row() {
        Text('考试记录')
          .fontColor('#465069')
          .fontSize(14)
          .margin({ right: 8 })
          .onClick(() => {
            ToastUtils.showToast('前往考试记录')
          })
      }
      .width(80)
      .height('100%')
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('100%')
  }

  startExam() {
    // 开始考试
    const params: QuickTestMainPageParams = {
      req_type: NewExamQuickType.examDoPaper,
      paper_id: this.paper_id,
      paper_index: this.paper_index,
      subject_index: this.subject_index
    }

    ExamStorageUtils.restartPaper(this.paper_id)

    router.replaceUrl({
      url: 'pages/exam/QuickTestMainPage',
      params: params
    })
  }

  clickStartBtn() {
    this.startExam()
  }
}