# Implementing Batch Question Submission (Every 10 Questions) in HarmonyOS Next

## 1. ExamCacheUtils Utility Class (Singleton Pattern)

```
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

## 2. Caching and Batch Submission Implementation

Handles upload scenarios including error recovery and concurrent submissions:

```
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
  make_time?: number;     // Time spent (seconds)
  time?: number;          // Timestamp
  question_type?: number  // Question type
  type?: NewExamQuickType // Custom type
  user_paper_id?: number  // User paper ID
  user_step_question_id?: number
  user_customs_id?: number
  q_user_step_id?: number
  know_id?: number        // Knowledge point ID
  extre_id?: number       // Extra ID
  subject_id?: number     // Subject ID
  plan_day_id: number     // Daily plan ID
  challenge_subject_id?: number
  number?: number         // Question number
  min_number?: number
  main_number?: number
  my_log_id?: number      // Log ID
  question_id?: number    // Question ID
  is_custom_test?: number // Custom test flag
}

interface PushExamItemParams {
  examItem: ExamItem        // Question data
  userAnswer: string        // User's answer
  elapsedTime: number       // Time spent (ms)
  questionMakingMode: boolean // Practice mode flag
}

export interface CommitAnswerBatchParams {
  is_write: number          // Practice mode: 1=Practice, 0=Memorization
  type: number              // Fixed value 3 (exam submission)
  is_special_training_base: number // Fixed value 0
  datas: string             // Serialized question data
  subject_id: number        // Subject ID
}

export interface PaperCommitParams {
  paper_id: number          // Paper ID
  user_paper_id: number     // User paper ID
  make_time: number         // Total time spent
  plan_day_id?: number      // Daily plan ID
}

export class ExamCacheUtils {
  private static instance: ExamCacheUtils;
  
  // Singleton access
  public static getInstance() {
    if (!ExamCacheUtils.instance) {
      ExamCacheUtils.instance = new ExamCacheUtils();
    }
    return ExamCacheUtils.instance;
  }

  // Cached user operations
  examCacheMap: ExamCacheItem[] = [];        // Practice mode cache
  examCacheTmpMap: ExamCacheItem[] = [];     // Temporary cache during upload
  examCacheErrorMap: ExamCacheItem[] = [];   // Failed submission cache
  examBeitiCacheMap: ExamCacheItem[] = [];   // Memorization mode cache
  
  maxNum = 10;              // Batch size threshold
  isUploading = false;      // Upload status flag

  // Add question to cache
  pushExamItem(params: PushExamItemParams) {
    let reqParam: ExamCacheItem = {
      uni_key: params.examItem.uni_key,
      answer: params.userAnswer,
      plan_day_id: params.examItem.plan_day_id || 0,
      make_time: Math.floor(params.elapsedTime / 1000)
    };

    // Populate additional metadata
    const examItem = params.examItem;
    reqParam.type = examItem.req_type;
    reqParam.user_paper_id = examItem.my_log?.q_user_paper_id;
    reqParam.user_step_question_id = examItem.my_log?.id;
    reqParam.user_customs_id = examItem.user_customs_id;
    reqParam.q_user_step_id = examItem.q_user_step_id;
    reqParam.know_id = examItem.knowledge_id;
    reqParam.extre_id = examItem.extre_id;
    reqParam.subject_id = examItem.subject_id;
    reqParam.challenge_subject_id = examItem.challenge_subject_id;
    reqParam.question_type = examItem.type;
    reqParam.time = examItem.my_log?.time;
    reqParam.my_log_id = examItem.my_log?.id;
    reqParam.question_id = examItem.question_id;

    // Handle question numbering
    if (examItem.parent_number) {
      reqParam.number = examItem.parent_number + 1;
      reqParam.min_number = examItem.son_number ?? 0;
      reqParam.main_number = examItem.main_number ?? 0;
    } else {
      reqParam.number = examItem.cur_index + 1;
      reqParam.min_number = 0;
      reqParam.main_number = examItem.cur_index + 1;
    }

    // Add to appropriate cache
    this.addCache(reqParam, params.questionMakingMode);
  }

