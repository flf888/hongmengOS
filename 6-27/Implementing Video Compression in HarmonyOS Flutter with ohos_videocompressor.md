# Implementing Video Compression in HarmonyOS Flutter with ohos_videocompressor

## Introduction
`ohos_videocompressor` is a high-performance video compression library for HarmonyOS. It provides robust video compression capabilities optimized for HarmonyOS applications.

**Key Features**:
- High-efficiency video compression
- Support for multiple video formats
- Quality level customization

## Installation Methods

### Method 1: Clone with Submodules
	```bash
	git clone https://gitee.com/openharmony-sig/ohos_videocompressor.git --recurse-submodules
	```

### Method 2: Manual Download
1. Download the main repository
2. Download [third_party_bounds_checking_function](https://gitee.com/openharmony/third_party_bounds_checking_function)
3. Place the downloaded files in `videoCompressor/src/cpp/boundscheck`

### Install via OHPM
```bash
ohpm install @ohos/videocompressor
```

## Usage Guide

### Basic Compression Example
	```javascript
	import { VideoCompressor, CompressQuality, CompressorResponseCode } from '@ohos/videocompressor';
	
	// Initialize compressor
	const videoCompressor = new VideoCompressor();
	
	// Execute compression
	videoCompressor.compressVideo(getContext(), this.selectFilePath, CompressQuality.COMPRESS_QUALITY_HIGH)
	  .then((data) => {
	    if (data.code == CompressorResponseCode.SUCCESS) {
	      console.log("Compression successful. Output path: " + data.outputPath);
	    } else {
	      console.error("Compression failed. Error: " + data.message);
	    }
	  })
	  .catch((err) => {
	    console.error("Compression error: " + err.message);
	  });
	```

## Supported Specifications

### Input Formats
- MP4
- MPEG-TS

### Video Codecs
- **Decoding**: AVC (H.264), HEVC (H.265)
- **Encoding**: AVC (H.264), HEVC (H.265)

### Audio Codecs
- **Decoding**: AAC
- **Encoding**: AAC

## API Reference

### `compressVideo(context: Context, inputFilePath: string, quality: CompressQuality): Promise<CompressionResult>`

**Parameters**:

	| Parameter      | Type             | Description                          |
	|----------------|------------------|--------------------------------------|
	| `context`      | `Context`        | Application context                  |
	| `inputFilePath`| `string`         | Path to source video file            |
	| `quality`      | `CompressQuality`| Compression quality level            |

**Quality Options**:

	```javascript
	enum CompressQuality {
	  COMPRESS_QUALITY_LOW,    // Fastest compression, lowest quality
	  COMPRESS_QUALITY_MEDIUM, // Balanced speed and quality
	  COMPRESS_QUALITY_HIGH    // Best quality, slower compression
	}
	```
	
	**Return Object**:
	```javascript
	interface CompressionResult {
	  code: CompressorResponseCode; // SUCCESS or error code
	  message: string;              // Status message
	  outputPath?: string;          // Path to compressed file (on success)
	}
	
	enum CompressorResponseCode {
	  SUCCESS,                     // Operation successful
	  ERR_INVALID_INPUT,           // Invalid input file
	  ERR_UNSUPPORTED_FORMAT,      // Unsupported file format
	  ERR_COMPRESSION_FAILED,      // General compression failure
	  ERR_INSUFFICIENT_STORAGE,    // Storage space issue
	  ERR_PERMISSION_DENIED        // Permission error
	}
	```

## Best Practices
1. **Check File Permissions**: Ensure read/write access to source and destination paths
2. **Handle Storage Space**: Verify sufficient storage before compression
3. **Quality Selection**:
   - Use `COMPRESS_QUALITY_LOW` for quick social media uploads
   - Use `COMPRESS_QUALITY_HIGH` for archival purposes
4. **Error Handling**: Always implement `.catch()` for promise rejection handling

## Performance Notes
- Compression time varies by device capability and video length
- HEVC encoding provides better compression but requires more processing power
- Typical compression ratios:
  - Low quality: 60-70% size reduction
  - Medium quality: 40-50% size reduction
  - High quality: 20-30% size reduction

This implementation provides a streamlined solution for adding video compression capabilities to HarmonyOS Flutter applications, balancing performance and quality while maintaining broad format compatibility.