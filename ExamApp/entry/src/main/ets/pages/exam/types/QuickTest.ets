import { NewExamQuickType } from "../utils/NewExamQuickType"

export type CheckErrorType = 0 | 1 | 2; // 0 题目列表， 1 查看所有解析, 2 查看所有错题

// know_test知识点练习 smart_test智能刷题 high_error高频错题 collect我的收藏 auto后台自定义  error错题本
export type NewExamType = "know_test" | "smart_test";

export type PreviewType = 0 | 1; //0试卷回顾 1只看错题

export type StatusKeyType = "total" | "mistake" | "undone" | "done" //total 全部, mistake 错题, undone 未做题, done 已做题

export interface QuickTestMainPageParams {
  req_type: NewExamQuickType
  new_exam_type?: NewExamType
  // group_id?: string
  // group_status?: number
  preview_type?: PreviewType // 只在试卷刷题时才有该参数
  number?: number // 题目位置 从0开始计数
  min_number?: number //材料题子页面位置 从0开始计数
  main_number?: number
  check_error?: CheckErrorType // 只有在普通刷题时才有该参数
  // isRealTopicSummary?: boolean
  knowledge_id?: number

  is_cover?: number // 1重做

  paper_id?: number
  paper_index?: number
  is_next?: number
  // config_id?: number
  // is_focus?: number
  examList?: string


  knowledge_index?: number
  subject_index?: number
}

export interface MiddlePageParams {
  routeParams: QuickTestMainPageParams
}

export interface GoParseParams {
  number?: number
  min_number?: number // 子材料题位置
  // main_number?: number
  check_error: CheckErrorType // 0 题目列表， 1 查看所有解析, 2 查看所有错题
}