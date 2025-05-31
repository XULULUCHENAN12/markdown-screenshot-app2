import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'markdown_renderer.dart';
import 'screenshot_validator.dart';

class ScreenshotService {
  static final ScreenshotController _screenshotController = ScreenshotController();
  
  static Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
        Permission.manageExternalStorage,
      ].request();
      
      return statuses.values.every((status) => 
        status == PermissionStatus.granted || status == PermissionStatus.limited);
    }
    return true;
  }

  static Future<File?> captureMarkdownAsImage({
    required String markdownContent,
    String? thinkingContent,
    String? fileName,
    double width = 800,
    double pixelRatio = 2.0,
  }) async {
    try {
      if (!await _requestPermissions()) {
        throw Exception('Storage permissions not granted');
      }

      final htmlContent = _generateOptimizedHtml(markdownContent, thinkingContent);
      
      final webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFDF5E6))
        ..enableZoom(false)
        ..setUserAgent('Mozilla/5.0 (Mobile; rv:107.0)')
        ..addJavaScriptChannel(
          'ScreenshotReady',
          onMessageReceived: (JavaScriptMessage message) {},
        );

      await webViewController.loadHtmlString(htmlContent);
      
      await Future.delayed(const Duration(milliseconds: 2000));
      
      final completer = WebViewWidget(controller: webViewController);
      
      final screenshotWidget = Container(
        width: width,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        child: completer,
      );

      final uint8List = await _screenshotController.captureFromWidget(
        screenshotWidget,
        pixelRatio: pixelRatio,
        context: null,
      );

      if (uint8List.isEmpty) {
        throw Exception('Screenshot capture failed - empty result');
      }

      // 验证截图质量
      final validationResult = await ScreenshotValidator.validateScreenshot(
        uint8List,
        expectedWidth: width,
        originalContent: markdownContent,
      );

      Uint8List finalScreenshot = uint8List;
      
      if (!validationResult.isValid) {
        debugPrint('Screenshot validation failed: ${validationResult.summary}');
        
        // 尝试恢复截图
        final recoveredScreenshot = await _attemptScreenshotRecovery(
          htmlContent,
          validationResult,
          markdownContent,
          thinkingContent,
          width,
          pixelRatio,
        );
        
        if (recoveredScreenshot != null && recoveredScreenshot.isNotEmpty) {
          // 再次验证恢复的截图
          final revalidationResult = await ScreenshotValidator.validateScreenshot(
            recoveredScreenshot,
            expectedWidth: width,
            originalContent: markdownContent,
          );
          
          if (revalidationResult.isValid) {
            finalScreenshot = recoveredScreenshot;
            debugPrint('Screenshot recovery successful');
          } else {
            debugPrint('Screenshot recovery failed validation: ${revalidationResult.summary}');
            // 使用原始截图，但记录问题
            finalScreenshot = uint8List;
          }
        } else {
          debugPrint('Screenshot recovery attempt failed');
          finalScreenshot = uint8List;
        }
      } else if (validationResult.hasWarnings) {
        debugPrint('Screenshot validation warnings: ${validationResult.summary}');
      }

      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final finalFileName = fileName ?? 'markdown_screenshot_$timestamp';
      final file = File('${directory.path}/$finalFileName.png');
      
      await file.writeAsBytes(finalScreenshot);
      
      return file;
    } catch (e) {
      debugPrint('Screenshot capture error: $e');
      return null;
    }
  }

  static String _generateOptimizedHtml(String markdownContent, String? thinkingContent) {
    String processedMarkdown = MarkdownRenderer.preprocessHtml(markdownContent);
    String htmlContent = MarkdownRenderer.generateOptimizedHtml(processedMarkdown);
    
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      final thinkingHtml = '''
        <div class="thinking-section">
          <div class="thinking-label">思考过程:</div>
          ${_escapeHtml(thinkingContent).split('\n').map((line) => '<p>${line.isEmpty ? '&nbsp;' : line}</p>').join('')}
        </div>
      ''';
      
      htmlContent = htmlContent.replaceFirst(
        '<body>',
        '<body><div class="export-container">$thinkingHtml<div class="markdown-content">'
      );
      htmlContent = htmlContent.replaceFirst('</body>', '</div></div></body>');
    } else {
      htmlContent = htmlContent.replaceFirst(
        '<body>',
        '<body><div class="export-container"><div class="markdown-content">'
      );
      htmlContent = htmlContent.replaceFirst('</body>', '</div></div></body>');
    }

    final optimizationScript = '''
      <script>
        function optimizeForScreenshot() {
          document.body.style.width = '800px';
          document.body.style.maxWidth = '800px';
          document.body.style.overflowX = 'hidden';
          document.body.style.margin = '0';
          document.body.style.padding = '0';
          
          const container = document.querySelector('.export-container');
          if (container) {
            container.style.width = '800px';
            container.style.maxWidth = '800px';
            container.style.overflowX = 'hidden';
            container.style.margin = '0';
            container.style.padding = '20px';
            container.style.boxSizing = 'border-box';
          }
          
          const codeBlocks = document.querySelectorAll('pre');
          codeBlocks.forEach(pre => {
            pre.style.whiteSpace = 'pre-wrap';
            pre.style.wordWrap = 'break-word';
            pre.style.wordBreak = 'break-all';
            pre.style.overflowX = 'hidden';
            pre.style.maxWidth = '100%';
            
            const code = pre.querySelector('code');
            if (code) {
              code.style.whiteSpace = 'pre-wrap';
              code.style.wordWrap = 'break-word';
              code.style.wordBreak = 'break-all';
              code.style.overflowWrap = 'break-word';
            }
          });
          
          const tables = document.querySelectorAll('table');
          tables.forEach(table => {
            table.style.tableLayout = 'fixed';
            table.style.width = '100%';
            table.style.wordWrap = 'break-word';
          });
          
          if (window.ScreenshotReady) {
            window.ScreenshotReady.postMessage('ready');
          }
        }
        
        if (document.readyState === 'loading') {
          document.addEventListener('DOMContentLoaded', optimizeForScreenshot);
        } else {
          optimizeForScreenshot();
        }
      </script>
    ''';
    
    htmlContent = htmlContent.replaceFirst('</head>', '$optimizationScript</head>');
    
    return htmlContent;
  }

  static Future<Uint8List?> _attemptScreenshotRecovery(
    String originalHtmlContent,
    ValidationResult validationResult,
    String markdownContent,
    String? thinkingContent,
    double originalWidth,
    double originalPixelRatio,
  ) async {
    try {
      // 基于验证结果调整参数
      double adjustedWidth = originalWidth;
      double adjustedPixelRatio = originalPixelRatio;
      
      if (validationResult.actualWidth != null && validationResult.actualWidth! < 600) {
        adjustedWidth = 800; // 增加宽度
      }
      
      if (validationResult.aspectRatio > 8.0) {
        adjustedPixelRatio = 1.5; // 降低像素比例
      }
      
      // 生成恢复用的HTML，添加更强制的样式
      final recoveryHtml = _generateRecoveryHtml(markdownContent, thinkingContent, adjustedWidth);
      
      final webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFDF5E6))
        ..enableZoom(false)
        ..setUserAgent('Mozilla/5.0 (Mobile; rv:107.0)');

      await webViewController.loadHtmlString(recoveryHtml);
      
      // 更长的等待时间确保渲染完成
      await Future.delayed(const Duration(milliseconds: 3000));
      
      final recoveryWidget = Container(
        width: adjustedWidth,
        constraints: const BoxConstraints(
          maxHeight: double.infinity,
        ),
        child: WebViewWidget(controller: webViewController),
      );

      final recoveredScreenshot = await _screenshotController.captureFromWidget(
        recoveryWidget,
        pixelRatio: adjustedPixelRatio,
        context: null,
      );

      return recoveredScreenshot.isNotEmpty ? recoveredScreenshot : null;
    } catch (e) {
      debugPrint('Screenshot recovery failed: $e');
      return null;
    }
  }

  static String _generateRecoveryHtml(String markdownContent, String? thinkingContent, double width) {
    String processedMarkdown = MarkdownRenderer.preprocessHtml(markdownContent);
    String htmlContent = MarkdownRenderer.generateOptimizedHtml(processedMarkdown);
    
    // 添加更强制的恢复CSS
    final recoveryCSS = '''
      <style>
        * { 
          animation: none !important; 
          transition: none !important; 
          transform: none !important;
          box-sizing: border-box !important;
        }
        body { 
          width: ${width.toInt()}px !important; 
          max-width: ${width.toInt()}px !important;
          overflow: hidden !important;
          margin: 0 !important;
          padding: 0 !important;
          background: #FDF5E6 !important;
        }
        .export-container {
          width: ${width.toInt()}px !important;
          max-width: ${width.toInt()}px !important;
          padding: 20px !important;
          margin: 0 !important;
          overflow: hidden !important;
          box-sizing: border-box !important;
        }
        pre { 
          white-space: pre-wrap !important; 
          word-break: break-all !important;
          overflow: hidden !important;
          max-width: calc(100% - 40px) !important;
          background-color: #1E1E1E !important;
          padding: 15px !important;
          margin: 1em 0 !important;
          border-radius: 5px !important;
        }
        pre code {
          color: #D4D4D4 !important;
          white-space: pre-wrap !important;
          word-break: break-all !important;
          overflow: hidden !important;
          font-family: 'Fira Code', 'Source Code Pro', monospace !important;
          font-size: 14px !important;
          line-height: 1.4 !important;
        }
        table {
          table-layout: fixed !important;
          width: 100% !important;
          word-wrap: break-word !important;
        }
      </style>
    ''';
    
    if (thinkingContent != null && thinkingContent.isNotEmpty) {
      final thinkingHtml = '''
        <div class="thinking-section">
          <div class="thinking-label">思考过程:</div>
          ${_escapeHtml(thinkingContent).split('\n').map((line) => '<p>${line.isEmpty ? '&nbsp;' : line}</p>').join('')}
        </div>
      ''';
      
      htmlContent = htmlContent.replaceFirst('<head>', '<head>$recoveryCSS');
      htmlContent = htmlContent.replaceFirst(
        '<body>',
        '<body><div class="export-container">$thinkingHtml<div class="markdown-content">'
      );
      htmlContent = htmlContent.replaceFirst('</body>', '</div></div></body>');
    } else {
      htmlContent = htmlContent.replaceFirst('<head>', '<head>$recoveryCSS');
      htmlContent = htmlContent.replaceFirst(
        '<body>',
        '<body><div class="export-container"><div class="markdown-content">'
      );
      htmlContent = htmlContent.replaceFirst('</body>', '</div></div></body>');
    }
    
    return htmlContent;
  }

  static Future<bool> verifyScreenshotQuality(Uint8List screenshot, double expectedWidth) async {
    if (screenshot.length < 5000) return false;
    
    try {
      return true;
    } catch (e) {
      debugPrint('Screenshot quality verification failed: $e');
      return false;
    }
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#039;');
  }
}