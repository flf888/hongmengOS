import router from '@ohos.router';
import { font } from '@kit.ArkUI';
import LoadingLayout from '../view/LoadingLayout';

@Entry
@Component
struct InitDataPage {
  aboutToAppear(): void {
    console.log('run aboutToAppear InitDataPage')

    font.registerFont({
      familyName: 'Icomoon',
      familySrc: '/common/fonts/icomoon.ttf'
    })
    font.registerFont({
      familyName: 'Icomoon2',
      familySrc: '/common/fonts/icomoon2.ttf'
    })

    this.getCourseStatus(() => {
      this.initAppData(() => {
        this.jumpToPage(() => {
          router.replaceUrl({
            url: 'pages/DnTabBarPage'
          })
        })
      });
    });
  }

  //第一步：获取课程配置
  getCourseStatus(callBack?: Function) {

    callBack?.()
  }

  //初始化APP数据
  async initAppData(callBack: Function) {
    //首先判断是不是有本地缓存token
    callBack()
  }

  jumpToPage(callBack?: Function) {
    callBack?.()
  }

  getMeData(callBack: Function) {
    callBack();
  }
  build() {
    Row() {
      Column() {
        LoadingLayout();
      }
      .width('100%')
    }
    .height('100%')
  }
}