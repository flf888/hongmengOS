import router from '@ohos.router';
import Utils from '../../common/utils/Utils';
import MiddleComponent from './component/MiddleComponent';
import ToastUtils from '../../common/utils/ToastUtils';
import { ExamBottomMenuDialog } from './dialog/ExamBottomMenuDialog';
import { ExamSettingDialog } from './dialog/ExamSettingDialog';
import { NewExamQuickType, NewExamQuickUtils } from './utils/NewExamQuickType';
import { ExamResetDialog } from './dialog/ExamResetDialog';
import { NoDoExamDialog } from './dialog/NoDoExamDialog';
import { PageState } from '../../common/constants/Constants';
import LoadingLayout from '../../view/LoadingLayout';
import FailLayout from '../../view/FailLayout';
import { StyleFit } from './utils/StyleFit';
import { NavigationIndicator } from '../../view/NavigationIndicator';
import { ExamItem, ExamItemType, MyLogItem } from './bean/ExamItem';
import { LogUtil } from '../../common/utils/LogUtil';
import { StyleColor, StyleRes } from './utils/StyleRes';
import { CustomIcon, CustomIconType } from '../../view/CustomIcon';
import { NewExamType, QuickTestMainPageParams } from './types/QuickTest';
import { EmitterUtil } from '../../common/utils/EmitterUtil';
import TopNavBar from '../../view/TopNavBar';
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';
import { ExamStorageUtils } from './utils/ExamStorageUtils';
import { it } from '@ohos/hypium';
import Config from '../../http/Config';

// 普通做题提交项
interface CommitExamItem {
  question_id: number
  is_right: number
  is_flag: number
  number: number
  min_number: number //材料题子页面位置
  main_number: number
  user_answer: string // 用户答案
  score: number // 试卷模式下的题目分数

}

export type GroupStatus = 0 | 1 //  0:暂存 1:交卷

export interface CommitGlobalReqParams {
  group_status: GroupStatus
  time: number
  type: NewExamType
  last_number: number
  upLoadList: CommitExamItem[],
  questionsTotal: number
}

@Entry
@Component
struct QuickTestMainPage {
  private parentSwiperController: SwiperController = new SwiperController();
  examBottomDialogController?: CustomDialogController; //底部选项卡弹窗
  examSettingDialogController?: CustomDialogController; //设置弹窗
  resetExamDialogController?: CustomDialogController; //重新作答弹窗
  noDoExamDialogController?: CustomDialogController; //未做完弹窗
  @Provide @Watch("onUpdateQuestionMakingMode") questionMakingMode: boolean = true; //true 做题模式 false 背题模式
  @Provide lightMode: boolean = true; //true 日间模式 false 夜间模式
  @Provide scaleTextStyle: number = 1; // 当前字体大小样式
  @Provide currentIndex: number = 0; //当前坐标
  @Provide questionsTotal: number = 0; // 总题数
  @Provide routeParams: QuickTestMainPageParams = {
    req_type: NewExamQuickType.examIntelligenceQuick,
  }; //外部传递过来的参数
  @Provide page: number = 1; //当前请求数据是第几页
  @Provide examList: ExamItem[] = []; //数据源
  @State format: string = 'mm:ss'
  @State pageState: PageState = PageState.Loading;
  @Provide isDoPaper: boolean = false; //true 代表做试卷
  @Provide makeTime: number = 0; // 总做题做题时长
  @State paperAllTime: number = 0; // 做试卷模式下的总时长
  // @State remainTimeUi: string = "00:00";
  // @State remainTime: number = 0; // ui显示的时长，做试卷为倒计时，普通做题为正记时
  @Provide isParse: boolean = false; // 是否是解析模式
  @State type_desc: string = "";
  doExamTimer?: number
  submitLock: boolean = false; // 提交锁
  lastCurrentOffset: number = 0;
  curSwiperDirection: "left" | "right" | "" = "";

