# open_filex

以字符串结果打开文件的插件

## 用法

  要使用此插件，请在 pubspec.yaml 文件中添加open_filex作为依赖项。
    
    dependencies:
      open_filex: ^lastVersion

## 例子

     import 'package:open_filex/open_filex.dart';
    
    OpenFilex.open("/sdcard/example.txt");
      
  

#### 鸿蒙OS代码

### 文件是否可用

      private isFileAvailable(path?: string): boolean {
    if (!path) {
      this.onResult(ResultType.error, "the file path cannot be null");
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
      Log.e(TAG, `readImage failed:${JSON.stringify(e)}`);
    }
    this.onResult(ResultType.fileNotFound, "the " + this.filePath + " file does not exists");
    return false;
      }


### 解析路径

      private processPath(path: string): string {
    if (path.includes(FILE_PROTOCOL_HEADER)) {
      return path
    }
    if (path.substring(0, 1) == "/") {
      return "file:/" + path
    }
    return "file://" + path
      }
    
### 获取文件类型
	
      private getFileType(filePath: string): string {
    let fileTypeStr: string = filePath.substring(filePath.lastIndexOf('.') + 1);
    this.getWantAction(fileTypeStr)
    if (AllType.has(fileTypeStr)) {
      return AllType.get(fileTypeStr)!
    } else {
      return "*/*";
    }
      }

### 选择文件

       private startAbility() {
    const want: Want = this.getWantInfo(this.filePath);
    let type: number = ResultType.done;
    let message: string = "done";
    try {
      this.ability?.context.startAbility(want);
    } catch (error) {
      let e = error as BusinessError;
      Log.i(TAG, `startAbility failed:${JSON.stringify(e)}`);
      if (e.code = CAN_NOT_MATCH_ANY_COMPONENT) {
    type = ResultType.noAppToOpen;
    message = "No APP found to open this file。";
      } else {
    type = ResultType.error;
    message = "File opened incorrectly。";
      }
    }
    this.onResult(type, message);
      }
    
      private getWantInfo(path: string): Want {
    let want: Want;
    if (this.isMediaStorePath(path)) {
      want = {
    bundleName: HARMONY_OS_PHOTOS_BUNDLE_NAME,
    abilityName: HARMONY_OS_PHOTOS_ABILITY_NAME,
    action: OHOS_WANT_ACTION_VIEW_DATA,
    parameters: {
      uri: path
    }
      }
    } else {
      want = {
    flags: wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION | wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION,
    action: this.action,
    uri: path,
    type: this.typeString,
      };
    }
    return want;
      }


### 回调
 
       private onResult(type: number, message: string) {
    if (this.result != null && !this.isResultSubmitted) {
      let map: HashMap<string, string> = new HashMap()
      map.set('type', type.toString())
      map.set('message', message)
      let obj: Record<string, string> = {};
      map.forEach((value: string, key: string) => {
    obj[key] = value;
      })
      this.result.success(JSON.stringify(obj));
      this.isResultSubmitted = true;
    }
      }