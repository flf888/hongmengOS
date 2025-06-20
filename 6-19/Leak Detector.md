# Leak Detector

**Flutter Memory Leak Detection Tool (HarmonyOS Adaptation)**

------

## Getting Started

### Initialization

To avoid crashes in the underlying `vm_service` library, initialize before adding memory leak detection objects:

```
// maxRetainingPath: Maximum length of the reference chain (shorter values improve performance but may truncate leak paths; default is 300)
LeakDetector().init(maxRetainingPath: 300);
```

**Note**: Enabling leak detection may degrade performance due to full GC cycles. The plugin uses `assert` statements, so it does not need to be disabled in release builds.

------

### Detection

Add `LeakNavigatorObserver` to `MaterialApp` to automatically detect memory leaks in pages and their associated `StatefulWidget` states:

```
import 'package:leak_detector/leak_detector.dart';

@override
Widget build(BuildContext context) {
  return MaterialApp(
    navigatorObservers: [
      LeakNavigatorObserver(
        // Skip validation for specific routes (e.g., root '/')
        shouldCheck: (route) => route.settings.name != null && route.settings.name != '/',
      ),
    ],
  );
}
```

------

### Retrieve Leak Information

Register a listener for `onLeakedStream` to receive leak notifications with reference chain data:

```
LeakDetector().onLeakedStream.listen((LeakedInfo info) {
  // Print reference chain to console
  info.retainingPath.forEach((node) => print(node));
  
  // Show leak preview page
  showLeakedInfoPage(navigatorKey.currentContext!, info);
});
```

The `LeakedInfo` object includes:

- Class information for each node in the reference chain
- Referenced property details
- Source code declaration locations (file:line:column)

------

### Memory Leak History

Retrieve historical leak records:

```
getLeakedRecording().then((List<LeakedInfo> infoList) {
  showLeakedInfoListPage(navigatorKey.currentContext!, infoList);
});
```

------

## Troubleshooting Real-Device `vm_service` Connection Issues

**Problem**:
 `vm_service` operates in ​**Single Client Mode**:

- When `DDS` (Dart Development Service) connects to `vm_service`, it enters single-client mode.
- Subsequent WebSocket connections (e.g., from `leak_detector`) are blocked until `DDS` disconnects.

**Solutions**:

1. **Manual Reconnection**:

   - Disconnect from the computer after running `flutter run`.
   - Restart the app (avoids DDS interference).

2. **Disable DDS**:
    Add `--disable-dds` to `flutter run` to bypass the debugger’s `DDS` service:

   ```
   flutter run --disable-dds
   ```

   This ensures `leak_detector` can connect directly to `vm_service` on the device.

