# HarmonyOS Flutter Video Trimmer (Video Clipping Implementation)

------

## Introduction

**videotrimmer** is a third-party library for video clipping capabilities in the **OpenHarmony** environment.

------

## Installation Guide

Install via the OpenHarmony package manager:

```
ohpm install @ohos/videotrimmer
```

For OpenHarmony `ohpm` environment configuration, refer to:
 [How to Install OpenHarmony ohpm Packages](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md).

------

## Usage Guide

### Step 1: Construct `VideoTrimmerOption`

```
getContext(this).resourceManager.getMediaContent($r('app.media.app_icon'))
  .then(uint8 => {
    let imageSource = image.createImageSource(uint8.buffer as any); // Step 1: Convert file to PixelMap and transform for Image component
    imageSource.createPixelMap().then(pixelmap => {
      this.videoTrimmerOption = {
        srcFilePath: this.filePath,
        listener: {
          onStartTrim: () => {
            console.log('Start trimming...');
            this.dialogController.open();
          },
          onFinishTrim: (path: string) => {
            console.log(`Trim completed. Output path: ${path}`);
            this.outPath = path;
            this.dialogController.close();
          },
          onCancel: () => {
            console.log('User canceled trimming');
            router.replaceUrl({ url: 'pages/Index', params: { outFile: this.outPath } });
          }
        },
        loadFrameListener: {
          onStartLoad: () => {
            console.log('Loading frame data...');
            this.dialogController.open();
          },
          onFinishLoad: () => {
            console.log('Frame data loaded.');
            this.dialogController.close();
          }
        },
        frameBackground: "#FF669900",
        framePlaceholder: pixelmap
      };
    });
  });
```

------

### Step 2: Use `VideoTrimmerView` in UI

```
@override
Widget build(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: Column(
          children: [
            VideoTrimmerView(videoTrimmerOption: this.videoTrimmerOption!)
          ]
        )
      ).width('100%')
    ]
  ).height('100%');
}
```

------

## Parameter Reference

### **VideoTrimmerOption (Video Clipping Options)**

| Field               | Description                               |
| ------------------- | ----------------------------------------- |
| `srcFilePath`       | Source video file path                    |
| `listener`          | Callbacks for trimming events             |
| `loadFrameListener` | Callbacks for frame loading progress      |
| `VIDEO_MAX_TIME`    | Maximum clip duration (default: 10s)      |
| `VIDEO_MIN_TIME`    | Minimum clip duration                     |
| `MAX_COUNT_RANGE`   | Number of thumbnails in seek bar          |
| `THUMB_WIDTH`       | Thumbnail edge padding width              |
| `PAD_LINE_HEIGHT`   | Thumbnail background padding height       |
| `framePlaceholder`  | Default placeholder while loading frames  |
| `frameBackground`   | Background color of the trim preview area |

------

### **VideoTrimListener (Clipping Callbacks)**

| Method           | Parameters           | Description                                             |
| ---------------- | -------------------- | ------------------------------------------------------- |
| `onStartTrim()`  | None                 | Triggered when trimming starts                          |
| `onFinishTrim()` | `outputFile: string` | Triggered when trimming completes (returns output path) |
| `onCancel()`     | None                 | Triggered when user cancels                             |

------

### **VideoLoadFramesListener (Frame Loading Callbacks)**

| Method           | Parameters | Description                            |
| ---------------- | ---------- | -------------------------------------- |
| `onStartLoad()`  | None       | Triggered when frame loading starts    |
| `onFinishLoad()` | None       | Triggered when frame loading completes |

------

## Key Features

- **Native Video Clipping**: Leverage OpenHarmony’s video processing capabilities.
- **Customizable UI**: Adjust thumbnail count, colors, and placeholders.
- **Progressive Loading**: Show loading states while processing large videos.

For more details, refer to the official [videotrimmer documentation](https://example.com/videotrimmer-docs).