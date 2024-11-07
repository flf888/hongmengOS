Flutter OHOS外接纹理适配简介-图片显示

Flutter在OHOS平台使用外接纹理，图片场景，以PixelMap的形式注册到flutter engine，与视频播放和相机预览有所区别。

注：1. 一般而言，为了方便复用，会将ohos对接flutter外接纹理的功能代码作为一个module模块组件单独写一个插件注册到Flutter engine。

2. 外接纹理背景色为白色，暂不支持修改

# 图片显示


## 使用说明

图片外接纹理，不需要使用surfaceId, 而是以PixelMap的形式注册到flutter engine。

1.  同样实现插件，在onAttachedToEngine中，从入参FlutterPluginBinding中获取TextureRegistry。

>     export class PicturePlugin implements FlutterPlugin, MethodCallHandler {
>       private binding: FlutterPluginBinding | null = null;
>       private mMethodChannel: MethodChannel | null = null;
>       private textureRegistry: TextureRegistry | null = null;
>       private pixelMapCache: HashMap<number, image.PixelMap= new HashMap<number, image.PixelMap>();
>     
>       getUniqueClassName(): string {
>     return TAG;
>       }
>     
>       onAttachedToEngine(binding: FlutterPluginBinding): void {
>     Log.e(TAG, "PicturePlugin onAttachedToEngine");
>     this.binding = binding;binding.getApplicationContext().resourceManager
>     this.mMethodChannel = new MethodChannel(binding.getBinaryMessenger(), "PictureChannel");
>     this.mMethodChannel.setMethodCallHandler(this);
>     this.textureRegistry = binding.getTextureRegistry();
>     
>       }

2.  在onMethodCall中实现注册纹理的响应方法

>       onMethodCall(call: MethodCall, result: MethodResult): void {
>     let method: string = call.method;
>     Log.e(TAG, "Received '" + method + "' message.");
>     switch (method) {
>       case "registerTexture":
>     this.registerPicturePixMap(call.argument("pic")).then((textureId: number) ={
>       result.success(textureId);
>     }).catch((err: Error) ={
>       Log.e(TAG, "method tag1, error: " + JSON.stringify(err));
>     })
>     break;
>       case "unregisterTexture":
>     this.unregisterPicturePixelMap(call.argument("textureId"));
>     result.success(null);
>     break;
>     }
>       }

3.  注册纹理实现方法中，把图片数据读进来，创建ImageSource，再创建PixelMap对象，使用registerPixelMap接口注册纹理到flutter engine，得到textureId返回给dart层。

>       async registerPicturePixMap(pictureName: string) {
>     let fileData = await this.binding!.getApplicationContext().resourceManager
>     .getRawFileContent(`flutter_assets/${pictureName}`);
>     let buffer : ArrayBuffer = fileData?.buffer as ArrayBuffer ?? new ArrayBuffer(0);
>     let imageSource : image.ImageSource = image.createImageSource(buffer);
>     let imageInfo = await imageSource.getImageInfo();
>     Log.d(TAG, "ImageHeight " + imageInfo.size.height);
>     let pixelMap = await imageSource.createPixelMap();
>     Log.d(TAG, "getPixelBytesNumber " + pixelMap.getPixelBytesNumber());
>     
>     let textureId = this.textureRegistry!.registerPixelMap(pixelMap);
>     Log.d(TAG, "register textureId= " + textureId);
>     
>     this.pixelMapCache.set(textureId, pixelMap);
>     return textureId;
>       }

4.  dart层得到该值，可以在texture Widget中使用该外接纹理完成渲染。

>       Widget getTextureBody(BuildContext context, PicBean picBean) {
>     return Column(
>       mainAxisAlignment: MainAxisAlignment.center,
>       children: [
>     SizedBox(
>       width: 300,
>       height: 300,
>       child: Texture(textureId: picBean.id),
>     ),
>     Container(
>       height: 10,
>     ),
>       ],
>     );
>       }