  // Cache management with upload handling
  private addCache(item: ExamCacheItem, isWrite: boolean) {
    if (this.isUploading) {
      // Queue during active upload
      isWrite ? this.examCacheTmpMap.push(item) 
              : this.examBeitiCacheMap.push(item);
    } else {
      // Add directly to cache
      isWrite ? this.examCacheMap.push(item) 
              : this.examBeitiCacheMap.push(item);
      
      // Trigger upload when threshold reached
      if (this.examCacheMap.length >= this.maxNum) {
        this.uploadQuestion(() => {});
      }
    }
  }

  // Prepare batch request data
  private getReqData(cacheList: ExamCacheItem[], isWrite: boolean = true): CommitAnswerBatchParams {
    return {
      is_write: isWrite ? 1 : 0, // Practice mode flag
      type: 3,                   // Exam submission type
      is_special_training_base: 0,
      datas: JSON.stringify(cacheList),
      subject_id: parseInt(UserCacheManager.getSubjectId()) || 0
    };
  }

  // Batch upload implementation
  uploadQuestion(callback: Function) {
    if (this.isUploading) {
      callback();
      return;
    }
    
    this.isUploading = true;

    // Retry failed submissions
    if (this.examCacheErrorMap.length) {
      ExamApi.commitAnswerBatch(this.getReqData(this.examCacheErrorMap))
        .then(() => this.examCacheErrorMap = [])
        .catch(() => this.examCacheErrorMap = []);
    }

    // Upload memorization mode questions
    if (this.examBeitiCacheMap.length) {
      ExamApi.commitAnswerBatch(this.getReqData(this.examBeitiCacheMap, false))
        .then(() => this.examBeitiCacheMap = [])
        .catch(() => this.examBeitiCacheMap = []);
    }

    // Upload practice mode questions
    if (this.examCacheMap.length) {
      ExamApi.commitAnswerBatch(this.getReqData(this.examCacheMap))
        .then(res => {
          if (res.code === 200) {
            this.examCacheMap = [];
          } else {
            this.examCacheErrorMap.push(...this.examCacheMap);
            this.examCacheMap = [];
          }
        })
        .catch(() => {
          this.examCacheErrorMap.push(...this.examCacheMap);
          this.examCacheMap = [];
        });
    }

    // Process queued items
    this.examCacheMap = this.examCacheTmpMap;
    this.examCacheTmpMap = [];
    this.isUploading = false;
    
    callback();
  }

  // Final paper submission
  commitPaper(params: PaperCommitParams) {
    this.uploadQuestion(() => {
      ExamApi.paperCommit(params)
        .then(res => {
          if (res.code === 200) {
            router.pushUrl({
              url: "pages/exam/ExamPaperDetailsResultPage",
              params: {
                user_paper_id: params.user_paper_id,
                paper_id: params.paper_id
              }
            });
          } else {
            ToastUtils.showToast(res.message);
          }
        })
        .catch(error => {
          LogUtil.error("paperCommit", error.message);
          ToastUtils.showToast("Request failed");
        });
    });
  }
}
```

### Key Features:

1. **Batch Processing**: Automatically submits questions every 10 items
2. **Dual Mode Support**: Handles both practice and memorization modes
3. **Error Recovery**: Retries failed submissions automatically
4. **Concurrent Handling**: Queues new items during active uploads
5. **Metadata Tracking**: Captures extensive question context
6. **Final Submission**: Handles complete paper submission

### Usage Flow:

1. Initialize singleton: `const examCache = ExamCacheUtils.getInstance()`
2. Add questions: `examCache.pushExamItem({...})`
3. Automatic batch upload at 10-question threshold
4. Final submission: `examCache.commitPaper({...})`
