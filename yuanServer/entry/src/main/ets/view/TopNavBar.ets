import { EditableLeftIconType, EditableTitleBar, router } from '@kit.ArkUI';
import { StatusBar } from './StatusBar';

@Component
export default struct TopNavBar {
  @Prop navTitle: string = ''
  @Prop bgColor: ResourceColor = '#FFFFFF';
  customBack?: Function

  build() {
    Column() {
      StatusBar({
        bgColor: this.bgColor
      })
      // 华为测试提出需要使用官方返回组件
      EditableTitleBar({
        leftIconStyle: EditableLeftIconType.Back,
        title: this.navTitle,
        options: {
          backgroundColor: this.bgColor
        },
        // 取消右侧保存按钮
        isSaveIconRequired: false,
        onCancel: () => {
          if (this.customBack) {
            this.customBack()
          } else {
            router.back();
          }

        },
      })
    }
  }
}