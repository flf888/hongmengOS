# GPUImage for Flutter

Flutter中相机、照片、视频添加各种滤镜效果。



## 本地环境

- [✓] Flutter (Channel stable, 3.0.0, on macOS 12.3.1 21E258 darwin-x64, locale zh-Hans-CN)
- [✓] Android toolchain develop for Android devices (Android SDK version 33.0.0-rc1)
- [✓] Xcode develop for iOS and macOS (Xcode 13.3.1)
- [✓] Chrome develop for the web
- [✓] Android Studio (version 2021.1)
- [✓] VS Code (version 1.66.2)
- [✓] Connected device (4 available)
- [✓] HTTP Host Availability


## 集成步骤

### 1、pubspec.yaml
```dart
gpu_image: ^1.0.0
```

### 2、引入
```dart
import 'package:gpu_image/gpu_image.dart';
```

## 相机

    final GlobalKey<GPUCameraWidgetStatecameraKey = GlobalKey();
    //相机widget
    GPUCameraWidget(
    key: cameraKey,
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    cameraCallBack: GPUCameraCallBack(
      recordPhoto: (path){
    print("拍照保存地址 $path");
    Navigator.of(context).push(MaterialPageRoute(
    builder: (context) =ImagePage(path: path)));
      }
    ),
      ),
    
    //拍照
    cameraKey.currentState?.recordPhoto();
    //切换摄像头
    cameraKey.currentState?.switchCamera();
    //设置滤镜
    cameraKey.currentState?.setFilter(filter);


## 图片

    final GlobalKey<GPUImageWidgetState> imageKey = GlobalKey();
    GPUImageWidget(
    key: imageKey,
    width: 400,
    height: 600,
    path: widget.path,
    callBack: GPUImageCallBack(
    saveImage: (path){
      print("保存图片地址 $path")
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImagePage(path: path)));
    }
    ),
    ),
    //设置滤镜
    imageKey.currentState?.setFilter(filter);
    //保存图片
    imageKey.currentState?.saveImage();


## 滤镜

- [x] GPUNormalFilter
  无滤镜

- [x] GPUBrightnessFilter 
  亮度
  brightness 取值范围为0-1，默认0.5

- [x] GPUColorInvertFilter
  反色

- [x] GPUContrastFilter
  对比度
  contrast 取值范围为0.0到4.0，正常值为1.0

- [x] GPUExposureFilter
  曝光度
  exposure 取值范围为-10.0到 - 10.0，正常值为0.0

- [x] GPUFalseColorFilter
  颜色混合
  fRed 取值0.0-1.0
  fGreen 取值0.0-1.0
  fBlue 取值0.0-1.0
  sRed 取值0.0-1.0
  sGreen 取值0.0-1.0
  sBlue 取值0.0-1.0

- [x] GPUGammaFilter
  伽马值
  gamma 取值范围0.0 - 3.0，默认1.0

- [x] GPUGrayscaleFilter
  灰度

- [x] GPUHighlightsShadowsFilter
  阴影高光
  shadows 取值范围0.0 - 1.0，默认1.0
  highlights 取值范围0.0 - 1.0，默认0.0

- [x] GPUHueFilter
  色度
  hue 默认90.0

- [x] GPULevelsFilter
  类似Photoshop的级别调整
  redMin 默认 [0.0, 1.0, 1.0,0.0,1.0];
  greenMin 默认 [0.0, 1.0, 1.0,0.0,1.0];
  blueMin 默认 [0.0, 1.0, 1.0,0.0,1.0];

- [x] GPUMonochromeFilter
  根据每个像素的亮度将图像转换为单色版本
  intensity 特定颜色替换正常图像颜色的程度（0.0-1.0，默认为1.0）
  red、green、blue、alpha用作效果基础的颜色，默认为（0.6,0.45,0.3,1.0）。

- [x] GPUPixelationFilter
  像素化
  pixel 默认为1.0

- [x] GPURGBFilter
  调整图像的各个RGB
  red （取值范围0.0 - 1.0，默认1.0
  green （取值范围0.0 - 1.0，默认1.0
  blue （取值范围0.0 - 1.0，默认1.0

