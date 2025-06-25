# Developing a Simple Universal Header Navigation Bar in HarmonyOS Next

In daily page development, most pages require a header to display navigation controls and page information. Repeating this code for every page is inefficient and leads to inconsistent implementations. This guide demonstrates how to create a reusable header component.

## Step 1: Create the NavBar Component

Create a new ArkTS file with a `@Component` decorated custom component:

```
import Utils from "../../../common/utils/Utils";

@Component
export struct NavBar {
  // Component implementation will go here
}
```

## Step 2: Implement Component Properties and UI

Add properties and build the header UI:

```
import Utils from "../../../common/utils/Utils";

@Component
export struct NavBar {
  @Prop title: string = '';         // Header title text
  @Prop backImg: string = '';       // Custom back button icon path
  @Prop bgColor: string = '#FFFFFF';// Header background color
  @Prop customBack?: () => void;    // Custom back button handler
  @Prop mode: string = 'center';    // Title alignment: 'center' or 'left'

  build() {
    Row() {
      // Back button section
      Row() {
        Image(this.backImg || Utils.getImgPath('home/adult_page_back_black.png'))
          .width(Utils.getVp(48))
          .height(Utils.getVp(48))
          .objectFit(ImageFit.Cover)
      }
      .onClick(() => {
        // Use custom handler if provided, else default back navigation
        this.customBack ? this.customBack() : router.back();
      })

      // Title section
      Row() {
        Text(this.title)
          .fontColor('#191B27')
          .fontSize(Utils.getVp(33))
          .fontWeight(FontWeight.Bold)
          .textAlign(this.mode === 'center' ? TextAlign.Center : TextAlign.Start)
          .width('100%')
      }
      .margin({ left: this.mode === 'center' ? 0 : Utils.getVp(20) })
      .flexShrink(1)  // Allow shrinking to fit content
      .height('100%')
    }
    .width('100%')
    .padding({ left: Utils.getVp(32), right: Utils.getVp(32) })
    .height(Utils.getVp(88))
    .backgroundColor(this.bgColor)
  }
}
```

## Step 3: Using the Component in Parent Views

### Center-aligned Title Example:

```
import { NavBar } from './component/NavBar';

@Entry
@Component
struct ParentPage {
  build() {
    Column() {
      NavBar({ title: 'Page Title', mode: 'center' })
      // Page content here
    }
    .width('100%')
    .height('100%')
  }
}
```

### Left-aligned Title Example:

```
import { NavBar } from './component/NavBar';

@Entry
@Component
struct ParentPage {
  build() {
    Column() {
      NavBar({ title: 'Page Title', mode: 'left' })
      // Page content here
    }
    .width('100%')
    .height('100%')
  }
}
```

## Customization Options

1. **Custom Icons**: Pass `backImg` property with image path

   ```
   NavBar({ 
     title: 'Settings',
     backImg: Utils.getImgPath('icons/custom_back.png')
   })
   ```

2. **Custom Background**: Change header color

   ```
   NavBar({ 
     title: 'Profile', 
     bgColor: '#F5F5F5'
   })
   ```

3. **Custom Back Action**: Override default navigation

   ```
   NavBar({
     title: 'Checkout',
     customBack: () => { /* Custom logic */ }
   })
   ```

## Key Features

- **Responsive Design**: Adapts to different screen sizes using `Utils.getVp()`
- **Flexible Layout**: Title alignment options (center/left)
- **Customizable**: Supports custom icons, colors, and behaviors
- **Consistent UI**: Ensures uniform header appearance across application
- **Easy Integration**: Simple props-based configuration

This implementation provides a reusable, customizable header component that eliminates code duplication and ensures consistent navigation experiences throughout your HarmonyOS Next application.