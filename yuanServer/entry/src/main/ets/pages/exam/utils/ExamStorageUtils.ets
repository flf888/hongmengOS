import { LogUtil } from '../../../common/utils/LogUtil';
import { PreferencesUtil } from '../../../common/utils/PreferencesUtil';
import { CommitGlobalReqParams, GroupStatus } from '../QuickTestMainPage';
import { QuickTestMainPageParams } from '../types/QuickTest';
import { NewExamQuickType, NewExamQuickUtils } from './NewExamQuickType';
import { router } from '@kit.ArkUI';
import { ExamPaperDetailsResultPageParams } from '../ExamPaperDetailsResultPage';
import { JsonDataUtils } from '../../../common/utils/JsonDataUtils';
import Utils from '../../../common/utils/Utils';

// 普通做题缓存项
interface NormalCacheQuesItem {
  user_answer: string
  is_right: number
}

interface KnowCache {
  mapObj: Record<number, NormalCacheQuesItem>
}

// 试卷做题缓存项
interface PaperCacheQuestItem {
  user_answer: string
  is_right: number
}

interface PaperCacheSingle {
  last_number: number
  group_status: GroupStatus
  user_score: number
  commit_at: string
}

interface PaperCache {
  single: PaperCacheSingle
  mapObj: Record<number, PaperCacheQuestItem>
}

// 知识点练习的分组做题数据记录
interface KnowTestGroup {
  my_log_count: number // 做过的题目数量
  group_index: number // 当前在第几组
  last_number: number // 当前组所在的下标
  group_status: GroupStatus
  group_commit_count: number // 当前组提交的数量
  commit_at: string
}

// 智能刷题分组做题数据记录
interface SmartTestGroup {
  group_index: number // 当前在第几组
  knowledge_index: number
  subject_index: number
  no_know_group_index: number
  last_number: number // 当前组所在的下标
  group_status: GroupStatus
  commit_at: string
}


export class ExamStorageUtils {
  private static knowTestQuestCacheMap: Record<number, KnowCache> = {}; // 知识点的题目缓存
  private static smartTestQuestCacheMap: Record<number, NormalCacheQuesItem> = {}; // 智能刷题的题目缓存
  private static paperCacheMap: Record<number, PaperCache> = {}; // 试卷题目缓存与做题数据
  private static knowTestGroupMap: Record<number, KnowTestGroup> = {}; // 知识点的分组做题数据
  private static smartTestGroup: SmartTestGroup = {
    group_index: 0,
    knowledge_index: 0,
    subject_index: 0,
    no_know_group_index: 0,
    last_number: 0,
    group_status: 0,
    commit_at: ''
  };

  static loadNormalCache() {
    const knowTestQuestCacheMapStr = PreferencesUtil.getStringSync("knowTestQuestCacheMap")
    if (knowTestQuestCacheMapStr) {
      ExamStorageUtils.knowTestQuestCacheMap = JSON.parse(knowTestQuestCacheMapStr)
    }

    const smartTestQuestCacheMapStr = PreferencesUtil.getStringSync("smartTestQuestCacheMap")
    if (smartTestQuestCacheMapStr) {
      ExamStorageUtils.smartTestQuestCacheMap = JSON.parse(smartTestQuestCacheMapStr)
    }

    const knowTestGroupMapStr = PreferencesUtil.getStringSync("knowTestGroupMap")
    if (knowTestGroupMapStr) {
      ExamStorageUtils.knowTestGroupMap = JSON.parse(knowTestGroupMapStr)
    }

    const smartTestGroupStr = PreferencesUtil.getStringSync("smartTestGroup")
    if (smartTestGroupStr) {
      ExamStorageUtils.smartTestGroup = JSON.parse(smartTestGroupStr)
    }

  }


  static loadPaperCache() {
    const paperCacheMapStr = PreferencesUtil.getStringSync("paperCacheMap")
    if (paperCacheMapStr) {
      ExamStorageUtils.paperCacheMap = JSON.parse(paperCacheMapStr)
    }
    LogUtil.info("paperCacheMapStr" + paperCacheMapStr)
  }

