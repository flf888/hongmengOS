import router from '@ohos.router';
import { ExamStorageUtils } from '../../pages/exam/utils/ExamStorageUtils';
import { NewExamQuickType } from '../../pages/exam/utils/NewExamQuickType';
import { GlobalContext } from './GlobalContext';

export default class IconUtils{
  static iconJump(item: Record<string,string|number>, params: Record<string,string|number>) {
    // 写死的知识点界面
    if(item['type'] == 'knowledge') {
      router.pushUrl({
        url: "pages/knowledge/KnowledgePage",
        params:{'pid':item["question_config_id"]}
      });
      return;
    }
    if ("1" == `${item["jump_type"]}`) {
      if ("-1" == `${item["level_type"]}`) {
        // level_type = -1 : 有子集，需要跳转子页面
        router.pushUrl({
          url: "pages/exam/ExamFunctionCommonPage",
          params:{'pid':item["question_config_id"]}
        });
      } else {
        // 跳转正常做题
        IconUtils.typeJumpPage(item, params);
      }
    } else if ("2" == `${item["jump_type"]}`) {
      // jump_type=2 : 自定义跳转--后台拼接路径，使用广告跳转模式
      // AdUtils.adClickJump(
      // buildContext: context,
      // urlString: "${item["redirect_rule"]["real_url"]}");
    }
  }

  static typeJumpPage(itemData: Record<string,string|number>, params: Record<string,string|number>, isSonIcon = false) {
    let type = itemData["type"] ?? 1;
    console.log(`跳转类型 = type = ${type}`);

    switch (type) {
      case 6: // 类型6：固定题目类试卷，点击进入试卷列表页（历年真题、模拟试卷）——隐藏题目筛选
        router.pushUrl({
          url: "pages/exam/ExamPaperListPage", params: {
            // tabType: `${itemData["tab"] ?? "1"}`  // tab类型：1-模拟，2-真题，3-密卷
          }
        });
        break;
      case 9: // 类型9：智能刷题
        ExamStorageUtils.restartSmartTest()
        router.pushUrl({
          url: "pages/exam/QuickTestMainPage", params: {
            "req_type": NewExamQuickType.examIntelligenceQuick,
            "new_exam_type": "smart_test"
          }
        });
        break;
      default:
        break;
    }
  }
}