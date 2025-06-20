# OpenFileX Plugin

**Open Files in HarmonyOS Using String Paths**

------

## Usage

Add `open_filex` as a dependency in `pubspec.yaml`:

```
dependencies:
  open_filex: ^lastVersion
```

------

## Example

```
import 'package:open_filex/open_filex.dart';

OpenFilex.open("/sdcard/example.txt"); // Open a file using a string path
```

------

## HarmonyOS Code Implementation

### 1. Check File Availability

```
private isFileAvailable(path?: string): boolean {
  if (!path) {
    this.onResult(ResultType.error, "File path cannot be null");
    return false;
  }
  this.filePath = this.processPath(path);
  let file: fileIo.File | undefined;
  try {
    file = fileIo.openSync(this.filePath, fileIo.OpenMode.READ_ONLY);
    if (file) {
      fileIo.closeSync(file);
      return true;
    }
  } catch (e) {
    Log.e(TAG, `readImage failed: ${JSON.stringify(e)}`);
  }
  this.onResult(ResultType.fileNotFound, `File not found: ${this.filePath}`);
  return false;
}
```

### 2. Parse File Path

```
private processPath(path: string): string {
  if (path.includes(FILE_PROTOCOL_HEADER)) {
    return path;
  }
  if (path.startsWith("/")) {
    return `file:/${path}`;
  }
  return `file://${path}`;
}
```

### 3. Get File MIME Type

```
private getFileType(filePath: string): string {
  const fileExtension = filePath.split('.').pop() || '';
  this.getWantAction(fileExtension);
  return AllType.has(fileExtension) ? AllType.get(fileExtension)! : "*/*";
}
```

### 4. Select File

```
private startAbility() {
  const want: Want = this.getWantInfo(this.filePath);
  let type: number = ResultType.done;
  let message: string = "Success";
  try {
    this.ability?.context.startAbility(want);
  } catch (error) {
    const e = error as BusinessError;
    Log.i(TAG, `startAbility failed: ${JSON.stringify(e)}`);
    type = e.code === CAN_NOT_MATCH_ANY_COMPONENT 
      ? ResultType.noAppToOpen 
      : ResultType.error;
    message = e.code === CAN_NOT_MATCH_ANY_COMPONENT 
      ? "No app found to open this file." 
      : "Failed to open file.";
  }
  this.onResult(type, message);
}
```

### 5. Build Intent (Want)

```
private getWantInfo(path: string): Want {
  if (this.isMediaStorePath(path)) {
    return {
      bundleName: HARMONY_OS_PHOTOS_BUNDLE_NAME,
      abilityName: HARMONY_OS_PHOTOS_ABILITY_NAME,
      action: OHOS_WANT_ACTION_VIEW_DATA,
      parameters: { uri: path }
    };
  } else {
    return {
      flags: wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
      action: this.action,
      uri: path,
      type: this.typeString
    };
  }
}
```

### 6. Handle Results

```
private onResult(type: number, message: string) {
  if (this.result && !this.isResultSubmitted) {
    const resultMap: HashMap<string, string> = new HashMap();
    resultMap.set('type', type.toString());
    resultMap.set('message', message);
    const jsonResponse: Record<string, string> = {};
    resultMap.forEach((value, key) => {
      jsonResponse[key] = value;
    });
    this.result.success(JSON.stringify(jsonResponse));
    this.isResultSubmitted = true;
  }
}
```

------

## Key Features

- **Cross-Platform File Handling**: Works with local and media store paths.
- **Error Handling**: Detailed error messages for debugging.
- **Intent Generation**: Builds `Want` objects for opening files with system apps.