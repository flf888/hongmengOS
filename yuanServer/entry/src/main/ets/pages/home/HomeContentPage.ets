import router from '@ohos.router';
import { PageState } from '../../common/constants/Constants';
import IconUtils from '../../common/utils/IconUtils';
import Utils from '../../common/utils/Utils';
import IconListLayout from '../../view/IconListLayout';
import LoadingLayout from '../../view/LoadingLayout';
import KnowledgeListItemLayout from './views/KnowledgeListItemLayout';
import EmptyLayout from '../../view/EmptyLayout';
import Config from '../../http/Config';
import { PaperListLayout } from '../dynamic/component/PaperListLayout';
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';
import { LogUtil } from '../../common/utils/LogUtil';
import { UIObserver, uiObserver } from '@kit.ArkUI';

export interface KnowledgeItem {
  id: number
  name: string
  my_log_count: number
  questions_count: number
  _index: number
}


export interface PaperItem {
  id: number;
  name: string;
  score: number;
  _index: number
}

@Component
export default struct HomeContentPage {
  index: number = 0;
  @Watch('changeCategory') @Link currentIndex: number;
  @State private gridMargin: number = 24
  @State pageState: number = PageState.Loading;

  @State iconDataList: Record<string, string| number>[] = [
    {
      'img': Utils.getImgPath(`exam/quick_icon_${Config.yuan_service_template}.png`),
      'name': Config.yuan_service_template == 3 ? '免费刷题' : '智能刷题',
      'type': 9,
      "jump_type": 1,
      "level_type": 0,
    }
  ];
  @State knowledgeDataList: KnowledgeItem[] = [];

  @State paper_list: PaperItem[] = []; // 试卷列表

  listener: (info: uiObserver.RouterPageInfo) => void = (info: uiObserver.RouterPageInfo) => {
    if (this.currentIndex !== this.index) {
      return;
    }
    let routerInfo: uiObserver.RouterPageInfo | undefined = this.queryRouterPageInfo();
    if (info.pageId == routerInfo?.pageId) {
      if (info.state == uiObserver.RouterPageState.ON_PAGE_SHOW) {
        LogUtil.info(`run onPageShow HomeContentPage`);
        this.getHomePageData();
      }
    }
  }


  aboutToAppear() {
    this.changeCategory();
    let uiObserver: UIObserver = this.getUIContext().getUIObserver();
    uiObserver.on('routerPageUpdate', this.listener);
  }

  aboutToDisappear(): void {
  }

  changeCategory() {
    if (this.currentIndex !== this.index) {
      return;
    }
    this.getHomePageData();
    this.getPracticeTestList();
  }

  getHomePageData() {
    LogUtil.info("getHomePageData")
    this.knowledgeDataList = JsonDataUtils.auxpoliceIndex(this.currentIndex)
    if((Config.yuan_service_template == 2 || Config.yuan_service_template == 3) && this.knowledgeDataList.length) {
      //新增
      const index = this.iconDataList.findIndex(item => item['type'] == 'knowledge')
      if(index == -1) {
        this.iconDataList.push({
          'img': Utils.getImgPath(`exam/knowledge_icon_${Config.yuan_service_template}.png`),
          'name': '知识点练习',
          'type': 'knowledge'
        });
      }
    }
    this.pageState = PageState.Success
  }

  //我的试卷列表
  getPracticeTestList() {
    this.paper_list = JsonDataUtils.my_paper_list(this.currentIndex);
  }

  build() {
    Column() {
      if (this.pageState == PageState.Loading) {
        LoadingLayout();
      } else {
        this.pageUIBuilder();
      }
    }

  }

  @Builder
  pageUIBuilder() {
    Scroll() {
      Column() {
        this.iconEntryUI()
        // 工程模式
        if(Config.yuan_service_template == 1) {
          // 知识点
          if(this.knowledgeDataList.length) {
            this.knowledgeBuilder();
          }
        } else if(Config.yuan_service_template == 3 || Config.yuan_service_template == 2) {
          // 试卷列表
          if(this.paper_list.length) {
            PaperListLayout({paper_list: this.paper_list, need_scroll: false, subject_index: this.currentIndex});
          }
        }
      }
      .width('100%')
      .backgroundColor($r('app.color.pageBg'))
    }
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Off)
    .align(Alignment.TopStart)
  }

  @Builder
  knowledgeBuilder() {
    this.knowledgeUI()
    // 来自: https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/typical-layout-scenario-V5#%E9%87%8D%E5%A4%8D%E5%B8%83%E5%B1%80
    GridRow({
      gutter: Utils.getVp(23)
    }) {
      ForEach(this.knowledgeDataList, (item: KnowledgeItem, tempIndex) => {
        GridCol({ span: { sm: 12, md: 6, lg: 4 } }) {
          KnowledgeListItemLayout({
            knowledgeInfo: item,
            level: 0,
            uiWidth: Utils.getVp(720 - 27 - 27),
            uiHeight: Utils.getVp(150),
            subject_index: this.currentIndex
          });
        }
      })
    }
    .margin({ left: this.gridMargin, right: this.gridMargin, top: Utils.getVp(23) })
    .onBreakpointChange((breakpoint: string) => {
      // this.currentBreakpoint = breakpoint;
      if (breakpoint == 'lg') {
        this.gridMargin = 32
      } else if (breakpoint == 'md') {
        this.gridMargin = 32
      } else {
        this.gridMargin = 24
      }
    })
    Column().height(150)
  }

  @Builder
  iconEntryUI() {
    IconListLayout({
      iconEnterList: this.iconDataList,
      marginTop: 23,
      callBack: (item: Record<string, string | number>, index: number) => {
        console.info('点击的item:', JSON.stringify(item));
        if(item.type === 'knowledge') {
          console.info('准备跳转到知识点页面');
          console.info('knowledgeDataList:', JSON.stringify(this.knowledgeDataList));
          router.pushUrl({
            url: 'pages/knowledge/KnowledgePage',
            params: {
              subject_index: this.currentIndex
            }
          }).then(() => {
            console.info('跳转成功');
          }).catch((err: Error) => {
            console.error('跳转失败:', err.message);
          });
        } else {
          IconUtils.iconJump(item, {});
        }
      },

    })
  }

  @Builder
  iconEntryItemUI(itemInfo: Record<string, string>) {
    Column() {
      Image(itemInfo['img'])
        .width(Utils.getVp(75))
        .height(Utils.getVp(75))
        .objectFit(ImageFit.Cover)
        .margin({ bottom: Utils.getVp(20) })

      Text(itemInfo['name'])
        .fontSize(Utils.getVp(24))
        .fontColor('#FF465069')
    }
  }



  ///知识内容
  @Builder
  knowledgeUI() {
    Column() {
      Text('知识点练习')
        .fontColor($r('app.color.blodTextColor'))
        .fontSize(Utils.getVp(32))
        .fontWeight(700)
        .margin({
          left: Utils.getVp(32),
          right: Utils.getVp(32),
          bottom: Utils.getVp(10),
          top: Utils.getVp(46)
        })

      Column()
        .width(Utils.getVp(720 - 64))
        .margin({ left: Utils.getVp(32), right: Utils.getVp(32) })
    }
    .alignItems(HorizontalAlign.Start)
  }


}