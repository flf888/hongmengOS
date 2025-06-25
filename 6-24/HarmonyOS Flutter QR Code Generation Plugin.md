# HarmonyOS Flutter QR Code Generation Plugin

------

## I. MethodChannel Implementation

### 1. Flutter Code Implementation

**Creating a MethodChannel & Receiving Parameters**

```
class RecognitionManager {
  static const MethodChannel _channel = MethodChannel('recognition_qrcode');

  /// Fetch the platform version
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Configure QR code scanning parameters
  static Future<void> setConfig({
    String? icon,
    double? iconWidth = 30,
    double? iconHeight = 30,
    double? cancelTitleFontSize = 16,
    String? cancelTitle = "Cancel",
  }) async {
    final Map<String, dynamic> config = {
      "iconWidth": iconWidth ?? 30,
      "iconHeight": iconHeight ?? 30,
      "cancelTitleFontSize": cancelTitleFontSize ?? 16,
      "cancelTitle": cancelTitle ?? "Cancel",
    };

    // Handle image/icon loading
    if (icon != null) {
      try {
        final ByteData byteData = await rootBundle.load(icon);
        final ByteBuffer buffer = byteData.buffer;
        config["icon"] = Uint8List.view(buffer);
      } catch (e) {
        print("RecognitionQrcode.config: Failed to load image");
      }
    }

    await _channel.invokeMethod("setConfig", config);
  }

  /// Recognize QR code from image source (base64, URL, or file path)
  static Future<RecognitionResult> recognize(dynamic img) async {
    final Map<String, dynamic> response = await _channel.invokeMethod('recognizeQrcode', img);
    return RecognitionResult(
      code: response["code"],
      value: response["value"],
    );
  }
}
```

------

### 2. OHOS Code Implementation

**Extending FlutterPlugin & Handling Method Calls**

```
import { detectBarcode, scanBarcode, util } from '@ohos.barcode';

const TAG: string = "QRCodePlugin";
const CHANNEL_NAME = "recognition_qrcode";

export class QRCodePlugin implements FlutterPlugin, MethodCallHandler {
  private methodChannel: MethodChannel | null = null;
  private applicationContext: Context | null = null;
  private ability: UIAbility | null = null;
  private config: Map<string, ESObject> = new Map();

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = binding.getApplicationContext();
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.methodChannel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.applicationContext = null;
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  async onMethodCall(call: MethodCall, result: MethodResult): Promise<void> {
    try {
      if (call.method === "getPlatformVersion") {
        result.success(`Ohos ${deviceInfo.sdkApiVersion}`);
      } else if (call.method === 'setConfig') {
        this.config = call.args;
        // Handle icon caching
        if (call.args.icon) {
          const imageBuffer = call.args.icon as ArrayBuffer;
          const cachedUrl = await this.saveCacheDir(imageBuffer);
          this.config.set('icon', cachedUrl);
        }
        result.success(null);
      } else if (call.method === 'recognizeQrcode') {
        let imageUrl = call.args as string;

        // Handle HTTP/S URLs
        if (imageUrl.includes('http') || imageUrl.includes('https')) {
          imageUrl = await this.downloadHttpImage(imageUrl);
        }
        // Handle Base64 data
        else if (!imageUrl.includes('/data/') && this.isBase64(imageUrl)) {
          imageUrl = await this.saveCacheDir(this.base64ToBuffer(imageUrl));
        }

        if (!imageUrl) return;

        // Define barcode detection parameters
        const inputImage: detectBarcode.InputImage = { uri: imageUrl };
        const options: scanBarcode.ScanOptions = {
          scanTypes: [scanCore.ScanType.ALL],
          enableMultiMode: true,
          enableAlbum: true,
        };

        // Perform barcode scanning
        const results = await detectBarcode.detect(inputImage, options);
        if (results.length > 1) {
          this.openAbility(results, imageUrl, result);
        } else if (results.length === 1) {
          result.success({
            code: "0",
            value: results[0].originalValue,
            rawResults: results, // Expose raw results to Flutter
          });
        } else {
          result.error("-1", "Image decoding failed", null);
        }
      } else {
        result.notImplemented();
      }
    } catch (error) {
      Log.e(TAG, `Error: ${error.message}`);
      result.error("-1", error.message, null);
    }
  }

  // Helper methods for image handling
  private base64ToBuffer(base64: string): ArrayBuffer {
    const binaryString = atob(base64);
    const len = binaryString.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    return bytes.buffer;
  }

  private isBase64(str: string): boolean {
    try {
      return btoa(atob(str)) === str;
    } catch (_) {
      return false;
    }
  }

  private saveCacheDir(buffer: ArrayBuffer): Promise<string> {
    // Implement cache saving logic here
    return Promise.resolve("/cache/image.jpg");
  }

  private downloadHttpImage(url: string): Promise<string> {
    // Implement HTTP image download logic here
    return Promise.resolve("http://example.com/image.jpg");
  }

  private openAbility(results: scanBarcode.ScanResult[], url: string, result: MethodResult) {
    // Implement ability opening logic here
    result.success({
      code: "1",
      value: "Multiple results found",
      results: results.map((r) => r.originalValue),
    });
  }
}
```

------

## II. QR Code Generation Workflow

### **1. Configuration**

Set scanning parameters (e.g., icon, cancel button text):

```
await RecognitionManager.setConfig(
  icon: AssetImage("assets/qr_icon.png"),
  cancelTitle: "Close",
);
```

### **2. Scanning**

Recognize QR codes from images:

```
final result = await RecognitionManager.recognize("https://example.com/qrcode.png");
if (result.code == "0") {
  print("Decoded value: ${result.value}");
}
```

------

## III. Supported Features

- **Input Sources**: Base64 data, HTTP(S) URLs, local file paths.
- **Multi-Format Support**: Detects all barcode types (QR Code, Code 128, etc.).
- **Customization**: Configurable UI (icons, button text, colors).

