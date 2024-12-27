import { LogUtil } from "./LogUtil"
import { JSON } from "@kit.ArkTS"

import realSubjectJson from "../../../../../../library/src/main/ets/jsonData/subject.json"
import realPaperJson from "../../../../../../library/src/main/ets/jsonData/paper.json"
import { NewExamQuickType } from "../../pages/exam/utils/NewExamQuickType"
import { SubjectItem } from "../../pages/home/HomePage"
import { KnowledgeItem, PaperItem } from "../../pages/home/HomeContentPage"
import { PaperInfo } from "../../pages/exam/ExaminationPaperDetailPage"

import { ReqParams, ResponseType } from '../../http/RequestApi'
import { NewExamType, QuickTestMainPageParams } from "../../pages/exam/types/QuickTest"
import { ExamStorageUtils } from "../../pages/exam/utils/ExamStorageUtils"
import Utils from "./Utils"
import { ExamItemType } from "../../pages/exam/bean/ExamItem"
import { UserPaperResultInfo } from "../../pages/exam/ExamPaperDetailsResultPage"


export class JsonDataUtils {
  static my_paper_list(subject_index: number): ESObject {
    // return myPaperListJson['data']['data'];
    if (!realPaperJson[subject_index] || !realPaperJson[subject_index].list) {
      return [];
    }

    let getList = realPaperJson[subject_index].list;
    let paper_list: PaperItem[] = [];

    getList.map((item, index) => {
      paper_list.push({
        id: item['id'],
        name: item['name'],
        score: item['score'],
        _index: index
      })
    })
    return paper_list;
  }


  static auxpoliceIndex(subject_index: number): ESObject {
    ExamStorageUtils.loadNormalCache()

    let knowList: KnowledgeItem[] = [];

    let tempKnowList: ESObject[] = realSubjectJson[subject_index]['list'];

    if (tempKnowList) {
      tempKnowList.map((item: ESObject, knowledge_index) => {
        let my_log_count = 0;
        let knowledge_id: number = item.id;

        const knowTestGroup = ExamStorageUtils.getKnowTestGroup(knowledge_id)
        if (knowTestGroup) {
          my_log_count = knowTestGroup.my_log_count
        }

        knowList.push({
          id: knowledge_id,
          name: item.name,
          my_log_count: my_log_count,
          questions_count: item.questions_count,
          _index: knowledge_index
        })
      })
    }


    return knowList;
  }

  // static articlesList() : ESObject {
  //   return articlesListJson['data']['list']['data']
  // }


  static hmMetaSubjects(): SubjectItem[] {
    // return hmMetaSubjectsJson['data']['data']

    let subjects: SubjectItem[] = [];
    realSubjectJson.map(item => {
      subjects.push({
        id: item['id'],
        name: item['name'],
      })
    })
    LogUtil.info("subjects:" + JSON.stringify(subjects))
    return subjects;
  }


  // static mixSubject(): Promise<ResponseType> {
  //   return Promise.resolve(mixSubjectJson as ESObject)
  // }

  private static _getTypeDescByNewExamType(new_exam_type?: NewExamType) {
    let type_desc = ""
    if (new_exam_type == "know_test") {
      type_desc = `知识点练习`
    } else if (new_exam_type == "smart_test") {
      type_desc = `智能刷题`
    }
    return type_desc;
  }

  // 获取知识点-组-下的题目
  static getKnowGroupQuestions(subject_index: number, knowledge_index: number, group_index: number) {
    let knowList: ESObject = realSubjectJson[subject_index]['list'];
    if (knowList) {
      let knowledge: ESObject = knowList[knowledge_index];
      let quesList: ExamItemType[] = Utils.deepClone(knowledge['questions_list'][group_index])
      return quesList;
    } else {
      return []
    }

  }

  // 获取知识点有多少组
  static getKnowGroupCount(subject_index: number, knowledge_index: number) {
    let knowList: ESObject = realSubjectJson[subject_index]['list'];

    if (knowList) {
      let knowledge: ESObject = knowList[knowledge_index];
      let quesList: ExamItemType[] = knowledge['questions_list']
      return quesList.length;
    } else {
      return 0
    }

  }

  // 获取科目下有多少知识点
  static getKnowCount(subject_index: number) {
    let knowList: ESObject = realSubjectJson[subject_index]['list'];
    if (knowList) {
      let count: number = knowList.length;
      return count;
    } else {
      return 0
    }

  }

  // 获取有多少个科目
  static getSubjectCount() {
    let count = realSubjectJson.length;
    return count;
  }

