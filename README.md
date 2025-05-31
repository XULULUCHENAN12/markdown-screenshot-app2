# Markdown截图工具 APK

一个专门解决Markdown内容中代码块截图和显示问题的Flutter Android应用。

## 核心功能

### 🎯 主要特性
- **代码块优化显示**: 强制自动换行，禁用水平滚动
- **VS Code Dark+主题**: 深色背景 (#1E1E1E) 配浅色文字 (#D4D4D4)
- **智能截图系统**: WebView渲染 + 质量验证 + 自动恢复
- **思考过程支持**: 可同时显示思考过程和回答内容
- **多语言代码支持**: JavaScript, Python, Java, C#, Go, Rust等

### 🔧 技术特性
- **双渲染器支持**: 优先使用 flutter_markdown_plus，备选 flutter_markdown
- **截图失败预防**: 自动检测并修复常见的截图问题
- **内容验证机制**: 验证图片尺寸、宽高比、颜色分布
- **恢复策略**: 截图失败时自动调整参数重试

## 核心解决的问题

### 1. 代码块换行问题 ✅
```css
pre {
  white-space: pre-wrap !important;
  word-break: break-all !important;
  overflow-x: hidden !important;
}
```

### 2. 截图长条图问题 ✅
- 固定容器宽度 (800px)
- 宽高比验证 (最大10:1)
- 自动恢复机制

### 3. VS Code主题适配 ✅
- 背景色: #1E1E1E
- 文字色: #D4D4D4
- 保持语法高亮可读性

### 4. 移动端适配 ✅
- 禁用缩放: `enableZoom(false)`
- 固定视口: 移动端优化User-Agent
- 权限管理: 自动申请存储权限

## 构建说明

### 环境要求
- Flutter 3.0+
- Android SDK 21+
- Dart 3.0+

### 构建步骤
```bash
# 1. 获取依赖
flutter pub get

# 2. 生成debug APK
flutter build apk --debug

# 3. 生成release APK
flutter build apk --release

# 4. 安装到设备
flutter install
```

### APK位置
构建完成后APK文件位置：
- Debug: `build/app/outputs/flutter-apk/app-debug.apk`
- Release: `build/app/outputs/flutter-apk/app-release.apk`

## 使用方法

### 基本使用
1. 在"思考过程"区域输入思考内容（可选）
2. 在"Markdown内容"区域输入要截图的Markdown
3. 设置文件名（可选，留空自动生成）
4. 点击"生成截图"按钮
5. 截图保存到设备存储

### 测试用例
点击工具栏的🧪图标可选择预设测试用例：
- **超长代码行测试**: 测试超长代码行的自动换行
- **混合内容测试**: 代码块与其他Markdown元素混合
- **特殊字符测试**: 各种特殊符号和Unicode字符
- **多语言代码测试**: 不同编程语言的复杂声明
- **思考过程示例**: 包含思考过程的完整示例

## 技术架构

### 核心服务
- `MarkdownRenderer`: Markdown渲染和HTML生成
- `ScreenshotService`: WebView截图和文件保存
- `ScreenshotValidator`: 截图质量验证和恢复

### CSS优化策略
```css
/* 强制代码块换行 */
pre code {
  white-space: pre-wrap !important;
  word-break: break-all !important;
  overflow-wrap: break-word !important;
}

/* VS Code Dark+主题 */
pre {
  background-color: #1E1E1E !important;
}
pre code {
  color: #D4D4D4 !important;
}
```

### 验证机制
- **尺寸检查**: 最小宽度600px，高度400px
- **宽高比验证**: 最大10:1（防止长条图）
- **颜色分析**: 检测纯色图片（可能是渲染失败）
- **内容复杂度**: 基于原始内容评估合理性

## 权限说明
- `INTERNET`: WebView加载和渲染
- `WRITE_EXTERNAL_STORAGE`: 保存截图文件
- `READ_EXTERNAL_STORAGE`: 读取存储内容

## 故障排除

### 常见问题
1. **截图空白**: 检查WebView渲染是否完成，增加等待时间
2. **权限被拒**: 手动到设置中授予存储权限
3. **内容截断**: 使用恢复机制自动调整参数重试
4. **长条图片**: 验证机制会自动检测并重新生成

### 调试信息
应用会在控制台输出详细的调试信息：
- WebView加载状态
- 截图验证结果
- 恢复策略执行情况

基于油猴脚本的成功实践，这个APK应用能够完美解决Markdown代码块的截图显示问题。