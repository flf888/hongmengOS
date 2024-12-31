import { ClickUtil } from '../../../common/utils/ClickUtil';
import { EmitterUtil } from '../../../common/utils/EmitterUtil';
import { LogUtil } from '../../../common/utils/LogUtil';
import { CustomIcon, CustomIconType, CustomIconType2 } from '../../../view/CustomIcon';
import { ExamItem } from '../bean/ExamItem';
import { StyleColor, StyleRes } from '../utils/StyleRes';
import MultipleSelectComponent from './MultipleSelectComponent';
import { QuesRichText } from './QuesRichText';
import SingleSelectComponent from './SingleSelectComponent';
import SubjectComponent from './SubjectComponent';


@Component
@Preview
export default struct MiddleComponent {
  index: number = 0;
  parentSelectCallBack?: Function;
  @Consume lightMode: boolean;
  @Consume examList: ExamItem[]; //数据源
  private materialSwiperController: SwiperController = new SwiperController();
  @ObjectLink curExamItem: ExamItem;
  lastCurrentOffset: number = 0;
  curSwiperDirection: "left" | "right" | "" = "";

  getMaterialStartNum() {
    const mainNumber = this.examList[this.index].material_ques?.[0].main_number ?? 0
    return mainNumber + 1
  }

  getMaterialEndNum() {
    const materalLen = this.examList[this.index]._materialCount ?? 1;
    const mainNumber = this.examList[this.index].material_ques?.[materalLen - 1].main_number ?? 0
    return mainNumber + 1
  }

