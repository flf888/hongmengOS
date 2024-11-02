# 鸿蒙 next 实现对象数组的界面更新

@Provide装饰器和@Consume装饰器只支持一层的数据的界面监听变化，所以遇到对象数组的场景只能用 @Observed装饰器和@ObjectLink装饰器，鸿蒙官方文档的说明: [https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-observed-and-objectlink-V5](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-observed-and-objectlink-V5)



## 1. 新建@Observed注解的 class 类

```JavaScript
interface ExplanItemType {
  type_name: string
  type?: string
  my_log?: MyLogItem
  list: ExamItem[]
}

@Observed
export class ExplanItem {
  type_name: string
  type?: string
  my_log?: MyLogItem
  list: ExamItem[]

  constructor(obj: ExplanItemType) {
    this.type_name = obj.type_name;
    this.type = obj.type;
    this.my_log = obj.my_log;
    this.list = obj.list;
  }
}


interface MyLogItemType {
  id: number
  user_answer: string
  is_right: string
  q_user_paper_id: number
  time: string
  is_flag: string
  is_collect?: boolean
}

@Observed
export class MyLogItem {
  id: number
  user_answer: string
  is_right: string
  q_user_paper_id: number
  time: string
  is_flag: string
  is_collect?: boolean

  constructor(obj: MyLogItemType) {
    this.id = obj.id;
    this.user_answer = obj.user_answer;
    this.is_right = obj.is_right;
    this.q_user_paper_id = obj.q_user_paper_id;
    this.time = obj.time;
    this.is_flag = obj.is_right;
    this.is_collect = obj.is_collect;
  }
}

interface OptionItemType {
  key: string
  value: string
  name: string
  select: string
}

@Observed
export class OptionItem {
  key: string
  value: string
  name: string
  select: string

  constructor(obj: OptionItemType) {
    this.key = obj.key;
    this.value = obj.value;
    this.name = obj.name;
    this.select = obj.select;
  }
}


export interface ExamItemType {
  user_answer: string
  type: string
  options: OptionItemType[];
  answer: string
  my_log: MyLogItemType
  answer_show: number
  type_name: string
  name: string
  uni_key: string
  req_type: number
  user_customs_id: string
  q_user_step_id: string
  knowledge_id: string
  extre_id: string
  subject_id: string
  plan_day_id: number
  challenge_subject_id: string
  parent_number: number
  main_number: number
  son_number: number
  material_length: number
  cur_index: number
  question_id: number
  id: number
  know_points: Record<string, string>[]
  percent_time: string
  right_percent: string
  easy_wrong: string
  analysis: string
  number: number
  min_number: number
  exam_type: string
  is_charge: boolean
  type_parse: string
  isRealTopicSummary: string
  q_user_high_error_id: number
  is_custom_test: number
  is_smart_test: number
  is_special_training_base: number
  suffix: number
  mock_id: number
  material_id: number
  selectUnKnow: number
  is_materials: string
  material_ques: ExamItemType[]
  is_right: string
  start_time: number
}

@Observed
export class ExamItem {
  user_answer: string
  type: string
  options: OptionItem[];
  answer: string
  my_log: MyLogItem
  answer_show: number
  type_name: string
  name: string
  uni_key: string
  req_type: number
  user_customs_id: string
  q_user_step_id: string
  knowledge_id: string
  extre_id: string
  subject_id: string
  plan_day_id: number
  challenge_subject_id: string
  parent_number: number
  main_number: number
  son_number: number
  material_length: number
  cur_index: number
  question_id: number
  id: number
  know_points: Record<string, string>[]
  percent_time: string
  right_percent: string
  easy_wrong: string
  analysis: string
  number: number
  min_number: number
  exam_type: string
  is_charge: boolean
  type_parse: string
  isRealTopicSummary: string
  q_user_high_error_id: number
  is_custom_test: number
  is_smart_test: number
  is_special_training_base: number
  suffix: number
  mock_id: number
  material_id: number
  selectUnKnow: number
  is_materials: string
  material_ques: ExamItem[] = []
  is_right: string
  start_time: number

  constructor(obj: ExamItemType) {
    this.user_answer = obj.user_answer;
    this.type = obj.type;

    this.options = obj.options.map(item => {
      return new OptionItem(item);
    });

    this.answer = obj.answer;
    this.my_log = new MyLogItem(obj.my_log);
    this.answer_show = obj.answer_show;
    this.type_name = obj.type_name;
    this.name = obj.name;
    this.uni_key = obj.uni_key;
    this.req_type = obj.req_type;
    this.user_customs_id = obj.user_customs_id;
    this.q_user_step_id = obj.q_user_step_id;
    this.knowledge_id = obj.knowledge_id;
    this.extre_id = obj.extre_id;
    this.subject_id = obj.subject_id;
    this.plan_day_id = obj.plan_day_id;
    this.challenge_subject_id = obj.challenge_subject_id;
    this.parent_number = obj.parent_number;
    this.main_number = obj.main_number;
    this.son_number = obj.son_number;
    this.material_length = obj.material_length;
    this.cur_index = obj.cur_index;
    this.question_id = obj.question_id;
    this.id = obj.id;
    this.know_points = obj.know_points;
    this.percent_time = obj.percent_time;
    this.right_percent = obj.right_percent;
    this.easy_wrong = obj.easy_wrong;
    this.analysis = obj.analysis;
    this.number = obj.number;
    this.min_number = obj.min_number;
    this.exam_type = obj.exam_type;
    this.is_charge = obj.is_charge;
    this.type_parse = obj.type_parse;
    this.isRealTopicSummary = obj.isRealTopicSummary;
    this.q_user_high_error_id = obj.q_user_high_error_id;
    this.is_custom_test = obj.is_custom_test;
    this.is_smart_test = obj.is_smart_test;
    this.is_special_training_base = obj.is_special_training_base;
    this.suffix = obj.suffix;
    this.mock_id = obj.mock_id;
    this.material_id = obj.material_id;
    this.selectUnKnow = obj.selectUnKnow;
    this.is_materials = obj.is_materials;
    this.material_ques = obj.material_ques.map(item => {
      return new ExamItem(item);
    });

    this.is_right = obj.is_right;
    this.start_time = obj.start_time;

  }
}
```





