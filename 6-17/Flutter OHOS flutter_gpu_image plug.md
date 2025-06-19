# GPUImage for Flutter

Add various filter effects to cameras, photos, and videos in Flutter applications.

## Local Environment

- [✓] Flutter (Stable channel, version 3.0.0, on macOS 12.3.1 21E258 darwin-x64, locale zh-Hans-CN)
- [✓] Android toolchain for Android development (Android SDK version 33.0.0-rc1)
- [✓] Xcode for iOS/macOS development (Xcode 13.3.1)
- [✓] Chrome for web development
- [✓] Android Studio (version 2021.1)
- [✓] VS Code (version 1.66.2)
- [✓] Connected devices (4 available)
- [✓] HTTP Host Availability

## Integration Steps

### 1. Add to pubspec.yaml
    ```yaml
    dependencies:
      gpu_image: ^1.0.0
    ```

### 2. Import package
    ```dart
    import 'package:gpu_image/gpu_image.dart';
    ```

## Camera Usage

    ```dart
    final GlobalKey<GPUCameraWidgetState> cameraKey = GlobalKey();
    
    // Camera widget
    GPUCameraWidget(
      key: cameraKey,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      cameraCallBack: GPUCameraCallBack(
    recordPhoto: (path) {
      print("Photo saved at: $path");
      Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => ImagePage(path: path)));
    }
      ),
    ),
    
    // Take photo
    cameraKey.currentState?.recordPhoto();
    
    // Switch camera
    cameraKey.currentState?.switchCamera();
    
    // Apply filter
    cameraKey.currentState?.setFilter(filter);
    ```

## Image Processing

    ```dart
    final GlobalKey<GPUImageWidgetState> imageKey = GlobalKey();
    
    // Image widget
    GPUImageWidget(
      key: imageKey,
      width: 400,
      height: 600,
      path: widget.path,
      callBack: GPUImageCallBack(
    saveImage: (path) {
      print("Image saved at: $path");
      Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => ImagePage(path: path)));
    }
      ),
    ),
    
    // Apply filter
    imageKey.currentState?.setFilter(filter);
    
    // Save processed image
    imageKey.currentState?.saveImage();
    ```

## Supported Filters

- [x] GPUNormalFilter
  No filter effect

- [x] GPUBrightnessFilter 
  Brightness adjustment
  Range: 0-1, default 0.5

- [x] GPUColorInvertFilter
  Color inversion

- [x] GPUContrastFilter
  Contrast adjustment
  Range: 0.0-4.0, default 1.0

- [x] GPUExposureFilter
  Exposure adjustment
  Range: -10.0 to 10.0, default 0.0

- [x] GPUFalseColorFilter
  Color mixing
  Parameters (all range 0.0-1.0):
  fRed, fGreen, fBlue, sRed, sGreen, sBlue

- [x] GPUGammaFilter
  Gamma correction
  Range: 0.0-3.0, default 1.0

- [x] GPUGrayscaleFilter
  Grayscale conversion

- [x] GPUHighlightsShadowsFilter
  Highlight and shadow adjustment
  shadows: 0.0-1.0 (default 1.0)
  highlights: 0.0-1.0 (default 0.0)

- [x] GPUHueFilter
  Hue adjustment
  Default: 90.0

- [x] GPULevelsFilter
  Photoshop-like level adjustment
  Parameters: redMin, greenMin, blueMin (arrays)

- [x] GPUMonochromeFilter
  Monochrome effect based on pixel luminance
  intensity: 0.0-1.0 (default 1.0)
  color: Base color for effect (default: [0.6,0.45,0.3,1.0])

- [x] GPUPixelationFilter
  Pixelation effect
  pixel: Default 1.0

- [x] GPURGBFilter
  Individual RGB channel adjustment
  red/green/blue: 0.0-1.0 (default 1.0)

- [x] GPUSaturationFilter
  Saturation adjustment
  saturation: 0.0-2.0 (default 1.0)

- [x] GPUSepiaFilter
  Sepia tone (vintage effect)
  sepia: 0.0-2.0 (default 1.0)

- [x] GPUSharpenFilter
  Sharpening
  sharpen: -4.0-4.0 (default 0.0)

- [x] GPUWhiteBalanceFilter
  Color temperature adjustment
  temperature: 4000-7000 (default 5000)
  tint: -200-200 (default 0)

### HarmonyOS Key Code Implementation

### Camera Component (CameraView.ets)
    ```typescript
    @Component
    struct XComponentView {
      @Prop params: Params
      @StorageLink('width') w: number = 1080
      @StorageLink('Height') h: number = 1920
      @StorageLink('id') idx: number = 1
      cameraView: CameraView = this.params.platformView as CameraView;
      
      build() {
    Column() {
      XComponent({
    id:'camera_' + this.idx.toString(), 
    type:'surface',
    libraryname:'gpuimagenative'
      })
      .width(this.w.toString() + 'px')
      .height(this.h.toString() + 'px')
      .onLoad(() => {
    /* 
     * OpenGL offscreen rendering thread created in XComponent's OnSurfaceCreated callback
     * Camera preview requires NativeImage's Surface, so call startCameraInView in onLoad
     */
    this.cameraView.startCameraInView();
      })
    }
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
      // ... member variables ...
      
      constructor(ctx: common.Context, uiAbility: UIAbility,
    messenger: BinaryMessenger, id: number, params: Map<string, ESObject>) {
    // ... initialization logic ...
      }
    
      // Handle method calls from Flutter
      onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "setFilter":
    // Apply filter
    break;
      case "switchCamera":
    // Switch between front/back camera
    break;
      case "recordPhoto":
    // Capture photo
    break;
      case "closeCamera":
    // Release camera resources
    break;
    }
      }
    
      getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(XComponentViewBuilder);
      }
      
      // Start camera in view
      public startCameraInView = () => {
    this.startCameraIfReady();
      }
      
      // Stop camera in view
      public stopCameraInView = () => {
    GpuImageNative.releaseRenderThread();
    this.stopCamera();
      }
    }
    ```

### Image Component (ImageView.ets)
    ```typescript
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
      // ... member variables ...
      
      constructor(ctx: common.Context, uiAbility: UIAbility,
    messenger: BinaryMessenger, id: number, params: Map<string, ESObject>) {
    // ... initialization logic ...
    this.initImage();
      }
      
      // Initialize image (supports both local and network paths)
      private initImage() {
    if(this.path.startsWith("http")) {
      // Load from network
    } else {
      // Load from local path
    }
      }
    
      // Handle method calls from Flutter
      onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "setFilter":
    // Apply filter
    break;
      case "saveImage":
    // Save processed image
    break;
    }
      }
      
      getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(ImageBuilder);
      }
    }
    ```