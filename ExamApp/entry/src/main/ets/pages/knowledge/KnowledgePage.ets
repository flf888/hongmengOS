import Utils from '../../common/utils/Utils';
import KnowledgeListItemLayout from '../home/views/KnowledgeListItemLayout';
import { KnowledgeItem } from '../home/HomeContentPage';
import router from '@ohos.router';
import TopNavBar from '../../view/TopNavBar'
import { JsonDataUtils } from '../../common/utils/JsonDataUtils';

interface KnowledgePageParams {
  subject_index: number
}

@Entry
@Component
export default struct KnowledgePage {
  @State currentBreakpoint: string = 'md';
  @State gridMargin: number = 24;
  @State login_loading: boolean = false;
  @State subject_index: number = 0;
  @State knowledgeDataList: KnowledgeItem[] = [];

  aboutToAppear() {
    const params = router.getParams() as KnowledgePageParams;
    this.subject_index = params.subject_index;

    this.getData()
  }

  onPageShow(): void {
    this.getData()
  }

  getData() {
    this.knowledgeDataList = JsonDataUtils.auxpoliceIndex(this.subject_index)
  }

  build() {
    Column() {
      // 使用 TopNavBar 替换原来的标题栏
      TopNavBar({ navTitle: '知识点练习' })

      // 添加滚动容器
      Scroll() {
        Column() {

          // 知识点列表
          GridRow({
            gutter: Utils.getVp(23)
          }) {
            ForEach(this.knowledgeDataList, (item: KnowledgeItem) => {
              GridCol({ span: { sm: 12, md: 6, lg: 4 } }) {
                KnowledgeListItemLayout({
                  knowledgeInfo: item,
                  level: 0,
                  uiWidth: Utils.getVp(720 - 27 - 27),
                  uiHeight: Utils.getVp(150),
                  subject_index: this.subject_index
                });
              }
            })
          }
          .margin({
            left: this.gridMargin,
            right: this.gridMargin,
            top: Utils.getVp(23)
          })
          .onBreakpointChange((breakpoint: string) => {
            this.currentBreakpoint = breakpoint;
            this.gridMargin = breakpoint === 'lg' || breakpoint === 'md' ? 32 : 24;
          })

          // 添加底部空白，确保内容可以完全滚动
          Column().height(150)
        }
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.pageBg'))
  }
} 

