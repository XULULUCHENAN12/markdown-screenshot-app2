# 📱 APK构建说明

## 🎯 项目已复制到 Windows 路径
项目文件已复制到：`C:\temp\markdown_screenshot_app`

## 🔧 构建步骤

### 1. 在Windows命令行中执行：
```cmd
cd C:\temp\markdown_screenshot_app
flutter pub get
flutter build apk --debug
flutter build apk --release
```

### 2. APK文件位置：
构建完成后，APK文件将在：
- **Debug版本**: `C:\temp\markdown_screenshot_app\build\app\outputs\flutter-apk\app-debug.apk`
- **Release版本**: `C:\temp\markdown_screenshot_app\build\app\outputs\flutter-apk\app-release.apk`

### 3. 快速构建脚本
也可以直接运行：
```cmd
cd C:\temp\markdown_screenshot_app
build_apk.sh
```

## 📦 APK功能特性

构建出的APK将具备以下功能：

### 🎯 核心功能
- ✅ Markdown内容截图
- ✅ VS Code Dark+主题代码块
- ✅ 自动换行防止长条图
- ✅ 思考过程合并显示
- ✅ 5种预设测试用例

### 🔧 技术特性
- ✅ 双渲染器支持（flutter_markdown_plus + flutter_markdown）
- ✅ 截图质量验证和自动恢复
- ✅ WebView优化渲染
- ✅ 移动端权限管理

### 📱 使用方法
1. 安装APK到Android设备
2. 授予存储权限
3. 输入Markdown内容
4. 点击"生成截图"
5. 查看保存的图片文件

## 🚨 如果构建失败

### 常见问题解决：
1. **Flutter未安装**：
   - 下载Flutter SDK
   - 配置环境变量

2. **Android SDK缺失**：
   ```cmd
   flutter doctor
   flutter doctor --android-licenses
   ```

3. **依赖问题**：
   ```cmd
   flutter clean
   flutter pub get
   ```

## 📊 APK预期大小
- Debug APK: ~25-35MB
- Release APK: ~15-25MB

## 🎉 完成后
APK构建完成后，可以直接安装到Android设备测试所有功能！