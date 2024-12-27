import { LogUtil } from '../../../common/utils/LogUtil';
import { ExamItem, ExamItemType, ExplanCardItem } from '../bean/ExamItem';
import { GoParseParams, NewExamType, QuickTestMainPageParams } from '../types/QuickTest';
import { router } from '@kit.ArkUI';
import Utils from '../../../common/utils/Utils';


export enum NewExamQuickType {
  //错题或者试卷解析
  examTestErrorOrAnalysis,
  //智能刷题
  examIntelligenceQuick,
  //新的知识点做题
  newExamKnowledge,
  // 试卷考试
  examDoPaper,
}

interface SortRuleItem {
  name: string;
  sort: number;
}

export class NewExamQuickUtils {


  //是否显示解析
  static isParse(req_type: NewExamQuickType, check_error?: number) {

    if (check_error || req_type == NewExamQuickType.examTestErrorOrAnalysis) {
      return true;
    }

    return false;
  }

  // 是否是做试卷
  static isDoPaper(req_type: NewExamQuickType) {
    if (req_type == NewExamQuickType.examDoPaper || req_type == NewExamQuickType.examTestErrorOrAnalysis) {
      return true;
    }
    return false;
  }


  static toExamItemList(examItemTypeArr: ExamItemType[], isDoPaper: boolean): ExamItem[] {
    let sortExamItemTypeArr: ExamItemType[] = []
    if (isDoPaper) {
      sortExamItemTypeArr = examItemTypeArr;
    } else {
      sortExamItemTypeArr = NewExamQuickUtils._sortExamlist(examItemTypeArr);
    }

    let examList: ExamItem[] = []
    for (let i = 0; i < sortExamItemTypeArr.length; i++) {
      const pushItem = sortExamItemTypeArr[i];
      // LogUtil.info("pushItem", JSON.stringify(pushItem))
      let item = new ExamItem(pushItem);
      examList.push(item);
    }
    return examList;
  }

  // 排序做题列表
  private static _sortExamlist(examList: ExamItemType[]): ExamItemType[] {
    const sortRule: Record<number, SortRuleItem> = {
      1: {
        name: '判断题',
        sort: 3
      },
      2: {
        name: '单选题',
        sort: 1
      },
      3: {
        name: '多选题',
        sort: 2
      },
      4: {
        name: '主观题',
        sort: 4
      }
    };

    let sortQuestionArr = examList.sort((a, b) => {
      return sortRule[a.type].sort - sortRule[b.type].sort;
    });

    return sortQuestionArr;
  }

  static parseExpList(examList: ExamItem[]) {
    let expList: ExamItem[] = [];

    let mainNumber = -1;
    for (let index = 0; index < examList.length; index++) {
      let item = examList[index];
      if (item.is_materials) {
        item.material_ques?.map((sonItem, sonIndex) => {
          mainNumber++;
          sonItem.son_number = sonIndex;
          sonItem.main_number = mainNumber;
          sonItem.parent_number = index;
          expList.push(sonItem)
        })
      } else {
        mainNumber++;
        item.son_number = 0;
        item.parent_number = index;
        item.main_number = mainNumber;
        expList.push(item)
      }
    }

    return expList
  }

  // 普通刷题的答题卡
  static parseExamCard(expList: ExamItem[]) {
    //记录最后 题型 1判断 2单选 3多选 4主观题 排序索引顺序
    let indexList: number[] = [];
    let judge: ExamItem[] = [];
    let single: ExamItem[] = [];
    let multiple: ExamItem[] = [];
    let mind: ExamItem[] = [];

    expList.forEach((element) => {
      let type = element.type;

      if (type == 1) {
        if (!indexList.includes(type)) {
          indexList.push(type);
        }
        judge.push(element);
      } else if (type == 2) {
        if (!indexList.includes(type)) {
          indexList.push(type);
        }
        single.push(element);
      } else if (type == 3) {
        if (!indexList.includes(type)) {
          indexList.push(type);
        }
        multiple.push(element);
      } else if (type == 4) {
        if (!indexList.includes(type)) {
          indexList.push(type);
        }
        mind.push(element);
      } else {
        judge.push(element);
      }

    })

    LogUtil.info("run parseExamCard indexList", JSON.stringify(indexList))


    const cardList: ExplanCardItem[] = [];
    indexList.forEach(element => {
      if (element == 1) {
        if (judge.length > 0) {
          cardList.push(new ExplanCardItem({
            type_name: "判断题",
            list: judge
          }));
        }
      } else if (element == 2) {
        if (single.length > 0) {
          cardList.push(new ExplanCardItem({
            type_name: "单选题",
            list: single
          }));
        }
      } else if (element == 3) {
        if (multiple.length > 0) {
          cardList.push(new ExplanCardItem({
            type_name: "多选题",
            list: multiple
          }));
        }
      } else if (element == 4) {
        if (mind.length > 0) {
          cardList.push(new ExplanCardItem({
            type_name: "主观题",
            list: mind
          }));
        }
      }

    })
    return cardList;
  }