  // 获取有多少组无知识点题目
  static getNoKnowGroupCount(subject_index: number) {
    let noKnow: ESObject = realSubjectJson[subject_index]['no_know'];
    if (noKnow) {
      let count: number = noKnow.length ?? 0;
      return count
    }
    return 0
  }

  static getSmartTestQuestList() {

  }

  static groupResult(subject_index: number, knowledge_index: number,
    new_exam_type: NewExamType): Promise<ResponseType> {
    // return Promise.resolve(groupResultJson as ESObject)

    ExamStorageUtils.loadNormalCache()

    let quesList: ExamItemType[] = []
    let right_num = 0;
    let total = 0;
    let group_index = 0

    let commit_at = "";

    if (new_exam_type == "know_test") {
      let knowList: ESObject = realSubjectJson[subject_index]['list'];

      if (knowList) {
        let knowledge: ESObject = knowList[knowledge_index];
        let knowledge_id: number = knowledge.id;

        const knowTestGroup = ExamStorageUtils.getKnowTestGroup(knowledge_id ?? 0)
        if (knowTestGroup) {
          group_index = knowTestGroup.group_index;
          commit_at = knowTestGroup.commit_at
        }

        quesList = Utils.deepClone(knowledge['questions_list'][group_index])
        total = quesList.length

        quesList.forEach(item => {
          const cacheItem = ExamStorageUtils.getKnowTestQuestItem(knowledge_id, item.id)
          if (cacheItem) {
            item.user_answer = cacheItem.user_answer
            item.is_right = cacheItem.is_right
            if (cacheItem.is_right) {
              right_num += 1
            }
          } else {
            item.user_answer = ''
            item.is_right = 0
          }
        })
      }

    } else if (new_exam_type == "smart_test") {
      const smartTestGroup = ExamStorageUtils.getSmartTestGroup()
      commit_at = smartTestGroup.commit_at
      group_index = smartTestGroup.group_index;
      subject_index = smartTestGroup.subject_index
      knowledge_index = smartTestGroup.knowledge_index
      let no_know_group_index = smartTestGroup.no_know_group_index;

      if (ExamStorageUtils.isUseNoKnow(subject_index)) {
        quesList = Utils.deepClone(realSubjectJson[subject_index]['no_know'][no_know_group_index])
      } else {
        quesList =
          Utils.deepClone(realSubjectJson[subject_index]['list'][knowledge_index]['questions_list'][group_index])
      }


      total = quesList.length

      quesList.forEach(item => {
        const cacheItem = ExamStorageUtils.getSmartTestQuestItem(item.id)
        if (cacheItem) {
          item.user_answer = cacheItem.user_answer
          item.is_right = cacheItem.is_right
          if (cacheItem.is_right) {
            right_num += 1
          }
        } else {
          item.user_answer = ''
          item.is_right = 0
        }
      })
    }


    let data: ResponseType = {
      'question': quesList,
      'has_next': 0,
      "total": total,
      'right_num': right_num,
      "right_percent": Utils.getRightPercent(right_num, total),
      "commit_at": commit_at,
      "type_desc": JsonDataUtils._getTypeDescByNewExamType(new_exam_type),
    }
    let resp: ResponseType = {
      'code': 200,
      'data': data
    }

    return Promise.resolve(resp)
  }

  static paperIntro(paper_index: number, subject_index: number): ESObject {
    // return Promise.resolve(paperIntroJson as ESObject)

    // return paperIntroJson['data']['paper']
    let respItem = realPaperJson[subject_index].list[paper_index];

    let paperInfo: PaperInfo = {
      name: respItem['name'],
      time: respItem['time'] ?? 3600,
      score: respItem['score'],
      last_progress: 0,
      question_count: respItem['question_count'],
      status: 0,
      paper_id: respItem['id'],
      question_type_data: respItem['question_type_data'],
      make_time: 0,
    }
    return paperInfo;

  }

