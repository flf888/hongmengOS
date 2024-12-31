import router from '@ohos.router';
import LoadingLayout from '../view/LoadingLayout';
import { AppUtil } from '../common/utils/AppUtil';


@Entry
@Component
struct Splash {
  @State message: string = 'Hello World';
  @State showAdv: boolean = false;
  @State countdown: number = 2;
  private timer: number = -1;
  @State showDialog: boolean = false;

  aboutToAppear() {
    console.log('run Splash')

    AppUtil.setStatusBar()
      this.getInitData(() => {
        this.jumpToPage();
      });
  }

  //第一步：走初始化接口
  getInitData(callBack?: Function) {
    console.log('run getInitData')
    callBack?.()
  }

  aboutToDisappear() {
    this.clearTiming();
  }

  startTiming() {
    this.timer = setInterval(() => {
      this.countdown--;
      if (this.countdown === 0) {
        this.clearTiming();
        this.jumpToPage();
      }
    }, 1000);
  }

  clearTiming() {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  jumpToPage() {
    this.clearTiming();
    router.replaceUrl({
      url: 'pages/InitDataPage'
    })

  }

  build() {
    Column() {
      LoadingLayout();
    }
    .width('100%')
  }
}