## 2.在通过接口获得的数组数据将其转换为 Class 对象数组

```JavaScript

_parseExamList(list: ESObject[]) {
    let objList: ExamItem[] = [];
    let mainNumber = 0;
    for (let i = 0; i < list.length; i++) {
      let objItem = new ExamItem(list[i]);
      objItem.main_number = mainNumber;
      mainNumber++;
      objList.push(objItem);
    }
    return objList;
  }
```



### 3.在非@Entry 组件中使用 @ObjectLink 来标识该数据可以被响应式界面更新。

```JavaScript
@Component
struct BotoomTool {
  @ObjectLink examItem: ExamItem;
  @ObjectLink myLogItem: MyLogItem;
  @State isParse: boolean = false;
  openExamBottomDialog?: () => void

  build() {
    Flex({ direction: FlexDirection.Row }) {
      Row() {
        Image(Utils.getImgPath(this.myLogItem.is_collect ? '033collect.png' :
          '038collect_off.png', "iconfont"))
          .width(Utils.getVp(46))
          .height(Utils.getVp(46))
          .objectFit(ImageFit.Cover)
      }
      .onClick(() => {
        // ToastUtils.showToast("完成小组测试才可收藏该题目..")
        const curQues = this.examItem;

        if (curQues.my_log.is_collect) {
          // 取消收藏
          const reqParam: ReqParams = {
            "question_uni_key": curQues.uni_key
          }
          ExamApi.delFavorite(reqParam).then(res => {
            if (res['code'] == 200) {
              this.myLogItem.is_collect = false;
              // curQues.my_log.is_collect = false;
              // this.examList.splice(this.currentIndex, 1, curQues);
              ToastUtils.showToast("已取消收藏成功")
            }
          })
        } else {
          // 收藏
          const reqParam: ReqParams = {
            "question_uni_key": curQues.uni_key
          }
          ExamApi.addFavorite(reqParam).then(res => {
            if (res['code'] == 200) {
              this.myLogItem.is_collect = true;

              // curQues.my_log.is_collect = true;
              // this.examList.splice(this.currentIndex, 1, curQues);
              ToastUtils.showToast("题目收藏成功，可在我的收藏中查看")
            }
          })
        }


      })
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .height('100%')


      if (!this.isParse) {
        Row() {
          Image(Utils.getImgPath(this.myLogItem.is_flag == '1' ? '039mark_on.png' :
            '037mark_off.png', "iconfont"))
            .width(Utils.getVp(46))
            .height(Utils.getVp(46))
            .objectFit(ImageFit.Cover)
        }
        .onClick(() => {
          // ToastUtils.showToast("完成小组测试才可标记该题目..")
          this.myLogItem.is_flag = this.myLogItem.is_flag == '1' ? '0' : '1';

          // this.examList.splice(this.currentIndex, 1, curQues);
        })
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .height('100%')
      }


      Row() {
        Image(Utils.getImgPath('036answer.png', "iconfont"))
          .width(Utils.getVp(46))
          .height(Utils.getVp(46))
          .objectFit(ImageFit.Cover)
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

    }.width('100%').height(Utils.getVp(96))
  }
}
```



