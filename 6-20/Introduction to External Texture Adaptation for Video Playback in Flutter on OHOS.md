# Introduction to External Texture Adaptation for Video Playback in Flutter on OHOS

Flutter uses external textures on the OHOS platform for video playback. During texture registration, the Flutter engine returns a `surfaceId`.

Notes:

1. For reusability, the OHOS-Flutter external texture integration is typically implemented as a separate module/plugin registered with the Flutter engine.
2. External textures default to a white background (currently not customizable).

### Video Playback Implementation

1. **Plugin Implementation**
   Create an OHOS native player using AVPlayer in the `video_player_ohos` plugin:

   ```
   export class VideoPlayerPlugin implements FlutterPlugin, AbilityAware {
     private pluginBinding: FlutterPluginBinding | null = null;
     private videoPlayerApi: VideoPlayerApiImpl | null = null;
     private flutterState: FlutterState | null = null;
   
     getUniqueClassName(): string {
       return TAG;
     }
   
     onAttachedToEngine(binding: FlutterPluginBinding): void {
       this.pluginBinding = binding;
       Log.i(TAG, "VideoPlayer onAttachedToEngine");
       this.flutterState = new FlutterState(
         this.pluginBinding.getBinaryMessenger(),
         this.pluginBinding.getTextureRegistry()
       );
     }
   ```

2. **Texture Registration**
   During player creation, obtain texture ID and register texture:

   ```
   let flutterRenderer = this.flutterState.getTextureRegistry();
   let textureId: number = flutterRenderer.getTextureId();
   Log.i(TAG, "Enter getRawFd, textureId=" + textureId);
   let surfaceTextureEntry: SurfaceTextureEntry = flutterRenderer.registerTexture(textureId);
   ```

3. **Surface ID Handling**
   Extract surface ID from the texture entry in the VideoPlayer constructor:

   ```
   constructor(
     playerModel: PlayerModel,
     textureEntry: SurfaceTextureEntry,
     url: resourceManager.RawFileDescriptor | null,
     iUrl: string | null,
     eventChannel: EventChannel,
     AudioFocus: Boolean,
     headers: Record<string, string> | null
   ) {
     this.playerModel = playerModel;
     this.textureEntry = textureEntry;
     this.surfaceId = textureEntry.getSurfaceId().toString();
     Log.i(TAG, "surfaceId: " + this.surfaceId);
   }
   ```

4. **Assign Surface to AVPlayer**
   Set the surface ID to AVPlayer during initialization:

   ```
   case AvplayerStatus.INITIALIZED:
     this.avPlayer.surfaceId = this.surfaceId;
     this.avPlayer.prepare();
     break;
   ```

5. **Dart-Side Integration**
   Return the texture ID to the Dart layer for rendering:

   ```
   // In Dart code
   Widget build(BuildContext context) {
     return Texture(textureId: _textureId);
   }
   ```

### Key Implementation Details

1. **Asset Handling**
   For assets bundled with the app:

   ```
   if (asset != null) {
     let rawFileDescriptor = await this.getContext().resourceManager.getRawFd("flutter_assets/" + asset);
     let videoPlayer = new VideoPlayer(playerModel, surfaceTextureEntry, rawFileDescriptor, null, eventChannel, this.AudioFocus, null);
     await videoPlayer.createAVPlayer();
     this.videoPlayers.set(textureId.toString(), videoPlayer);
   }
   ```

2. **URI Handling**
   For external URIs:

   ```
   else if (uri != null) {
     let videoPlayer = new VideoPlayer(playerModel, surfaceTextureEntry, null, uri, eventChannel, this.AudioFocus, header);
     await videoPlayer.createAVPlayer();
     this.videoPlayers.set(textureId.toString(), videoPlayer);
   }
   ```

3. **Preview Image Handling**
   Generate preview images using AVImageGenerator:

   ```
   let avImageGenerator = await media.createAVImageGenerator();
   avImageGenerator.fdSrc = await this.getContext().resourceManager.getRawFd("flutter_assets/" + asset);
   let pixelMap = await avImageGenerator.fetchFrameByTime(0, media.AVImageQueryOptions.AV_IMAGE_QUERY_NEXT_SYNC, {
     width: -1,
     height: -1
   });
   ```

This implementation enables Flutter applications on OHOS to leverage native video playback capabilities through external textures while maintaining a consistent rendering experience across platforms.