  aboutToAppear(): void {

    this.routeParams = router.getParams() as QuickTestMainPageParams;

    this.isParse = NewExamQuickUtils.isParse(this.routeParams.req_type, this.routeParams.check_error);
    this.isDoPaper = NewExamQuickUtils.isDoPaper(this.routeParams.req_type);
    this.questionMakingMode = StyleFit.getQuestionMakingMode();
    this.lightMode = StyleFit.getLightMode();
    this.scaleTextStyle = StyleFit.getScaleTextStyle();

    if (this.isDoPaper) {
      // 做试卷没有背题模式
      // StyleFit.setQuestionMakingMode(true);
      this.questionMakingMode = true;
    }


    this.getExamList();

    EmitterUtil.onSubscribe("parentShowNext", () => {
      // this.parentSwiperController.showNext();
      this.nextQuestionFunc()
    })

    EmitterUtil.onSubscribe("parentShowPrevious", () => {
      this.parentSwiperController.showPrevious();
    })
  }

  aboutToDisappear() {

    clearTimeout(this.doExamTimer)

    EmitterUtil.unSubscribe("parentShowNext");
    EmitterUtil.unSubscribe("parentShowPrevious");
  }

  onBackPress(): boolean | void {
    LogUtil.info("run onBackPress")
    this.backLogic(false)
  }

  backLogic(isRouteBack: boolean) {
    if (this.isParse) {
      if (isRouteBack) {
        Utils.routeBack();
      }
    } else {
      // 做题暂存题目
      this.commitExam(0).then(() => {
        if (isRouteBack) {
          Utils.routeBack();
        }
      })
    }

  }

  onUpdateQuestionMakingMode() {
    LogUtil.info("onUpdateQuestionMakingMode:" + this.questionMakingMode)

    if (this.questionMakingMode) {
      // 练习模式-将所有的题目的 answer_show设置为 0
      this._eachExamList((examItem) => {
        examItem.answer_show = 0;
      })
    } else {
      // 背题模式-将做过的题目 answer_show设置为 1
      this._eachExamList((examItem) => {
        if (examItem.my_log.user_answer) {
          examItem.answer_show = 1;
        }
      })
    }
  }

  _eachExamList(callback: (examItem: ExamItem) => void) {
    this.examList.map(item => {
      if (item.is_materials) {
        item.material_ques?.forEach(citem => {
          callback(citem);
        })
      } else {
        callback(item);
      }
    })
  }

  // timerInit() {
  //   if (this.isDoPaper) {
  //     this.remainTime = this.paperAllTime - this.makeTime;
  //   } else {
  //     this.remainTime = this.makeTime;
  //   }
  //   this.remainTimeUi = Utils.formatSeconds(this.remainTime);
  //
  //   this.secondReturn();
  // }

  // secondReturn() {
  //   this.doExamTimer = setTimeout(() => {
  //     if (this.isDoPaper) {
  //       // 做试卷
  //
  //       this.remainTime--;
  //       this.remainTimeUi = Utils.formatSeconds(this.remainTime);
  //       this.makeTime = this.paperAllTime - this.remainTime;
  //
  //       if (this.remainTime <= 0) {
  //         return;
  //       }
  //     } else {
  //       this.remainTime++;
  //       this.remainTimeUi = Utils.formatSeconds(this.remainTime);
  //       this.makeTime = this.remainTime;
  //     }
  //
  //     // LogUtil.info(`doExamTimer: ${this.remainTime}`)
  //
  //     this.secondReturn();
  //
  //   }, 1000)
  //
  // }

  _parseExamList(list: ExamItem[]) {
    let objList: ExamItem[] = [];
    let mainNumber = -1;
    let questionsTotal = 0;
    for (let index = 0; index < list.length; index++) {
      // let item = new ExamItem(list[index]);
      let item = list[index];
      if (item.is_materials) {
        item.materialChildIndex = 0
        item.material_ques?.map((sonItem, sonIndex) => {
          mainNumber++;
          sonItem.son_number = sonIndex;
          sonItem.main_number = mainNumber;
          sonItem.parent_number = index;
          this._parseExamItem(sonItem, index);
          questionsTotal++;
        })
      } else {
        mainNumber++;
        item.son_number = 0;
        item.parent_number = index;
        item.main_number = mainNumber;
        this._parseExamItem(item, index);
        questionsTotal++;
      }
      objList.push(item);

    }
    this.questionsTotal = questionsTotal;
    return objList;
  }

