# Implementing In-App Font Size Switching in HarmonyOS Next

===============================================================================================================================================================================================================================================
In HarmonyOS Next, font size switching can be managed both at the system level and within individual applications. For system-wide adjustments, users can navigate to Settings > Display & Brightness and then find the option to change the text size. Additionally, Quick Settings provides a convenient tile for quickly adjusting font size. For in-app font size adjustments, developers can implement dynamic font sizing using mechanisms like @Provider and @Consume to share font size preferences. 
Here's a more detailed breakdown:
System-Level Font Size Adjustment:
Access Settings: Open the Settings application on your HarmonyOS Next device. 
Navigate to Display: Find and tap on "Display & Brightness" (or similar wording). 
Change Text Size: Locate the option for adjusting text size or font size. This might be labeled "Text Size," "Font Size," or similar. 
Use the Slider: A slider or similar control will allow you to increase or decrease the font size. 
Quick Settings Tile: If you've previously adjusted font size in Settings, a "Font size" tile will be automatically added to your Quick Settings for easy access. 
In-App Font Size Adjustment:
1. Dynamic Font Sizing:
Developers can use HarmonyOS Next's capabilities to make apps adaptable to different font sizes.
2. @Provider and @Consume:
The @Provider and @Consume decorators enable sharing font size preferences across different parts of an application.
3. Example:
A code snippet from a developer resource demonstrates how to get font size preferences and update the font size of a component. 
Benefits of Dynamic Font Sizing:
Accessibility: Allows users with visual impairments to customize the text size for comfortable reading.
User Experience: Provides a more personalized and adaptable experience for all users.
Adaptability: Apps can dynamically adjust their layouts to accommodate different font sizes without breaking the UI.


The core approach for implementing dynamic font sizing uses `@Provider` and `@Consume` to share a `scaleTextStyle`variable. Font size settings are persisted and retrieved during page initialization.
===============================================================================================================================================================================================================================================



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
