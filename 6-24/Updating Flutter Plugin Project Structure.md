# Updating Flutter Plugin Project Structure

## Update Summary

- Replacing HarmonyOS project structure with module structure in the `ohos` directory of Flutter plugins
- Consolidating all referenced HAR files under `ohos/har`
- Removing outdated module directories in OHOS plugins after update

## Update Procedure

Demonstrated using [integration_test](https://gitee.com/openharmony-sig/flutter_flutter) from flutter_flutter:

### 1. Restructure integration_test/ohos from project to module format
	```sh
	cd flutter_flutter/packages/integration_test
	mv ohos/ohos ./ohos2  # Backup original structure
	rm -rf ohos           # Remove old structure
	mv ohos2 ohos          # Rename to standard module format
	cd example
	flutter pub get        # Refresh dependencies
	flutter build hap --debug # Verify build
	```

> **Note**: Running `flutter run` at this stage will fail until configuration updates are completed.

### 2. Configuration Updates

#### 2.1 Update integration_test/ohos/oh-package.json5
**Before**:
	```json
	{
	  "name": "ohos",
	  ...
	}
	```

**After** (match plugin name from pubspec.yaml):
	```json
	{
	  "name": "integration_test",
	  "license": "Apache-2.0",
	  "dependencies": {
	    "@ohos/flutter_ohos": "file:har/flutter.har"
	  }
	}
	```

#### 2.2 Update integration_test/ohos/src/main/module.json5
**Before**:
	```json
	{
	  "module": {
	    "name": "ohos",
	    ...
	  }
	}
```

**After**:
	```json
	{
	  "module": {
	    "name": "integration_test",
	    ...
	  }
	}
	```

#### 2.3 Update integration_test/ohos/hvigorfile.ts
**Before**:
	```typescript
	import { appTasks } from '@ohos/hvigor-ohos-plugin';
	export default {
	    system: appTasks,
	    plugins:[]
	}
	```

**After**:
	```typescript
	export { harTasks } from '@ohos/hvigor-ohos-plugin';
	```

## Verification Steps

1. Open `integration_test/example` in DevEco Studio and configure signing
2. Run the example:
	```sh
	cd integration_test/example
	flutter run -d $DEVICE --debug
	```

### Critical HAR Reference Configuration
HAR files are now located in `ohos/har`

#### Update example/ohos/oh-package.json5
	```json
	{
	  "dependencies": {
	    "@ohos/flutter_ohos": "file:./har/flutter.har"
	  },
	  "overrides": {
	    "@ohos/flutter_ohos": "file:./har/flutter.har"
	  }
	}
	```

#### Update example/ohos/entry/oh-package.json5
**Before**:
	```json
	{
	  "dependencies": {
	    "@ohos/integration_test": "file:./har/integration_test.har"
	  }
	}
	```

**After**:
	```json
	{
	  "dependencies": {
	    "integration_test": "file:../har/integration_test.har"
	  }
	}
	```

## Troubleshooting Common Issues

### 1. ENOENT: No such file or directory
	**Error**:
	```log
	hvigor ERROR: ENOENT: no such file or directory, stat 
	'xxx/flutter_flutter/packages/integration_test/ohos/build/default/cache/default/default@packageHar/ohos/oh_modules/@ohos/flutter_ohos'
	```

**Solution**:  
Manually delete the path mentioned in the error message.

### 2. Operation not permitted (symlink error)
**Error**:
	```log
	hvigor ERROR: ENOENT: operation not permitted, symlink
	'xxx/webview_flutter_ohos/ohos/webview_flutter/oh_modules/.ohpm/@ohos+flutter_ohos@file+libs+flutter.har/oh_modules/@ohos/flutter_ohos' -> 
	'xxx/webview_flutter_ohos/ohos/build/default/cache/default/default@PackageHar/webview_flutter/oh_modules/@ohos/flutter_ohos'
	```

**Solution**:  
Remove legacy directories from previous structure:
	```sh
	rm -rf flutter_packages/packages/webview_flutter_ohos/ohos/webview_flutter
	rm -rf flutter_packages/packages/path_provider_ohos/ohos/path_provider
	rm -rf flutter_packages/packages/file_selector_ohos/ohos/FileSelector
	```