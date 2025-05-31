# 🌐 在线构建APK方案

如果本地Flutter环境有问题，可以使用在线构建服务：

## 📱 推荐的在线构建平台

### 1. GitHub Actions（免费）
1. 将项目上传到GitHub
2. 使用Flutter GitHub Actions自动构建
3. 下载构建好的APK

### 2. Codemagic（免费额度）
1. 连接GitHub仓库
2. 配置Flutter构建流水线
3. 自动生成APK文件

### 3. App Center（微软）
1. 上传项目代码
2. 配置构建环境
3. 下载构建产物

## 🔧 GitHub Actions配置示例

创建 `.github/workflows/build.yml`：

```yaml
name: Build Flutter APK
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-java@v1
      with:
        java-version: '12.x'
    - uses: subosito/flutter-action@v1
      with:
        flutter-version: '3.0.0'
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v2
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## 📁 项目文件准备

项目已包含所有必要文件：
- ✅ `pubspec.yaml` - 依赖配置
- ✅ `android/` - Android配置
- ✅ `lib/` - Flutter代码
- ✅ `build_apk.sh` - 构建脚本

## 🚀 快速开始

最快的方式是在有Flutter环境的机器上：
```bash
cd C:\temp\markdown_screenshot_app
flutter build apk --release
```

APK将生成在：`build\app\outputs\flutter-apk\app-release.apk`