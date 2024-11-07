# 鸿蒙 next 实现应用内字体大小切换

实现暗黑模式的大致思路是利用@Provider 与 @Consume 共享一个 scaleTextStyle 变量，在页面创建时读取持久化的scaleTextStyle，来实现字体大小切换。



## 1.在 Entry 页面使用 @Provide 注解 scaleTextStyle



```JavaScript
@Entry
@Component
struct QuickTestMainPage { 
    @Provide scaleTextStyle: number = 1; // 当前字体大小样式
}
```



## 2.在aboutToAppear 中读取持久化变量 scaleTextStyle

```JavaScript
import { StyleFit } from './utils/StyleFit';

@Entry
@Component
struct QuickTestMainPage { 
   @Provide scaleTextStyle: number = 1; // 当前字体大小样式
  
  aboutToAppear() {
         this.scaleTextStyle = StyleFit.getScaleTextStyle();
  }
}
```





```JavaScript

export type ScaleTextSizeType = 'base' | 'mini' | 'large';
export class StyleFit {
  private static scaleTextSize: ScaleTextSizeType = 'base'; // base标准 mini小字体 large大字体

  static init() {
     PreferencesUtil.getString("scale_text_size").then(value => {
      if (value == "") {
        StyleFit.scaleTextSize = "base";
      } else {
        StyleFit.scaleTextSize = value as ScaleTextSizeType;
      }
    })
  }
  
 static setScaleTextSize(value: ScaleTextSizeType) {
    StyleFit.scaleTextSize = value;
    PreferencesUtil.putSync("scale_text_size", value);
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
```





## 3.在需要字体大小 ui 的地方.

使用代码: `.fontSize(15 * this.scaleTextStyle)`

```JavaScript


@Component
export default struct SingleSelectComponent {
   @Consume scaleTextStyle: number;
  
  build() {
  Text(`aaaaaaaaa`)
            .fontSize(15 * this.scaleTextStyle)
            .fontWeight(FontWeight.Bold)
            
  
  }
} 
```

