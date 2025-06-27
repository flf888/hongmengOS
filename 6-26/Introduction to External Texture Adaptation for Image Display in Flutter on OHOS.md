# Introduction to External Texture Adaptation for Image Display in Flutter on OHOS

>       Flutter uses external textures on the OHOS platform for image display scenarios by registering `PixelMap` objects with the Flutter engine. This approach differs from video playback and camera preview implementations.
>
>       Notes:
>
>       1. For reusability, the OHOS-Flutter external texture integration is typically implemented as a separate module/plugin registered with the Flutter engine.
>       2. External textures default to a white background (currently not customizable).
>
>       ### Image Display Implementation Guide
>
>       Image external textures use PixelMap for engine registration instead of surface IDs.
>
>       1. **Plugin Implementation**
>          Obtain `TextureRegistry` from `FlutterPluginBinding`:
>
>          ```
>          export class PicturePlugin implements FlutterPlugin, MethodCallHandler {
>            private binding: FlutterPluginBinding | null = null;
>            private mMethodChannel: MethodChannel | null = null;
>            private textureRegistry: TextureRegistry | null = null;
>            private pixelMapCache: HashMap<number, image.PixelMap> = new HashMap();
>          
>            getUniqueClassName(): string {
>              return TAG;
>            }
>          
>            onAttachedToEngine(binding: FlutterPluginBinding): void {
>              Log.e(TAG, "PicturePlugin onAttachedToEngine");
>              this.binding = binding;
>              this.mMethodChannel = new MethodChannel(binding.getBinaryMessenger(), "PictureChannel");
>              this.mMethodChannel.setMethodCallHandler(this);
>              this.textureRegistry = binding.getTextureRegistry();
>            }
>          ```
>
>       2. **Texture Registration Handling**
>          Implement methods in `onMethodCall`:
>
>          ```
>          onMethodCall(call: MethodCall, result: MethodResult): void {
>            let method: string = call.method;
>            Log.e(TAG, "Received '" + method + "' message.");
>            switch (method) {
>              case "registerTexture":
>                this.registerPicturePixMap(call.argument("pic"))
>                  .then((textureId: number) => {
>                    result.success(textureId);
>                  })
>                  .catch((err: Error) => {
>                    Log.e(TAG, "Error in registerTexture: " + JSON.stringify(err));
>                  });
>                break;
>              case "unregisterTexture":
>                this.unregisterPicturePixelMap(call.argument("textureId"));
>                result.success(null);
>                break;
>            }
>          }
>          ```
>
>       3. **PixelMap Registration**
>          Load image data and register with engine:
>
>          ```
>          async registerPicturePixMap(pictureName: string) {
>            // Load image resource from assets
>            let fileData = await this.binding!.getApplicationContext().resourceManager
>              .getRawFileContent(`flutter_assets/${pictureName}`);
>            let buffer: ArrayBuffer = fileData?.buffer as ArrayBuffer ?? new ArrayBuffer(0);
>            
>            // Create PixelMap from image data
>            let imageSource: image.ImageSource = image.createImageSource(buffer);
>            let imageInfo = await imageSource.getImageInfo();
>            Log.d(TAG, "Image height: " + imageInfo.size.height);
>            let pixelMap = await imageSource.createPixelMap();
>            Log.d(TAG, "Pixel bytes count: " + pixelMap.getPixelBytesNumber());
>            
>            // Register PixelMap with Flutter engine
>            let textureId = this.textureRegistry!.registerPixelMap(pixelMap);
>            Log.d(TAG, "Registered textureId: " + textureId);
>            
>            // Cache PixelMap for future reference
>            this.pixelMapCache.set(textureId, pixelMap);
>            return textureId;
>          }
>          ```
>
>       4. **Dart-Side Implementation**
>          Use texture ID in widget for rendering:
>
>          ```
>          Widget getTextureBody(BuildContext context, PicBean picBean) {
>            return Column(
>              mainAxisAlignment: MainAxisAlignment.center,
>              children: [
>                SizedBox(
>                  width: 300,
>                  height: 300,
>                  child: Texture(textureId: picBean.id),
>                ),
>                Container(height: 10),
>              ],
>            );
>          }
>          ```
