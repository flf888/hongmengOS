import measure from '@ohos.measure'
import HomeContentPage from './HomeContentPage';
import Utils from '../../common/utils/Utils';
import Config from '../../http/Config';
import IconListLayout from '../../view/IconListLayout';
import IconUtils from '../../common/utils/IconUtils';
import { StatusBar } from '../../view/StatusBar';
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';
import { bundleManager } from '@kit.AbilityKit';
import appJson from  '../../http/appType.json'

export  interface SubjectItem {
  "id": number,
  "name": string,
}



@Entry
@Component
@Preview
export struct HomePage {
  @State message: string = '首页'
  @State subDataList: SubjectItem[] = []; // 考试分类列表
  @State currentIndex: number = 0;
  @State iconDataList: Record<string, string| number>[] = [
    {
      'img': Utils.getImgPath(`exam/quick_icon_${Config.yuan_service_template}.png`),
      'name': Config.yuan_service_template == 3 ? '免费刷题' : '智能刷题',
      'type': 9,
      // "question_config_id": 403,
      "jump_type": 1,
      "level_type": 0,
    }
  ];
  @State appName: string = '';

  aboutToAppear() {
    try {
      this.appName = appJson.appName || '';
    } catch (err) {
    }
    this.subDataList = JsonDataUtils.hmMetaSubjects();
  }

  build() {
    Column() {
      StatusBar()
      this.topNavUIBuild()
      this.pageUIBuilder()
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.pageBg'))
  }

  @Builder
  iconEntryUI() {
    IconListLayout({
      iconEnterList: this.iconDataList,
      marginTop: 23,
      callBack: (item: Record<string, string | number>, index: number) => {
        console.info('点击的item:', JSON.stringify(item));
        IconUtils.iconJump(item, {});
      },
    })
  }
  @Builder
  pageUIBuilder() {
    Column() {
      Stack() {
        if (this.subDataList != undefined && this.subDataList.length > 0) {
          Tabs() {
            ForEach(this.subDataList, (item: SubjectItem, tempIndex) => {
              TabContent() {
                Column() {
                  HomeContentPage({ currentIndex: this.currentIndex, index: tempIndex });
                }
              }
              .tabBar(this.TabBuilder(tempIndex))
            })
          }
          // 科目是否显示
          .barHeight(this.subDataList != undefined && this.subDataList.length > 1 ? Utils.getVp(86) : 0)
          .barMode(this.subDataList.length > 2 ? BarMode.Scrollable : BarMode.Fixed)
          .barWidth('100%')
          .onContentWillChange((currentIndex: number, comingIndex: number) => {
            // 自定义Tabs页面切换拦截事件能力，新页面即将显示时触发该回调。
            return true;
          })
          .onChange((index: number) => {
            this.currentIndex = index;
          })
          .vertical(false)
        }

      }
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  topNavUIBuild() {
    Row() {
      Row() {
        Text(this.appName) {
        }.fontSize(Utils.getVp(35)).fontWeight(700).fontColor($r('app.color.blodTextColor'))
        .onClick(() => {
        })

      }

    }
    .height(Utils.getVp(96))
    .width('100%')
    .margin({ top: Utils.getVp(5) })
    .padding({ left: Utils.getVp(31), right: Utils.getVp(31) })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  TabBuilder(index: number) {
    // 科目是否显示
    if(this.subDataList != undefined && this.subDataList.length > 1) {
      Stack({ alignContent: Alignment.Bottom }) {
        Text(this.subDataList[index].name)
          .height(Utils.getVp(86))
          .textAlign(TextAlign.Center)
          .padding({ left: Utils.getVp(10), right: Utils.getVp(10) })
          .fontSize(this.currentIndex === index ? Utils.getVp(31) : Utils.getVp(27))
          .fontWeight(this.currentIndex === index ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.currentIndex === index ? $r('app.color.blodTextColor') : $r('app.color.subTextColor'))

        if (this.currentIndex === index) {
          Row()
            .height(4)
            .backgroundColor(Color.Transparent)
            .width(Utils.getVp(measure.measureText({
              textContent: this.subDataList[index].name,
              fontSize: Utils.getVp(20)
            }) - 2))
            .borderRadius(Utils.getVp(4))
            .margin({ bottom: Utils.getVp(3) })
            .linearGradient({
              direction: GradientDirection.Left, // 渐变方向
              repeating: false, // 渐变颜色是否重复
              colors: [[$r('app.color.shallowMainColor'), 0], [$r('app.color.mainColor'), 1]] // 数组末尾元素占比小于1时满足重复着色效果
            })
        }
      }
      .height(Utils.getVp(86))
      .padding({
        right: index == this.subDataList.length - 1 ? Utils.getVp(50) : 0,
      })
    }
  }
}