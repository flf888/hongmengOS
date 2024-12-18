# flutter_ohos_原生和flutter交互跳转

## 1. EntryAbility 可以继承 UIAbility

```ts
export default class EntryAbility extends UIAbility implements ExclusiveAppComponent<UIAbility> {

  detachFromFlutterEngine(): void {
    // throw new Error('Method not implemented.');
  }

  getAppComponent(): UIAbility {
    return this;
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    FlutterManager.getInstance().pushUIAbility(this);
  }

  onDestroy(): void | Promise<void> {
    FlutterManager.getInstance().popUIAbility(this);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
    FlutterManager.getInstance().pushWindowStage(this, windowStage);
    windowStage.loadContent('pages/Index');
  }

  onWindowStageDestroy() {
    FlutterManager.getInstance().popWindowStage(this);
  }
}
```

## 2. 继承 FlutterEntry 并注册插件

```ts
export default class MyFlutterEntry extends FlutterEntry {
  configureFlutterEngine(flutterEngine: FlutterEngine): void {
    super.configureFlutterEngine(flutterEngine);
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    this.delegate?.addPlugin(new BatteryPlugin());
  }
}
```

## 3. FlutterEntry 需要和 FlutterView 一起使用

```ts
@Entry
@Component
struct Index {
  private flutterEntry: FlutterEntry | null = null;
  private flutterView?: FlutterView

  aboutToAppear() {
    Log.d("Flutter", "Index aboutToAppear===");
    this.flutterEntry = new MyFlutterEntry(getContext(this))
    this.flutterEntry.aboutToAppear()
    this.flutterView = this.flutterEntry.getFlutterView()
  }

  aboutToDisappear() {
    Log.d("Flutter", "Index aboutToDisappear===");
    this.flutterEntry?.aboutToDisappear()
  }

  onPageShow() {
    Log.d("Flutter", "Index onPageShow===");
    this.flutterEntry?.onPageShow()
  }

  onPageHide() {
    Log.d("Flutter", "Index onPageHide===");
    this.flutterEntry?.onPageHide()
  }

  build() {
    Stack() {
      FlutterPage({ viewId: this.flutterView?.getId() })
      Button('跳转页面2')
        .onClick(() => {
          try {
            router.pushUrl({ url: 'pages/Index2', params: { route: '/second' } })
          } catch (err) {
            Log.d("Flutter", "跳转页面2 error ===" + JSON.stringify(err));
          }
        })
    }
  }
}
```