  getExamList() {
    // let GlobalReqParams = NewExamQuickUtils.getReqMap(this.page, 112, this.routeParams);
    let reqType = (this.routeParams.req_type) || 0;
    // reqType, GlobalReqParams
    JsonDataUtils.newExeFastDetailList(reqType, this.routeParams, this.isDoPaper).then(res => {
      if (res['code'] === 200) {
        this.pageState = PageState.Success;

        if (this.isParse) {
          this.type_desc = "查看解析"
        } else {
          if(res['data']['type_desc'] == '智能刷题') {
            this.type_desc = Config.yuan_service_template == 3 ? '免费刷题' : '智能刷题';
          } else {
            this.type_desc = res['data']['type_desc']
          }
        }

        if (this.routeParams.examList) {
          const sortExamList =
            NewExamQuickUtils.toExamItemList(JSON.parse(this.routeParams.examList) ?? [], this.isDoPaper)
          const examList = this._parseExamList(sortExamList);
          this.examList = examList;
        } else {
          const sortExamList = NewExamQuickUtils.toExamItemList(res['data']['data'], this.isDoPaper);
          const examList = this._parseExamList(sortExamList);
          this.examList = examList;
        }

        if (!this.isParse) {
          this.onUpdateQuestionMakingMode();
        }


        if (res['data']['number']) {
          this.currentIndex = res['data']['number'] as number ?? 0;
        }

        if (this.routeParams.number != undefined) {
          // 判断是否越界
          if (this.routeParams.number > this.examList.length - 1) {
            this.routeParams.number = this.examList.length - 1;
          } else {
            this.currentIndex = this.routeParams.number;
          }
        }

        // 子材料题位置
        if (this.routeParams.min_number != undefined) {
          const minNumber = this.routeParams.min_number;
          // 防止minNumber越界
          if (minNumber <= this.examList[this.currentIndex]._materialCount - 1) {
            this.examList[this.currentIndex].materialChildIndex = minNumber;
          } else {
            LogUtil.info("minNumber越界:" + minNumber)
          }
        }

        if (this.examList.length) {
          this.examList[this.currentIndex].start_time = Date.now();
        }

        if (this.isDoPaper) {
          // 做试卷
          this.makeTime = res['data']['make_time'];
          this.paperAllTime = res['data']['time'];
        } else {
          // 普通刷题
          this.makeTime = res['data']['time'];

        }
        // this.timerInit()

      } else {
        this.pageState = PageState.Fail;

        LogUtil.error("newExeFastDetailList fail", JSON.stringify(res))
        ToastUtils.showToast(res['message']);
        Utils.routeBack()
      }

    }).catch((err: Error) => {
      this.pageState = PageState.Fail;
      LogUtil.error("err msg:", JSON.stringify(err))
      Utils.routeBack()
    })

  }

  _parseExamItem(examItem: ExamItem, index: number) {
    // const answerDecode = AesUtils.aesECBDecryptSync(examItem.answer ?? "")
    let answer = examItem.answer;

    examItem.answer = answer;


    examItem.cur_index = index;

    if (this.routeParams.check_error) {
      examItem.answer_show = 1;
    }

    // 判断是否显示答案
    if (this.isParse) {
      examItem.answer_show = 1;
    }

  }

  nextQuestionFunc() {

    // 是否还能往右滑动
    const isNext = this.currentIndex < (this.examList.length - 1);
    LogUtil.info("nextQuestionFunc:" + isNext)
    if (isNext) {
      this.parentSwiperController.showNext();
    } else {
      if (this.isParse) {
        // 解析模式不进行提交题目

      } else if (this.questionMakingMode == false) {
        // 背题模式
        this.submit()
      } else {
        //先判断是否做完
        if (this.checkIsDoAll()) {
          this.submit()
        } else {
          this.noDoExamDialog();
        }
      }

    }
  }

