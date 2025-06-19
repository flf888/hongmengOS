# Obtaining System File Paths in Flutter + HarmonyOS NEXT Development

During development, you often need to access system directories like temporary files, documents, etc. This guide explains how to use the `path_provider` plugin in Flutter for HarmonyOS NEXT. The OpenHarmony SIG has adapted this plugin for HarmonyOS NEXT - here's how to implement it:

## 1. Add Dependency in pubspec.yaml

```
dependencies:
  path_provider:
    git:
      url: "https://gitee.com/openharmony-sig/flutter_packages.git"
      path: "packages/path_provider/path_provider"
```

Run `flutter pub get` - this automatically adds HAR dependencies in `ohos/entry/oh-package.json5`:

```
{
  "name": "entry",
  "version": "1.0.0",
  "dependencies": {
    "@ohos/flutter_ohos": "file:../har/flutter.har",
    "path_provider_ohos": "file:../har/path_provider_ohos.har"
  }
}
```

## 2. Import the Plugin

```
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
```

## 3. Access System Paths

```
// Initialize provider
final PathProviderPlatform provider = PathProviderPlatform.instance;

// Directory references
Future<String?>? _tempDirectory;
Future<String?>? _appSupportDirectory;
Future<String?>? _appDocumentsDirectory;
Future<String?>? _appCacheDirectory;
Future<String?>? _externalDocumentsDirectory;
Future<List<String>?>? _externalStorageDirectories;
Future<List<String>?>? _externalCacheDirectories;
Future<String?>? _downloadsDirectory;

// Get temporary directory
void _requestTempDirectory() {
  setState(() {
    _tempDirectory = provider.getTemporaryPath();
  });
}

// Get documents directory
void _requestAppDocumentsDirectory() {
  setState(() {
    _appDocumentsDirectory = provider.getApplicationDocumentsPath();
  });
}

// Get application support directory
void _requestAppSupportDirectory() {
  setState(() {
    _appSupportDirectory = provider.getApplicationSupportPath();
  });
}

// Get cache directory
void _requestAppCacheDirectory() {
  setState(() {
    _appCacheDirectory = provider.getApplicationCachePath();
  });
}

// Get external storage directory
void _requestExternalStorageDirectory() {
  setState(() {
    _externalDocumentsDirectory = provider.getExternalStoragePath();
  });
}

// Get specific external storage directories
void _requestExternalStorageDirectories(StorageDirectory type) {
  setState(() {
    _externalStorageDirectories = provider.getExternalStoragePaths(type: type);
  });
}

// Get external cache directories
void _requestExternalCacheDirectories() {
  setState(() {
    _externalCacheDirectories = provider.getExternalCachePaths();
  });
}

// Get downloads directory
void _requestDownloadsDirectory() {
  setState(() {
    _downloadsDirectory = provider.getDownloadsPath();
  });
}
```

### Key Methods:

1. **Temporary Files**: `getTemporaryPath()`
2. **App Documents**: `getApplicationDocumentsPath()`
3. **App Support**: `getApplicationSupportPath()`
4. **Cache**: `getApplicationCachePath()`
5. **External Storage**: `getExternalStoragePath()`
6. **Specific External Storage**: `getExternalStoragePaths(type: StorageDirectory)`
7. **External Cache**: `getExternalCachePaths()`
8. **Downloads**: `getDownloadsPath()`

### StorageDirectory Types:

```
enum StorageDirectory {
  root,        // Root directory
  music,       // Music files
  podcasts,    // Podcasts
  ringtones,   // Ringtones
  alarms,      // Alarms
  notifications, // Notifications
  pictures,    // Pictures
  movies,      // Movies
  downloads,   // Downloads
  dcim,        // Camera photos
  documents,   // Documents
}
```

This implementation provides full access to HarmonyOS NEXT's file system directories within your Flutter application.