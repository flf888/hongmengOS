# Implementing In-App Font Size Switching in HarmonyOS Next

The core approach for implementing dynamic font sizing uses `@Provider` and `@Consume` to share a `scaleTextStyle`variable. Font size settings are persisted and retrieved during page initialization.

## 1. Declare @Provide Annotation in Entry Page

```
@Entry
@Component
struct QuickTestMainPage { 
    @Provide scaleTextStyle: number = 1; // Current font size multiplier
}
```

## 2. Retrieve Persistent scaleTextStyle in aboutToAppear

```
import { StyleFit } from './utils/StyleFit';

@Entry
@Component
struct QuickTestMainPage { 
   @Provide scaleTextStyle: number = 1; // Current font size multiplier
  
  aboutToAppear() {
    // Retrieve persisted font size setting
    this.scaleTextStyle = StyleFit.getScaleTextStyle();
  }
}
```

## 3. StyleFit Utility Class Implementation

```
export type ScaleTextSizeType = 'base' | 'mini' | 'large';

export class StyleFit {
  private static scaleTextSize: ScaleTextSizeType = 'base'; // Default: base size

  // Initialize from persistent storage
  static init() {
    PreferencesUtil.getString("scale_text_size").then(value => {
      StyleFit.scaleTextSize = (value || "base") as ScaleTextSizeType;
    })
  }
  
  // Update font size setting
  static setScaleTextSize(value: ScaleTextSizeType) {
    StyleFit.scaleTextSize = value;
    PreferencesUtil.putSync("scale_text_size", value);
  }

  // Convert text size type to multiplier
  static getScaleTextStyle() {
    switch(StyleFit.scaleTextSize) {
      case "mini": return 0.8;
      case "large": return 1.25;
      default: return 1; // base size
    }
  }
}
```

## 4. Applying Font Size in UI Components

```
@Component
export default struct SingleSelectComponent {
   @Consume scaleTextStyle: number; // Access shared font multiplier
  
  build() {
    Text(`Sample Text`)
      .fontSize(15 * this.scaleTextStyle) // Apply dynamic sizing
      .fontWeight(FontWeight.Bold)
  }
} 
```

### Key Implementation Notes:

1. **Persistent Storage**: Font preferences are saved using `PreferencesUtil`
2. **Size Options**: Three predefined sizes (mini: 80%, base: 100%, large: 125%)
3. **Reactive Updates**: All @Consume components automatically update when scaleTextStyle changes
4. **Simple Integration**: Just multiply base font sizes by `this.scaleTextStyle`
