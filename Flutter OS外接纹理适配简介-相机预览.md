HarmonyOS next之Flutter OHOS外接纹理适配简介

Flutter在OHOS平台使用外接纹理，视频播放和相机预览使用方法是一致的，在注册纹理时，flutter engine返回surfaceId。图片场景，则是以PixelMap的形式注册到flutter engine。

注：1. 一般而言，为了方便复用，会将ohos对接flutter外接纹理的功能代码作为一个module模块组件单独写一个插件注册到Flutter engine

2. 外接纹理背景色为白色，暂不支持修改
# 相机预览

## 实现说明

1． 实现插件，在onAttachedToEngine中，从入参FlutterPluginBinding中获取TextureRegistry
    
    const TAG = "CameraPlugin";
    export class CameraPlugin implements FlutterPlugin, MethodCallHandler {
      private binding: FlutterPluginBinding | null = null;
      private mMethodChannel: MethodChannel | null = null;
      private textureRegistry: TextureRegistry | null = null;
      private textureId: number = -1;
      private surfaceId: number = -1;
    
      getUniqueClassName(): string {
    return TAG;
      }
    
      onAttachedToEngine(binding: FlutterPluginBinding): void {
    Log.e(TAG, "CameraPlugin onAttachedToEngine");
    this.binding = binding;
    this.mMethodChannel = new MethodChannel(binding.getBinaryMessenger(), "CameraControlChannel");
    this.mMethodChannel.setMethodCallHandler(this);
    this.textureRegistry = binding.getTextureRegistry();
    
      }

2． 在onMethodCall中实现注册纹理的响应方法

      onMethodCall(call: MethodCall, result: MethodResult): void {
    let method: string = call.method;
    Log.e(TAG, "Received '" + method + "' message.");
    switch (method) {
      case "registerTexture":
    this.registerCameraTexture();
    result.success(this.textureId);
    break;
      case "startCamera":
    this.startCamera();
    result.success(null);
    break;
      case "unregisterTexture":
    this.unregisterTexture(call.argument("textureId"));
    result.success(null);
    break;
    }
      }

registerCameraTexture中实现注册纹理，先获取textureId，再使用该textureId去注册纹理到flutter engine，返回surfaceId。

      registerCameraTexture(): void {
    Log.i(TAG, "start register Camera texture in flutter engine");
    this.textureId = this.textureRegistry!.getTextureId();
    this.surfaceId = this.textureRegistry!.registerTexture(this.textureId)!.getSurfaceId();
      }

3． 在启动相机预览中，使用前面获取到的surfaceId。

      startSession() {
    console.log(`[camera test] 已经授权，相机开始拍摄`);
    let cameraManager = getCameraManager(getContext(this) as common.BaseContext);
    let cameraDevices = getCameraDevices(cameraManager);
    let cameraInput = getCameraInput(cameraDevices[0], cameraManager);
    if (cameraInput != null) {
      getSupportedOutputCapability(cameraDevices[0], cameraManager, cameraInput)
    .then((supportedOutputCapability) => {
      if (supportedOutputCapability != undefined) {
    let previewOutput = getPreviewOutput(cameraManager, supportedOutputCapability, this.surfaceId.toString());
    let captureSession = getCaptureSession(cameraManager);
    if (captureSession != undefined && previewOutput != undefined && cameraInput != null) {
      beginConfig(captureSession);
      setSessionCameraInput(captureSession, cameraInput);
      setSessionPreviewOutput(captureSession, previewOutput);
      startSession(captureSession);
    }
      }
    });
    }
      }

4 . dart侧通过MethodChannel触发，触发纹理注册和启动相机预览。

    class _CameraPageState extends State<CameraPage> {
      final MethodChannel _channel = MethodChannel('CameraControlChannel');
    
      int textureId = -1;
    
      @override
      void initState() {
    super.initState();
    
    newTexture();
    startCamera();
      }
    
      @override
      void dispose() {
    super.dispose();
    if (textureId >= 0) {
      _channel.invokeMethod('unregisterTexture', {'textureId': textureId});
    }
      }
    
      void startCamera() async {
    await _channel.invokeMethod('startCamera');
      }
    
      void newTexture() async {
    int id = await _channel.invokeMethod('registerTexture');
    setState(() {
      this.textureId = id;
    });
      }

预览画面使用获取到的textureId构造一个texture widget。

      Widget getTextureBody(BuildContext context) {
    return Container(
      width: 500,
      height: 500,
      child: Texture(
    textureId: textureId,
      ),
    );
      }
