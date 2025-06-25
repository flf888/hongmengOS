# Video Compression with harmony_flutter_videoCompress

### 1. MethodChannel Implementation

#### 1.1 Flutter Implementation

	```dart
	// Create communication channel for video compression
	final compressProgress$ = ObservableBuilder<double>();
	final _channel = const MethodChannel('video_compress');
	
	@protected
	void initProcessCallback() {
	  // Set up method call handler for progress updates
	  _channel.setMethodCallHandler(_progressCallback);
	}
	
	MethodChannel get channel => _channel;
	
	bool _isCompressing = false;
	
	bool get isCompressing => _isCompressing;
	
	@protected
	void setProcessingStatus(bool status) {
	  _isCompressing = status;
	}
	
	// Handle progress updates from native
	Future<void> _progressCallback(MethodCall call) async {
	  switch (call.method) {
	    case 'updateProgress':
	      final progress = double.tryParse(call.arguments.toString());
	      if (progress != null) compressProgress$.next(progress);
	      break;
	  }
	}
	```

	```dart
	// Encapsulate request method to pass compression parameters
	final jsonStr = await _invoke<String>('compressVideo', {
	  'path': path,               // Source video path
	  'quality': quality.index,   // Compression quality level
	  'deleteOrigin': deleteOrigin, // Delete original after compression
	  'startTime': startTime,      // Start trim position (seconds)
	  'duration': duration,        // Video duration to keep
	  'includeAudio': includeAudio, // Include audio in output
	  'frameRate': frameRate,      // Target frames per second
	});
	```

#### 1.2 HarmonyOS Implementation

	```typescript
	const CHANNEL_NAME = "video_compress";
	
	private methodChannel: MethodChannel | null = null;
	private applicationContext: Context | null = null;
	private ability: UIAbility | null = null;
	private unity: Unity | null = null;
	private videoCompress: VideoCompress | null = null;
	
	// Called when attached to UIAbility
	onAttachedToAbility(binding: AbilityPluginBinding): void {
	  Log.i(TAG, "Attached to Ability");
	  this.ability = binding.getAbility();
	  this.unity = new Unity(this.ability.context); // Media utilities
	  this.videoCompress = new VideoCompress(this.ability.context); // Compression module
	}
	
	// Called when detached from UIAbility
	onDetachedFromAbility(): void {
	  Log.i(TAG, "Detached from Ability");
	  this.ability = null;
	}
	
	// Called when attached to Flutter engine
	onAttachedToEngine(binding: FlutterPluginBinding): void {
	  this.applicationContext = binding.getApplicationContext();
	  // Create MethodChannel instance named 'video_compress'
	  this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
	  this.methodChannel.setMethodCallHandler(this);
	}
	
	// Called when detached from Flutter engine
	onDetachedFromEngine(binding: FlutterPluginBinding): void {
	  this.applicationContext = null;
	  this.methodChannel?.setMethodCallHandler(null);
	  this.methodChannel = null;
	}
	
	// Handle method calls from Flutter
	onMethodCall(call: MethodCall, result: MethodResult): void {
	  Log.d(TAG, "Received call: " + call.method)
	
	  try {
	    switch (call.method) {
	      case 'compressVideo': {
	        // Extract compression parameters
	        const path = call.argument("path") as string;
	        const quality = call.argument("quality") as number;
	        const deleteOrigin = call.argument("deleteOrigin") as boolean;
	        const startTime = call.argument("startTime") as number;
	        const duration = call.argument("duration") as number;
	
	        // Set default values if not provided
	        let includeAudio = call.argument("includeAudio") as boolean | undefined;
	        if (includeAudio === undefined) includeAudio = true;
	        
	        let frameRate = call.argument("frameRate") as number | undefined;
	        if (frameRate === undefined) frameRate = 30;
	
	        // Generate unique output path
	        const tempDir = this.applicationContext!.tempDir;
	        const timestamp = dayjs().format('YYYY-MM-DD HH-mm-ss');
	        const destPath: string = `${tempDir}/VID_${timestamp}.mp4`;
	
	        // Send initial progress update
	        this.methodChannel?.invokeMethod("updateProgress", 1)
	        
	        // Execute compression
	        this.videoCompress?.compress(path, quality, {
	          startTime,
	          duration,
	          includeAudio,
	          frameRate,
	          destPath
	        }).then(out => {
	          // Delete original if requested
	          if (deleteOrigin) fs.unlinkSync(path);
	          
	          // Get compressed media info
	          this.unity?.getMediaInfoJson(out).then((json) => {
	            Log.d(TAG, JSON.stringify(json))
	            json['isCancel'] = false;
	            
	            // Send completion progress
	            this.methodChannel?.invokeMethod("updateProgress", 100)
	            
	            // Return result to Flutter
	            result.success(JSON.stringify(json))
	          })
	        })
	        break;
	      }
	      default:
	        result.notImplemented()
	    }
	  } catch (err) {
	    result.error("Processing failed", err.message, null)
	  }
	}
	```