  // 试卷的答题卡
  static parsePaperCard(expList: ExamItem[]) {
    // 存储下标
    const paperIdMapObj: Record<number, number> = {}

    const cardList: ExplanCardItem[] = [];

    expList.map((item, index) => {
      if (item.paper_type_id) {
        if (paperIdMapObj[item.paper_type_id] != undefined) {
          // 拿到下标
          const tempIndex = paperIdMapObj[item.paper_type_id];
          cardList[tempIndex].list.push(item);
        } else {
          //新建并记录下标
          const explanItem = new ExplanCardItem({
            type_name: item.paper_type_title ?? "",
            list: [item]
          });
          cardList.push(explanItem);
          paperIdMapObj[item.paper_type_id] = cardList.length - 1;
        }
      }
    })

    return cardList;

  }

  /**
   * 跳转查看解析页面
   * @param params 自定义参数
   * @param allData 接口groupResult返回的数据
   * @param routeParams 页面接口参数
   */
  static goParse(params: GoParseParams,
    routeParams: QuickTestMainPageParams) {
    let itemMap: QuickTestMainPageParams = {
      "number": params.number ?? 0,
      "min_number": params.min_number ?? 0,
      'new_exam_type': routeParams.new_exam_type,
      "req_type": routeParams.req_type,
      // 'parent_chapter_id': routeParams.parent_chapter_id ?? 0,
      "check_error": params.check_error,
      // 'config_id': allData['config_id'] as number ?? 0,
      // 'group_id': routeParams.group_id ?? ""
    };
    LogUtil.info("run goParse", JSON.stringify(itemMap))

    NewExamQuickUtils.goNewQuickTestMainPage(itemMap, routeParams, false);
  }

  /**
   *
   * @param itemMapData 自定义参数
   * @param routeParams 路由参数
   * @param isNeedReplace
   */
  static goNewQuickTestMainPage(itemMapData: Record<string, ESObject>, routeParams: QuickTestMainPageParams,
    isNeedReplace: boolean) {
    let itemMap: Record<string, ESObject> = {};

    itemMap = Utils.deepClone(routeParams);

    // 自定义参数赋值，优先级最高
    Object.keys(itemMapData).forEach(key => {
      itemMap[key] = itemMapData[key];
    });


    if (isNeedReplace) {
      router.replaceUrl({ url: "pages/exam/QuickTestMainPage", params: itemMap })
    } else {
      router.pushUrl({ url: "pages/exam/QuickTestMainPage", params: itemMap })
    }
  }

  static getCurMainNumber(examItem: ExamItem) {
    return examItem.is_materials ?
      (examItem.material_ques?.[examItem.materialChildIndex].main_number ?? 0) + 1 :
      examItem.main_number + 1;
  }

  // 计算做题时间
  // static calcDoQuesTime(examItem: ExamItem) {
  //   if (examItem.start_time) {
  //     const useTime = Math.floor((Date.now() - examItem.start_time) / 1000)
  //     examItem.my_log.time = (useTime <= 0 ? 1 : useTime);
  //     LogUtil.info(`run calcDoQuesTime ${examItem.my_log.time}`)
  //   } else {
  //     // 修复未知情况至少一秒
  //     examItem.my_log.time = 1;
  //   }
  // }

  // 将英文答案A,B 转换为中文答案对，错
  static replaceJudgeAnswerToCn(userAnswer: string) {
    let tmpUserAnswer = userAnswer;
    tmpUserAnswer = tmpUserAnswer.replace('A', '对').replace('B', '错');
    return tmpUserAnswer;
  }

  // 将中文答案转换为英文答案A,B
  static replaceJudgeAnswerToEn(userAnswer: string) {
    let tmpUserAnswer = userAnswer;
    tmpUserAnswer = tmpUserAnswer.replace('对', 'A').replace('错', 'B');
    return tmpUserAnswer;
  }

  static getUserAnswer(userAnswer: string) {

    return userAnswer;
  }
}