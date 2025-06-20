# Using and Encapsulating Rich Text with hp-richtext in HarmonyOS Next

This implementation wraps the third-party rich text component ([hp-richtext](https://ohpm.openharmony.cn/#/cn/detail/@ohasasugar%2Fhp-richtext)) to create a custom reusable component. This approach provides flexibility to add custom logic or switch to alternative rich text solutions in the future.

## Custom Rich Text Component Implementation

```
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
  };
  
  @State imgType: ImgType = 'widthLimit';

  // Update handler for property changes
  onUpdate() {
    this.richTextOption = {
      content: this.getRichContent(this.richContent),
      baseFontSize: this.fontSize * this.scaleTextStyle,
      baseFontColor: this.fontColor,
    };
  }

  // Initialize on component creation
  aboutToAppear() {
    this.onUpdate();
  }

  // Process rich content with image constraints
  getRichContent(value: string) {
    let tempValue = value;
    
    switch(this.imgType) {
      case 'widthLimit':
        tempValue = tempValue.replace(/\Hello World</p>",
  fontSize: 18,
  fontColor: "#333333",
  imgType: 'maxWidth'
})
```

### Key Features:

1. **Dynamic Styling**: Supports font size/color changes with `@Watch` decorator

2. 

   Image Constraints

   : Three image sizing modes:

   - `widthLimit`: Fixed width (160vp) with auto height
   - `heightLimit`: Fixed height (65vp) with auto width
   - `maxWidth`: Maximum width constraint (100vp)

3. **Content Processing**: Automatic HTML content transformation

4. **Scalable Text**: Integrates with app-wide text scaling

5. **Logging**: Content processing debugging with `LogUtil`

### Customization Options:

- **fontSize**: Base font size (default: 16)
- **fontColor**: Text color (default: #FF465069)
- **richContent**: HTML content to render
- **imgType**: Image sizing strategy (default: widthLimit)
- **scaleTextStyle**: App-wide text scaling factor

This implementation provides a reusable, configurable rich text component that abstracts the underlying hp-richtext library while adding custom image handling and styling capabilities.
