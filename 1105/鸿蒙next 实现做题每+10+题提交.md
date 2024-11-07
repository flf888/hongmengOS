# 鸿蒙 next 实现做题每 10 题提交



## 1.封装一个ExamCacheUtils 工具类，使用单列的模式进行调用



```JavaScript
export class ExamCacheUtils { 
  private static instance: ExamCacheUtils;

  public static getInstance() {
    if (!ExamCacheUtils.instance) {
      ExamCacheUtils.instance = new ExamCacheUtils();
    }
    return ExamCacheUtils.instance;
  }


}
```



## 2.使用数组存储待提交的题目数据

下面代码考虑到了上传错误场景，正在上传时添加题目的场景：

```JavaScript
import { LogUtil } from '../../../common/utils/LogUtil';
import UserCacheManager from '../../../common/utils/UserCacheManager';
import ExamApi from '../../../http/action/ExamApi';
import { ReqParams } from '../../../http/RequestApi';
import { ExamItem, ExamItemType } from '../bean/ExamItem';
import { NewExamQuickType } from './NewExamQuickType';
import { router } from '@kit.ArkUI';
import ToastUtils from '../../../common/utils/ToastUtils';


interface ExamCacheItem {
  uni_key: string
  answer: string
  make_time?: number;
  time?: number;
  question_type?: number
  type?: NewExamQuickType
  user_paper_id?: number
  user_step_question_id?: number
  user_customs_id?: number
  q_user_step_id?: number
  know_id?: number
  extre_id?: number
  subject_id?: number
  plan_day_id: number
  challenge_subject_id?: number
  number?: number
  min_number?: number
  main_number?: number
  my_log_id?: number
  question_id?: number
  is_custom_test?: number
}

interface PushExamItemParams {
  examItem: ExamItem
  userAnswer: string
  elapsedTime: number
  questionMakingMode: boolean

}

export interface CommitAnswerBatchParams {
  is_write: number // /是否练习 1 练习 0背题
  type: number // 3 考试提交答案 固定参数3
  is_special_training_base: number // //是否是专项训练基础题 固定参数0
  datas: string // 题目数据
  subject_id: number
}

export interface PaperCommitParams {
  paper_id: number
  user_paper_id: number
  make_time: number
  plan_day_id?: number // 计划试卷 id

}

export class ExamCacheUtils {
  private static instance: ExamCacheUtils;

  public static getInstance() {
    if (!ExamCacheUtils.instance) {
      ExamCacheUtils.instance = new ExamCacheUtils();
    }
    return ExamCacheUtils.instance;
  }

  ///缓存的用户操作列表
  examCacheMap: ExamCacheItem[] = [];
  examCacheTmpMap: ExamCacheItem[] = [];
  examCacheErrorMap: ExamCacheItem[] = [];
  ///缓存的用户背题操作列表
  examBeitiCacheMap: ExamCacheItem[] = [];
  ///题目缓存数量上限
  maxNum = 10;
  ///是否正在上传题目
  isUploading = false;

  pushExamItem(params: PushExamItemParams) {
    let reqParam: ExamCacheItem = {
      uni_key: '',
      answer: '',
      plan_day_id: 0
    };

    const examItem = params.examItem;
    const userAnswer = params.userAnswer;
    const elapsedTime = params.elapsedTime;

    reqParam.uni_key = examItem.uni_key;
    reqParam.answer = userAnswer;
    reqParam.make_time = parseInt(`${elapsedTime / 1000}`, 10)

    if (examItem.req_type) {
      reqParam.type = examItem.req_type;
    }

    if (examItem.my_log?.q_user_paper_id) {
      reqParam.user_paper_id = examItem.my_log.q_user_paper_id;
    }

    if (examItem.my_log?.id) {
      reqParam.user_step_question_id = examItem.my_log.id;
    }

    if (examItem.user_customs_id) {
      reqParam.user_customs_id = examItem.user_customs_id;
    }

    if (examItem.q_user_step_id) {
      reqParam.q_user_step_id = examItem.q_user_step_id;
    }

    if (examItem.knowledge_id) {
      reqParam.know_id = examItem.knowledge_id;
    }

    if (examItem.extre_id) {
      reqParam.extre_id = examItem.extre_id;
    }

    if (examItem.subject_id) {
      reqParam.subject_id = examItem.subject_id;
    }
    if (examItem.plan_day_id) {
      reqParam.plan_day_id = examItem.plan_day_id;
    }

    if (examItem.challenge_subject_id) {
      reqParam.challenge_subject_id = examItem.challenge_subject_id;
    }

    if (examItem.parent_number) {
      reqParam.number = examItem.parent_number + 1;
      reqParam.min_number = examItem.son_number ?? 0;
      reqParam.main_number = examItem.main_number ?? 0;

    } else {
      reqParam.number = examItem.cur_index + 1;
      reqParam.min_number = 0;
      reqParam.main_number = (examItem.cur_index + 1);
    }

    // 新增字段
    reqParam.my_log_id = examItem.my_log?.id;
    reqParam.question_id = examItem.question_id;

    reqParam.question_type = examItem.type;

    if (examItem.my_log?.time) {
      reqParam.time = examItem.my_log.time;
    }

    this.addCache(reqParam, params.questionMakingMode);

  }

  /**
   *isWrite 是否是做题模式
   * @returns
   */
  private addCache(itemMap: ExamCacheItem, isWrite: boolean) {
    if (this.isUploading) {
      if (isWrite) {
        this.examCacheTmpMap.push(itemMap);
      } else {
        this.examBeitiCacheMap.push(itemMap);
      }
    } else {
      if (isWrite) {
        this.examCacheMap.push(itemMap);
      } else {
        this.examBeitiCacheMap.push(itemMap);
      }
      ///判断是否达到上限
      if (this.examBeitiCacheMap.length >= this.maxNum) {
        ///主动上传
        this.uploadQuestion(() => {
        });
      }
    }

    LogUtil.info("addCache", JSON.stringify(this.examCacheMap), JSON.stringify(itemMap))
  }

  private getReqData(cacheList: ExamCacheItem[], isWrite: boolean = true) {

    let data: CommitAnswerBatchParams = {
      is_write: 0,
      type: 0,
      is_special_training_base: 0,
      datas: '',
      subject_id: 0
    };

    if (isWrite) { //是否练习 1 练习 0背题
      data.is_write = 1;
    } else {
      data.is_write = 0;
    }

    data.type = 3; // type 3 考试提交答案
    data.subject_id = parseInt(UserCacheManager.getSubjectId()) ?? 0;

    let datas = JSON.stringify(cacheList);
    console.log("===> datas : " + datas);
    data.datas = datas;
    data.is_special_training_base = 0;

    return data;
  }

  /**
   * 上传缓存的题目
   */
  uploadQuestion(backFunc: Function) {
    if (this.isUploading) {
      backFunc();
      return;
    }
    this.isUploading = true;

    LogUtil.info("this.examCacheMap", JSON.stringify(this.examCacheMap))

    ///上传失败的数据
    if (this.examCacheErrorMap.length) {
      ExamApi.commitAnswerBatch(this.getReqData(this.examCacheErrorMap)).then((rs) => {
        this.examCacheErrorMap = [];
      }).catch((_: Error) => {
        this.examCacheErrorMap = [];
      })
    }


    // 上传背题数据
    if (this.examBeitiCacheMap.length) {
      ExamApi.commitAnswerBatch(this.getReqData(this.examBeitiCacheMap, false)).then((rs) => {
        this.examBeitiCacheMap = [];
      }).catch((_: Error) => {
        this.examBeitiCacheMap = [];
      })
    }


    // 正常的数据
    if (this.examCacheMap.length) {
      ExamApi.commitAnswerBatch(this.getReqData(this.examCacheMap)).then((rs) => {
        if (rs['code'] == 200) {
          this.examCacheMap = [];
        } else {
          ///上传失败
          this.examCacheErrorMap.push(...this.examCacheMap);
          this.examCacheMap = [];
        }
      }).catch((_: Error) => {
        this.examCacheErrorMap.push(...this.examCacheMap);
        this.examCacheMap = [];
      })
    }


    ///上传结束
    this.examCacheMap = [];
    this.examCacheMap = this.examCacheTmpMap;
    this.examCacheTmpMap = [];

    this.isUploading = false;
    backFunc();

  }


  // 提交试卷
  commitPaper(params: PaperCommitParams) {
    this.uploadQuestion(() => {
      ExamApi.paperCommit(params).then(res => {
        if (res['code'] == 200) {
          router.pushUrl({
            url: "pages/exam/ExamPaperDetailsResultPage",
            params: {
              user_paper_id: params.user_paper_id,
              paper_id: params.paper_id
            }
          })
        } else {
          ToastUtils.showToast(res['message']);
        }
      }).catch((error: Error) => {
        LogUtil.error("paperCommit", error.message)
        ToastUtils.showToast("请求失败");
      })

    })
  }
}


```

