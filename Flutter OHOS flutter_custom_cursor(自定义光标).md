# flutter_custom_cursor

该插件允许直接从内存缓冲区创建/设置自定义鼠标光标。

## 使用

  1.先注册自定义光标

    // register this cursor
    cursorName = await CursorManager.instance.registerCursor(CursorData()
      ..name = "test"
      ..buffer =
      Platform.isWindows ? memoryCursorDataRawBGRA : memoryCursorDataRawPNG
      ..height = img.height
      ..width = img.width
      ..hotX = 0
      ..hotY = 0);
      
  cacheName注意，该函数将返回一个字符串registerCursor，可用于将此游标设置为系统或者删除此游标。

  2.设置自定义光标

   我们已经实现了FlutterCustomMemoryImageCursor类，它是 的子类MouseCursor。该类将自动为您设置内存光标。保持简单。
   
       MouseRegion(
      cursor: FlutterCustomMemoryImageCursor(key: cursorName),
      child: Row(
    children: [
      Text("Memory image here", style: style),
    ],
      ),
    ),

  3.删除光标
   
   `await CursorManager.instance.deleteCursor("cursorName");`


#### 鸿蒙OS代码

### 创建光标

      createCustomCursor(name: string, buffer: ArrayBufferLike, hotX: number, hotY: number): string | null {
    try {
      let imgSource = image.createImageSource(buffer)
      let customCursor: CustomCursor = {
    pixelMap: imgSource.createPixelMapSync(), focusX: hotX, focusY: hotY
      }
      this.caches.set(name, customCursor)
    } catch (e) {
      Log.e(TAG, "Catch: createCustomCursor Error : " + JSON.stringify(e));
      return null
    }
    return name
      }


### 设置光标

      setCustomCursor(name: string): boolean {
    try {
      if (!this.caches.has(name)) {
    return false
      }
      let cursor = this.caches.get(name)
      if (cursor != undefined) {
    pointer.setCustomCursorSync(
      this.mainWindow?.getWindowProperties().id,
      cursor.pixelMap,
      cursor.focusX,
      cursor.focusY)
      } else {
    return false
      }
    } catch (e) {
      Log.i(TAG, "Catch: setCustomCursor Error : " + JSON.stringify(e));
      return false
    }
    return true
      }
    
### 删除
	
      deleteCustomCursor(name: string): boolean {
    if (!this.caches.has(name)) {
      return false
    }
    try {
      this.caches.get(name)?.pixelMap.release()
      this.caches.delete(name)
    } catch (e) {
      Log.i(TAG, "Catch: deleteCustomCursor Error : " + JSON.stringify(e));
      return false
    }
    return true
      }

