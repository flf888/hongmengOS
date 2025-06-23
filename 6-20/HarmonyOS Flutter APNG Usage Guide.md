# HarmonyOS Flutter APNG Usage Guide

------

## Introduction

**ohos_apng** is a high-performance APNG animation library for HarmonyOS, rebuilt based on the [apng-js](https://github.com/davidmz/apng-js) v1.1.2 decoder. It splits APNG frames into individual layers, combines them into `ImageBitmap` objects using ArkUI capabilities, and renders animations via `Canvas` with timers.

**Key Features**:

- Decodes APNG frames and combines them into animated images.
- Supports local, network, and in-memory resources.
- Customizable playback speed and memory caching.

------

## Installation

Install via the HarmonyOS package manager:

```
ohpm install @ohos/apng
```

------

## Usage Examples

### 1. **Passing Context in HSP Modules**

**Method 1**: Set global context in `EntryAbility`:

```
import { GlobalContext } from '@ohos/apng';

export default class EntryAbility extends UIAbility {
  onCreate() {
    GlobalContext.getContext().setObject('MainContext', this.context);
  }
}
```

**Method 2**: Pass context directly to components:

```
apngV2({
  src: $r('app.media.stack'),
  speedRate: this.speedRate,
  context: getContext() // Pass current context
});
```

------

### 2. **Basic Usage**

Import the APNG module:

```
import { apng, ApngController } from '@ohos/apng';
```

**Examples**:

```
// Local resource
apng({
  src: $r('app.media.stack'), // Resource ID
  speedRate: 1 // Playback speed (1x)
});

// Network resource
apng({
  src: 'https://example.com/animation.apng',
  speedRate: 2 // Double speed
});

// Uint8Array data
apng({
  src: this.uint8ArrayData, // Preloaded Uint8Array
  speedRate: 0.5 // Half speed
});

// Sandbox file path
apng({
  src: getContext().filesDir + '/animation.apng',
  speedRate: 1
});

// Custom dimensions
apng({
  src: $r('app_media.stack'),
  apngWidth: 300,
  apngHeight: 200
});

// Controller-based control
final controller = ApngController();
apng({
  src: $r('app_media.stack'),
  controller: controller // Control playback programmatically
});
controller.pause();
controller.stop();
```

------

### 3. **Event Listening**

Listen for APNG lifecycle events:

```
@override
aboutToAppear() {
  emitter.on("ohos-apng", (data) => {
    print('APNG event: $data');
  });
}
```

------

### 4. **Memory Cache Configuration**

Customize memory caching behavior:

```
// Initialize LRU cache (max entries: 200, max size: 128MB)
Apng.getInstance().initMemoryCache(new MemoryLruCache(200, 128 * 1024 * 1024));

// Enable/disable cache
Apng.getInstance().setEnableCache(true/false);

// Clear all caches
Apng.getInstance().removeAllMemoryCache();

// Clear specific cache by source URL
Apng.getInstance().removeMemoryCache('https://example.com/image.apng');
```

------

## Key APIs

### **ApngController**

| Method     | Description                         |
| ---------- | ----------------------------------- |
| `pause()`  | Pause animation                     |
| `stop()`   | Stop animation and reset to frame 0 |
| `resume()` | Resume paused animation             |

### **Global Configuration**

| Method                   | Description                            |
| ------------------------ | -------------------------------------- |
| `initMemoryCache(cache)` | Initialize custom memory cache         |
| `setEnableCache(enable)` | Enable/disable memory caching          |
| `removeAllMemoryCache()` | Clear all cached frames                |
| `removeMemoryCache(src)` | Remove cache for a specific source URL |

------

## Best Practices

1. **Resource Management**:

   - Use `Uint8Array` for large animations to avoid memory spikes.
   - Release unused resources with `removeMemoryCache()`.

2. **Performance**:

   - Avoid excessive frame rates (e.g., `speedRate > 3`).
   - Use `sandbox` paths for local files in release builds.

3. **Error Handling**:

   ```
   apng({
     src: 'invalid_url',
     onError: (error) => print('APNG load failed: $error')
   });
   ```