  static getSmartTestQuestItem(question_id: number) {
    return ExamStorageUtils.smartTestQuestCacheMap[question_id]
  }

  static saveSmartTestQuestItem(question_id: number, item: NormalCacheQuesItem) {
    ExamStorageUtils.smartTestQuestCacheMap[question_id] = item;
    PreferencesUtil.putSync("smartTestQuestCacheMap", JSON.stringify(ExamStorageUtils.smartTestQuestCacheMap))
  }

  static clearSmartTestQuest() {
    ExamStorageUtils.smartTestQuestCacheMap = {};
    PreferencesUtil.putSync("smartTestQuestCacheMap", JSON.stringify(ExamStorageUtils.smartTestQuestCacheMap))
  }

  // 智能刷题再练一次
  static smartTestAgain() {
    ExamStorageUtils.smartTestGroup.group_status = 0;
    ExamStorageUtils.clearSmartTestQuest()
    PreferencesUtil.putSync("smartTestGroup", JSON.stringify(ExamStorageUtils.smartTestGroup))
  }

  static getKnowTestQuestItem(knowledge_id: number, question_id: number): NormalCacheQuesItem | undefined {
    let knowTemp = ExamStorageUtils.knowTestQuestCacheMap[knowledge_id];
    if (knowTemp) {
      return knowTemp.mapObj[question_id]
    }
    return undefined
  }

  static saveKnowTestQuestItem(knowledge_id: number, question_id: number, item: NormalCacheQuesItem) {
    if (!ExamStorageUtils.knowTestQuestCacheMap[knowledge_id]) {
      ExamStorageUtils.knowTestQuestCacheMap[knowledge_id] = {
        mapObj: {}
      }
    }

    ExamStorageUtils.knowTestQuestCacheMap[knowledge_id].mapObj[question_id] = item;
    PreferencesUtil.putSync("knowTestQuestCacheMap", JSON.stringify(ExamStorageUtils.knowTestQuestCacheMap))
  }

  // 清除指定知识点下的所有题目
  static clearKnowTestQuest(knowledge_id: number) {
    if (ExamStorageUtils.knowTestQuestCacheMap[knowledge_id]) {
      ExamStorageUtils.knowTestQuestCacheMap[knowledge_id].mapObj = {};
      PreferencesUtil.putSync("knowTestQuestCacheMap", JSON.stringify(ExamStorageUtils.knowTestQuestCacheMap))
    }

  }

  // 清除指定知识点下指定组的题目
  static clearKnowTestGroupQuest(
    knowledge_id: number,
    group_index: number,
    subject_index: number,
    knowledge_index: number
  ) {

    let groupQuests = JsonDataUtils.getKnowGroupQuestions(subject_index, knowledge_index, group_index)

    groupQuests.map(item => {
      if (ExamStorageUtils.knowTestQuestCacheMap[knowledge_id]) {
        ExamStorageUtils.knowTestQuestCacheMap[knowledge_id].mapObj[item.id] = {
          user_answer: '',
          is_right: 0
        };
      }

    })

    PreferencesUtil.putSync("knowTestQuestCacheMap", JSON.stringify(ExamStorageUtils.knowTestQuestCacheMap))
  }

  // 知识点刷题再练一次
  static knowTestAgain(
    knowledge_id: number,
    subject_index: number,
    knowledge_index: number
  ) {
    let group_index = ExamStorageUtils.knowTestGroupMap[knowledge_id].group_index;
    ExamStorageUtils.clearKnowTestGroupQuest(knowledge_id, group_index, subject_index, knowledge_index)

    ExamStorageUtils.knowTestGroupMap[knowledge_id].group_status = 0;
    ExamStorageUtils.knowTestGroupMap[knowledge_id].my_log_count -= ExamStorageUtils.knowTestGroupMap[knowledge_id].group_commit_count
    ExamStorageUtils.knowTestGroupMap[knowledge_id].group_commit_count = 0
    PreferencesUtil.putSync("knowTestGroupMap", JSON.stringify(ExamStorageUtils.knowTestGroupMap))
  }


