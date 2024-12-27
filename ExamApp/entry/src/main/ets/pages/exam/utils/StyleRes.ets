import Utils from "../../../common/utils/Utils";

export enum StyleColor {
  backgroundColor, // 背景色
  pageColor, // 页面颜色
  dividerColor, // 下划线颜色
  cardBgColor, // 悬浮卡片背景色
  cardBgActiveColor, // 悬浮卡片背景色激活态颜色
  textNormalColor, // 普通文字颜色
  textBoldColor, // 加粗文字颜色
  blackTextActiveColor, // 日间黑色激活文本颜色
  texSubColor, // 次文字颜色
  shadowColor, // 阴影颜色
  materailTabBgColor, // 材料题tab背景色
  materailTabActiveBgColor, // 材料题tab激活背景色
  materailTabColor, // 材料题tab文本色
  toBeActivatedTextColor, // 待激活文本颜色

}

export enum StyleImage {
  examMiddleTopBg
}


export class StyleRes {
  static getStyleColor(styleColor: StyleColor, lightMode: boolean) {
    let color = "#ffffffff";

    switch (styleColor) {
      case StyleColor.backgroundColor:
        color = lightMode ? "#ffffffff" : "#FF191B27";
        break;
      case StyleColor.pageColor:
        color = lightMode ? "#fff7f8fb" : "#FF191B27";
        break;
      case StyleColor.dividerColor:
        color = lightMode ? "#fff7f8fb" : "##66030303";
        break;
      case StyleColor.cardBgColor:
        color = lightMode ? "#ffffffff" : "#FF292B38";
        break;
      case StyleColor.cardBgActiveColor:
        color = lightMode ? "#FFE0EFFF" : "#FF162741";
        break;
      case StyleColor.textNormalColor:
        color = lightMode ? "#FF465069" : "#FF999FB5";
        break;
      case StyleColor.textBoldColor:
        color = lightMode ? "#FF191B27" : "#FF999FB5";
        break;
      case StyleColor.blackTextActiveColor:
        color = lightMode ? "#FF191B27" : "#FF0080FF";
        break;
      case StyleColor.texSubColor:
        color = lightMode ? "#FF465069" : "#FF999FB5";
        break;
      case StyleColor.shadowColor:
        color = lightMode ? "#14000000" : "#FF222634";
        break;
      case StyleColor.materailTabBgColor:
        color = lightMode ? "#FFF3F4F6" : "#FF292B38";
        break;
      case StyleColor.materailTabActiveBgColor:
        color = lightMode ? "#FFE0F0FF" : "#1F0080FF";
        break;
      case StyleColor.materailTabColor:
        color = lightMode ? "#FF465069" : "#FF999FB5";
        break;
      case StyleColor.toBeActivatedTextColor:
        color = lightMode ? "#FFBEC2D1" : "#FF465069";
        break;


    }

    return color;
  }

  static getStyleImage(styleImage: StyleImage, lightMode: boolean): string {
    let imagePath = "";

    switch (styleImage) {
      case StyleImage.examMiddleTopBg:
        imagePath = lightMode ? "exam/exam_middle_top_bg.png" : "exam/exam_middle_top_dark_bg.png";
        break;
    }

    return Utils.getImgPath(imagePath);
  }
}