# HarmonyOS Next: Maintaining and Extending a Custom Rich Text Component

Our business currently uses HarmonyOS Next’s built-in `HPRichText` component. However, we encountered limitations such as **missing `max-width`/`max-height` support** and **text rendering issues after upgrading from v2 to v3**. To address these challenges, we decided to fork and customize the `HPRichText` component.

This customization is based on the **v2.2.4 release** of the community-maintained [HPRichText](https://github.com/asasugar/HPRichText/releases/tag/v2.2.4).

------

## Key Enhancements

### 1. Support for `maxWidth`, `maxHeight`, `minWidth`, `minHeight` Attributes

#### 1-1. Add Constraint Sizing to `fancyImage`

```
.constraintSize({
  maxWidth: $$.maxWidth,
  maxHeight: $$.maxHeight,
  minWidth: $$.minWidth,
  minHeight: $$.minHeight,
})
```

#### 1-2. Extend `ShapeAttr` Interface

```
export interface ShapeAttr {
  // Existing properties...
  maxWidth?: string | number;
  maxHeight?: string | number;
  minWidth?: string | number;
  minHeight?: string | number;
}
```

#### 1-3. Update HTML Parser

```
this.assignArtUIStyleObject(node, {
  // Existing properties...
  maxWidth: node?.artUIStyleObject?.maxWidth,
  maxHeight: node?.artUIStyleObject?.maxHeight,
  minWidth: node?.artUIStyleObject?.minWidth,
  minHeight: node?.artUIStyleObject?.minHeight,
});
```

------

### 2. Auto-Set Original Width for Images on Load Completion

#### 2-1. Rename `HPRichText` to `MyRichText`

#### 2-2. Extract `Image` Logic into `ImageNode` Component

```
import type { FancyImageOptions } from './index';
import type { ArtStyleObject, Attr } from '../../common/types/htmlParser';
import { LogUtil } from '../../../../common/utils/LogUtil';

@Extend(Image)
function fancyImage($$: FancyImageOptions = {}, attrs: Attr = {}) {
  .width($$.width)
  .height($$.height)
  .constraintSize({
    maxWidth: $$.maxWidth,
    maxHeight: $$.maxHeight,
    minWidth: $$.minWidth,
    minHeight: $$.minHeight,
  })
  .margin($$.margin)
  .padding($$.padding)
  .alt(attrs.alt)
  .opacity($$.opacity)
  .objectFit($$.objectFit);
}

@Component
export struct ImageNode {
  @Prop src: string;
  @Prop artUIStyleObject: ArtStyleObject;
  @Prop attr: Attr;
  onClickEvent?: (event: ClickEvent) => void;

  build() {
    Image(this.src)
      .fancyImage(this.artUIStyleObject, this.attr)
      .onClick(event => {
        if (this.onClickEvent) this.onClickEvent(event);
      })
      .onComplete(event => {
        if (event && this.artUIStyleObject) {
          // Auto-set original width if not defined
          if (!this.artUIStyleObject.width) {
            this.artUIStyleObject.width = event.width;
            LogUtil.info("Auto-set original width:", this.artUIStyleObject.width);
          }
        }
      });
  }
}
```

------

## Key Fixes and Improvements

1. **Compatibility**: Resolved text rendering regressions introduced in HPRichText v3.
2. **Flexibility**: Added explicit sizing constraints for images and text containers.
3. **Performance**: Optimized image loading by preserving original dimensions only when needed.
