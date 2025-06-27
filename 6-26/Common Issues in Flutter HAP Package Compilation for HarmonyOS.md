# Common Issues in Flutter HAP Package Compilation for HarmonyOS

## 1. Configuring Aliases to Simplify Build Commands

Add these aliases to your environment variables for streamlined development:

**Windows** (via Git Bash):
Right-click in File Explorer → *Git Bash Here*
​**Linux/Mac**: Edit `~/.bash_profile` and add to `~/.zshrc` via `source ~/.bash_profile`

```
# Optional --local-engine for custom engine builds (recommended on Linux/Mac)
export ENGINE_DIR=~/ohos/engine
export ENGINE_DEBUG=$ENGINE_DIR/src/out/ohos_debug_unopt_arm64
export ENGINE_PROFILE=$ENGINE_DIR/src/out/ohos_profile_arm64
export ENGINE_RELEASE=$ENGINE_DIR/src/out/ohos_release_arm64

# Build aliases
alias fbuildD="flutter build hap --local-engine=$ENGINE_DEBUG --debug"
alias fbuildP="flutter build hap --local-engine=$ENGINE_PROFILE --profile"
alias fbuildR="flutter build hap --local-engine=$ENGINE_RELEASE --release"

# Run aliases
alias frunD="flutter run -d $(hdc list targets) --local-engine=$ENGINE_DEBUG --debug"
alias frunP="flutter run -d $(hdc list targets) --local-engine=$ENGINE_PROFILE --profile"
alias frunR="flutter run -d $(hdc list targets) --local-engine=$ENGINE_RELEASE --release"
```

**Usage**:

```
flutter create hello --platforms ohos
cd hello
fbuildD  # Build debug version
frunD    # Run debug version
```

------

## 2. White Screen After Installation

**Error Log**:

```
Reason:Signal:SIGSEGV(SEGV_MAPERR)@0x00000086e3272bf8
LastFatalMessage:Thread:547846269584[FATAL:flutter/runtime/dart_vm_initializer.cc] 
Error while initializing the Dart VM: 
Wrong full snapshot version, expected '8af474944053df1f0a3be6e6165fa7cf' 
found 'adb4292f3ec25074ca70abcd2d5c7251'
```

**Cause**: Engine build mode mismatch (e.g., using debug engine with release build)
​**Solution**: Match engine mode with build flags:

```
flutter run -d --debug    # Debug mode
flutter run -d --release  # Release mode
flutter run -d --profile  # Profile mode
```

------

## 3. Plugin Structure Compatibility Error

**Error Log**:

```
Oops; flutter has exited unexpectedly: 
"type 'Null' is not a subtype of type 'List<dynamic>' in type cast".
```

**Solution**: Update Flutter to latest master/dev branch (commit 45bd5e627e1 or newer)

------

## 4. Dependency Conflict During `flutter pub get`

**Error Log**:

```
Because flutter_cache_manager >=3.0.0-nullsafety.0 <3.3.2 depends on path_provider...
version solving failed. pub get failed... exit code: 1
```

**Solution**: Add dependency overrides in `pubspec.yaml`:

```
dependency_overrides:
  path_provider:
    git:
      url: https://gitee.com/openharmony-sig/flutter_packages.git
      path: packages/path_provider/path_provider
  path_provider_ohos:
    git:
      url: https://gitee.com/openharmony-sig/flutter_packages.git
      path: packages/path_provider/path_provider_ohos
```

------

## 5. Unaccepted SDK License Agreement

**Error Log**:

```
hvigor install success.
> hvigor ERROR: Cause: The SDK license agreement is not accepted.
```

**Cause**: Project uses API 12 SDK with API 11 project structure
​**Solution**:

1. In DevEco Studio: *Migrate Assistant → 5.0.0 → Migrate*
2. *File → Project Structure → Compatible SDK → 5.0.0(12)*

------

## 6. Version Reset in app.json

**Issue**: `versionName` in app.json resets to 1.0.0 after `flutter build hap --release`
​**Solution**: Explicitly specify versions in build command:

```
flutter build hap --build-name=4.0.3 --build-number=10000
```