# HarmonyOS Flutter File Sharing Plugin (Supports Text, Images, Videos, and Files)

------

## OHOS Platform Adaptation

### Installation Guide

Install via the OpenHarmony package manager:

```
ohpm install @ohos/share_extend
```

For OpenHarmony `ohpm` environment configuration, refer to:
 [How to Install OpenHarmony ohpm Packages](https://gitee.com/openharmony-tpc/docs/blob/master/OpenHarmony_har_usage.md).

------

## Usage Guide

### 1. Share Text

```
ShareExtend.share("Hello, HarmonyOS!", "text", subject: "Greetings");
```

### 2. Share Files

```
List<String> filePaths = ["/path/to/image.jpg", "/path/to/video.mp4"];
ShareExtend.shareMultiple(filePaths, "file", subject: "My Files");
```

### 3. Share Images/Videos

```
// Share a single image
ShareExtend.share("/path/to/image.jpg", "image");

// Share a single video
ShareExtend.share("/path/to/video.mp4", "video");
```

------

## Parameter Reference

### **Share Options**

| Parameter             | Type           | Description                                  | Default Value    |
| --------------------- | -------------- | -------------------------------------------- | ---------------- |
| `list`                | `List<String>` | List of file paths or text content           | Required         |
| `type`                | `String`       | Share type: `text`, `image`, `video`, `file` | Required         |
| `subject`             | `String`       | Share title (for Android/iOS)                | Empty string     |
| `sharePanelTitle`     | `String`       | Custom panel title (Android-only)            | Platform default |
| `sharePositionOrigin` | `Rect`         | Share position (iPadOS-only)                 | `null`           |
| `extraTexts`          | `List<String>` | Additional text (Android file/image sharing) | `[]`             |

------

## OHOS Backend Implementation

### **Share Class**

```
import { systemShare } from '@hms.collaboration.systemShare';
import uniformTypeDescriptor from '@ohos/data.uniformTypeDescriptor';

export default class Share {
  private ability?: UIAbility;

  setAbility(ability: UIAbility | undefined) {
    this.ability = ability;
  }

  shareText(text: string, withResult?: boolean, result?: MethodResult) {
    if (!this.ability) return;
    const record: systemShare.SharedRecord = {
      utd: uniformTypeDescriptor.getUniformDataTypeByMIMEType('text/plain'),
      content: text || ''
    };
    this.startShare(record, withResult, result);
  }

  async shareFiles(paths: List<string>, subject: string | null, withResult?: boolean, result?: MethodResult) {
    if (!this.ability) return;
    await this.clearShareCache();
    const fileUris = await this.getUrisForPaths(paths);
    if (!fileUris.length) return;
    
    const data = new systemShare.SharedData();
    fileUris.forEach((uri, index) => {
      const record: systemShare.SharedRecord = {
        utd: this.getUniformTypeDescriptor(uri),
        uri,
        title: subject || ''
      };
      data.addRecord(record);
    });
    this.startShare(data, withResult, result);
  }

  private startShare(data: systemShare.SharedData | null, withResult?: boolean, result?: MethodResult) {
    if (!this.ability || !data) return;
    try {
      const controller = new systemShare.ShareController(data);
      if (withResult) {
        controller.on('dismiss', () => result?.success(''));
      }
      controller.show(this.ability.context, {
        previewMode: systemShare.SharePreviewMode.DETAIL,
        selectionMode: systemShare.SelectionMode.BATCH
      });
    } catch (err) {
      Log.e(TAG, `Share failed: ${JSON.stringify(err)}`);
    }
  }

  private getUniformTypeDescriptor(fileUri: string): string {
    const extension = fileUri.split('.').pop() || '';
    return uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(extension) || 'general.file';
  }

  private async clearShareCache() {
    const folder = this.shareCacheFolder();
    if (folder && fs.existsSync(folder)) {
      fs.readdirSync(folder).forEach(file => fs.unlinkSync(`${folder}/${file}`));
      fs.rmdirSync(folder);
    }
  }

  private async copyToShareCache(file: string): Promise<string> {
    const folder = this.shareCacheFolder();
    if (!fs.existsSync(folder)) fs.mkdirSync(folder);
    const newFile = `${folder}/${path.basename(file)}`;
    fs.copyFileSync(file, newFile);
    return newFile;
  }

  private shareCacheFolder(): string {
    return this.ability?.context.cacheDir + '/share_extend' || '';
  }
}
```

------

## Flutter Plugin Integration

### **MethodChannelHandlerImpl**

```
import { MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import Share from './Share';

export default class MethodCallHandlerImpl implements MethodCallHandler {
  private share: Share;

  constructor(share: Share) {
    this.share = share;
  }

  onMethodCall(call: MethodCall, result: MethodResult) {
    const type = call.argument('type');
    const list = call.argument('list') as List<string>;
    try {
      if (type === 'text') {
        this.share.shareText(list[0]);
      } else {
        this.share.shareFiles(list, null);
      }
      result.success(null);
    } catch (err) {
      Log.e(TAG, `Error: ${JSON.stringify(err)}`);
      result.error('SHARE_FAILED', err.message, null);
    }
  }
}
```

------

## Key Features

- **Cross-Platform Sharing**: Works seamlessly on both Android and iOS.
- **Flexible File Support**: Handles text, images, videos, and generic files.
- **Customizable UI**: Adjust share panel titles and positions (iPadOS-only).
- **Error Handling**: Robust logging and callback mechanisms.