# Detailed Guide to Developing Flutter Plugins for HarmonyOS

## 0. Environment Setup

**Prerequisite**: Configure HarmonyOS Flutter environment
​**Reference**: [HarmonyOS Flutter Environment Setup Guide](https://juejin.cn/post/7317214081261207603)
​**Note**: Downloading and compiling the engine is time-consuming. Pre-built engines are available upon request.

------

## 1. Obtain Original Plugin Code

```
git clone <original_plugin_repository>
```

------

## 2. Generate OHOS Directory

```
# Option 1: Direct generation (may fail)
flutter create -t plugin --platforms ohos

# Option 2: Create demo project and copy
flutter create -t plugin --platforms ohos demo
cp -r demo/ohos ./
```

------

## 3. Configure Local Dependency

Add local dependency in `pubspec.yaml`:

```
dependencies:
  your_plugin:
    path: ../path_to_plugin
```

![iwEcAqNwbmcDAQTRCQAF0QS4BrDBDM9ETs38UAcIagyL5gAAB9IGLKvECAAJomltCgAL0gALGaw.png_620x10000q90](https://p.ipic.vip/kjme9r.jpg)

## 4. Build Plugin Package

```bash
flutter build hap \
  --local-engine-src-path /path/to/ohos_flutter/src \
  --local-engine ohos_release_arm64
```

**Successful Output**:

```markdown
√ Built build/hap/release/entry-release.hap (XX.XMB)
```

------

## 5. Verify Generated Files

After successful build:

![1](https://p.ipic.vip/6k3z3k.png)

## 6. Locate Plugin HAR Package

Plugin output directory:

```markdown
your_plugin/ohos/build/outputs/
└── har
    └── your_plugin_ohos.har  # Plugin package
```

![2](https://p.ipic.vip/2cjnbx.png)

## 7. Add HAR to Demo Project

Copy HAR to demo project:

bash

```bash
cp your_plugin_ohos.har demo_portal/module/ohos/libs/
```

------

![3](https://p.ipic.vip/n9sgfo.png)

## 8. Configure HAR Dependency

![4](https://p.ipic.vip/wlkxik.png)

## 9. Initialize Plugin

![5](https://p.ipic.vip/ee33ah.png)

## 10. Test Plugin Functionality

![6](https://p.ipic.vip/4fy0hk.png)



![7](https://p.ipic.vip/w30wew.png)

## 11. Develop Native Implementation

Follow these steps for native development:

1. Analyze existing iOS/Android native logic
2. Create HarmonyOS equivalent in `ohos/src/main/cpp/`
3. Implement platform interface:cpp