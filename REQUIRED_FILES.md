# 📋 GitHub构建必需文件清单

## ✅ 必须上传的文件（构建会失败如果缺少）

### 1. GitHub Actions配置
```
.github/
└── workflows/
    └── build.yml                    # 构建流程配置
```

### 2. Flutter项目配置
```
pubspec.yaml                        # 项目依赖和配置
analysis_options.yaml               # 代码分析配置（推荐）
```

### 3. Android配置文件
```
android/
├── app/
│   ├── build.gradle                # Android构建配置
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml # Android应用清单
│           └── kotlin/
│               └── com/
│                   └── example/
│                       └── markdown_screenshot_app/
│                           └── MainActivity.kt
```

### 4. Flutter源代码
```
lib/
├── main.dart                       # 应用入口
├── screens/
│   └── markdown_screenshot_screen.dart
├── services/
│   ├── markdown_renderer.dart
│   ├── screenshot_service.dart
│   └── screenshot_validator.dart
└── data/
    └── test_cases.dart
```

## ❌ 可以不上传的文件

### 1. 构建产物
```
build/                              # 构建输出（.gitignore已排除）
.dart_tool/                         # Dart工具缓存
.packages                           # 包缓存
```

### 2. IDE配置
```
.vscode/                            # VS Code配置
.idea/                              # IntelliJ IDEA配置
*.iml                               # IntelliJ模块文件
```

### 3. 演示文件
```
demo.html                           # HTML演示文件
DEMO.md                             # 演示说明
BUILD_INSTRUCTIONS.md               # 本地构建说明
ONLINE_BUILD.md                     # 在线构建说明
build_apk.sh                        # 本地构建脚本
```

### 4. Web支持文件（如果不需要Web版本）
```
web/                                # Web平台文件
```

## 📂 最小化上传清单

如果想最精简上传，只需要这些文件：

### 核心必需文件（13个文件）
1. `.github/workflows/build.yml`
2. `pubspec.yaml`
3. `analysis_options.yaml`
4. `android/app/build.gradle`
5. `android/app/src/main/AndroidManifest.xml`
6. `android/app/src/main/kotlin/com/example/markdown_screenshot_app/MainActivity.kt`
7. `lib/main.dart`
8. `lib/screens/markdown_screenshot_screen.dart`
9. `lib/services/markdown_renderer.dart`
10. `lib/services/screenshot_service.dart`
11. `lib/services/screenshot_validator.dart`
12. `lib/data/test_cases.dart`
13. `.gitignore`

### 推荐额外文件
14. `README.md` - 项目说明
15. `android/app/src/main/res/values/strings.xml` - 应用名称

## 🚨 构建失败的常见原因

### 1. 缺少关键文件
- ❌ 没有 `pubspec.yaml` → 无法识别为Flutter项目
- ❌ 没有 `AndroidManifest.xml` → Android构建失败
- ❌ 没有 `MainActivity.kt` → 应用入口缺失

### 2. 文件路径错误
- ❌ `lib/main.dart` 写成 `src/main.dart`
- ❌ Android文件路径不正确

### 3. 文件内容错误
- ❌ `pubspec.yaml` 格式错误
- ❌ Dart代码语法错误

## 🎯 推荐上传策略

### 方案1：完整上传（推荐）
上传所有文件（除了.gitignore排除的），确保万无一失。

### 方案2：最小上传
只上传上面列出的13个核心文件，减少上传时间。

### 方案3：分批上传
先上传核心文件，如果构建成功再补充其他文件。

## 🔍 验证文件完整性

上传前检查：
- ✅ `pubspec.yaml` 是否包含所有依赖
- ✅ `lib/` 目录下所有Dart文件是否存在
- ✅ `android/app/build.gradle` 配置是否正确
- ✅ 文件路径是否与项目结构一致