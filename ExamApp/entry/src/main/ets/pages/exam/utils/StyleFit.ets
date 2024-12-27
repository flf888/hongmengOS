import { PreferencesUtil } from "../../../common/utils/Preferencesutil";

export type ScaleTextSizeType = 'base' | 'mini' | 'large';

export class StyleFit {
  private static questionMakingMode: boolean = true; //true 做题模式 false 背题模式
  private static lightMode: boolean = true; // true 日间模式 false 夜间模式
  private static scaleTextSize: ScaleTextSizeType = 'base'; // base标准 mini小字体 large大字体

  static init() {
    PreferencesUtil.getString("question_making_mode").then(value => {
      if (value == "1" || value == "") {
        ///做题模式
        StyleFit.questionMakingMode = true;
      } else {
        // 背题模式
        StyleFit.questionMakingMode = false;
      }
    })

    PreferencesUtil.getString("light_mode").then(value => {
      if (value == "1" || value == "") {
        /// 日间模式
        StyleFit.lightMode = true;
      } else {
        // 夜间模式
        StyleFit.lightMode = false;
      }
    })

    PreferencesUtil.getString("scale_text_size").then(value => {
      if (value == "") {
        StyleFit.scaleTextSize = "base";
      } else {
        StyleFit.scaleTextSize = value as ScaleTextSizeType;
      }
    })
  }


  static setQuestionMakingMode(value: boolean) {
    StyleFit.questionMakingMode = value;
    PreferencesUtil.putSync("question_making_mode", value ? "1" : "0");
  }

  static getQuestionMakingMode() {
    return StyleFit.questionMakingMode;
  }

  static setLightMode(value: boolean) {
    StyleFit.lightMode = value;
    PreferencesUtil.putSync("light_mode", value ? "1" : "0");
  }

  static getLightMode() {
    return StyleFit.lightMode;
  }

  static setScaleTextSize(value: ScaleTextSizeType) {
    StyleFit.scaleTextSize = value;
    PreferencesUtil.putSync("scale_text_size", value);
  }

  static getScaleTextSize() {
    return StyleFit.scaleTextSize;
  }

  // 获取当前字体大小样式
  static getScaleTextStyle() {
    let style = 1;
    if (StyleFit.scaleTextSize == "mini") {
      style = 0.8;
    } else if (StyleFit.scaleTextSize == "base") {
      style = 1;
    } else if (StyleFit.scaleTextSize == "large") {
      style = 1.25;
    }
    return style;
  }
}