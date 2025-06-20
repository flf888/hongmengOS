# Introduction to External Texture Adaptation for Camera Preview in Flutter on OHOS

Flutter uses external textures on the OHOS platform for both video playback and camera previews. During texture registration, the Flutter engine returns a `surfaceId`. For image scenarios, textures are registered to the Flutter engine via `PixelMap`.

Notes:

1. For reusability, the OHOS-Flutter external texture integration is typically implemented as a separate module/plugin registered with the Flutter engine.
2. External textures default to a white background (currently not customizable).

### Camera Preview Implementation

1. **Plugin Implementation**
   Obtain `TextureRegistry` from `FlutterPluginBinding` in `onAttachedToEngine`:

   ```
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
   ```

2. **Texture Registration Handling**
   Implement texture registration in `onMethodCall`:

   ```
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
   ```

   Register texture and obtain surface ID:

   ```
   registerCameraTexture(): void {
     Log.i(TAG, "Start registering camera texture in Flutter engine");
     this.textureId = this.textureRegistry!.getTextureId();
     this.surfaceId = this.textureRegistry!.registerTexture(this.textureId)!.getSurfaceId();
   }
   ```

3. **Camera Preview Initialization**
   Use the obtained `surfaceId` for camera preview:

   ```
   startSession() {
     console.log(`[Camera test] Starting authorized camera session`);
     let cameraManager = getCameraManager(getContext(this) as common.BaseContext);
     let cameraDevices = getCameraDevices(cameraManager);
     let cameraInput = getCameraInput(cameraDevices[0], cameraManager);
     if (cameraInput != null) {
       getSupportedOutputCapability(cameraDevices[0], cameraManager, cameraInput)
         .then((supportedOutputCapability) => {
           if (supportedOutputCapability != undefined) {
             let previewOutput = getPreviewOutput(
               cameraManager, 
               supportedOutputCapability, 
               this.surfaceId.toString()
             );
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
   ```

4. **Dart-Side Integration**
   Trigger texture registration and camera start:

   ```
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
       if (textureId >= 0) {
         _channel.invokeMethod('unregisterTexture', {'textureId': textureId});
       }
       super.dispose();
     }
   
     void startCamera() async {
       await _channel.invokeMethod('startCamera');
     }
   
     void newTexture() async {
       int id = await _channel.invokeMethod('registerTexture');
       setState(() => this.textureId = id);
     }
   ```

   Render preview using `Texture` widget:

   ```
   Widget getTextureBody(BuildContext context) {
     return Container(
       width: 500,
       height: 500,
       child: Texture(textureId: textureId),
     );
   }
   ```