  static getPaperItem(paper_id: number) {
    const paperItem = ExamStorageUtils.paperCacheMap[paper_id]
    return paperItem
  }

  // 是否使用无知识点的题目
  static isUseNoKnow(subject_index: number) {
    const knowCount = JsonDataUtils.getKnowCount(subject_index)
    const noKnowGroupCount = JsonDataUtils.getNoKnowGroupCount(subject_index)
    return knowCount == 0 && noKnowGroupCount > 0
  }

  static restartSmartTest() {
    const smartTestGroup = ExamStorageUtils.smartTestGroup;

    if (smartTestGroup.group_status == 1) {
      let group_index = smartTestGroup.group_index
      let knowledge_index = smartTestGroup.knowledge_index
      let subject_index = smartTestGroup.subject_index
      let no_know_group_index = smartTestGroup.no_know_group_index

      const knowGroupCount = JsonDataUtils.getKnowGroupCount(subject_index, knowledge_index)
      const knowCount = JsonDataUtils.getKnowCount(subject_index)
      const subjectCount = JsonDataUtils.getSubjectCount()
      const noKnowGroupCount = JsonDataUtils.getNoKnowGroupCount(subject_index)

      if (group_index < knowGroupCount - 1) {
        // 可以增加组数
        ExamStorageUtils.smartTestGroup.group_index++;
      } else if (knowledge_index < knowCount - 1) {
        // 可以增加知识点下标
        ExamStorageUtils.smartTestGroup.group_index = 0;
        ExamStorageUtils.smartTestGroup.knowledge_index++;
      } else if (ExamStorageUtils.isUseNoKnow(subject_index) && no_know_group_index < noKnowGroupCount - 1) {
        // 有无知识点题目，并且可以增加无知识点组下标
        ExamStorageUtils.smartTestGroup.group_index = 0;
        ExamStorageUtils.smartTestGroup.knowledge_index = 0;
        ExamStorageUtils.smartTestGroup.no_know_group_index++;
      } else if (subject_index < subjectCount - 1) {
        // 可以增加科目下标
        ExamStorageUtils.smartTestGroup.group_index = 0;
        ExamStorageUtils.smartTestGroup.knowledge_index = 0;
        ExamStorageUtils.smartTestGroup.no_know_group_index = 0;
        ExamStorageUtils.smartTestGroup.subject_index++;
      } else {
        // 都无法增加了重置 0
        ExamStorageUtils.smartTestGroup.group_index = 0
        ExamStorageUtils.smartTestGroup.knowledge_index = 0
        ExamStorageUtils.smartTestGroup.subject_index = 0;
        ExamStorageUtils.smartTestGroup.no_know_group_index = 0;

      }

      ExamStorageUtils.clearSmartTestQuest()

      PreferencesUtil.putSync("smartTestGroup", JSON.stringify(ExamStorageUtils.smartTestGroup))
    }
  }

  static restartKnowTest(knowledge_id: number, knowledge_index: number, subject_index: number) {

    const knowTestGroup = ExamStorageUtils.getKnowTestGroup(knowledge_id)
    if (knowTestGroup) {
      if (knowTestGroup.group_status == 1) {
        const knowGroupCount = JsonDataUtils.getKnowGroupCount(subject_index, knowledge_index)
        ExamStorageUtils.sureExitKnowTestGroupMap(knowledge_id)
        if (ExamStorageUtils.knowTestGroupMap[knowledge_id].group_index < knowGroupCount - 1) {
          // 进入下一组
          ExamStorageUtils.knowTestGroupMap[knowledge_id].group_index++;
          ExamStorageUtils.knowTestGroupMap[knowledge_id].group_status = 0
          ExamStorageUtils.knowTestGroupMap[knowledge_id].last_number = 0
        } else {
          // 重置清空
          ExamStorageUtils.knowTestGroupMap[knowledge_id].group_index = 0;
          ExamStorageUtils.knowTestGroupMap[knowledge_id].group_status = 0
          ExamStorageUtils.knowTestGroupMap[knowledge_id].my_log_count = 0;
          ExamStorageUtils.knowTestGroupMap[knowledge_id].last_number = 0
        }

        ExamStorageUtils.clearKnowTestQuest(knowledge_id)

        PreferencesUtil.putSync("knowTestGroupMap", JSON.stringify(ExamStorageUtils.knowTestGroupMap))
      }
    }
  }

