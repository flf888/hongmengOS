import { NewExamQuickType } from "../utils/NewExamQuickType"

interface ExplanCardItemType {
  type_name: string
  type?: number
  my_log?: MyLogItem
  list: ExamItem[]
  paper_type_id?: number
}

@Observed
export class ExplanCardItem {
  type_name: string
  type?: number
  my_log?: MyLogItem
  list: ExamItem[]
  paper_type_id?: number

  constructor(obj: ExplanCardItemType) {
    this.type_name = obj.type_name;
    this.type = obj.type;
    this.my_log = obj.my_log;
    this.list = obj.list;
    this.paper_type_id = obj.paper_type_id;
  }
}


interface MyLogItemType {
  // id: number
  user_answer: string
  // user_image: string
  is_right: number
  // q_user_paper_id: number
  // time: number
  is_flag: number
  // is_collect?: boolean
}

@Observed
export class MyLogItem {
  // id: number
  user_answer: string
  // user_image: string
  is_right: number
  // q_user_paper_id: number
  // time: number
  is_flag: number
  is_collect?: boolean

  constructor(obj: MyLogItemType) {
    // this.id = obj.id;
    this.user_answer = obj.user_answer;
    // this.user_image = obj.user_image;
    this.is_right = obj.is_right;
    // this.q_user_paper_id = obj.q_user_paper_id;
    // this.time = obj.time;
    this.is_flag = obj.is_flag;
    // this.is_collect = obj.is_collect;
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

interface Materials {
  content: string
}

export interface ExamItemType {
  user_answer: string
  type: number // 1判断题 2单选题 3多选题 4主观题
  options: OptionItemType[];
  answer: string // 答案
  my_log: MyLogItemType
  answer_show: number
  type_name: string
  name: string
  uni_key: string
  req_type: NewExamQuickType
  user_customs_id: number
  q_user_step_id: number
  knowledge_id?: number
  extre_id: number
  subject_id: number
  plan_day_id: number
  challenge_subject_id: number
  parent_number: number // 真实题目位置下标
  main_number: number // 答题卡总题下标
  son_number: number // 子材料题下标
  material_length: number // 子材料题数量
  cur_index: number
  // question_id: number
  id: number
  // know_points: Record<string, string>[]
  percent_time: string
  right_percent: string
  easy_wrong: string
  analysis: string
  number: number
  min_number: number
  check_error: number
  isRealTopicSummary: string
  q_user_high_error_id: number
  is_custom_test: number
  is_smart_test: number
  is_special_training_base: number
  suffix: number
  mock_id: number
  material_id: number
  // selectUnKnow: number
  is_materials: boolean
  material_ques?: ExamItemType[]
  materials: Materials
  is_right: number
  start_time: number // 做题开始时间
  score: number
  materialChildIndex: number
  paper_type_id?: number
  paper_type_title?: string
  grade?: number // -1待评分
}

@Observed
export class ExamItem {
  user_answer?: string
  type: number
  options: OptionItem[];
  answer: string
  my_log: MyLogItem
  answer_show: number
  type_name: string
  name: string
  uni_key: string
  req_type: NewExamQuickType
  user_customs_id: number
  q_user_step_id: number
  knowledge_id?: number
  extre_id: number
  subject_id: number
  plan_day_id: number
  challenge_subject_id: number
  parent_number: number // 真实题目位置下标
  main_number: number
  son_number: number
  material_length: number //请使用_materialCount， 因为material_length在试卷列表中没有值
  cur_index: number
  // question_id: number
  id: number
  // know_points: Record<string, string>[]
  percent_time: string
  right_percent: string
  easy_wrong: string
  analysis: string
  // number: number
  min_number: number
  check_error: number
  isRealTopicSummary: string
  q_user_high_error_id: number
  is_custom_test: number
  is_smart_test: number
  is_special_training_base: number
  suffix: number
  mock_id: number
  material_id: number
  // selectUnKnow: number
  is_materials: boolean
  material_ques?: ExamItem[]
  _materialCount: number // 由前端计算的材料题数量
  materials: Materials
  is_right: number
  start_time: number
  score: number // 试卷模式下的题目分数
  materialChildIndex: number
  paper_type_id?: number
  paper_type_title?: string
  grade?: number // -1待评分

  constructor(obj: ExamItemType) {
    this.user_answer = obj.user_answer;
    this.type = obj.type;
    if (obj.options) {
      this.options = obj.options.map(item => {
        return new OptionItem(item);
      });
    } else {
      this.options = []
    }

    this.answer = obj.answer;
    if (obj.my_log) {
      this.my_log = new MyLogItem(obj.my_log);
    } else {
      this.my_log = new MyLogItem({
        // id: 0,
        user_answer: '',
        // user_image: '',
        is_right: 0,
        // q_user_paper_id: 0,
        // time: 0,
        is_flag: 0,
        // is_collect: false
      });
    }
    this.answer_show = obj.answer_show ?? 0;
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
    // this.question_id = obj.question_id;
    this.id = obj.id;
    // this.know_points = obj.know_points;
    this.percent_time = obj.percent_time;
    this.right_percent = obj.right_percent;
    this.easy_wrong = obj.easy_wrong;
    this.analysis = obj.analysis;
    // this.number = obj.number;
    this.min_number = obj.min_number;
    this.check_error = obj.check_error;
    this.isRealTopicSummary = obj.isRealTopicSummary;
    this.q_user_high_error_id = obj.q_user_high_error_id;
    this.is_custom_test = obj.is_custom_test;
    this.is_smart_test = obj.is_smart_test;
    this.is_special_training_base = obj.is_special_training_base;
    this.suffix = obj.suffix;
    this.mock_id = obj.mock_id;
    this.material_id = obj.material_id;
    // this.selectUnKnow = obj.selectUnKnow;
    this.is_materials = obj.is_materials;
    this.materials = obj.materials;
    if (obj.material_ques) {
      this.material_ques = obj.material_ques.map(item => {
        return new ExamItem(item);
      });
      this._materialCount = this.material_ques.length;
    } else {
      this._materialCount = 0;
    }

    this.is_right = obj.is_right;
    this.start_time = obj.start_time;
    this.score = obj.score;
    this.materialChildIndex = obj.materialChildIndex;
    this.paper_type_id = obj.paper_type_id;
    this.paper_type_title = obj.paper_type_title;
    this.grade = obj.grade;

  }
}