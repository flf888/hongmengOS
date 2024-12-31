import Utils from '../common/utils/Utils';

@Component
export default struct IconListLayout {
  @Prop iconEnterList: Record<string, string| number>[] = [];
  @State marginTop: number = 23;
  callBack?: Function;

  aboutToAppear() {
    console.debug('课程首页获取到的图标数量子页面:' + this.iconEnterList.length)
  }

  build() {
    if (this.iconEnterList.length > 0) {
      Row() {
        List() {
          ForEach(this.iconEnterList, (item: Record<string, string | string[]>, index) => {
            ListItem() {
              Stack() {
                Column() {
                  Image(item["img"] as string).width(Utils.getVp(84)).height(Utils.getVp(84))
                  Text(item["name"] as string)
                    .maxLines(1)
                    .fontSize(Utils.getVp(23))
                    .fontColor($r('app.color.blodTextColor'))
                    .margin({
                      top: Utils.getVp(13)
                    })
                }
                .width(this.iconEnterList.length < 5 ? Utils.getVp((720 - 44) / this.iconEnterList.length) :
                Utils.getVp(136))
                .height(Utils.getVp(155))
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .onClick(() => {
                  this.callBack?.(item, index)
                })

              }
              .width(this.iconEnterList.length < 5 ? Utils.getVp((720 - 44) / this.iconEnterList.length) :
              Utils.getVp(136))
              .height(Utils.getVp(155))

            }
          });
        }.listDirection(Axis.Horizontal).height(Utils.getVp(155))
      }.width('100%').justifyContent(FlexAlign.Center)
      .margin({
        top: Utils.getVp(this.marginTop)
      })

    }
  }
}