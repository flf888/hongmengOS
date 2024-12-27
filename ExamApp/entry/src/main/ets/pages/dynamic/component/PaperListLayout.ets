import Utils from "../../../common/utils/Utils"
import router from '@ohos.router';
import { PaperItem } from "../../home/HomeContentPage";



@Component
  // 试卷模块
export struct PaperListLayout {
  @Prop paper_list: PaperItem[] = []; // 试卷列表
  @Prop need_scroll: boolean = true; // 是否需要滚动
  @Prop subject_index: number = 0;

  build() {
    Column() {
      this.relativeTitle()
      if(this.need_scroll) {
        Scroll() {
          Column() {
            this.paperListBuilder()
          }
          .width('100%')
        }
        .flexShrink(1)
        .width('100%')
        .scrollBar(BarState.Off)
        .align(Alignment.TopStart)
      } else {
        Column() {
          this.paperListBuilder()
        }
        .width('100%')
      }
    }
    .flexShrink(1)
    .width('100%')
  }
  @Builder
  relativeTitle() {
    Column() {
      Row()
        .height(Utils.getVp(15))
        .width('100%')
        .backgroundColor($r('app.color.pageBg'))
        .margin({ top: Utils.getVp(20) })
      Text('模拟试卷')
        .fontColor($r('app.color.blodTextColor'))
        .fontSize(Utils.getVp(29))
        .fontWeight(FontWeight.Bold)
        .margin({ top: Utils.getVp(31), bottom: Utils.getVp(20), left: Utils.getVp(31) })

    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  paperListBuilder() {
    Column() {
      ForEach(this.paper_list, (item: PaperItem, index) => {
        Column() {
          Row() {
            // 左
            Row() {
              Column() {
                Text(item.name)
                  .fontColor('#191B27')
                  .fontSize(15)
                  .textAlign(TextAlign.Start)
                  .width('100%')
                  .margin({ bottom: 12 })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
            }
            .width(235)
            .margin({
              left: 16,
              top: 16,
              bottom: 11
            })

            // 右
            Row() {
              Text('开始考试')
                .fontColor('#0080FF')
                .fontSize(12)
                .textAlign(TextAlign.Center)
                .backgroundColor('#E0F0FF')
                .width(64)
                .height(28)
                .borderRadius(14)
            }
            .margin({ right: 9, })
          }
          .width(343)
          .constraintSize({
            minHeight: 80
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .clip(true)
          .borderRadius(16)
          .onClick(() => {
            router.pushUrl({
              url: "pages/exam/ExaminationPaperDetailPage",
              params: {
                paper_id: item.id,
                paper_index: item._index,
                subject_index: this.subject_index
              }
            });
          })
        }
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 12 })
        .shadow({ radius: 16, color: '#0f000000' })
      })
    }
    .margin({ bottom: Utils.getVp(180) })
  }
}