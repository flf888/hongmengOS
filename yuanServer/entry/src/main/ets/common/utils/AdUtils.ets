import AdvTagList from './AdvTagList';
import { LogUtil } from './LogUtil';
import ToastUtils from './ToastUtils';
import Utils from './Utils';
import { router } from '@kit.ArkUI';

interface AdvTag {
  value: string;
  isUse: number;
}

export class AdUtils {
  private static advTagList: AdvTag[] = [
    { 'value': AdvTagList.advTagFloat, 'isUse': 1 },
    { 'value': AdvTagList.advBaiKeFloat, 'isUse': 1 },
    { 'value': AdvTagList.advTagDialog, 'isUse': 1 },
    { 'value': AdvTagList.advTagHomeBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagCourseBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagNewsDetailBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagNewsIndexBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagQuestionsBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagBrushTopicBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagRecruitBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagCollegeBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagIndexMiniBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagMyTxtBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagMyToolsBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagIndexMidaBanner, 'isUse': 1 },
    { 'value': AdvTagList.guideConcentrationTagNewsIndexBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagStudyPlanBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagFiveStarBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagStudyPlanPop, 'isUse': 1 },
    { 'value': AdvTagList.advTagNewerGiftBottomBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagCoursePreSales, 'isUse': 1 },
    { 'value': AdvTagList.advTagCoursePreSalesText, 'isUse': 1 },
    { 'value': AdvTagList.advTagCourseAfterSalesText, 'isUse': 1 },
    { 'value': AdvTagList.advTagCourseAfterSalesBtn, 'isUse': 1 },
    { 'value': AdvTagList.advTagSetmealPreSales, 'isUse': 1 },
    { 'value': AdvTagList.advTagSetmealPreSalesText, 'isUse': 1 },
    { 'value': AdvTagList.advTagSetmealAfterSalesText, 'isUse': 1 },
    { 'value': AdvTagList.advTagSetmealAfterSalesBtn, 'isUse': 1 },
    { 'value': AdvTagList.advTagQuestionPreSalesText, 'isUse': 1 },
    { 'value': AdvTagList.advTagQuestionAfterSalesText, 'isUse': 1 },
    { 'value': AdvTagList.advTagQuestionAfterSalesBtn, 'isUse': 1 },
    { 'value': AdvTagList.advTagCommonPopPreSales, 'isUse': 1 },
    { 'value': AdvTagList.advTagMineContactUs, 'isUse': 1 },
    { 'value': AdvTagList.advTagDiscussQuestion, 'isUse': 1 },
    { 'value': AdvTagList.advTagAnswerQuestion, 'isUse': 1 },
    { 'value': AdvTagList.advTagConsultteachers, 'isUse': 1 },
    { 'value': AdvTagList.hotMajorBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagambitionMiniBanner, 'isUse': 1 },
    { 'value': AdvTagList.majorTestBanner, 'isUse': 1 },
    { 'value': AdvTagList.majorTestReportText, 'isUse': 1 },
    { 'value': AdvTagList.advOpenPackage, 'isUse': 1 },
    { 'value': AdvTagList.practiceMidBanner, 'isUse': 1 },
    { 'value': AdvTagList.videoDetailsPageAD, 'isUse': 1 },
    { 'value': AdvTagList.findBanner, 'isUse': 1 },
    { 'value': AdvTagList.wecomUnlockTk, 'isUse': 1 },
    { 'value': AdvTagList.courseListBanner, 'isUse': 1 },
    { 'value': AdvTagList.courseDetailBanner, 'isUse': 1 },
    { 'value': AdvTagList.yCCourseBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagAdultKnowBanner, 'isUse': 1 },
    { 'value': AdvTagList.goodsPayAD, 'isUse': 1 },
    { 'value': AdvTagList.advTagBktckkcTopBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagBktcktkTopBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagBktcksyTopBanner, 'isUse': 1 },
    { 'value': AdvTagList.advRecruitkSLMoreAd, 'isUse': 1 },
    { 'value': AdvTagList.advRecruitkGZMoreAd, 'isUse': 1 },
    { 'value': AdvTagList.baikemidBanner, 'isUse': 1 },
    { 'value': AdvTagList.inforPackBanner, 'isUse': 1 },
    { 'value': AdvTagList.baikeTopBanner, 'isUse': 1 },
    { 'value': AdvTagList.YCInformationBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagAgentLearnBottomBanner, 'isUse': 1 },
    { 'value': AdvTagList.advTagAgentLoginPageBanner, 'isUse': 1 },
    { 'value': AdvTagList.cetthreeIndexBanner, 'isUse': 1 },
    { 'value': AdvTagList.dYWrittenCourseBanner, 'isUse': 1 },
    { 'value': AdvTagList.dYCourseDetailsBanner, 'isUse': 1 },
  ];

  static requestGetAllAdData(refreshCall?: Function) {
    let reqData = '';

    AdUtils.advTagList.forEach(element => {
      if (element.isUse == 1) {
        reqData = reqData + ',' + element.value;
      }
    });
  }

  static adClickJump(urlString: string) {

    let jumpType = 2;
    const proctolObj = Utils.parseProtoclUrl(urlString);
    LogUtil.info("adClickJump:" + JSON.stringify(proctolObj))

    if (!proctolObj.pathName) {
      ToastUtils.showToast("请配置跳转地址");
      return;
    }

    if (proctolObj.params.type) {
      jumpType = parseInt(proctolObj.params.type as string);
    }

    if (jumpType == 1) {
      // 原生
      router.pushUrl({
        url: proctolObj.pathName,
        params: proctolObj.params
      })

    } else {
      ToastUtils.showToast("暂不支持的功能")
    }
  }
}


