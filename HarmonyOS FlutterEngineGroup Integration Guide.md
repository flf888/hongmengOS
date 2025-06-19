# HarmonyOS FlutterEngineGroup Integration Guide

## 1. Modifying EntryAbility to Extend UIAbility

	```ts
	export default class EntryAbility extends UIAbility implements ExclusiveAppComponent<UIAbility> {
	  // Detach from Flutter engine
	  detachFromFlutterEngine(): void {
	    // Implementation not required
	  }
	
	  // Get current UIAbility component
	  getAppComponent(): UIAbility {
	    return this;
	  }
	
	  static app?: EntryAbility; // Static application instance
	
	  // Called when ability is created
	  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
	    // Register current UIAbility
	    FlutterManager.getInstance().pushUIAbility(this);
	    EntryAbility.app = this;
	  }
	
	  // Called when ability is destroyed
	  onDestroy(): void | Promise<void> {
	    // Unregister UIAbility
	    FlutterManager.getInstance().popUIAbility(this);
	    EntryAbility.app = undefined;
	  }
	
	  // Called when window stage is created
	  onWindowStageCreate(windowStage: window.WindowStage): void {
	    // Register window stage
	    FlutterManager.getInstance().pushWindowStage(this, windowStage);
	    // Load main page content
	    windowStage.loadContent('pages/MainPage');
	  }
	
	  // Called when window stage is destroyed
	  onWindowStageDestroy() {
	    FlutterManager.getInstance().popWindowStage(this);
	  }
	}
	```

## 2. Encapsulating Flutter Engine Attach and Detach Operations

	```ts
	export class EngineBindings implements DataModelObserver {
	  private engine?: FlutterEngine;       // Flutter engine instance
	  private channel?: MethodChannel;      // Method channel
	  private context: common.Context;       // Context
	  private delegate: EngineBindingsDelegate; // Delegate object
	  private flutterView: FlutterView;     // Flutter view
	
	  constructor(context: common.Context, delegate: EngineBindingsDelegate) {
	    this.context = context;
	    this.delegate = delegate;
	    // Create Flutter view
	    this.flutterView = FlutterManager.getInstance().createFlutterView(context);
	  }
	
	  // Get Flutter view ID
	  getFlutterViewId() {
	    return this.flutterView.getId();
	  }
	
	  // Attach to Flutter engine
	  async attach() {
	    if (this.engine) {
	      Log.i("Multi->attach", "Engine already exists");
	      return;
	    }
	    
	    // Step 1: Register data model observer
	    DataModel.instance.addObserver(this);
	    
	    // Step 2: Check engine loader
	    await engines.checkLoader(this.context, []);
	    
	    // Step 3: Create launch configuration
	    let options: Options = new Options(this.context)
	        .setDartEntrypoint(DartEntrypoint.createDefault());
	    
	    // Step 4: Create and run engine
	    this.engine = await engines.createAndRunEngineByOptions(options) ?? undefined;
	    if (!this.engine) {
	      throw new Error("Engine creation failed");
	    }
	    
	    // Step 5: Notify app is resumed
	    this.engine.getLifecycleChannel()?.appIsResumed();
	    
	    // Step 6: Attach to ability
	    if (EntryAbility.app) {
	      this.engine.getAbilityControlSurface()?.attachToAbility(EntryAbility.app);
	    }
	    
	    // Step 7: Attach view to engine
	    this.flutterView.attachToFlutterEngine(this.engine);
	    
	    // Step 8: Register generated plugins
	    GeneratedPluginRegistrant.registerWith(this.engine);
	
	    // ... Additional initialization
	  }
	
	  // Detach from engine
	  detach() {
	    // 1. Detach view from engine
	    this.flutterView.detachFromFlutterEngine();
	    
	    // 2. Destroy engine
	    this.engine?.destroy();
	    
	    // 3. Remove data observer
	    DataModel.instance.removeObserver(this);
	    
	    // 4. Clear method channel
	    this.channel?.setMethodCallHandler(null);
	  }
	
	  // ... Additional methods
	}
	```

## 3. Invoking Flutter Engine Attach and Detach Operations

	```ts
	@Entry()
	@Component
	struct SingleFlutterPage {
	  @State viewId: string = "";  // View ID state
	  private context = getContext(this) as common.UIAbilityContext;
	  private engineBindings: EngineBindings = new EngineBindings(this.context, this);
	
	  // Navigate to next page
	  onNext() {
	    router.pushUrl({ "url": "pages/MainPage" });
	  }
	
	  // Called when page is about to appear
	  aboutToAppear() {
	    Log.i("Multi->aboutToAppear", "Single Flutter Page");
	    // Get Flutter view ID
	    this.viewId = this.engineBindings.getFlutterViewId();
	    Log.i("Multi->aboutToAppear", `View ID=${this.viewId}`);
	    // Attach to engine
	    this.engineBindings.attach();
	  }
	
	  // Called when page is about to disappear
	  aboutToDisappear(): void {
	    // Detach from engine
	    this.engineBindings.detach();
	  }
	
	  // Build UI
	  build() {
	    Column() {
	      // Display Flutter page
	      FlutterPage({ 
	        viewId: this.viewId, 
	        xComponentType: XComponentType.TEXTURE 
	      }).backgroundColor(Color.Transparent)
	    }
	  }
	}
	```

### Key Implementation Notes:
1. **Lifecycle Alignment**:
   - Engine attachment in `aboutToAppear`
   - Engine detachment in `aboutToDisappear`
   - Ensures proper resource cleanup

2. **Multi-Engine Management**:
   - Each `FlutterView` has its own engine instance
   - Centralized management through `FlutterManager`

3. **Error Handling**:
   - Explicit error on engine creation failure
   - Reverse initialization sequence during detachment

This implementation provides a robust pattern for integrating FlutterEngineGroup in HarmonyOS applications, enabling efficient multi-engine management and resource handling.