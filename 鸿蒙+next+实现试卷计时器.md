

# 鸿蒙next 实现试卷计时器



## 1.实现计时器 ui

```JavaScript
@Entry
@Component
struct QuickTestMainPage {
  @State paperAllTime: number = 0; // 做试卷模式下的总时长
  @State remainTimeUi: string = "00:00";
  @State remainTime: number = 0; // ui显示的时长，做试卷为倒计时，普通做题为正记时
  
  
  build() {
     Column() {
            CustomIcon({
              iconType: CustomIconType.icon_timer,
              iconSize: 19,
              iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
            })
            Text(this.remainTimeUi)
              .fontColor(StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode))
              .fontSize(11)
          }
  }

}
```



## 2.利用setTimeout 来实现没一秒执行一次。

```JavaScript
@Entry
@Component
struct QuickTestMainPage {
  @State paperAllTime: number = 0; // 做试卷模式下的总时长
  @State remainTimeUi: string = "00:00";
  @State remainTime: number = 0; // ui显示的时长，做试卷为倒计时，普通做题为正记时
  
  aboutToAppear(): void { 
  
    this.timerInit()
  }
  
  
  timerInit() {
    if (this.isTest) {
      this.remainTime = this.paperAllTime - this.makeTime;
    } else {
      this.remainTime = this.makeTime;
    }
    this.remainTimeUi = Utils.formatSeconds(this.remainTime);

    this.secondReturn();
  }

  secondReturn() {
    this.doExamTimer = setTimeout(() => {
      if (this.isTest) {
        // 做试卷

        this.remainTime--;
        this.remainTimeUi = Utils.formatSeconds(this.remainTime);
        this.makeTime = this.paperAllTime - this.remainTime;

        if (this.remainTime <= 0) {
          return;
        }
      } else {
        this.remainTime++;
        this.remainTimeUi = Utils.formatSeconds(this.remainTime);
        this.makeTime = this.remainTime;
      }

      // LogUtil.info(`doExamTimer: ${this.remainTime}`)

      this.secondReturn();

    }, 1000)

  }
  
  
  build() {
     Column() {
            CustomIcon({
              iconType: CustomIconType.icon_timer,
              iconSize: 19,
              iconColor: StyleRes.getStyleColor(StyleColor.textBoldColor, this.lightMode)
            })
            Text(this.remainTimeUi)
              .fontColor(StyleRes.getStyleColor(StyleColor.texSubColor, this.lightMode))
              .fontSize(11)
          }
  }

}
```