  static restartPaper(paper_id: number) {
    const paperItem = ExamStorageUtils.paperCacheMap[paper_id];
    if (!paperItem) {
      return;
    }

    if (paperItem.single.group_status == 1) {
      // 已交卷则重做
      ExamStorageUtils.paperCacheMap[paper_id] = {
        single: {
          group_status: 0,
          last_number: 0,
          user_score: 0,
          commit_at: ""
        },
        mapObj: {}
      }
      PreferencesUtil.putSync("paperCacheMap", JSON.stringify(ExamStorageUtils.paperCacheMap))

      LogUtil.info("run restartParper:" + JSON.stringify(ExamStorageUtils.paperCacheMap))
    }
  }

  static savePaperItem(paper_id: number, cacheSingle: PaperCacheSingle) {
    ExamStorageUtils.sureExitPaperCache(paper_id)

    LogUtil.info("cacheSingle:" + JSON.stringify(cacheSingle) + " paper_id:" + paper_id)

    ExamStorageUtils.paperCacheMap[paper_id].single = cacheSingle
    PreferencesUtil.putSync("paperCacheMap", JSON.stringify(ExamStorageUtils.paperCacheMap))
  }

  static getPaperQuestItem(paper_id: number, question_id: number): PaperCacheQuestItem | undefined {
    const paperItem = ExamStorageUtils.paperCacheMap[paper_id]
    if (paperItem) {
      return paperItem.mapObj[question_id]
    }
    return undefined
  }

  static sureExitPaperCache(paper_id: number) {
    if (!ExamStorageUtils.paperCacheMap[paper_id]) {
      ExamStorageUtils.paperCacheMap[paper_id] = {
        single: {
          group_status: 0,
          last_number: 0,
          user_score: 0,
          commit_at: ""
        },
        mapObj: {}
      }
    }
  }

  static savePaperQuestItem(paper_id: number, question_id: number, item: PaperCacheQuestItem) {
    ExamStorageUtils.sureExitPaperCache(paper_id)

    LogUtil.info(`savePaperQuestItem: paper_id:${paper_id} question_id:${question_id} item:${JSON.stringify(item)}`)

    ExamStorageUtils.paperCacheMap[paper_id].mapObj[question_id] = item;

    PreferencesUtil.putSync("paperCacheMap", JSON.stringify(ExamStorageUtils.paperCacheMap))
  }

  static getSmartTestGroup() {
    return ExamStorageUtils.smartTestGroup
  }

  static commitSmartTestGroup(requestData: CommitGlobalReqParams, routeParams: QuickTestMainPageParams) {

    if (requestData.group_status == 0) {
      // 暂存
      ExamStorageUtils.smartTestGroup.last_number = requestData.last_number
      ExamStorageUtils.smartTestGroup.group_status = 0
    } else {
      // 交卷
      ExamStorageUtils.smartTestGroup.last_number = 0
      ExamStorageUtils.smartTestGroup.group_status = 1
      ExamStorageUtils.smartTestGroup.commit_at = Utils.getCurCommitTime()
    }

    PreferencesUtil.putSync("smartTestGroup", JSON.stringify(ExamStorageUtils.smartTestGroup))
  }

  static getKnowTestGroup(knowledge_id: number) {
    return ExamStorageUtils.knowTestGroupMap[knowledge_id]
  }

