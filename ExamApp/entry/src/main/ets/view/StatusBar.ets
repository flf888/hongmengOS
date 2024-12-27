import { AppUtil } from "../common/utils/AppUtil";


@Component
@Preview
export struct StatusBar {
  @State statusBarHeight: number = 0;
  @Prop bgColor: ResourceColor = $r('app.color.mainBgColor');

  aboutToAppear(): void {
    this.statusBarHeight = AppUtil.getStatusBarHeight();
    
  }

  build() {
    Row() {
    }
    .width('100%')
    .height(this.statusBarHeight)
    .backgroundColor(this.bgColor)
  }
}