  build() {
    Column() {

      TopNavBar({
        customBack: () => {
          this.backLogic(true)
        }
      })

      if (this.pageState == PageState.Loading) {
        LoadingLayout();
      } else if (this.pageState == PageState.Fail) {
        FailLayout({
          reloadFunc: () => {
            this.pageState = PageState.Loading
            this.getExamList();
          }
        });
      } else {
        if (this.examList[this.currentIndex]) {
          TopExamBar({
            isParse: this.isParse,
            lightMode: this.lightMode,
            // remainTimeUi: this.remainTimeUi,
            examItem: this.examList[this.currentIndex],
            type_desc: this.type_desc
          })
        }


        Swiper(this.parentSwiperController) {
          ForEach(this.examList, (_: ExamItem, index) => {
            MiddleComponent({
              index: index,
              curExamItem: this.examList[index],
              parentSelectCallBack: () => {
                this.nextQuestionFunc()
              }
            })
          })
        }
        .cachedCount(2)
        .index(this.currentIndex)
        .autoPlay(false)
        .interval(4000)
        .indicator(false)
        .loop(false)
        .duration(100)
        .itemSpace(0)
        .curve(Curve.Linear)
        .width('100%')
        .height('100%')
        .flexShrink(1)
        .onChange((index: number) => {
          console.log("run pageChange", index);
          this.currentIndex = index;

          const examItem = this.examList[this.currentIndex];

          examItem.start_time = Date.now();
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
          const tempNum = this.examList.length - 1;
          if (this.curSwiperDirection == "right" && index == targetIndex && index == tempNum) {
            // 最后一个元素向右滑动
            LogUtil.info("最后一个元素向右滑动")
            this.nextQuestionFunc()
          }
        })


        if (this.examList.length && this.examList[this.currentIndex]) {
          BotoomTool({
            examItem: this.examList[this.currentIndex],
            isParse: this.isParse,
            openExamBottomDialog: () => {
              this.openExamBottomDialog();
            }
          })
        }


      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode))
  }

