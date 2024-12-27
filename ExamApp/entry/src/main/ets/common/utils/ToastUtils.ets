import promptAction from '@ohos.promptAction'

export default class  ToastUtils{
  static showToast(messageInfo : string | Resource ,duration = 2000) {
    promptAction.showToast({
      message: messageInfo,
      duration: duration,
    });
  }
}