  static sureExitKnowTestGroupMap(knowledge_id: number) {
    if (!ExamStorageUtils.knowTestGroupMap[knowledge_id]) {
      // 设置默认值
      ExamStorageUtils.knowTestGroupMap[knowledge_id] = {
        my_log_count: 0,
        group_index: 0,
        last_number: 0,
        group_status: 0,
        commit_at: "",
        group_commit_count: 0
      }
    }
  }

  static commitKnowTestGroup(requestData: CommitGlobalReqParams, routeParams: QuickTestMainPageParams) {
    const knowledge_id = routeParams.knowledge_id;
    if (!knowledge_id) {
      return
    }
    ExamStorageUtils.sureExitKnowTestGroupMap(knowledge_id)

    if (requestData.group_status == 0) {
      // 暂存
      ExamStorageUtils.knowTestGroupMap[knowledge_id].last_number = requestData.last_number
    } else {
      // 交卷
      ExamStorageUtils.knowTestGroupMap[knowledge_id].last_number = 0;
      ExamStorageUtils.knowTestGroupMap[knowledge_id].my_log_count += requestData.questionsTotal
      ExamStorageUtils.knowTestGroupMap[knowledge_id].group_commit_count = requestData.questionsTotal
      ExamStorageUtils.knowTestGroupMap[knowledge_id].group_status = 1;
      ExamStorageUtils.knowTestGroupMap[knowledge_id].commit_at = Utils.getCurCommitTime()
    }

    PreferencesUtil.putSync("knowTestGroupMap", JSON.stringify(ExamStorageUtils.knowTestGroupMap))
  }

  // 组交卷
  static groupCommit(requestData: CommitGlobalReqParams, routeParams: QuickTestMainPageParams) {

    let user_score = 0;

    requestData.upLoadList.forEach(item => {
      if (routeParams.req_type == NewExamQuickType.examDoPaper) {
        ExamStorageUtils.savePaperQuestItem(routeParams.paper_id ?? 0, item.question_id, {
          is_right: item.is_right,
          user_answer: item.user_answer
        })
        if (item.is_right && item.score) {
          user_score += item.score
        }

      } else if (routeParams.new_exam_type == "know_test") {
        let knowledge_id = routeParams.knowledge_id ?? 0
        ExamStorageUtils.saveKnowTestQuestItem(knowledge_id, item.question_id, {
          is_right: item.is_right,
          user_answer: item.user_answer
        })
      } else if (routeParams.new_exam_type == "smart_test") {
        ExamStorageUtils.saveSmartTestQuestItem(item.question_id, {
          is_right: item.is_right,
          user_answer: item.user_answer
        })
      }
    })

    if (routeParams.new_exam_type == "know_test") {
      ExamStorageUtils.commitKnowTestGroup(requestData, routeParams)
    } else if (routeParams.new_exam_type == "smart_test") {
      ExamStorageUtils.commitSmartTestGroup(requestData, routeParams)
    } else if (routeParams.req_type == NewExamQuickType.examDoPaper) {
      if (routeParams.paper_id) {
        ExamStorageUtils.savePaperItem(routeParams.paper_id, {
          last_number: requestData.last_number,
          group_status: requestData.group_status,
          user_score: user_score,
          commit_at: Utils.getCurCommitTime()
        })
      }
    }

    if (requestData.group_status == 1) {
      if (routeParams.req_type == NewExamQuickType.examDoPaper) {
        router.replaceUrl({
          url: "pages/exam/ExamPaperDetailsResultPage",
          params: {
            paper_id: routeParams.paper_id,
            paper_index: routeParams.paper_index,
            subject_index: routeParams.subject_index
          } as ExamPaperDetailsResultPageParams
        })
      } else {
        // 交卷
        router.replaceUrl({
          url: "pages/exam/ExamMiddleResultPage",
          params: {
            routeParams: routeParams
          }
        })
      }

    }
  }
}