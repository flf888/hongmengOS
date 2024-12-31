import { RichTextOption } from '../../../library/myrich/components/hprichtext';
import { MyRichText } from '../../../library/myrich/components/hprichtext/MyRichText';


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
    baseFontColor: '',

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

  getRichContent(value: string) {
    let tempValue = value;

    return tempValue;
  }

  build() {
    if (this.richTextOption.content) {
      MyRichText({
        richTextOption: this.richTextOption,
        isPreviewImg: true,
      })
    }

  }
}