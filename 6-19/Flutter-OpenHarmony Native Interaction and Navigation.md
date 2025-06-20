# Flutter-OpenHarmony Native Interaction and Navigation

## 1. EntryAbility Extending UIAbility

	```ts
	export default class EntryAbility extends UIAbility implements ExclusiveAppComponent<UIAbility> {
	
	  // Detach from Flutter engine
	  detachFromFlutterEngine(): void {
	    // Method implementation goes here
	  }
	
	  // Get current UIAbility component
	  getAppComponent(): UIAbility {
	    return this;
	  }
	
	  // Called when ability is created
	  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
	    // Register this UIAbility with Flutter manager
	    FlutterManager.getInstance().pushUIAbility(this);
	  }
	
	  // Called when ability is destroyed
	  onDestroy(): void | Promise<void> {
	    // Unregister this UIAbility from Flutter manager
	    FlutterManager.getInstance().popUIAbility(this);
	  }
	
	  // Called when window stage is created
	  onWindowStageCreate(windowStage: window.WindowStage): void {
	    // Set full screen layout
	    windowStage.getMainWindowSync().setWindowLayoutFullScreen(true);
	    // Register window stage with Flutter manager
	    FlutterManager.getInstance().pushWindowStage(this, windowStage);
	    // Load content
	    windowStage.loadContent('pages/Index');
	  }
	
	  // Called when window stage is destroyed
	  onWindowStageDestroy() {
	    // Unregister window stage from Flutter manager
	    FlutterManager.getInstance().popWindowStage(this);
	  }
	}
	```

## 2. Extending FlutterEntry and Registering Plugins

	```ts
	export default class MyFlutterEntry extends FlutterEntry {
	  
	  // Configure Flutter engine
	  configureFlutterEngine(flutterEngine: FlutterEngine): void {
	    // Call parent configuration
	    super.configureFlutterEngine(flutterEngine);
	    
	    // Register generated plugins
	    GeneratedPluginRegistrant.registerWith(flutterEngine);
	    
	    // Add custom plugin (BatteryPlugin example)
	    this.delegate?.addPlugin(new BatteryPlugin());
	  }
	}
	```

## 3. Using FlutterEntry with FlutterView

	```ts
	@Entry
	@Component
	struct Index {
	  private flutterEntry: FlutterEntry | null = null;
	  private flutterView?: FlutterView
	
	  // Called when component is about to appear
	  aboutToAppear() {
	    Log.d("Flutter", "Index aboutToAppear===");
	    // Initialize Flutter entry
	    this.flutterEntry = new MyFlutterEntry(getContext(this))
	    this.flutterEntry.aboutToAppear()
	    // Get Flutter view
	    this.flutterView = this.flutterEntry.getFlutterView()
	  }
	
	  // Called when component is about to disappear
	  aboutToDisappear() {
	    Log.d("Flutter", "Index aboutToDisappear===");
	    this.flutterEntry?.aboutToDisappear()
	  }
	
	  // Called when page is shown
	  onPageShow() {
	    Log.d("Flutter", "Index onPageShow===");
	    this.flutterEntry?.onPageShow()
	  }
	
	  // Called when page is hidden
	  onPageHide() {
	    Log.d("Flutter", "Index onPageHide===");
	    this.flutterEntry?.onPageHide()
	  }
	
	  // Component layout
	  build() {
	    Stack() {
	      // Display Flutter page
	      FlutterPage({ viewId: this.flutterView?.getId() })
	      
	`      // Navigation button
	      Button('Navigate to Page 2')
	        .onClick(() => {
	          try {
	            // Route to second page
	            router.pushUrl({ url: 'pages/Index2', params: { route: '/second' } })
	          } catch (err) {
	            Log.d("Flutter", "Navigation to Page 2 error ===" + JSON.stringify(err));
	          }
	        })
	    }`
	  }
	}
	```
