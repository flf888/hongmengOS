### Create Custom Cursor

```
createCustomCursor(name: string, buffer: ArrayBufferLike, hotX: number, hotY: number): string | null {
  try {
    // Create image source from buffer
    let imgSource = image.createImageSource(buffer);
    // Create custom cursor object
    let customCursor: CustomCursor = {
      pixelMap: imgSource.createPixelMapSync(), // Synchronized pixel map creation
      focusX: hotX, // X-axis hotspot coordinate
      focusY: hotY  // Y-axis hotspot coordinate
    };
    // Cache the custom cursor
    this.caches.set(name, customCursor);
  } catch (e) {
    Log.e(TAG, `createCustomCursor Error: ${JSON.stringify(e)}`);
    return null;
  }
  return name;
}
```

------

### Set Custom Cursor

```
setCustomCursor(name: string): boolean {
  try {
    // Check if cursor exists in cache
    if (!this.caches.has(name)) return false;
    // Retrieve cursor from cache
    let cursor = this.caches.get(name);
    if (cursor) {
      // Synchronously apply custom cursor to system pointer
      pointer.setCustomCursorSync(
        this.mainWindow?.getWindowProperties().id, // Window ID
        cursor.pixelMap, // PixelMap data
        cursor.focusX, // Hotspot X
        cursor.focusY  // Hotspot Y
      );
    } else {
      return false;
    }
  } catch (e) {
    Log.i(TAG, `setCustomCursor Error: ${JSON.stringify(e)}`);
    return false;
  }
  return true;
}
```

------

### Delete Custom Cursor

```
deleteCustomCursor(name: string): boolean {
  if (!this.caches.has(name)) return false;
  try {
    // Release pixelMap resources
    this.caches.get(name)?.pixelMap.release();
    // Remove cursor from cache
    this.caches.delete(name);
  } catch (e) {
    Log.i(TAG, `deleteCustomCursor Error: ${JSON.stringify(e)}`);
    return false;
  }
  return true;
}
```

------

### Key Notes

1. 

   Memory Management

   :

   - Explicitly releases `pixelMap` resources in `deleteCustomCursor` to prevent memory leaks.

2. 

   Error Handling

   :

   - Logs detailed error messages for debugging.
   - Returns `null`/`false` on failure to indicate invalid operations.

3. 

   Hotspot Coordinates

   :

   - `focusX`/`focusY` define the cursor's "active" point (e.g., tip of arrow).
