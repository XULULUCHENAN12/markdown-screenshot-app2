import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ScreenshotValidator {
  static const int minImageSize = 5000; // 最小图片大小（字节）
  static const double minWidth = 600; // 最小图片宽度
  static const double minHeight = 400; // 最小图片高度
  static const double maxAspectRatio = 10.0; // 最大宽高比（防止过窄的长条图）

  static Future<ValidationResult> validateScreenshot(
    Uint8List imageData, {
    double expectedWidth = 800,
    String? originalContent,
  }) async {
    final result = ValidationResult();

    // 检查图片大小
    if (imageData.length < minImageSize) {
      result.isValid = false;
      result.issues.add('图片文件过小 (${imageData.length} bytes)，可能生成失败');
      return result;
    }

    try {
      // 解码图片获取尺寸信息
      final codec = await ui.instantiateImageCodec(imageData);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      
      final width = image.width.toDouble();
      final height = image.height.toDouble();
      
      result.actualWidth = width;
      result.actualHeight = height;
      result.aspectRatio = width / height;

      // 验证图片尺寸
      if (width < minWidth) {
        result.isValid = false;
        result.issues.add('图片宽度过小 (${width.toInt()}px < ${minWidth.toInt()}px)');
      }

      if (height < minHeight) {
        result.isValid = false;
        result.issues.add('图片高度过小 (${height.toInt()}px < ${minHeight.toInt()}px)');
      }

      // 检查宽高比（防止长条图）
      if (result.aspectRatio > maxAspectRatio) {
        result.isValid = false;
        result.issues.add('图片过于狭长 (宽高比: ${result.aspectRatio.toStringAsFixed(2)})');
      }

      // 检查宽度是否接近期望值
      final widthDifference = (width - expectedWidth).abs();
      if (widthDifference > expectedWidth * 0.2) { // 20%容差
        result.warnings.add('图片宽度与期望值差异较大 (期望: ${expectedWidth.toInt()}px, 实际: ${width.toInt()}px)');
      }

      // 检查图片是否为纯色（可能是渲染失败）
      final colorAnalysis = await _analyzeDominantColors(imageData);
      if (colorAnalysis.isDominantlySingleColor) {
        result.isValid = false;
        result.issues.add('图片疑似为纯色，可能是渲染失败');
      }

      // 如果有原始内容，检查内容复杂度
      if (originalContent != null) {
        final contentComplexity = _analyzeContentComplexity(originalContent);
        if (contentComplexity.hasCodeBlocks && height < 600) {
          result.warnings.add('包含代码块但图片高度较小，可能存在内容截断');
        }
      }

      image.dispose();
      
      if (result.issues.isEmpty) {
        result.isValid = true;
      }

    } catch (e) {
      result.isValid = false;
      result.issues.add('图片解码失败: ${e.toString()}');
    }

    return result;
  }

  static Future<ColorAnalysis> _analyzeDominantColors(Uint8List imageData) async {
    try {
      final codec = await ui.instantiateImageCodec(imageData);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      
      // 获取图片的字节数据进行颜色分析
      final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        return ColorAnalysis(isDominantlySingleColor: false, dominantColor: Colors.transparent);
      }

      final buffer = byteData.buffer;
      final pixels = buffer.asUint8List();
      
      Map<int, int> colorCount = {};
      int totalPixels = 0;
      
      // 采样检查（每隔10个像素检查一次以提高性能）
      for (int i = 0; i < pixels.length; i += 40) { // RGBA每个像素4字节，所以间隔40
        if (i + 3 < pixels.length) {
          final r = pixels[i];
          final g = pixels[i + 1];
          final b = pixels[i + 2];
          final a = pixels[i + 3];
          
          // 忽略透明像素
          if (a > 128) {
            // 将RGB值组合成一个整数
            final colorKey = (r << 16) | (g << 8) | b;
            colorCount[colorKey] = (colorCount[colorKey] ?? 0) + 1;
            totalPixels++;
          }
        }
      }
      
      if (totalPixels == 0) {
        return ColorAnalysis(isDominantlySingleColor: true, dominantColor: Colors.transparent);
      }
      
      // 找出最频繁的颜色
      int maxCount = 0;
      int dominantColorKey = 0;
      
      colorCount.forEach((color, count) {
        if (count > maxCount) {
          maxCount = count;
          dominantColorKey = color;
        }
      });
      
      // 如果单一颜色占比超过80%，认为是纯色图片
      final dominanceRatio = maxCount / totalPixels;
      final isDominant = dominanceRatio > 0.8;
      
      final r = (dominantColorKey >> 16) & 0xFF;
      final g = (dominantColorKey >> 8) & 0xFF;
      final b = dominantColorKey & 0xFF;
      
      image.dispose();
      
      return ColorAnalysis(
        isDominantlySingleColor: isDominant,
        dominantColor: Color.fromARGB(255, r, g, b),
        dominanceRatio: dominanceRatio,
      );
      
    } catch (e) {
      return ColorAnalysis(isDominantlySingleColor: false, dominantColor: Colors.transparent);
    }
  }

  static ContentComplexity _analyzeContentComplexity(String content) {
    final codeBlockCount = RegExp(r'```[\s\S]*?```').allMatches(content).length;
    final inlineCodeCount = RegExp(r'`[^`]+`').allMatches(content).length;
    final listCount = RegExp(r'^[\s]*[-\*\+]\s|^[\s]*\d+\.\s', multiLine: true).allMatches(content).length;
    final headerCount = RegExp(r'^#+\s', multiLine: true).allMatches(content).length;
    final linkCount = RegExp(r'\[([^\]]*)\]\(([^)]*)\)').allMatches(content).length;
    
    return ContentComplexity(
      hasCodeBlocks: codeBlockCount > 0,
      codeBlockCount: codeBlockCount,
      inlineCodeCount: inlineCodeCount,
      listItemCount: listCount,
      headerCount: headerCount,
      linkCount: linkCount,
      estimatedLineCount: content.split('\n').length,
    );
  }

  static Future<Uint8List?> attemptScreenshotRecovery(
    String htmlContent,
    ValidationResult failedResult, {
    double fallbackWidth = 600,
    double fallbackPixelRatio = 1.5,
  }) async {
    try {
      // 基于验证结果调整参数
      double adjustedWidth = fallbackWidth;
      // double adjustedPixelRatio = fallbackPixelRatio;
      
      if (failedResult.actualWidth != null && failedResult.actualWidth! < minWidth) {
        adjustedWidth = minWidth * 1.2;
      }
      
      // 简化HTML内容，移除可能导致问题的元素
      String simplifiedHtml = htmlContent
          .replaceAll(RegExp(r'<script[\s\S]*?</script>'), '')
          .replaceAll(RegExp(r'animation[^;]*;'), '')
          .replaceAll(RegExp(r'transition[^;]*;'), '');
      
      // 添加更强制的CSS重置
      final recoveryCSS = '''
        <style>
          * { 
            animation: none !important; 
            transition: none !important; 
            transform: none !important;
            position: static !important;
          }
          body { 
            width: ${adjustedWidth.toInt()}px !important; 
            max-width: ${adjustedWidth.toInt()}px !important;
            overflow: hidden !important;
            margin: 0 !important;
            padding: 20px !important;
            box-sizing: border-box !important;
          }
          pre, code { 
            white-space: pre-wrap !important; 
            word-break: break-all !important;
            overflow: hidden !important;
          }
        </style>
      ''';
      
      simplifiedHtml = simplifiedHtml.replaceFirst('<head>', '<head>$recoveryCSS');
      
      // 这里应该调用截图服务重新生成
      // 返回null表示需要上层重新调用截图服务
      return null;
      
    } catch (e) {
      debugPrint('Screenshot recovery failed: $e');
      return null;
    }
  }
}

