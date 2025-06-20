
# Flutter App Scheme Implementation Guide

## Configuration Instructions

### 1. Android Configuration
Add the scheme configuration in your project's `AndroidManifest.xml` file (e.g., `android/app/src/main/AndroidManifest.xml`):

#### a. Add the following intent-filter to your launch Activity:
	```xml
	<!-- Android Scheme Configuration -->
	<intent-filter>
	  <action android:name="android.intent.action.VIEW" />
	  <category android:name="android.intent.category.DEFAULT" />
	  <!-- Required for web-based app launching -->
	  <category android:name="android.intent.category.BROWSABLE" />
	  <category android:name="android.intent.category.APP_BROWSER" />
	  <!-- Scheme definition -->
	  <data
	    android:host="hong.com"
	    android:path="/product"
	    android:scheme="app" />
	</intent-filter>
	```

### 2. iOS Configuration
Add the scheme configuration in your project's `Info.plist` file (e.g., `ios/Runner/Info.plist`):

#### a. Add the following configuration to your Info.plist:
	```xml
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	  <dict>
	    ...
	    <key>CFBundleURLTypes</key> <!-- Scheme configuration container -->
	    <array>
	      <dict>
	        <key>CFBundleURLName</key>
	        <string>hong.com/product</string>
	        <key>CFBundleURLSchemes</key>
	        <array>
	          <string>app</string> <!-- Your scheme identifier -->
	        </array>
	      </dict>
	    </array>
	    ...
	  </dict>
	</plist>
	```

## Implementation Methods

### 1. Initialization
	```dart
	AppScheme appScheme = AppSchemeImpl.getInstance();
	```

### 2. Get Initial Scheme
	```dart
	appScheme.getInitScheme().then((value) {
	  if(value != null) {
	    setState(() {
	      _platformVersion = "Init ${value.dataString}";
	    });
	  }
	});
	```

### 3. Get Latest Scheme
	```dart
	appScheme.getLatestScheme().then((value) {
	  if(value != null) {
	    setState(() {
	      _platformVersion = "Latest ${value.dataString}";
	    });
	  }
	});
	```

### 4. Register Scheme Listener
	```dart
	appScheme.registerSchemeListener().listen((event) {
	  if(event != null) {
	    setState(() {
	      _platformVersion = "Listen ${event.dataString}";
	    });
	  }
	});
	```

## URL Scheme Format Specification
A complete URL Scheme consists of the following components:
	
	```
	<scheme>://<host>:<port>/<path>?<query>
	```

Example:  
`openapp://hhong:80/product?productId=10000007`

- **scheme**: Protocol identifier (required)  
  Example: `openapp`
- **host**: Target domain (required)  
  Example: `hhong`
- **port**: Connection port  
  Example: `80`
- **path**: Target page/resource  
  Example: `/product`
- **query**: Parameters (formatted as `key=value` pairs separated by `&`)  
  Example: `productId=10000007`

Parameters follow web conventions:  
- Separated from path by `?`
- Key-value pairs joined by `=`
- Multiple parameters joined by `&`

## Implementation Considerations
When implementing scheme handling:
1. Consider initializing scheme handling at the **Splash Screen** if your app requires:
   - Authentication token validation
   - Critical initialization checks
   - Pre-launch security verifications
2. Save scheme parameters during initialization
3. Process navigation in your main interface after critical setup completes
4. Alternative: Handle schemes in specific screens if they don't require global initialization

## HTML Implementation Example
    ```html
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset='utf-8'>
      <meta name='viewport' content='width=device-width, initial-scale=1, user-scalable=no'>
      <title>App Scheme Test Page</title>
    </head>
    <body>
      <!-- Standard scheme links -->
      <a href="app://hong.com/product?productId=10000007">Android & iOS</a>
      
      <a href="app://">app:// (no host)</a>
      
      <a href="app://hong.com">app:// (no path)</a>
      
      <a href="app://hong.com/product">app:// (no query)</a>
      
      <!-- Android-specific format -->
      <a href="intent://hong.com/product?productId=10000007#Intent;scheme=app;end">
    Android Special Format
      </a>
      
      <!-- E-commerce example -->
      <div style="text-align:center;">
    <h4>E-commerce Test</h4>
    <a href="shopapp://api.shop.com/home?type=1&ios_redirect=example.com&android_redirect=example.com">
      Test Type 1
    </a>
    <a href="intent://api.shop.com/home?type=1&ios_redirect=example.com&android_redirect=example.com#Intent;scheme=shopapp;end">
      Android Special Format
    </a>
      </div>
    </body>
    </html>
    ```
