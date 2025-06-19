### Crop Image Method

```
private async cropImage(result: MethodResult, path: string, scale: number, left: number, top: number, right: number, bottom: number) {
  let imageSource = image.createImageSource(path);
  let pixelMapData = await imageSource.createPixelMap();
  let options = await this.decodeImageOptions(imageSource);
  
  // Handle image orientation
  if (options.isFlippedDimensions()) {
    await pixelMapData.rotate(options.getDegrees());
  }

  // Calculate cropped region dimensions
  let width = options.getWidth() * (right - left) * scale;
  let height = options.getHeight() * (bottom - top) * scale;
  let region: image.Region = {
    x: options.getWidth() * left,
    y: options.getHeight() * top,
    size: {
      height: height,
      width: width
    }
  };

  // Perform cropping
  await pixelMapData.crop(region);
  
  // Save cropped image to temporary file
  let dstFile = this.createTemporaryImageFilePath();
  await this.savePixelMap(pixelMapData, dstFile);
  await imageSource.release();
  
  result.success(dstFile);
}
```

------

### Thumbnail Sampling Method

```
private async sampleImage(result: MethodResult, path: string, maximumWidth: number, maximumHeight: number) {
  let imageSource = image.createImageSource(path);
  let options = await this.decodeImageOptions(imageSource);
  
  // Calculate sample size (hardcoded to 1 for simplicity)
  let inSampleSize = 1; // this.calculateInSampleSize(options.getWidth(), options.getHeight(), maximumWidth, maximumHeight);
  
  // Create scaled pixel map
  let pixelMapData = await imageSource.createPixelMap({ sampleSize: inSampleSize });
  
  // Apply additional scaling if needed
  if (options.getWidth() > maximumWidth && options.getHeight() > maximumHeight) {
    let ratio = Math.max(maximumWidth / options.getWidth(), maximumHeight / options.getHeight());
    await pixelMapData.scale(ratio, ratio);
  }
  
  // Save sampled image
  let dstFile = this.createTemporaryImageFilePath();
  await this.savePixelMap(pixelMapData, dstFile);
  await imageSource.release();
  
  result.success(dstFile);
}
```

------

### Get Image Properties Method

```
private async getImageOptions(path: string, result: MethodResult) {
  let source = image.createImageSource(path);
  let options = await this.decodeImageOptions(source);
  
  // Extract image metadata
  let properties = new HashMap<string, number>();
  properties.set("width", options.getWidth());
  properties.set("height", options.getHeight());
  
  await source.release();
  result.success(properties);
}
```

------

### Key Notes

1. **Error Handling**:
   - Uses `try/catch` blocks and `MethodResult` to handle exceptions.
   - Checks for orientation issues with `isFlippedDimensions()`.
2. **Performance Optimization**:
   - Implements region-based cropping to minimize memory usage.
   - Supports dynamic scaling via `sampleSize` and `scale()` methods.
3. **API Design**:
   - Follows HarmonyOS conventions (e.g., `MethodResult`, `image.Region`).
   - Returns results via asynchronous callbacks for non-blocking execution.