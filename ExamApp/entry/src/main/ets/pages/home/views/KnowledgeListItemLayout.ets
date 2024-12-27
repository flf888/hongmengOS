import Utils from '../../../common/utils/Utils';
import router from '@ohos.router';
import { KnowledgeItem } from "../HomeContentPage"
import { QuickTestMainPageParams } from '../../exam/types/QuickTest';
import { NewExamQuickType } from '../../exam/utils/NewExamQuickType';
import ToastUtils from '../../../common/utils/ToastUtils';
import { ExamStorageUtils } from '../../exam/utils/ExamStorageUtils';


@Component
@Preview
export default struct KnowledgeListItemLayout {
  @State uiWidth: string = '';
  @State uiHeight: string = '';
  @State knowledgeInfo: KnowledgeItem = {
    id: 0,
    name: '',
    my_log_count: 0,
    questions_count: 0,
    _index: 0
  };
  @Prop @Require subject_index: number = 0;
  level: number = 0;
  isLast: boolean = false;

  build() {
    Column() {
      this.firstKnowLedge();
    }
  }

  @Builder
  firstKnowLedge() {
    Stack() {
      Row() {
        Column() {
          Image(Utils.getImgPath('home/first_know_not_more.png'))
            .width(Utils.getVp(30))
            .height(Utils.getVp(30))
            .objectFit(ImageFit.Cover)

          Divider()
            .width(Utils.getVp(1))
            .color($r('app.color.toBeActivatedTextColor'))

        }
        .width(Utils.getVp(104))
        .margin({ top: Utils.getVp(27) })
        .onClick(() => {
          this.expandAction();
        })

        Column() {
          Text(this.knowledgeInfo.name)
            .fontSize(15)
            .fontWeight(700)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontColor($r('app.color.blodTextColor'))
            .margin({ top: Utils.getVp(31) })

          Row() {
            Stack() {
              Text()
                .width(Utils.getVp(81 * (this.knowledgeInfo.my_log_count) / (this.knowledgeInfo.questions_count)))
                .height(Utils.getVp(12))
                .borderRadius(Utils.getVp(6))
                .backgroundColor($r('app.color.mainColor'))
            }
            .width(Utils.getVp(81))
            .height(Utils.getVp(12))
            .borderRadius(Utils.getVp(6))
            .backgroundColor($r('app.color.shallowTwoMainColor'))
            .align(Alignment.Start)

            Row() {
              Text(`${this.knowledgeInfo.my_log_count}`)
                .fontSize(Utils.getVp(23))
                .fontColor($r('app.color.mainColor'))
                .margin({ left: Utils.getVp(8) })
              Text(`/${this.knowledgeInfo.questions_count}道`)
                .fontSize(Utils.getVp(23))
                .fontColor($r('app.color.auxiliaryTextColor'))
                .margin({ right: Utils.getVp(31) })

            }

          }
          .margin({ top: Utils.getVp(21) })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

        }
        .alignItems(HorizontalAlign.Start)
        .width(Utils.getVp(480))
        .onClick(() => {
          this.goDetail(this.knowledgeInfo);
        })

        Column() {
          Image(Utils.getImgPath('home/arrow_right_01.png'))
            .width(Utils.getVp(32))
            .height(Utils.getVp(32))
            .objectFit(ImageFit.Cover)
        }
        .width(Utils.getVp(75))
        .height(Utils.getVp(30))
      }
      .constraintSize({
        minHeight: this.uiHeight
      })
      .padding({ bottom: Utils.getVp(25) })
    }
    .constraintSize({
      minHeight: this.uiHeight
    })
    .width(this.uiWidth)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .onClick(() => {
      this.goDetail(this.knowledgeInfo);
    });

    // this.childKnowledge();

  }

  //展开收起
  expandAction() {
    this.goDetail(this.knowledgeInfo);
  }

  //跳转详情页面
  goDetail(subCities: KnowledgeItem) {
    // if (subCities.my_log_count >= subCities.questions_count) {
    //   ToastUtils.showToast("该知识点没有题目可以练习了")
    //   return;
    // }

    let itemMap: QuickTestMainPageParams = {
      "req_type": NewExamQuickType.newExamKnowledge,
      "new_exam_type": 'know_test',
      "knowledge_id": subCities.id,
      "knowledge_index": subCities._index,
      "subject_index": this.subject_index
    };

    ExamStorageUtils.restartKnowTest(itemMap.knowledge_id ?? 0, itemMap.knowledge_index ?? 0,
      itemMap.subject_index ?? 0)

    router.pushUrl({
      url: "pages/exam/QuickTestMainPage", params: itemMap
    });

  }
}