  /**
   * 底部题目选项卡
   */
  openExamBottomDialog() {

    if (this.examBottomDialogController == undefined) {
      this.examBottomDialogController = new CustomDialogController({
        builder: ExamBottomMenuDialog({
          clickNumFunc: (examItem) => {
            this.currentIndex = examItem.parent_number;
            if (this.examList[this.currentIndex].is_materials) {
              const materialChildIndex = examItem.son_number
              const item = this.examList[this.currentIndex];
              item.materialChildIndex = materialChildIndex;
              if (item.material_ques) {
                item.material_ques[materialChildIndex].start_time = Date.now();
              }
            } else {
              this.examList[this.currentIndex].start_time = Date.now();
            }
          },
          isParse: this.isParse,
          questionsTotal: this.questionsTotal,
          curExamItem: this.examList[this.currentIndex],
          commitFunc: () => {
            //胶卷
            //先判断是否做完
            if (this.checkIsDoAll()) {
              this.submit()
            } else {
              this.noDoExamDialog();
            }
          },
          resetFunc: () => {
            //重新作答
            this.resetExamDialog();
          }
        }),
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: 0 },
        // gridCount: 4,
        customStyle: true
      })
    }
    this.examBottomDialogController.open()
  }

  /**
   * 检查是否所有题目都做完了
   *
   */
  checkIsDoAll() {

    const doNumber = this.getDoNumber();
    if (doNumber <= 0) {
      return false;
    }
    if (doNumber < this.questionsTotal) {
      return false;
    }
    return true;
  }

  /**
   * 底部题目选项卡
   */
  openExamSettingDialog() {
    if (this.examSettingDialogController == undefined) {
      this.examSettingDialogController = new CustomDialogController({
        builder: ExamSettingDialog({
          isParse: this.isParse
        }),
        alignment: DialogAlignment.Bottom,
        offset: { dx: 0, dy: 0 },
        customStyle: true
      })
    }
    this.examSettingDialogController.open()
  }

  /**
   * 重新作答
   */
  resetExamDialog() {
    if (this.resetExamDialogController == undefined) {
      this.resetExamDialogController = new CustomDialogController({
        builder: ExamResetDialog({
          clearFunc: () => {

            if (this.isDoPaper) {
              this.routeParams.is_cover = 1;
              this.routeParams.number = 0;
              router.replaceUrl({
                url: "pages/exam/QuickTestMainPage",
                params: this.routeParams
              })

            } else {
              //待实现重做

            }


          }
        }),
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: 0 },
        // gridCount: 4,
        customStyle: true
      })
    }
    this.resetExamDialogController.open()
  }

  /**
   * 获取总共做了多少题
   * @returns
   */
  getDoNumber() {
    let doNumber = 0;
    for (let a = 0; a < this.examList.length; a++) {
      let item = this.examList[a];
      if (item.is_materials) {
        item.material_ques?.map((sonItem) => {
          if (sonItem.my_log && sonItem.my_log.user_answer) {
            doNumber++;
          }
        })
      } else {
        if (item.my_log && item.my_log.user_answer) {
          doNumber++;
        }
      }

    }

    return doNumber;
  }

  /**
   * 未做完弹窗
   */
  noDoExamDialog() {
    if (this.noDoExamDialogController == undefined) {
      this.noDoExamDialogController = new CustomDialogController({
        builder: NoDoExamDialog({
          doNumber: this.getDoNumber(),
          lightMode: this.lightMode,
          questionsTotal: this.questionsTotal,
          commitFunc: () => {
            this.submit()
          }
        }),
        alignment: DialogAlignment.Center,
        offset: { dx: 0, dy: 0 },
        // gridCount: 4,
        customStyle: true
      })
    }
    this.noDoExamDialogController.open()
  }

  // 提交
  submit() {
    this.commitExam()
  }

  _getCommitItem(itemData: ExamItem) {

    let commitItem: CommitExamItem = {
      question_id: itemData.id,
      is_right: itemData.my_log.is_right,
      is_flag: itemData.my_log.is_flag,
      number: itemData.main_number,
      min_number: itemData.min_number,
      main_number: itemData.main_number,
      user_answer: '', // 用户答案
      score: itemData.score
    };


    let userAnswer = itemData.my_log.user_answer;

    if (itemData.type == 1) {
      // 判断题处理提交答案
      let temAnswer = NewExamQuickUtils.replaceJudgeAnswerToEn(userAnswer)
      userAnswer = temAnswer;
    }
    commitItem.user_answer = NewExamQuickUtils.getUserAnswer(userAnswer);

    if (!commitItem.user_answer) {
      commitItem.is_right = 0;
    }

    return commitItem;
  }

  /**
   * 普通交卷
   * groupStatus 状态类型 0:暂存 1:交卷 default 1
   */
  commitExam(groupStatus: GroupStatus = 1) {
    LogUtil.info("run commitExam")
    if (this.submitLock) {
      return Promise.resolve();
    }

    // 修复-没有题目时则不提交
    if (this.questionsTotal == 0) {
      return Promise.resolve();
    }

    this.submitLock = true;

    let upLoadList: CommitExamItem[] = [];
    for (let index = 0; index < this.examList.length; index++) {
      let item = this.examList[index];
      if (item.is_materials) {
        item.material_ques?.map(citem => {
          if (citem.my_log.user_answer) {
            const commitItem = this._getCommitItem(citem)
            upLoadList.push(commitItem);
          }
        })
      } else {
        if (item.my_log.user_answer) {
          const commitItem = this._getCommitItem(item)
          upLoadList.push(commitItem);
        }
      }

    }
    let requestData: CommitGlobalReqParams = {
      // group_id: "",
      group_status: groupStatus,
      time: this.makeTime,
      type: this.routeParams.new_exam_type ?? "smart_test",
      last_number: this.currentIndex,
      upLoadList: upLoadList,
      questionsTotal: this.questionsTotal
    };

    ExamStorageUtils.groupCommit(requestData, this.routeParams)

    return Promise.resolve();

  }
}

@Component
struct BotoomTool {
  @Consume lightMode: boolean;
  @Consume routeParams: QuickTestMainPageParams;
  @Consume currentIndex: number;
  @Consume isDoPaper: number;
  @ObjectLink @Watch('onUpdateExamItem') examItem: ExamItem;
  @State uiLogItem: MyLogItem = new MyLogItem({
    user_answer: '',
    is_right: 0,
    is_flag: 0
  });
  @State uniKey: string = "";
  @State isParse: boolean = false;
  openExamBottomDialog?: () => void

  aboutToAppear(): void {
    this.onUpdateExamItem();
  }

  onUpdateExamItem() {
    const examItem = this.examItem;
    if (examItem.is_materials && examItem.material_ques) {
      let temItem = examItem.material_ques[examItem.materialChildIndex];
      this.uiLogItem = temItem.my_log;
      this.uniKey = temItem.uni_key;
    } else {
      this.uiLogItem = examItem.my_log;
      this.uniKey = examItem.uni_key;
    }
  }