class ValidationResult {
  bool isValid = true;
  List<String> issues = [];
  List<String> warnings = [];
  double? actualWidth;
  double? actualHeight;
  double aspectRatio = 0.0;
  
  bool get hasIssues => issues.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  
  String get summary {
    final parts = <String>[];
    if (hasIssues) {
      parts.add('错误: ${issues.join('; ')}');
    }
    if (hasWarnings) {
      parts.add('警告: ${warnings.join('; ')}');
    }
    if (parts.isEmpty) {
      parts.add('验证通过');
    }
    return parts.join('\n');
  }
}

class ColorAnalysis {
  final bool isDominantlySingleColor;
  final Color dominantColor;
  final double dominanceRatio;
  
  ColorAnalysis({
    required this.isDominantlySingleColor,
    required this.dominantColor,
    this.dominanceRatio = 0.0,
  });
}

class ContentComplexity {
  final bool hasCodeBlocks;
  final int codeBlockCount;
  final int inlineCodeCount;
  final int listItemCount;
  final int headerCount;
  final int linkCount;
  final int estimatedLineCount;
  
  ContentComplexity({
    required this.hasCodeBlocks,
    required this.codeBlockCount,
    required this.inlineCodeCount,
    required this.listItemCount,
    required this.headerCount,
    required this.linkCount,
    required this.estimatedLineCount,
  });
  
  bool get isComplex => hasCodeBlocks || estimatedLineCount > 50 || listItemCount > 10;
}