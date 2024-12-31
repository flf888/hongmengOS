import { AppUtil } from "../common/utils/AppUtil";

@Component
@Preview
export struct NavigationIndicator {
  @State indicatorHeight: number = 0;
  @Prop bgColor: ResourceColor = $r('app.color.mainBgColor');

  aboutToAppear(): void {
    this.indicatorHeight = AppUtil.getNavigationIndicatorHeight();
  }

  build() {
    Row() {
    }
    .width('100%')
    .height(this.indicatorHeight)
    .backgroundColor(this.bgColor)
  }
}