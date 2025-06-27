# Implementing AppLinking in HarmonyOS Next Atomic Services

## 1. Background Information

Official Documentation:  
[Atomic Service AppLinking Guide](https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/atomic-applinking-V5)

Key Requirements:
1. **Deep Linking**: Parse `pagePath` parameter to navigate to specific pages within atomic services
2. **Link Generation**: Create links programmatically for atomic service navigation
3. **Universal Usage**: Links work both within apps and via external sources (SMS, websites, etc.)

## 2. AppLinkingUtils Implementation

	```typescript
	import { common, Want, wantAgent } from '@kit.AbilityKit';
	import { GlobalContext } from './GlobalContext';
	import { router } from '@kit.ArkUI';
	import { AppUtil } from './AppUtil';
	import { BusinessError } from '@kit.BasicServicesKit';
	import { LogUtil } from './LogUtil';
	
	interface MessageReceivedParams {
	  want?: Want;
	  method: "onCreate" | "enterDnTabBarPage";
	}
	
	/**
	 * AppLinking Utility Class
	 * Official Docs: https://developer.huawei.com/consumer/cn/doc/atomic-guides-V5/atomic-applinking-V5
	 */
	export class AppLinkingUtils {
	  /**
	   * Handles incoming AppLinking requests
	   * @param params Contains either launch parameters or navigation command
	   */
	  static messageReceived(params: MessageReceivedParams) {
	    // Process incoming link parameters
	    if (params.want) {
	      const want = params.want;
	      const pagePath = want.parameters?.['pagePath'] as string;
	      
	      if (pagePath) {
	        // Store target path for later navigation
	        GlobalContext.getContext().setObject("appLinkingPagePath", pagePath);
	      }
	    }
	    
	    // Execute navigation when app is ready
	    if (params.method === "enterDnTabBarPage") {
	      const appLinkingPagePath = GlobalContext.getContext().getObject("appLinkingPagePath") as string;
	      
	      if (appLinkingPagePath) {
	        // Clear stored path and navigate
	        GlobalContext.getContext().deleteObject("appLinkingPagePath");
	        router.pushUrl({ url: appLinkingPagePath });
	      }
	    }
	  }
	  
	  /**
	   * Opens an AppLinking URL
	   * @param url The AppLinking URL to open
	   */
	  static openLink(url: string) {
	    const context: common.UIAbilityContext = AppUtil.getContext();
	    
	    context.openLink(url)
	      .then(() => {
	        LogUtil.info('AppLinking opened successfully');
	      })
	      .catch((error: BusinessError) => {
	        LogUtil.error(`AppLinking failed: ${JSON.stringify(error)}`);
	      });
	  }
	}
	```

## 3. Integration Points

### 3.1 EntryAbility Integration
	```typescript
	export default class EntryAbility extends UIAbility {
	  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
	    // Initialize application context
	    AppUtil.init(this.context);
	    
	    // Process AppLinking launch parameters
	    AppLinkingUtils.messageReceived({
	      want: want,
	      method: "onCreate"
	    });
	  }
	}
	```

### 3.2 Main Page Integration
	```typescript
	@Preview
	@Entry
	@Component
	struct DnTabBarPage {
	  aboutToAppear() {
	    // Execute AppLinking navigation when main page appears
	    AppLinkingUtils.messageReceived({
	      method: "enterDnTabBarPage"
	    });
	  }
	}
	```

## Implementation Workflow

1. **Link Creation**:
   - Create links in AppGallery Connect → AppLinking
   - Configure `pagePath` parameter for deep linking

2. **Link Handling**:
   - When app launches via link, `EntryAbility.onCreate()` captures `pagePath`
   - Path is stored in global context
   - When main page loads, it checks for stored path and navigates

3. **Programmatic Usage**:
   - Use `AppLinkingUtils.openLink()` to navigate to atomic services
   - Works for both in-app navigation and external triggers

## Key Features

1. **Deep Linking Support**:
   - Seamlessly navigates to specific pages within atomic services
   - Maintains navigation state across app lifecycle

2. **Lifecycle Management**:
   - Separates link capture (onCreate) and execution (page ready)
   - Ensures navigation only occurs when UI is prepared

3. **Error Handling**:
   - Comprehensive logging for debugging
   - Graceful error handling for invalid links

4. **Global State Management**:
   - Uses GlobalContext to persist navigation targets
   - Automatically cleans up after navigation

## Usage Examples

### 1. Creating AppLinking URLs
	```typescript
	// Generated in AppGallery Connect
	const DEEP_LINK = "https://hoas.drcn.agconnect.link/9P7g?pagePath=pages/DetailPage";
	```

### 2. Triggering Navigation
	```typescript
	// Navigate to atomic service from within app
	AppLinkingUtils.openLink(DEEP_LINK);
	
	// Open via SMS (same link works externally)
	sendSMS("Check this out: " + DEEP_LINK);
	```

### 3. Handling Incoming Links
	```
	User clicks: https://hoas.drcn.agconnect.link/9P7g?pagePath=pages/DetailPage
	
	App flow:
	1. EntryAbility captures pagePath ("pages/DetailPage")
	2. Stores path in GlobalContext
	3. Main page (DnTabBarPage) loads
	4. Detects stored path and navigates to DetailPage
	```

This implementation provides a complete solution for AppLinking in HarmonyOS Next atomic services, enabling both deep linking from external sources and programmatic navigation within applications.