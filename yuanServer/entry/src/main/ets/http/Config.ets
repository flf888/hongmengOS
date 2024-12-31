import appTypeJson from "./appType.json"

type BuildModeType = 'debug' | 'release'

class Config {
  static online = true;
  static device = 'exam221154545dfdf5d454fd';
  //业务数据API请求域名
  static api_hosts = Config.online ? '1' : '1';
  //用户中心接口域名
  static hosts_user = Config.online ? '2' : '2';
  // h5地址
  static h5UrlConfig = '1/#/';
  static version = 'v1.7.3';
  static app_type = appTypeJson.appType; // exam-辅警协警 lawenforce-执法资格 senioriup-高职单招 bookingagent-演出经纪人
  static app_name = appTypeJson.appName;
  static appId = appTypeJson.appId;
  static buildMode: BuildModeType = appTypeJson.buildMode as BuildModeType; // debug-开发调试  release-打包
  static platform = 'yuanservice';
  //省份id;
  static province_id = '';
  static appkey = Config.online ? "11" : "22";
  static channel = 'default';
  //小程序的短标题;
  static homeTopBanner = 'MiniAppIndexBanner';
  //首页TopBannerTag标识;后期不用修改;
  static dynamicTopBanner = 'MiniAppNewsIndexBanner';
  //动态首页TopBannerTag标识;后期不用修改;
  static searchBanner = 'MiniAppQuestionsBanner';
  //智能搜索页BottomBannerTag标识;后期不用修改;
  static courseBanner = 'MiniAppCourseBanner';
  //用户协议Tag标识;
  static userProtocolTag = `${Config.app_type}UserRule`;
  //隐私政策Tag标识;
  static privacyProtocolTag = `${Config.app_type}PrivateRule`;
  // 畅学卡权益对比
  static BaseCardRightsCompared = "equityContrast";
  static protocol = [//说明Tag标识;后期不用修改;
    'SearchHelp', //搜题卡规则说明的请求tagName;
    'SearchRule',//搜题小技巧的请求tagName;
  ];
  static share = [//分享的配置;
    'bookingagentInviteFriend', //分享邀请朋友
    'bookingagentQuestionDetail', //题目详情分享
    'bookingagentNewsDetail',//动态详情分享
  ];
  static shareSwitch = 0;
  //分享是否获取接口数据;
  static courseView = 0;
  //课程之外的模块是否显示课程相关模块;
  ///测试数据
  static cateId = '5';
  static subjectId = '6';
  // static goodAppType = 'exam';
  static isCourseData = false;
  //是否配置课程数据 默认配置
  static isDynamicData = false;
  //是否配置动态数据 默认配置
  static isHasAliPay = true;
  //是否配置支付宝支付
  static isSimplifiedVersion = true;
  //阿里OSS域名 ， 线上图片域名，测试域名为 http://test.xcximage.wet35.com/mini_program/questionsMakeUniapp/
  static aliossHost = Config.online ? 'https://img2.meite.com/xcximage/hm_yuan/harmonyOsYuanServeExam/' :
    'http://test.xcximage.wet35.com/hm_yuan/harmonyOsYuanServeExam/';
  // 元服务模板 1 默认模板，知识点练习在首页 2 首页展示资讯列表 3 首页展示试卷列表  project_template
  // static yuan_service_template = appTypeJson.yuan_service_template ?? 1;
  static yuan_service_template = 1;
}

export default Config;