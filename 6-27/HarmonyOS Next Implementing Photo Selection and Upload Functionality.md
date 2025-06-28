# HarmonyOS Next: Implementing Photo Selection and Upload Functionality

## Implementation Journey

Initially, we used the `PickerUtil.selectPhoto` method from the [HarmonyUtils Library](https://ohpm.openharmony.cn/#/cn/detail/@pura%2Fharmony-utils) to select photos from the gallery, which returns a `fileUri`. However, this library lacks an upload API. To address this, we researched Huawei’s official documentation and forums and discovered the [HarmonyOS File Upload API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-request-V5#requestuploadfile9), which allows direct file uploads.

------

## Code Implementation

### 1. Upload Function Wrapper

```
import { request, BusinessError } from '@kit.BasicServicesKit';
import { LogUtil } from '../common/utils/LogUtil';
import { PreferencesUtil } from '../common/utils/PreferencesUtil';
import UserCacheManager from '../common/utils/UserCacheManager';
import CommonHttp from './CommonHttp';
import Config from './Config';

// Normalize request URL
function requestSrc(val: string): string {
  return val.toLowerCase().startsWith('http') ? val : `${Config.api_hosts}${val}`;
}

// Convert params to FormData format
function reqParamsToData(params: Record<string, any> = {}): Array<request.RequestData> {
  const data: Array<request.RequestData> = [];
  Object.keys(params).forEach(key => {
    if (params[key]) {
      data.push({ name: key, value: params[key].toString() });
    }
  });
  LogUtil.info(`reqParamsToData: ${JSON.stringify(data)}`);
  return data;
}

// Upload API interface
export interface RequestUploadResp {
  uploadTask: request.UploadTask;
  err?: Error;
}

export interface RequestUploadConfig {
  files: Array<request.File>;
}

// Global upload function
export const globalRequestUpload = (
  url: string,
  params: Record<string, any> = {},
  config: RequestUploadConfig
): Promise<RequestUploadResp> => {
  // Fetch user context data
  const cateId = UserCacheManager.getSubjectCatId() || PreferencesUtil.getStringSync('_subjectCatId');
  const subjectId = UserCacheManager.getSubjectId() || PreferencesUtil.getStringSync('_subjectId');
  const goodAppType = UserCacheManager.getSubAppType() || PreferencesUtil.getStringSync('_subAppType');

  // Merge default params
  params.cate_id = params.cate_id || cateId;
  params.subject_id = params.subject_id || subjectId;
  params.good_app_type = params.good_app_type || goodAppType;

  // Construct request URL
  const urls = CommonHttp.requestMd5Params({});
  const reqUrl = requestSrc(`${url}${CommonHttp.formatGetUri(urls)}`);

  // Prepare headers and data
  const token = UserCacheManager.getLoginToken() || PreferencesUtil.getStringSync('access_token');
  const uploadConfig: request.UploadConfig = {
    url: reqUrl,
    header: {
      'Content-Type': 'multipart/form-data',
      Authorization: token
    },
    method: 'POST',
    files: config.files,
    data: reqParamsToData(params)
  };

  LogUtil.info(`uploadConfig: ${JSON.stringify(uploadConfig)}`);

  return new Promise((resolve, reject) => {
    try {
      request.uploadFile(getContext(), uploadConfig)
        .then((task: request.UploadTask) => resolve({ uploadTask: task }))
        .catch((err: BusinessError) => {
          LogUtil.error(`Upload failed. Code: ${err.code}, Message: ${err.message}`);
          reject({ err });
        });
    } catch (err) {
      LogUtil.error(`Upload error: ${JSON.stringify(err)}`);
      reject({ err });
    }
  });
};
```

------

### 2. Photo Selection and URI Conversion

```
// Convert image URI to sandbox path (required for upload)
static async toInternalCacheUrl(selImg: string, fileType: string = 'jpg'): Promise<string> {
  if (!selImg) throw new Error('Invalid image URI');

  // Copy file to internal cache
  const cacheDir = getContext().cacheDir;
  const fileName = `${Date.now()}.${fileType}`;
  const originImg = await fileIo.open(selImg); // Open original file
  const source = image.createImageSource(originImg.fd); // Convert to ImageSource
  const packer = image.createImagePacker(); // Initialize packer
  const arrayBuffer = await packer.packing(source, { quality: 10, format: 'image/jpeg' }); // Compress

  // Write to cache
  const newFile = fileIo.openSync(
    `${cacheDir}/${fileName}`,
    fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE
  );
  fileIo.writeSync(newFile.fd, arrayBuffer); // Save compressed file

  return `internal://cache/${fileName}`; // Return sandbox URI
}
```

------

## Key Notes

1. **Error Handling**:

   - Uploading directly via `fileUri` returns a **404 error**.
   - Use `internal://cache/` prefixed URIs (e.g., from `toInternalCacheUrl`).

2. **Workflow**:

   ```
   selectPhoto → toInternalCacheUrl → globalRequestUpload
   ```

3. **Dependencies**:

   - Requires `@pura/harmony-utils` for photo selection.
   - Uses Huawei’s `request.uploadFile` API for file uploads.

