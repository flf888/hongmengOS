
@Preview
@Component
export default struct LoadingLayout {
  reloadFunc?: Function

  aboutToDisappear(): void {
    console.log("aboutToDisappear")
  }

  build() {
    Column(){
      LoadingProgress()
        .color(Color.Blue)
        .width(80)
        .height(80)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .height('100%')
  }
}