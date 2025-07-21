# Toggle Component Quick Start Guide

The **Toggle** component in HarmonyOS provides versatile switch functionality, including checkbox, state button, and switch styles. Below is a concise guide to using it:

=================================================================================================================================================================================================================================


Getting Started with HarmonyOS (Java)

AppGallery Connect provides you with various development services in terms of building, quality, and growth. The development process of an AppGallery Connect service is as follows:

Prepare a development environment.
Create your project and app.
Set a data processing location.
Integrate required AppGallery Connect SDKs.
Develop the app.
Integrate required AppGallery Connect services.
Preparing a Development Environment
Install HUAWEI DevEco Studio.
Google Chrome is recommended for accessing AppGallery Connect. If you are using Mozilla Firefox on Windows 10, requests may be blocked by the browser and download button clicks may have no responses.
You can perform the following operations to solve this issue:

Enter about:config in the address box of the Firefox browser.
Search for security.csp.enable and change its value to false.
Register as a Huawei developer and complete identity verification on HUAWEI Developers.
Creating Your Project and App
A project is a container of your apps in AppGallery Connect. You can add different platform versions of an app to the same project. If you do not have any projects yet, create one to get started.
If you have not added any apps to your project, add a new one or an existing one to your project first. An app can be added to only one project.
Setting a Data Processing Location
Some services in AppGallery Connect involve app data processing. Before using these services, you need to set a data processing location.

Integrating Required AppGallery Connect SDKs
To use any of the following AppGallery Connect services, integrate their AppGallery Connect SDKs to your development environment in advance. Currently, the following services provide HarmonyOS SDKs for Java:

Crash
Remote Configuration
App Linking
Auth Service
Cloud Functions
App Messaging
Cloud DB
Cloud Storage
Adding the Configuration File
To free you from complex configurations, AppGallery Connect provides a configuration file storing your app configurations. You simply need to add the configuration file to your project and integrate the AppGallery Connect plugin. The AppGallery Connect plugin will automatically load the app information configured in AppGallery Connect to your development environment.

Sign in to AppGallery Connect and click Development and services.
Select your desired project and app.


Go to Project settings > General information and download the configuration file agconnect-services.json.
NOTE
The configuration file contains the client secret and API key allocated by AppGallery Connect to your app by default. Both the client secret and API key are in ciphertext.
If you select Do not include key before downloading the configuration file, your client secret and API key will not be included in the file. In this case, you need to call the APIs of the AppGallery Connect SDK to set relevant parameters manually in the configuration file.
If your plan is upgraded to a paid tier, you are advised to store the client secret and API key on your own server and ensure they are kept secure to prevent unauthorized use, which could lead to abnormal charges.


Copy the agconnect-services.json file to the directory of the entry module.


Configuring the SDK Addresses
After adding the configuration file to your project, you need to configure the Maven repository address and AppGallery Connect plugin address in the Huawei DevEco Studio project.

Configure the Maven repository address and AppGallery Connect plugin address.
Open the project-level build.gradle file.


Go to allprojects > repositories and ensure that the Maven repository address has been configured.
allprojects { 
            repositories { 
                maven {url 'https://repo.huaweicloud.com/repository/maven/' } 
                maven {url 'https://developer.huawei.com/repo/'} 
                jcenter() 
            } 
        }
Go to buildscript > repositories and ensure that the Maven repository address has been configured.
buildscript { 
            repositories { 
                maven {url 'https://repo.huaweicloud.com/repository/maven/' } 
                maven {url 'https://developer.huawei.com/repo/'} 
                jcenter() 
            } 
 }
Go to buildscript > dependencies and configure the AppGallery Connect plugin address.
buildscript {
    dependencies {
        classpath 'com.huawei.agconnect:agcp-harmony:1.5.1.300'
    } 
}
Add build dependencies.
Open the app-level build.gradle file.


Add the following configuration under com.huawei.ohos.hap:
apply plugin: 'com.huawei.agconnect'
Add a dependency on agconnect-core to the dependencies block.
dependencies {      
      implementation 'com.huawei.agconnect:agconnect-core-harmony:1.5.1.300'    
}
Add a dependency on AppGallery Connect services to the dependencies block.
Service

Configuration

Remote Configuration

implementation 'com.huawei.agconnect:agconnect-remoteconfig-harmony:1.5.1.300'

App Linking

implementation 'com.huawei.agconnect:agconnect-applinking-harmony:1.5.1.300'

Auth Service

implementation "com.huawei.agconnect:agconnect-auth-harmony:1.5.1.300"

Cloud Functions

implementation 'com.huawei.agconnect:agconnect-function-harmony:1.5.1.300'

App Messaging

implementation 'com.huawei.agconnect:agconnect-appmessaging-harmony:1.5.1.300'

Cloud Storage

implementation 'com.huawei.agconnect:agconnect-storage-harmony:1.5.1.300'

Cloud DB

implementation 'com.huawei.agconnect:agconnect-cloud-database-harmony:1.5.1.300'

Open the modified build.gradle file again. Click Sync Now in the upper right corner of the page and wait until synchronization is complete.


