# Keyboard Visibility Monitoring with harmony_flutter_keyboard_visibility

## MethodChannel Implementation

### 1. Flutter Implementation

#### KeyboardVisibilityBuilder Widget  
	```dart
	final KeyboardVisibilityController? controller;
	
	KeyboardVisibilityController get _controller =>
	    controller ?? KeyboardVisibilityController();
	
	const KeyboardVisibilityBuilder({
	  Key? key,
	  required this.builder,
	  this.controller,
	}) : super(key: key);
	
	/// Builder method that exposes keyboard visibility status
	final Widget Function(BuildContext, bool isKeyboardVisible) builder;
	
	@override
	Widget build(BuildContext context) {
	  return StreamBuilder<bool>(
	    stream: _controller.onChange,
	    initialData: _controller.isVisible,
	    builder: (context, snapshot) {
	      if (snapshot.data != null) {
	        return builder(context, snapshot.data;
	      } else {
	        return builder(context, false);
	      }
	    },
	  );
	}
	```

#### Stream Controller Implementation  
	```dart
	// Create stream controller for keyboard visibility changes
	static final _onChangeController = StreamController<bool>();
	static final _onChange = _onChangeController.stream.asBroadcastStream();
	
	/// Stream for keyboard visibility changes
	static Stream<bool> get onChange {
	  // Initialize only if not in test mode
	  if (!_isInitialized && _testIsVisible == null) {
	    _platform.onChange.listen(_updateValue);
	    _isInitialized = true;
	  }
	  return _onChange;
	}
	```

### 2. HarmonyOS Implementation

	```typescript
	export default class FlutterKeyboardVisibilityPlugin implements FlutterPlugin, StreamHandler, AbilityAware {
	  private eventSink: EventSink | null = null;
	  private isVisible: boolean = false;
	  private context: common.Context | null = null;
	  private window: window.Window | undefined = undefined;
	
	  constructor() {
	    // Initialization
	  }
	
	  getUniqueClassName(): string {
	    return "FlutterKeyboardVisibilityPlugin"
	  }
	
	  // Called when attached to Flutter engine
	  onAttachedToEngine(binding: FlutterPluginBinding): void {
	    this.init(binding.getBinaryMessenger());
	    this.context = binding.getApplicationContext();
	  }
	
	  // Initialize event channel
	  private init(messenger: BinaryMessenger): void {
	    const eventChannel = new EventChannel(messenger, "flutter_keyboard_visibility");
	    eventChannel.setStreamHandler(this);
	  }
	
	  onDetachedFromEngine(binding: FlutterPluginBinding): void {
	    // Cleanup when detached
	  }
	
	  onAttachedToAbility(binding: AbilityPluginBinding): void {
	    // Ability attachment handling
	  }
	
	  onDetachedFromAbility(): void {
	    this.unregisterListener();
	  }
	
	  // Handle stream listeners
	  onListen(o: ESObject, eventSink: EventSink): void {
	    this.eventSink = eventSink;
	    this.listenForKeyboard();
	  }
	
	  onCancel(o: ESObject): void {
	    this.eventSink = null;
	  }
	
	  // Monitor keyboard visibility changes
	  private async listenForKeyboard(): Promise<void> {
	    try {
	      if(this.window == undefined) {
	        // Get current window reference
	        const uiAbility = FlutterManager.getInstance().getUIAbility((getContext(this)));
	        const windowStage = FlutterManager.getInstance().getWindowStage(uiAbility);
	        this.window = windowStage.getMainWindowSync();
	      }
	      
	      // Register keyboard area change listener
	      this.window?.on("avoidAreaChange", (data) => {
	        if (data.type == 3) { // Keyboard avoidance area type
	          let newState = data.area.bottomRect.height > 0;
	          if (newState != this.isVisible) {
	            this.isVisible = newState;
	            if (this.eventSink != null) {
	              // Send visibility status to Flutter (1 = visible, 0 = hidden)
	              this.eventSink.success(this.isVisible ? 1 : 0);
	            }
	          }
	        }
	      });
	    } catch (err) {
	      Log.e(TAG, "Failed to obtain window reference: " + JSON.stringify(err));
	    }
	  }
	
	  // Unregister keyboard listener
	  private unregisterListener(): void {
	    if(this.window != undefined) {
	      this.window.off("avoidAreaChange");
	      this.window = undefined;
	    }
	  }
	}
	```

## Key Implementation Details

1. **Reactive Architecture**:
   - Uses StreamBuilder to reactively rebuild UI on keyboard changes
   - Maintains synchronized state between native and Flutter layers

2. **Platform Integration**:
   - Monitors `avoidAreaChange` events (type 3 = keyboard)
   - Calculates visibility based on bottom rectangle height
   - Sends integer codes (1 = visible, 0 = hidden) for cross-platform compatibility

3. **Lifecycle Management**:
   - Automatically registers listener when stream is active
   - Cleans up resources when ability detaches
   - Handles event sink cancellation

This implementation provides a robust solution for monitoring keyboard visibility in Flutter applications running on HarmonyOS devices, enabling responsive UI adjustments based on keyboard state changes.