- [x] GPUSaturationFilter
  饱和度
  saturation（取值范围0.0 - 2.0，默认1.0）

- [x] GPUSepiaFilter
  褐色（怀旧）
  sepia (取值范围0.0 - 2.0，默认1.0)

- [x] GPUSharpenFilter
  锐化
  sharpen (取值范围-4.0 - 4.0，默认0.0)

- [x] GPUWhiteBalanceFilter
  色温
  temperature （取值范围4000 - 7000，默认5000）
  tint （取值范围-200 - 200，默认0）

### 鸿蒙OS关键代码

### 相机 CameraView.ets
    
    @Component
    struct XComponentView {
      @Prop params: Params
      @StorageLink('width') w: number = 1080
      @StorageLink('Height') h: number = 1920
      @StorageLink('id') idx: number = 1
      cameraView: CameraView = this.params.platformView as CameraView;
      build() {
    Column() {
      XComponent({id:'camera_' + this.idx.toString(), type:'surface',libraryname:'gpuimagenative'})
    .width(this.w.toString() + 'px')
    .height(this.h.toString() + 'px')
    .onLoad(() => {
      /*OpenGL的离屏渲染线程在XComponent的OnSurfaceCreated回调创建，
      * 相机启动预览流需要NativeImage的Surface，所以在onLoad中调用startCameraInView启动相机
      */
      this.cameraView.startCameraInView();
    })
    }
      }
    
      aboutToAppear(): void {
      }
    
      aboutToDisappear(): void {
      }
    
      aboutToRecycle(): void {
      }
    }
    
    @Builder
    function XComponentViewBuilder(params: Params) {
      XComponentView({ params: params})
    }
    
    AppStorage.setOrCreate('width', 1080)
    AppStorage.setOrCreate('Height', 1920)
    AppStorage.setOrCreate('id', 1)
    
    @Observed
    export class CameraView extends PlatformView implements MethodCallHandler {
      private context: common.Context | null = null;
      private uiAbility: UIAbility | null = null;
      private width: number = 0;
      private height: number = 0;
      private id: number = 0;
      private channel: MethodChannel | null = null;
      private isBackCamera: boolean = true;
      private offScreenSurface: string = '0';
      private cameraSession: camera.PhotoSession | null = null;
      private previewOutput: camera.PreviewOutput | null = null;
      private cameraInput: camera.CameraInput | null = null;
    
      constructor(ctx: common.Context, uiAbility: UIAbility,
    messenger: BinaryMessenger, id: number, params: Map<string, ESObject>) {
    super();
    this.id = id;
    this.width = params.get("width") as number;
    this.height = params.get("height") as number;
    let widthLink: SubscribedAbstractProperty<number> = AppStorage.link("width");
    widthLink.set(this.width);
    let heightLink: SubscribedAbstractProperty<number> = AppStorage.link("Height");
    heightLink.set(this.height);
    let idLink: SubscribedAbstractProperty<number> = AppStorage.link("id");
    idLink.set(this.id);
    this.channel = new MethodChannel(messenger, "com.gstory.gpu_image/camera_" + this.id.toString());
    this.channel.setMethodCallHandler(this);
      }
    
      onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "setFilter":
    let args: Map<string, ESObject> = call.args as Map<string, ESObject>;
    FilterTools.switchFilter(args);
    break;
      case "switchCamera":
    this.isBackCamera = !this.isBackCamera;
    this.startCameraIfReady();
    break;
      case "recordPhoto":
    let folderName: string = "GPUImage";
    let fileName: string = systemDateTime.getTime(false).toString() + ".jpg";
    GpuImageNative.savePixelMap((err: BusinessError, pixelMap: image.PixelMap) => {
      const ctx = getContext(this);
      let folderPath = ctx.filesDir + "/" + folderName;
      if (!fs.accessSync(folderPath)) {
    fs.mkdirSync(folderPath);
      }
      let imagePath = folderPath + "/" + fileName;
      let imageFile = fs.openSync(imagePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      const imagePacker = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
      imagePacker.packToFile(pixelMap, imageFile.fd, packOpts).then(() => {
    let args: Map<string, ESObject> = new Map();
    args.set("path", imagePath);
    this.channel!.invokeMethod("recordPhoto", args);
      });
    });
    break;
      case "closeCamera":
    //PlatformView的原生Component生命周期不会触发aboutToDisappear
    //根据Flutter页面的dispose回调释放相机和渲染线程资源
    this.stopCamera();
    GpuImageNative.releaseRenderThread();
    break;
      default:
    result.notImplemented();
    break;
    }
      }
    
      getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(XComponentViewBuilder);
      }
    
      dispose(): void {
    
      }
    
      private async startCameraIfReady(): Promise<void> {
    checkPermissions(permissions).then((hasPermission: boolean) => {
      if (hasPermission) {
    this.startCamera();
      } else {
    reqPermissionsFromUser(permissions, getContext(this) as Context).then((isPermit: boolean) => {
      if (isPermit) {
    this.startCamera();
      } else {
    Log.e(TAG, "get permission failed!");
      }
    })
      }
    })
    
      }
    
      private async startCamera(): Promise<void> {
    await this.stopCamera();
    let cameraManager = CameraUtil.getCameraManager(this.context!);
    let inputCamera: camera.CameraDevice | null = null;
    if (this.isBackCamera) {
      inputCamera = CameraUtil.getCameraDevice(cameraManager, camera.CameraPosition.CAMERA_POSITION_BACK);
      GpuImageNative.setRotation(Rotation.ROTATION_0, false, false);
    } else {
      inputCamera = CameraUtil.getCameraDevice(cameraManager, camera.CameraPosition.CAMERA_POSITION_FRONT);
      GpuImageNative.setRotation(Rotation.ROTATION_0, false, true);
    }
    this.offScreenSurface = GpuImageNative.getSurfaceId().toString();
    if (this.offScreenSurface == '0') {
      Log.e(TAG, "getSurfaceId error!");
      return;
    }
    await this.startPreviewOutput(cameraManager, inputCamera!, this.offScreenSurface, this.height / this.width);
      }
    
      private async startPreviewOutput(cameraManager: camera.CameraManager, inputCamera: camera.CameraDevice,
    surfaceId: string, scale: number): Promise<void> {
    try {
      let profiles: camera.CameraOutputCapability =
    cameraManager.getSupportedOutputCapability(inputCamera, camera.SceneMode.NORMAL_PHOTO);
      let bestProfile =
    CameraUtil.getSuitableProfile(camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP, scale, profiles.previewProfiles);
      this.previewOutput = cameraManager.createPreviewOutput(bestProfile, surfaceId);
      this.cameraInput = cameraManager.createCameraInput(inputCamera);
      await this.cameraInput.open();
      this.cameraSession =
    cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
      this.setSessionListener();
      this.cameraSession.beginConfig();
      this.cameraSession.addInput(this.cameraInput);
      this.cameraSession.addOutput(this.previewOutput);
      await this.cameraSession.commitConfig();
      await this.cameraSession.start();
    } catch (err) {
      Log.e(TAG, "startPreviewOutput error: " + JSON.stringify(err));
    }
      }
    
      private async stopCamera(): Promise<void> {
    try{
      if (this.cameraInput) {
    await this.cameraInput.close();
      }
      if (this.previewOutput) {
    await this.previewOutput.release();
      }
      if (this.cameraSession) {
    await this.cameraSession.release();;
      }
    } catch (err) {
      Log.e(TAG, "stopCamera failed! " + JSON.stringify(err))
    }
      }
    
      private setSessionListener(): void {
    if(this.cameraSession) {
      this.cameraSession.on("error", (err: BusinessError) => {
    Log.e(TAG, "cameraSession error: " + JSON.stringify(err));
      })
    }
      }
    
      public startCameraInView = () => {
    this.startCameraIfReady();
      }
    
      public stopCameraInView = () => {
    GpuImageNative.releaseRenderThread();
    this.stopCamera();
      }
    }
    