  build() {
    Column() {
      Row() {
        if (!this.isParse) {
          Row() {
            CustomIcon({
              iconType: this.uiLogItem.is_flag == 1 ? CustomIconType.icon_mark_on : CustomIconType.icon_mark_off,
              iconSize: 23,
              iconColor: this.uiLogItem.is_flag == 1 ? "#FFFF0C00" :
              StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
            })
          }
          .onClick(async () => {

            if (this.uiLogItem.is_flag == 0) {
              if (this.isDoPaper) {
                // await ExamApi.setFlag({
                //   "user_paper_id": this.routeParams.user_paper_id ?? 0,
                //   "number": this.currentIndex + 1,
                //   "is_flag": 1
                // })

              }
              this.uiLogItem.is_flag = 1;
              ToastUtils.showToast("标记成功，已在答题卡中标记此题")
            } else {
              if (this.isDoPaper) {
                // await ExamApi.setFlag({
                //   "user_paper_id": this.routeParams.user_paper_id ?? 0,
                //   "number": this.currentIndex + 1,
                //   "is_flag": 0
                // })
              }

              this.uiLogItem.is_flag = 0;
              ToastUtils.showToast("已取消标记");
            }


          })
          .flexGrow(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .height('100%')
        }
        Row() {

          CustomIcon({
            iconType: CustomIconType.icon_answer,
            iconWeight: 23,
            iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
          })
        }
        .onClick(() => {
          if (this.openExamBottomDialog) {
            this.openExamBottomDialog()
          }
        })
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .height('100%')
      }
      .width('100%')
      .height(Utils.getVp(96))

      NavigationIndicator({
        bgColor: StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode)
      })
    }
    .width('100%')
    .backgroundColor(StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode))
  }
}


@Component
struct TopExamBar {
  @Consume routeParams: QuickTestMainPageParams;
  @Consume isDoPaper: number;
  @ObjectLink examItem: ExamItem;
  @Prop type_desc: string;
  @Consume questionsTotal: number;
  @Prop isParse: boolean = false; // 是否是解析模式
  @Prop lightMode: boolean = true; //true 日间模式 false 夜间模式

  // @Prop remainTimeUi: string = "00:00";

  build() {
    Row() {
      if (this.isDoPaper) {
        Text(`${this.examItem.score}分`)
          .fontColor($r('app.color.mainColor'))
          .fontSize(Utils.getVp(21))
          .padding({
            left: Utils.getVp(13),
            right: Utils.getVp(13),
            top: Utils.getVp(6),
            bottom: Utils.getVp(6)
          })
          .backgroundColor($r('app.color.shallowTwoMainColor'))
          .borderRadius(Utils.getVp(4))
      } else {
        Text(this.type_desc)
          .fontColor($r('app.color.auxiliaryTextColor'))
          .fontSize(Utils.getVp(27))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(Utils.getVp(400))
      }

      Blank()
      // if (!this.isParse) {
      //   // 倒计时
      //   Column() {
      //     CustomIcon({
      //       iconType: CustomIconType.icon_timer,
      //       iconSize: 19,
      //       iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
      //     })
      //     Text(this.remainTimeUi)
      //       .fontColor(StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode))
      //       .fontSize(11)
      //   }
      //   .margin({
      //     left: Utils.getVp(50),
      //     right: Utils.getVp(60)
      //   })
      //
      // }
      Text(`${NewExamQuickUtils.getCurMainNumber(this.examItem)}`
      ).fontColor($r('app.color.mainColor'))
        .fontSize(Utils.getVp(35))
      Text(`/${this.questionsTotal}`).fontColor($r('app.color.auxiliaryTextColor'))
        .fontSize(Utils.getVp(27))
    }
    .width('100%')
    .height(Utils.getVp(67))
    .backgroundColor($r('app.color.toBeActivatedTextColorPercentTen'))
    .padding({ left: Utils.getVp(38), right: Utils.getVp(25) })
  }

  getLeftNum(item: ExamItem) {
    if (item.is_materials) {
      return item.material_ques?.[0].main_number
    } else {
      return item.main_number
    }
  }
}