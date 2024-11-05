# 鸿蒙 next 实现应用内的暗黑模式切换



实现暗黑模式的大致思路是利用@Provider 与 @Consume 共享一个 lightMode 变量，在页面创建时读取持久化的lightMode，来实现暗黑模式。



## 1.在 Entry 页面使用 @Provide 注解 lightMode



```JavaScript
@Entry
@Component
struct QuickTestMainPage { 
   @Provide lightMode: boolean = true; //true 日间模式 false 夜间模式
}
```



## 2.在aboutToAppear 中读取持久化变量 lightMode

```JavaScript
import { StyleFit } from './utils/StyleFit';

@Entry
@Component
struct QuickTestMainPage { 
   @Provide lightMode: boolean = true; //true 日间模式 false 夜间模式
  
  aboutToAppear() {
       this.lightMode = StyleFit.getLightMode();
  }
}
```



```JavaScript
export class StyleFit {
  private static lightMode: boolean = true; // true 日间模式 false 夜间模式

  static init() {
     PreferencesUtil.getString("light_mode").then(value => {
      if (value == "1" || value == "") {
        /// 日间模式
        StyleFit.lightMode = true;
      } else {
        // 夜间模式
        StyleFit.lightMode = false;
      }
    })
  }
  
  static setLightMode(value: boolean) {
    StyleFit.lightMode = value;
    PreferencesUtil.putSync("light_mode", value ? "1" : "0");
  }

  static getLightMode() {
    return StyleFit.lightMode;
  }
}
```



## 3.封装工具类StyleRes来统一颜色 token 管理。

```JavaScript
export enum StyleColor {
  backgroundColor, // 背景色
  pageColor, // 页面颜色
  cardBgColor, // 悬浮卡片背景色
  cardBgActiveColor, // 悬浮卡片背景色激活态颜色
  textNormalColor, // 普通文字颜色
  textBoldColor, // 加粗文字颜色
  blackTextActiveColor, // 日间黑色激活文本颜色
  texSubColor, // 次文字颜色
  shadowColor, // 阴影颜色

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

    }

    return color;
  }
}
```





## 4.在需要暗黑模式 ui 的地方.

使用代码: `StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)`

```JavaScript
import { StyleColor, StyleRes } from './utils/StyleRes';

@Component
struct BotoomTool {
    @Consume lightMode: boolean;
  
    build() {
      Column() {
      }
      .backgroundColor(StyleRes.getStyleColor(StyleColor.backgroundColor, this.lightMode))
    }
}
```