  static questionList(routeParams: QuickTestMainPageParams): Promise<ResponseType> {

    // let quesList = questionListJson['data']['data'];

    ExamStorageUtils.loadNormalCache()

    let group_index = 0
    let last_number = 0;
    let subject_index = 0;
    let knowledge_index = 0;

    let quesList: ExamItemType[] = []

    if (routeParams.new_exam_type == "know_test") {
      let knowledge_id = routeParams.knowledge_id ?? 0
      const knowTestGroup = ExamStorageUtils.getKnowTestGroup(knowledge_id)
      if (knowTestGroup) {
        group_index = knowTestGroup.group_index
        last_number = knowTestGroup.last_number
      }
      subject_index = routeParams.subject_index ?? 0
      knowledge_index = routeParams.knowledge_index ?? 0

      quesList = Utils.deepClone(realSubjectJson[subject_index]['list'][knowledge_index]['questions_list'][group_index])
      quesList.forEach(item => {
        const cacheItem = ExamStorageUtils.getKnowTestQuestItem(knowledge_id, item.id)
        if (cacheItem) {
          item.my_log = {
            user_answer: cacheItem.user_answer,
            is_right: cacheItem.is_right,
            is_flag: 0
          }
        }
      })
    } else if (routeParams.new_exam_type == 'smart_test') {
      const smartTestGroup = ExamStorageUtils.getSmartTestGroup()
      group_index = smartTestGroup.group_index;
      last_number = smartTestGroup.last_number
      subject_index = smartTestGroup.subject_index
      knowledge_index = smartTestGroup.knowledge_index
      let no_know_group_index = smartTestGroup.no_know_group_index;

      if (ExamStorageUtils.isUseNoKnow(subject_index)) {
        quesList = Utils.deepClone(realSubjectJson[subject_index]['no_know'][no_know_group_index])
      } else {
        quesList =
          Utils.deepClone(realSubjectJson[subject_index]['list'][knowledge_index]['questions_list'][group_index])
      }

      quesList.forEach(item => {
        const cacheItem = ExamStorageUtils.getSmartTestQuestItem(item.id)
        if (cacheItem) {
          item.my_log = {
            user_answer: cacheItem.user_answer,
            is_right: cacheItem.is_right,
            is_flag: 0
          }
        }
      })

    }


    let data: ResponseType = {
      'data': quesList,
      "type_desc": JsonDataUtils._getTypeDescByNewExamType(routeParams.new_exam_type),
      'number': last_number,
      'time': 0
    }
    let resp: ResponseType = {
      'code': 200,
      'data': data
    }

    return Promise.resolve(resp)
  }


  static paperQuestionList(paper_index?: number, subject_index?: number): Promise<ResponseType> {
    // let quesList = paperQuestionListJson['data']['data'];


    let getPaper = realPaperJson[subject_index ?? 0].list[paper_index ?? 0]

    let quesList: ExamItemType[] = Utils.deepClone(getPaper['questions_list'])
    let paper_id = getPaper['id']
    LogUtil.info("paperQuestionList" + JSON.stringify(quesList))
    ExamStorageUtils.loadPaperCache()

    let last_number = 0;
    const paperItem = ExamStorageUtils.getPaperItem(paper_id)
    if (paperItem) {
      last_number = paperItem.single.last_number;
    }

    quesList.forEach(item => {
      const cacheItem = ExamStorageUtils.getPaperQuestItem(paper_id, item.id)
      if (cacheItem) {
        LogUtil.info("paperQuestionList has cacheItem:" + JSON.stringify(cacheItem))
        item.my_log = {
          user_answer: cacheItem.user_answer,
          is_right: cacheItem.is_right,
          is_flag: 0
        }
      }
    })

    let data: ResponseType = {
      'data': quesList,
      'number': last_number,
      'make_time': 0,
      'time': 10000
    }
    let resp: ResponseType = {
      'code': 200,
      'data': data
    }

    return Promise.resolve(resp)
  }

  static paperResult(paper_index?: number, subject_index?: number): Promise<ResponseType> {
    // return Promise.resolve(paperResultJson as ESObject)

    let getPaper = realPaperJson[subject_index ?? 0].list[paper_index ?? 0]
    let paper_id = getPaper.id;

    let user_score = 0;
    let commit_at = ""
    const paperItem = ExamStorageUtils.getPaperItem(paper_id)
    if (paperItem) {
      user_score = paperItem.single.user_score;
      commit_at = paperItem.single.commit_at
    }

    let user_paper_info: UserPaperResultInfo = {
      "paper_name": getPaper.name,
      "commit_at": commit_at,
      "right_percent": Utils.getRightPercent(user_score, getPaper.score),
      "score": getPaper.score, // 总分
      "user_score": user_score,
    }
    let data: ResponseType = {
      "user_paper_info": user_paper_info
    }

    let resp: ResponseType = {
      'code': 200,
      'data': data
    }

    return Promise.resolve(resp)
  }

  static newExeFastDetailList(type: NewExamQuickType, routeParams: QuickTestMainPageParams, isDoPaper: boolean) {
    if (isDoPaper) {
      // 做试卷
      return JsonDataUtils.paperQuestionList(routeParams.paper_index, routeParams.subject_index)
    } else {
      return JsonDataUtils.questionList(routeParams)
    }
  }
}