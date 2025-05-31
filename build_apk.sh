#!/bin/bash

# Markdown截图工具 APK构建脚本
# 自动构建debug和release版本的APK

echo "🚀 开始构建 Markdown截图工具 APK..."

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: 未找到Flutter环境，请先安装Flutter SDK"
    exit 1
fi

echo "📋 Flutter环境信息:"
flutter --version

# 进入项目目录
cd "$(dirname "$0")"

echo "📦 获取依赖包..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ 错误: 依赖包获取失败"
    exit 1
fi

echo "🛠️ 清理构建缓存..."
flutter clean
flutter pub get

# 构建debug APK
echo "🔨 构建Debug APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Debug APK构建成功!"
    echo "📍 位置: build/app/outputs/flutter-apk/app-debug.apk"
else
    echo "❌ Debug APK构建失败"
    exit 1
fi

# 构建release APK
echo "🔨 构建Release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ Release APK构建成功!"
    echo "📍 位置: build/app/outputs/flutter-apk/app-release.apk"
else
    echo "❌ Release APK构建失败"
    exit 1
fi

# 显示APK信息
echo ""
echo "📊 APK文件信息:"
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    DEBUG_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-debug.apk | awk '{print $5}')
    echo "🔧 Debug APK: $DEBUG_SIZE"
fi

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    RELEASE_SIZE=$(ls -lh build/app/outputs/flutter-apk/app-release.apk | awk '{print $5}')
    echo "🚀 Release APK: $RELEASE_SIZE"
fi

echo ""
echo "🎉 构建完成!"
echo ""
echo "📱 安装命令:"
echo "   Debug版本:   flutter install --debug"
echo "   Release版本: flutter install --release"
echo ""
echo "📁 APK文件位置:"
echo "   Debug:   $(pwd)/build/app/outputs/flutter-apk/app-debug.apk"
echo "   Release: $(pwd)/build/app/outputs/flutter-apk/app-release.apk"