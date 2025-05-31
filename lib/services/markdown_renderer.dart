import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownRenderer {
  static const String _optimizedCodeCSS = '''
    <style>
      * {
        box-sizing: border-box !important;
      }
      
      body {
        margin: 0 !important;
        padding: 20px !important;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif !important;
        line-height: 1.6 !important;
        color: #333 !important;
        background: #FDF5E6 !important;
        overflow-x: hidden !important;
        max-width: 100vw !important;
        word-wrap: break-word !important;
      }
      
      .export-container {
        background-color: #FDF5E6 !important;
        color: #333 !important;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif !important;
        font-size: 16px !important;
        line-height: 1.6 !important;
        padding: 20px !important;
        box-sizing: border-box !important;
        max-width: 800px !important;
        margin: 0 auto !important;
      }
      
      .thinking-section {
        font-size: 14px !important;
        color: #555 !important;
        margin-bottom: 20px !important;
        border-left: 3px solid #999 !important;
        padding-left: 10px !important;
        background-color: rgba(0,0,0,0.05) !important;
        padding-top: 5px !important;
        padding-bottom: 5px !important;
        white-space: pre-wrap !important;
      }
      
      .thinking-label {
        font-weight: bold !important;
        color: #444 !important;
      }
      
      pre {
        background-color: #1E1E1E !important;
        padding: 15px !important;
        border-radius: 5px !important;
        overflow-x: hidden !important;
        overflow-y: auto !important;
        margin-top: 1em !important;
        margin-bottom: 1em !important;
        white-space: pre-wrap !important;
        word-wrap: break-word !important;
        word-break: break-all !important;
        max-width: 100% !important;
        box-sizing: border-box !important;
      }
      
      code {
        font-family: 'Fira Code', 'Source Code Pro', 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace !important;
        font-size: 14px !important;
        line-height: 1.4 !important;
        white-space: pre-wrap !important;
        word-wrap: break-word !important;
        word-break: break-all !important;
        overflow-wrap: break-word !important;
      }
      
      pre code {
        display: block !important;
        color: #D4D4D4 !important;
        background: transparent !important;
        border: none !important;
        padding: 0 !important;
        margin: 0 !important;
        width: 100% !important;
        max-width: 100% !important;
        white-space: pre-wrap !important;
        word-break: break-all !important;
      }
      
      pre code .punctuation,
      pre code .token.punctuation,
      pre code .hljs-punctuation,
      pre code .punc,
      pre code .delimiter,
      pre code .paren,
      pre code .brace,
      pre code span[class*="punct"],
      pre code .operator,
      pre code .token.operator {
        color: #D4D4D4 !important;
      }
      
      :not(pre) > code {
        background-color: rgba(0,0,0,0.1) !important;
        padding: 2px 4px !important;
        border-radius: 3px !important;
        font-size: 0.9em !important;
        color: #c7254e !important;
        word-break: break-all !important;
      }
      
      .code-block {
        position: relative !important;
        max-width: 100% !important;
        overflow: hidden !important;
      }
      
      .language-tag {
        position: absolute !important;
        top: 8px !important;
        right: 8px !important;
        background: rgba(0,0,0,0.1) !important;
        padding: 2px 6px !important;
        border-radius: 3px !important;
        font-size: 12px !important;
        color: #666 !important;
      }
      
      h1, h2, h3, h4, h5, h6 {
        color: #222 !important;
        margin-top: 1.5em !important;
        margin-bottom: 0.8em !important;
        padding-bottom: 0.3em !important;
        border-bottom: 1px solid rgba(0,0,0,0.1) !important;
        word-wrap: break-word !important;
      }
      
      h1 { font-size: 2em !important; }
      h2 { font-size: 1.7em !important; }
      h3 { font-size: 1.4em !important; }
      h4 { font-size: 1.2em !important; }
      
      p {
        margin-bottom: 1em !important;
        word-wrap: break-word !important;
        overflow-wrap: break-word !important;
      }
      
      strong {
        color: #000 !important;
      }
      
      em {
        font-style: italic !important;
      }
      
      a {
        color: #007bff !important;
        text-decoration: none !important;
        word-break: break-all !important;
      }
      
      a:hover {
        text-decoration: underline !important;
      }
      
      ul, ol {
        margin-left: 20px !important;
        margin-bottom: 1em !important;
        word-wrap: break-word !important;
      }
      
      li {
        margin-bottom: 0.5em !important;
        word-wrap: break-word !important;
      }
      
      blockquote {
        border-left: 4px solid #ccc !important;
        margin: 1em 0 !important;
        padding: 0.5em 15px !important;
        color: #666 !important;
        background-color: rgba(0,0,0,0.03) !important;
        word-wrap: break-word !important;
      }
      
      table {
        width: 100% !important;
        border-collapse: collapse !important;
        margin-bottom: 1em !important;
        max-width: 100% !important;
        overflow-x: auto !important;
        display: block !important;
        white-space: nowrap !important;
      }
      
      th, td {
        border: 1px solid #ddd !important;
        padding: 8px !important;
        text-align: left !important;
        word-wrap: break-word !important;
      }
      
      th {
        background-color: #eee !important;
        color: #333 !important;
      }
      
      img {
        max-width: 100% !important;
        height: auto !important;
        display: block !important;
        margin: 10px 0 !important;
      }
      
      hr {
        border: none !important;
        border-top: 1px solid #e1e4e8 !important;
        margin: 24px 0 !important;
      }
      
      .highlight {
        background: #fff3cd !important;
        padding: 2px 4px !important;
        border-radius: 3px !important;
      }
    </style>
  ''';

  static String preprocessHtml(String htmlContent) {
    String processed = htmlContent;
    
    processed = processed.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '');
    
    processed = processed.replaceAll(RegExp(r'style\s*=\s*"[^"]*"', caseSensitive: false), '');
    processed = processed.replaceAll(RegExp(r'style\s*=\s*\'[^\']*\'', caseSensitive: false), '');
    
    processed = processed.replaceAll(RegExp(r'<pre([^>]*)>', caseSensitive: false), 
        '<div class="code-block"><pre\\1>');
    processed = processed.replaceAll('</pre>', '</pre></div>');
    
    processed = processed.replaceAllMapped(
      RegExp(r'<code[^>]*class\s*=\s*["\']([^"\']*)["\'][^>]*>', caseSensitive: false),
      (match) {
        String className = match.group(1) ?? '';
        String language = className.replaceFirst('language-', '');
        return '${match.group(0)}<span class="language-tag">$language</span>';
      },
    );
    
    processed = processed.replaceAll(RegExp(r'<div[^>]*style[^>]*>', caseSensitive: false), '<div>');
    processed = processed.replaceAll(RegExp(r'<span[^>]*style[^>]*>', caseSensitive: false), '<span>');
    
    return processed;
  }

  static String generateOptimizedHtml(String markdownContent) {
    String processedMarkdown = markdownContent;
    
    processedMarkdown = processedMarkdown.replaceAllMapped(
      RegExp(r'```(\w+)?\n(.*?)\n```', dotAll: true),
      (match) {
        String language = match.group(1) ?? '';
        String code = match.group(2) ?? '';
        
        code = code.replaceAll('&', '&amp;')
                  .replaceAll('<', '&lt;')
                  .replaceAll('>', '&gt;')
                  .replaceAll('"', '&quot;');
        
        return '''
<div class="code-block">
  <pre><code class="language-$language">$code</code></pre>
  ${language.isNotEmpty ? '<span class="language-tag">$language</span>' : ''}
</div>''';
      },
    );
    
    processedMarkdown = processedMarkdown.replaceAllMapped(
      RegExp(r'`([^`]+)`'),
      (match) => '<code>${match.group(1)}</code>',
    );
    
    processedMarkdown = processedMarkdown.replaceAllMapped(
      RegExp(r'^# (.+)$', multiLine: true),
      (match) => '<h1>${match.group(1)}</h1>',
    );
    
    processedMarkdown = processedMarkdown.replaceAllMapped(
      RegExp(r'^## (.+)$', multiLine: true),
      (match) => '<h2>${match.group(1)}</h2>',
    );
    
    processedMarkdown = processedMarkdown.replaceAllMapped(
      RegExp(r'^### (.+)$', multiLine: true),
      (match) => '<h3>${match.group(1)}</h3>',
    );
    
    processedMarkdown = processedMarkdown.replaceAllMapped(
      RegExp(r'^\*\*(.+?)\*\*', multiLine: true),
      (match) => '<strong>${match.group(1)}</strong>',
    );
    
    processedMarkdown = processedMarkdown.replaceAllMapped(
      RegExp(r'^\*(.+?)\*', multiLine: true),
      (match) => '<em>${match.group(1)}</em>',
    );
    
    List<String> lines = processedMarkdown.split('\n');
    List<String> processedLines = [];
    
    for (String line in lines) {
      if (line.trim().isEmpty) {
        processedLines.add('<br>');
      } else if (!line.contains('<div class="code-block">') && 
                 !line.contains('<h1>') && 
                 !line.contains('<h2>') && 
                 !line.contains('<h3>')) {
        processedLines.add('<p>$line</p>');
      } else {
        processedLines.add(line);
      }
    }
    
    String htmlContent = processedLines.join('\n');
    
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    $_optimizedCodeCSS
</head>
<body>
    $htmlContent
</body>
</html>''';
  }

  static Widget buildFlutterMarkdown(String content, {bool useAlternative = false}) {
    return Markdown(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        code: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: Color(0xfff1f3f4),
        ),
        codeblockDecoration: const BoxDecoration(
          color: Color(0xff1E1E1E),
          borderRadius: BorderRadius.all(Radius.circular(6)),
          border: Border.fromBorderSide(BorderSide(color: Color(0xffe9ecef))),
        ),
        codeblockPadding: const EdgeInsets.all(16),
        codeblockAlign: WrapAlignment.start,
        blockquote: const TextStyle(
          color: Color(0xff6a737d),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: const BoxDecoration(
          color: Color(0xfff6f8fa),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: Border(left: BorderSide(color: Color(0xffdfe2e5), width: 4)),
        ),
        blockquotePadding: const EdgeInsets.all(16),
        p: const TextStyle(
          fontSize: 16,
          height: 1.6,
        ),
        h1: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xff222222),
        ),
        h2: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xff222222),
        ),
        h3: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xff222222),
        ),
      ),
    );
  }
}