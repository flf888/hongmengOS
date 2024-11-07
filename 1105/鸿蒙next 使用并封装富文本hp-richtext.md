

# 鸿蒙 next 使用并封装富文本hp-richtext

使用鸿蒙第三方富文本([https://ohpm.openharmony.cn/#/cn/detail/@ohasasugar%2Fhp-richtext](https://ohpm.openharmony.cn/#/cn/detail/@ohasasugar%2Fhp-richtext)) , 并再将其包一层实现自己的富文本组件，这样的好处是以后可以自己再里面添加一下逻辑，或者以后可以更换成其他的富文本组件。



```JavaScript
import { HPRichText, RichTextOption } from '@ohasasugar/hp-richtext';
import { LogUtil } from '../../../common/utils/LogUtil';


type ImgType = 'heightLimit' | 'widthLimit' | 'maxWidth'

@Component
export struct QuesRichText {
  @Prop @Watch('onUpdate') fontSize: number = 16;
  @Prop @Watch('onUpdate') fontColor: string = "#FF465069";
  @Prop @Watch('onUpdate') richContent: string = '';
  @Consume @Watch('onUpdate') scaleTextStyle: number;
  @State richTextOption: RichTextOption = {
    content: ``,
    baseFontSize: 0,
    baseFontColor: ''
  }; // 富文本对象
  @State realContent: string = '';
  @State imgType: ImgType = 'widthLimit';

  onUpdate() {
    this.richTextOption =
      {
        content: this.getRichContent(this.richContent),
        baseFontSize: this.fontSize * this.scaleTextStyle,
        baseFontColor: this.fontColor,
      };
  }

  aboutToAppear() {
    this.onUpdate()
  }

  // aboutToAppear(): void {
  //
  //   this.realContent = this.richTextOption.content;
  //   if (this.imgType == 'widthLimit') {
  //     this.richTextOption.content =
  //       this.richTextOption.content.replace(/\<img/g, '<img style="width: 160vp;height: auto;"')
  //   } else if (this.imgType == 'heightLimit') {
  //     this.richTextOption.content =
  //       this.richTextOption.content.replace(/\<img/g, '<img style="width: auto;height: 65vp;"')
  //   } else if (this.imgType == 'maxWidth') {
  //     // 看了HPRichText的源码-不支持max-width属性, 但是可以用 constraintSize 实现
  //     this.richTextOption.content =
  //       this.richTextOption.content.replace(/\<img/g, '<img style="max-width: 100vp"')
  //   }
  // }

  getRichContent(value: string) {
    let tempValue = value;
    if (this.imgType == 'widthLimit') {
      tempValue =
        tempValue.replace(/\<img/g, '<img style="width: 160vp;height: auto;"')
    } else if (this.imgType == 'heightLimit') {
      tempValue =
        tempValue.replace(/\<img/g, '<img style="width: auto;height: 65vp;"')
    } else if (this.imgType == 'maxWidth') {
      // 看了HPRichText的源码-不支持max-width属性, 但是可以用 constraintSize 实现
      tempValue =
        tempValue.replace(/\<img/g, '<img style="max-width: 100vp"')
    }

    LogUtil.info("tempValue", tempValue)

    return tempValue;
  }

  build() {
    if (this.richTextOption.content) {
      HPRichText({
        richTextOption: this.richTextOption,
      })

    }

  }
}
```



使用:

```JavaScript
QuesRichText({
         
          richContent: "<p>hell world</p>",
        })
```