Initializing the AppGallery Connect SDK
NOTE
You are advised to perform the initialization in the onInitialize method of AbilityPackage or the onStart method of the first started Ability.

Initialize the AppGallery Connect SDK as follows:

If you have deselected Do not include key when downloading the configuration file, you can use the default configuration to initialize the AppGallery Connect SDK.
// Add the following code:
try {
    AGConnectInstance.initialize(getAbilityPackage());
} catch (Exception e) {
    e.printStackTrace();
}
// Code adding ends.
If you have selected Do not include key when downloading the configuration file, you need to customize parameters in the configuration file and then initialize the AppGallery Connect SDK.
The AppGallery Connect SDK provides the AGConnectOptionsBuilder class to set parameters in the agconnect-services.json file. If you have selected Do not include key when downloading the file, the file does not include the client_id, client_secret, and api_key parameters. You must set these parameters in the AppGallery Connect SDK through the AGConnectOptionsBuilder class during app launch.
// Add the following code:
try {
    AGConnectOptionsBuilder builder = new AGConnectOptionsBuilder();
    ResourceManager resourceManager = getResourceManager();
    // Path to the agconnect-services.json file.
    RawFileEntry rawFileEntry =  resourceManager.getRawFileEntry("resources/rawfile/agconnect-services.json");
    Resource resource = rawFileEntry.openRawFile();
    builder.setInputStream(resource );
    // If the client_id, client_secret, and api_key parameters are not set in your JSON file, call the following APIs to set them:
    builder.setClientId("your client_id ...");
    builder.setClientSecret("your client_secret ...");
    builder.setApiKey("your api_key ...");
    AGConnectInstance.initialize(getAbilityPackage(), builder);
} catch (Exception e) {
    e.printStackTrace();
}
// Code adding ends.
You can go to Project settings > General information and query the value of each parameter, or click  next to a parameter to copy the parameter value.

Replace the parameters in the code with the settings on the General information tab page as follows:

Replace client_id with the value of Client ID in the Project information area.
Replace client_secret with the value of Client secret in the Project information area.
Replace api_key with the value of API key in the Project information area.
Replace cp_id with the value of Developer ID in the Developer information area.
Replace product_id with the value of Project ID in the Project information area.
Replace app_id with the value of App ID in the App information area.


Configuring Obfuscation Scripts
Before building the APP package, configure obfuscation scripts to prevent the AppGallery Connect SDK from being obfuscated. If obfuscation arises, the AppGallery Connect SDK may not function properly.

Open the obfuscation configuration file.
Add configurations to exclude the AppGallery Connect SDK from obfuscation.
If ProGuard‎ is used, implement the following configurations:
-ignorewarnings
-keep class com.huawei.agconnect.**{*;}
If DexGuard is used, implement the following configurations:

-ignorewarnings
-keep class com.huawei.agconnect.** {*;} 
-keepresourcexmlelements ** 
-keepresources */*
Developing the App
This section does not describe app function development in detail. You need to complete the development by yourself.



=======================================================================================================================================

### 1. Component Introduction and Basic Structure

- **Version Requirement**: Supported from **API Version 8**. Ensure your project meets this requirement.
- **Basic Usage**:
   In your `.ets` file, import and initialize the `Toggle` component within a `Column` or other layout:

```
@Entry
@Component
struct ToggleExample {
  build() {
    Column({ space: 10 }) {
      // Add Toggle components here
    }
    .width('100%')
    .padding(24);
  }
}
```

------

### 2. Setting Toggle Styles

Create a `Toggle` instance with the `type` parameter to define its style:

- `ToggleType.Checkbox` (checkbox style)
- `ToggleType.Button` (state button style with optional text)
- `ToggleType.Switch` (switch style)

**Example**:

```
Toggle({ type: ToggleType.Switch, isOn: false });
```

------

### 3. Style Customization

- **Background Color**: Use `selectedColor` for the active state:

  ```
  .selectedColor('#007DFF')
  ```

- **Slider Color (Switch Only)**: Customize the switch thumb color:

  ```
  .switchPointColor('#FFFFFF')
  ```

- **Advanced Switch Styles (API 12+)**:
   Use `switchStyle` to refine slider appearance:

  ```
  .switchStyle({
    pointRadius: 15,
    trackBorderRadius: 10,
    pointColor: '#D2B48C',
    unselectedColor: Color.Pink
  });
  ```

------

### 4. Event Handling

Listen for state changes with the `onChange` event:

```
.onChange((isOn: boolean) => {
  console.info('Toggle status: ' + isOn);
});
```

------

### 5. Advanced Customization (API 12+)

Implement the `ContentModifier` interface for full styling control:

```
class MySwitchStyle implements ContentModifier<ToggleConfiguration> {
  build(context: Context, config: ToggleConfiguration) {
    // Custom UI logic here
  }
}

Toggle({ type: ToggleType.Switch })
  .contentModifier(new MySwitchStyle())
  .onChange((isOn) => console.info('Switch state: ' + isOn));
```

------

### Summary

The **Toggle** component is ideal for:

- Checkbox-style selections
- Stateful buttons with optional text
- Customizable switch controls
- Responsive UI designs

For deeper customization, explore combining `ContentModifier` with state management or animations.
