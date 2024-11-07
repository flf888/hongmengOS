Flutter OHOS外接纹理适配简介-视频播放

Flutter在OHOS平台使用外接纹理，视频播在注册纹理时，flutter engine返回surfaceId。

注：1. 一般而言，为了方便复用，会将ohos对接flutter外接纹理的功能代码作为一个module模块组件单独写一个插件注册到Flutter engine

2. 外接纹理背景色为白色，暂不支持修改

# 视频播放

## 实现说明

1.  在video_player_ohos插件中实现ohos原生播放器：AVplayer。
2.  实现插件，在onAttachedToEngine中，从入参FlutterPluginBinding中获取TextureRegistry（此处放入FlutterState中封装）。

>  
>     
>     export class VideoPlayerPlugin implements FlutterPlugin, AbilityAware {
>       private pluginBinding: FlutterPluginBinding | null = null;
>       private videoPlayerApi: VideoPlayerApiImpl | null = null;
>       private flutterState: FlutterState | null = null;
>     
>       getUniqueClassName(): string {
>     return TAG;
>       }
>     
>       onAttachedToEngine(binding: FlutterPluginBinding): void {
>     this.pluginBinding = binding;
>     Log.i(TAG, "VideoPlayer onAttachedToEngine");
>     this.flutterState = new FlutterState(this.pluginBinding.getBinaryMessenger(), this.pluginBinding.getTextureRegistry());
>       }


3.  在创建视频播放器的方法中，（先从FlutterState拿出TextureRegistry）同样的先获取textureId，再注册纹理到engine，得到surfaceId（surfaceId在返回的SurfaceTextureEntry对象中）：

>        let flutterRenderer = this.flutterState.getTextureRegistry();
>     let uri: string = arg.getUri();
>     let asset: string = arg.getAsset();
>     let header: Record<string, string= {};
>     arg.getHttpHeaders().forEach((value, key) ={
>       header[key.toString()] = value.toString();
>     })
>     let textureId: number = flutterRenderer.getTextureId();
>     Log.i(TAG, "enter getRawFd, textureId=" + textureId);
>     let surfaceTextureEntry: SurfaceTextureEntry = flutterRenderer.registerTexture(textureId);
>     if (asset != null) {
>       let avImageGenerator = await media.createAVImageGenerator();
>       avImageGenerator.fdSrc = await this.getContext().resourceManager.getRawFd("flutter_assets/" + asset);
>       let pixelMap = await avImageGenerator.fetchFrameByTime(0, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC, {
>     width: -1,
>     height: -1
>       });
>       this.pixelMaps.set(JSON.stringify(arg), pixelMap);
>       avImageGenerator.release();
>       flutterRenderer.setTextureBackGroundPixelMap(textureId, this.pixelMaps.get(JSON.stringify(arg)));
>     } else if (uri != null && uri.startsWith("fd://")) {
>       let avImageGenerator = await media.createAVImageGenerator();
>       avImageGenerator.fdSrc = {
>     fd: Number.parseInt(uri.replace("fd://", ""))
>       };
>       let pixelMap = await avImageGenerator.fetchFrameByTime(0, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC, {
>     width: -1,
>     height: -1
>       });
>       this.pixelMaps.set(JSON.stringify(arg), pixelMap);
>       avImageGenerator.release();
>       flutterRenderer.setTextureBackGroundPixelMap(textureId, this.pixelMaps.get(JSON.stringify(arg)));
>     }
>     let eventChannel: EventChannel = new EventChannel(this.flutterState.getBinaryMessenger(), "flutter.io/videoPlayer/videoEvents" + textureId.toString());
>     if (asset != null) {
>       let rawFileDescriptor: resourceManager.RawFileDescriptor = await this.getContext().resourceManager.getRawFd("flutter_assets/" + asset);
>       let videoPlayer = new VideoPlayer(playerModel, surfaceTextureEntry, rawFileDescriptor, null, eventChannel, this.AudioFocus, null);
>       await videoPlayer.createAVPlayer();
>       this.videoPlayers.set(textureId.toString(), videoPlayer);
>     } else if (uri != null) {
>       let videoPlayer = new VideoPlayer(playerModel, surfaceTextureEntry, null, uri, eventChannel, this.AudioFocus, header);
>       await videoPlayer.createAVPlayer();
>       this.videoPlayers.set(textureId.toString(), videoPlayer);
>     }

4.  Videoplaye构造方法中取出surfaceId：

>       constructor(playerModel: PlayerModel, textureEntry: SurfaceTextureEntry, url: resourceManager.RawFileDescriptor | null, iUrl: string | null, eventChannel: EventChannel, AudioFocus: Boolean, headers: Record<string, string| null) {
>     this.playerModel = playerModel;
>     this.textureEntry = textureEntry;
>     this.surfaceId = textureEntry.getSurfaceId().toString();
>     this.url = url;
>     this.iUrl = iUrl;
>     this.eventChannel = eventChannel;
>     this.headers = headers;
>     if (AudioFocus == true) {
>       this.interruptMode = audio.InterruptMode.SHARE_MODE;
>       Log.i(TAG, "set interruptMode : " + this.interruptMode);
>     }
>     Log.i(TAG, "surfaceId : " + this.surfaceId);
>       }

5.  在AVplayer是AvplayerStatus.INITIALIZED状态时，把surfaceId赋给AVplayer
> 
>     case AvplayerStatus.INITIALIZED:
>       this.avPlayer.surfaceId = this.surfaceId;
>       this.avPlayer.prepare();

1.  第三步创建AVplayer时，需要把textureId返回给dart层，dart层得到该值，可以在texture Widget中使用该外接纹理完成渲染。