import type { FancyImageOptions, } from './index';
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
  .objectFit($$.objectFit)
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
        if (this.onClickEvent) {
          this.onClickEvent(event)
        }
      })
      .onComplete((event) => {
        // LogUtil.info(`onComplete: ${JSON.stringify(event)}\n${JSON.stringify(this.artUIStyleObject)}`)
        if (event) {
          if (this.artUIStyleObject) {
            // 设置原宽度
            if (!this.artUIStyleObject.width) {
              this.artUIStyleObject.width = event.width;
              // LogUtil.info("onComplete-设置原宽度:" + this.artUIStyleObject.width)
            }
          }
        }
      })
  }
}