### 图片 ImageView.ets

    @Component
    struct ImageComponent {
      @Prop params: Params
      @StorageLink('picture') pixelMap: image.PixelMap | null = null;
      @StorageLink('width') w: number = 1080
      @StorageLink('Height') h: number = 1920
      build() {
    Column() {
      Image(this.pixelMap)
    .width(this.w.toString() + 'px')
    .height(this.h.toString() + 'px')
    }
      }
    
      aboutToAppear(): void {
      }
    
      aboutToDisappear(): void {
      }
    
      aboutToRecycle(): void {
      }
    }
    
    @Builder
    function ImageBuilder(params: Params) {
      ImageComponent({params: params})
    }
    
    AppStorage.setOrCreate('picture', null)
    AppStorage.setOrCreate('width', 1080)
    AppStorage.setOrCreate('Height', 1920)
    
    @Observed
    export class ImageView extends PlatformView implements MethodCallHandler {
      private context: common.Context | null = null;
      private uiAbility: UIAbility | null = null;
      private width: number = 0;
      private height: number = 0;
      private path: string = "";
      private channel: MethodChannel | null = null;
    
      constructor(ctx: common.Context, uiAbility: UIAbility,
      messenger: BinaryMessenger, id: number, params: Map<string, ESObject>) {
    super();
    this.width = params.get("width") as number;
    this.height = params.get("height") as number;
    let widthLink: SubscribedAbstractProperty<number> = AppStorage.link("width");
    widthLink.set(this.width);
    let heightLink: SubscribedAbstractProperty<number> = AppStorage.link("Height");
    heightLink.set(this.height);
    this.path = params.get("path") as string;
    this.channel = new MethodChannel(messenger, "com.gstory.gpu_image/image_" + id);
    this.channel.setMethodCallHandler(this);
    this.initImage();
      }
    
      private initImage() {
    if(this.path.startsWith("http")) {
      let httpRequest = http.createHttp();
      httpRequest.request(this.path,(err, data)=>{
    if(http.ResponseCode.OK == data.responseCode) {
      let imageResource = image.createImageSource(data.result as ArrayBuffer);
      let options: Record<string, ESObject> = {
    'alphaType': 0,
    'editable': false,
    'pixelFormat': image.PixelMapFormat.RGBA_8888,
    'scaleMode': 1,
    'size': { height: 100, width: 100 }
      }
      imageResource.createPixelMap(options).then((pixelMap) => {
    GpuImageNative.setImage(pixelMap);
      });
    }
      });
    } else {
      const imageSource = image.createImageSource(this.path);
      imageSource.createPixelMap((err: BusinessError, pixelMap: image.PixelMap) => {
    pixelMap.getImageInfo().then((imageInfo) => {
      const readBuffer: ArrayBuffer = new ArrayBuffer(imageInfo.size.height*imageInfo.size.width*4);
      pixelMap.readPixelsToBufferSync(readBuffer);
    })
    try {
      let pictureLink: SubscribedAbstractProperty<image.PixelMap> = AppStorage.link("picture");
      pictureLink.set(pixelMap);
    } catch (err) {
      Log.e(TAG, "setImage error:" + err);
    }
      });
    }
      }
    
    
      onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "setFilter":
    let args: Map<string, ESObject> = call.args as Map<string, ESObject>;
    FilterTools.switchFilter(args);
    break;
      case "saveImage":
    let folderName: string = "GPUImage";
    let fileName: string = systemDateTime.getTime(false).toString() + ".jpg";
    GpuImageNative.savePixelMap((err: BusinessError, pixelMap: image.PixelMap)=>{
      const ctx = getContext(this);
      let folderPath = ctx.filesDir + "/" + folderName;
      if(!fs.accessSync(folderPath)) {
    fs.mkdirSync(folderPath);
      }
      let imagePath = folderPath + "/" + fileName;
      let imageFile = fs.openSync(imagePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      const imagePacker = image.createImagePacker();
      const packOpts: image.PackingOption = { format: 'image/jpeg', quality: 100 };
      imagePacker.packToFile(pixelMap, imageFile.fd, packOpts).then(()=>{
    let args: Map<string, ESObject> = new Map();
    args.set("path", imagePath);
    this.channel!.invokeMethod("recordPhoto", args);
      });
    });
    break;
      default :
    result.notImplemented();
    break;
      }
    }
    
      getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(ImageBuilder);
      }
    
      dispose(): void {
      }
    }