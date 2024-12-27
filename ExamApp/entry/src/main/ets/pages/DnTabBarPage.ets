import { HomePage } from '../pages/home/HomePage';
import Utils from '../common/utils/Utils';
import { BreakPointType } from '../common/utils/breakpointsystem'
import { AppLinkingUtils } from '../common/utils/AppLinkingUtils';
import { AppUtil } from '../common/utils/AppUtil';
import { LogUtil } from '../common/utils/LogUtil';


@Preview
@Entry
@Component
struct DnTabBarPage {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = 'md'
  @State @Watch('onIndexChange') bottomTabIndex: number = 0;
  private controller: TabsController = new TabsController();
  @State private titles: string[] = ["首页"];
  @State tabOffImagePath: string[] = ['home/homeOffTab.png'];
  @State tabOnImagePath: string[] = ['home/homeOnTab.png'];
  aboutToAppear() {
    AppLinkingUtils.messageReceived({
      method: "enterDnTabBarPage"
    })
  }
  onPageShow(): void {
    LogUtil.info("DnTabBarPage onPageShow")
  }

  @Builder
  TabBuilder(index: number) {
    // 参考自: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/typical-layout-scenario-V5#%E9%A1%B5%E7%AD%BE%E6%A0%8F
    Stack({ alignContent: Alignment.TopStart }) {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Image(Utils.getImgPath(index == this.bottomTabIndex ? this.tabOnImagePath[index] :
        this.tabOffImagePath[index]))
          .width(Utils.getVp(61))
          .width(Utils.getVp(60))

        Text(this.titles[index])
          .fontSize(Utils.getVp(19))
          .fontColor(this.bottomTabIndex === index ? $r('app.color.mainTabSelectColor') :
          $r('app.color.mainTabNormalColor'))// .margin({ top: Utils.getVp(2) })
          .margin(new BreakPointType<Padding>({
            sm: { top: 2 },
            md: { top: 2 },
            lg: { top: 2 }
          }).getValue(this.currentBreakpoint)!)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
    }
  }

  onIndexChange() {
    this.controller.changeIndex(this.bottomTabIndex);
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.End }) {
      Tabs({
        barPosition: new BreakPointType({
          sm: BarPosition.End,
          md: BarPosition.End,
          lg: BarPosition.Start
        }).getValue(this.currentBreakpoint),
        index: 0,
        controller: this.controller
      }) {
        ForEach(this.titles, (item: string, index) => {
          TabContent() {
            if (index == 0) {
              HomePage()
            }
          }.tabBar(this.TabBuilder(index))
        })
      }
      .scrollable(false)
      .vertical(new BreakPointType({ sm: false, md: false, lg: true }).getValue(this.currentBreakpoint))
      .barWidth(new BreakPointType({ sm: '100%', md: '100%', lg: Utils.getVp(94) }).getValue(this.currentBreakpoint))
      .barHeight(new BreakPointType({
        sm: Utils.getVp(110),
        md: Utils.getVp(94),
        lg: '100%'
      }).getValue(this.currentBreakpoint))
      .onChange((index: number) => {
        this.bottomTabIndex = index;
      })
    }
    .width('100%')
    .padding({
      bottom: AppUtil.getNavigationIndicatorHeight()
    })
  }
}