  build() {
    Column() {
      if (this.examList[this.index].is_materials) {
        // 材料题
        if (this.examList[this.index].material_ques) {
          Scroll() {
            Column() {

              Row() {
                CustomIcon({
                  iconType2: CustomIconType2.ico_material_t,
                  iconSize: 16,
                  iconColor: '#FF5E677E'
                })
                  .margin({
                    right: 6
                  })
                Text('材料')
                  .fontSize($r("app.float.textBase"))
                  .lineHeight($r("app.float.textBase"))
                  .fontColor('#5E677E')
                  .margin({
                    right: 4
                  })
                // Text(`（回答${this.getMaterialStartNum()}~${this.getMaterialEndNum()}题）`)
                //   .fontSize($r("app.float.textBase"))
                //   .lineHeight($r("app.float.textBase"))
                //   .fontColor('#999FB5')
              }
              .width('100%')
              .alignItems(VerticalAlign.Bottom)
              .padding({
                left: 20,
                top: 17,
                bottom: 11
              })

              QuesRichText({
                richContent: this.examList[this.index].materials.content,
                fontColor: StyleRes.getStyleColor(StyleColor.textNormalColor, this.lightMode),
              })
                .padding({
                  left: 23,
                  right: 23
                })

              // 子材料题tab切换
              Scroll() {
                Row() {
                  ForEach(this.examList[this.index].material_ques, (citem: ExamItem, cindex) => {
                    Row() {
                      Text(citem.main_number + 1 + '')
                        .fontColor(this.curExamItem.materialChildIndex == cindex ? '#FF0080FF' :
                        StyleRes.getStyleColor(StyleColor.materailTabColor, this.lightMode))
                        .fontSize(12)
                    }
                    .width(58)
                    .height(28)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(VerticalAlign.Center)
                    .borderRadius(100)
                    .backgroundColor(this.curExamItem.materialChildIndex == cindex ?
                    StyleRes.getStyleColor(StyleColor.materailTabActiveBgColor, this.lightMode) :
                    StyleRes.getStyleColor(StyleColor.materailTabBgColor, this.lightMode)
                    )
                    .margin({
                      right: 12
                    })
                    .onClick(() => {
                      this.changeMaterIndex(cindex)
                    })
                  })
                }
                .padding({
                  top: 30,
                  left: 20,
                  right: 20
                })
                .constraintSize({
                  minWidth: '100%'
                })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)


              Swiper(this.materialSwiperController) {
                ForEach(this.examList[this.index].material_ques, (citem: ExamItem, cindex) => {
                  MiddleBaseComponent({
                    examItem: citem,
                    materialSelectCallBack: () => {
                      LogUtil.info(`materialSelectCallBack: ${this.curExamItem.materialChildIndex} ${this.curExamItem._materialCount}`)
                      if (this.curExamItem.materialChildIndex < this.curExamItem._materialCount - 1) {
                        this.materialSwiperController.showNext()
                      } else {
                        // LogUtil.info("父级切换")
                        this.parentSelectCallBack?.()
                      }

                    }
                  })
                })
              }
              .cachedCount(2)
              .index(this.curExamItem.materialChildIndex)
              .autoPlay(false)
              .indicator(false)
              .loop(false)
              .duration(100)
              .itemSpace(0)
              .curve(Curve.Linear)
              .onChange((index: number) => {
                this.changeMaterIndex(index)

                this.lastCurrentOffset = 0;
                this.curSwiperDirection = "";
              })
              .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
                if (this.lastCurrentOffset != 0) {
                  // 判断是左滑动还是右滑动
                  if (extraInfo.currentOffset < this.lastCurrentOffset) {
                    // 右滑动
                    this.curSwiperDirection = "right";
                  } else if (extraInfo.currentOffset > this.lastCurrentOffset) {
                    // 左滑动
                    this.curSwiperDirection = "left";
                  }
                  this.lastCurrentOffset = extraInfo.currentOffset;
                } else {
                  // 第一次记录
                  this.lastCurrentOffset = extraInfo.currentOffset;
                }

              })
              .onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
                // LogUtil.info(`onAnimationStart index:${index}, targetIndex:${targetIndex}, extraInfo:${JSON.stringify(extraInfo)}`)
                const tempNum = this.examList[this.index]._materialCount - 1;
                if (this.curSwiperDirection == "right" && index == targetIndex && index == tempNum) {
                  // 最后一个元素向右滑动
                  ClickUtil.throttle(() => {
                    EmitterUtil.post("parentShowNext")
                  })
                } else if (this.curSwiperDirection == "left" && index == targetIndex && index == 0) {
                  // 第一个元素向左滑动
                  ClickUtil.throttle(() => {
                    EmitterUtil.post("parentShowPrevious")
                  })
                }
              })
            }
            .padding({
              bottom: 100
            })
          }
          .scrollBar(BarState.Off)

        }
      } else {
        Scroll() {
          Column() {
            MiddleBaseComponent({
              examItem: this.examList[this.index],
              parentSelectCallBack: this.parentSelectCallBack
            })
          }
        }
        .scrollBar(BarState.Off)

        // .height('100%')
      }
    }

  }

  changeMaterIndex(index: number) {

    this.curExamItem.materialChildIndex = index;
    LogUtil.info("run changeMaterIndex:" + this.curExamItem.materialChildIndex)

    if (this.curExamItem.material_ques) {
      this.curExamItem.material_ques[this.curExamItem.materialChildIndex].start_time = Date.now();
    }

  }
}


@Component
struct MiddleBaseComponent {
  parentSelectCallBack?: Function;
  materialSelectCallBack?: Function;
  @ObjectLink examItem: ExamItem;

  build() {
    Column() {
      if (this.examItem.type == 1) { //判断题
        SingleSelectComponent({
          examItem: this.examItem,
          parentSelectCallBack: this.parentSelectCallBack,
          materialSelectCallBack: this.materialSelectCallBack
        })
      } else if (this.examItem.type == 2) { //单选题
        SingleSelectComponent({
          examItem: this.examItem,
          parentSelectCallBack: this.parentSelectCallBack,
          materialSelectCallBack: this.materialSelectCallBack
        })
      } else if (this.examItem.type == 3) { //多选题
        MultipleSelectComponent({
          examItem: this.examItem,
          parentSelectCallBack:
          this.parentSelectCallBack,
          materialSelectCallBack: this.materialSelectCallBack
        })
      } else { //主观题
        SubjectComponent({
          examItem: this.examItem,
          parentSelectCallBack: this.parentSelectCallBack,
          materialSelectCallBack: this.materialSelectCallBack
        })
      }
    }

  }
}