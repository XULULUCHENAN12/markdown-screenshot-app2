import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../services/markdown_renderer.dart';
import '../services/screenshot_service.dart';
import '../data/test_cases.dart';

class MarkdownScreenshotScreen extends StatefulWidget {
  const MarkdownScreenshotScreen({super.key});

  @override
  State<MarkdownScreenshotScreen> createState() => _MarkdownScreenshotScreenState();
}

class _MarkdownScreenshotScreenState extends State<MarkdownScreenshotScreen> {
  final TextEditingController _markdownController = TextEditingController();
  final TextEditingController _thinkingController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  
  bool _isGenerating = false;
  bool _useAlternativeRenderer = false;
  String? _lastScreenshotPath;
  
  @override
  void initState() {
    super.initState();
    _loadTestData();
  }
  
  void _loadTestData() {
    _markdownController.text = '''# Markdown截图测试

## 基本文本格式
这是一个**加粗文本**和*斜体文本*的示例。

## 代码块测试

### JavaScript代码
```javascript
function processLongVariableNamesAndComplexFunctionCallsWithManyParametersAndNestedObjects() {
  const veryLongVariableNameThatShouldWrapCorrectly = "这是一个很长的字符串，应该能够正确换行显示";
  const anotherLongVariable = someFunction.call(this, param1, param2, param3, param4);
  
  if (condition && anotherCondition && yetAnotherVeryLongConditionName) {
    console.log("这行代码包含多个嵌套的函数调用和长参数名称");
    someObject.someMethod().chainedMethod().anotherChainedMethod();
  }
  
  return {
    result: "success",
    data: processedData,
    metadata: { timestamp: Date.now(), version: "1.0.0" }
  };
}
```

### Python代码
```python
def extremely_long_function_name_that_demonstrates_wrapping_behavior():
    very_long_variable_name_for_demonstration = "这是一个测试字符串用于验证Python代码的换行效果"
    another_variable_with_long_name = some_function_call(param1, param2, param3, param4, param5)
    
    if condition_one and condition_two and very_long_condition_name:
        print("这是一行很长的Python代码，用于测试自动换行功能是否正常工作")
        result = some_object.method_call().chained_method().another_chained_method()
    
    return {
        "status": "success",
        "data": processed_data,
        "very_long_key_name": another_variable_with_long_name
    }
```

### SQL查询
```sql
SELECT users.id, users.username, users.email, profiles.first_name, profiles.last_name, posts.title, posts.content, posts.created_at
FROM users 
INNER JOIN profiles ON users.id = profiles.user_id 
INNER JOIN posts ON users.id = posts.author_id 
WHERE users.created_at > '2023-01-01' AND posts.status = 'published' AND profiles.country = 'China';
```

## 列表测试
1. 第一个项目包含很长的文本内容，用于测试列表项的换行效果
2. 第二个项目
   - 嵌套列表项目一
   - 嵌套列表项目二，包含长文本内容测试换行
3. 第三个项目

## 引用块测试
> 这是一个引用块，包含一些重要的信息。引用块应该有特殊的样式显示，并且能够正确处理长文本的换行效果。

## 表格测试
| 功能 | 描述 | 状态 |
|------|------|------|
| 代码块换行 | 强制使用pre-wrap实现自动换行 | ✅ 完成 |
| 水平滚动禁用 | 使用overflow-x: hidden | ✅ 完成 |
| VS Code主题 | 深色背景配浅色文字 | ✅ 完成 |''';

    _thinkingController.text = '''让我分析一下这个Markdown截图的需求：

1. 首先需要确保代码块能够正确换行，避免出现水平滚动
2. 使用VS Code Dark+主题风格，深色背景配浅色文字
3. 确保截图过程中不会出现内容截断的问题
4. 支持思考过程和回答内容的合并显示

基于油猴脚本的实现经验，关键是要在CSS中强制设置：
- white-space: pre-wrap
- word-break: break-all
- overflow-x: hidden
- 固定的容器宽度

这样可以确保长代码行能够正确换行显示。''';

    _fileNameController.text = 'markdown_test_${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
  }

  Future<void> _generateScreenshot() async {
    if (_markdownController.text.trim().isEmpty) {
      _showMessage('请输入Markdown内容', isError: true);
      return;
    }

    setState(() {
      _isGenerating = true;
      _lastScreenshotPath = null;
    });

    try {
      final file = await ScreenshotService.captureMarkdownAsImage(
        markdownContent: _markdownController.text,
        thinkingContent: _thinkingController.text.isNotEmpty ? _thinkingController.text : null,
        fileName: _fileNameController.text.isNotEmpty ? _fileNameController.text : null,
        width: 800,
        pixelRatio: 2.0,
      );

      if (file != null) {
        setState(() {
          _lastScreenshotPath = file.path;
        });
        _showMessage('截图已保存: ${file.path}', isError: false);
      } else {
        _showMessage('截图生成失败', isError: true);
      }
    } catch (e) {
      _showMessage('生成截图时出错: $e', isError: true);
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showMessage('已复制到剪贴板', isError: false);
  }

  void _clearAll() {
    setState(() {
      _markdownController.clear();
      _thinkingController.clear();
      _fileNameController.clear();
      _lastScreenshotPath = null;
    });
  }

  void _loadTestCase(String caseKey) {
    final testCase = TestCases.getCase(caseKey);
    if (testCase != null) {
      setState(() {
        _markdownController.text = testCase.markdown;
        _thinkingController.text = testCase.thinking ?? '';
        _fileNameController.text = '${caseKey}_${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
      });
      _showMessage('已加载测试用例: ${testCase.title}', isError: false);
    }
  }

  void _showTestCaseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择测试用例'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: TestCases.allTitles.length,
              itemBuilder: (context, index) {
                final caseKey = TestCases.allTitles[index];
                final testCase = TestCases.getCase(caseKey)!;
                return ListTile(
                  title: Text(testCase.title),
                  subtitle: Text(testCase.description),
                  onTap: () {
                    Navigator.of(context).pop();
                    _loadTestCase(caseKey);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown截图工具'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.science),
            onPressed: _showTestCaseDialog,
            tooltip: '选择测试用例',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: '清空所有内容',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fileNameController,
                    decoration: const InputDecoration(
                      labelText: '文件名（可选）',
                      border: OutlineInputBorder(),
                      hintText: '留空将自动生成',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SwitchListTile(
                  title: const Text('使用备选渲染器'),
                  value: _useAlternativeRenderer,
                  onChanged: (value) {
                    setState(() {
                      _useAlternativeRenderer = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text('思考过程（可选）:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _thinkingController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '在这里输入思考过程...',
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text('Markdown内容:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              flex: 4,
              child: TextField(
                controller: _markdownController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '在这里输入Markdown内容...',
                ),
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateScreenshot,
                    icon: _isGenerating 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
                    label: Text(_isGenerating ? '生成中...' : '生成截图'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(_markdownController.text),
                  icon: const Icon(Icons.copy),
                  label: const Text('复制Markdown'),
                ),
              ],
            ),
            
            if (_lastScreenshotPath != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '截图已生成:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _copyToClipboard(_lastScreenshotPath!),
                      child: Text(
                        _lastScreenshotPath!,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _markdownController.dispose();
    _thinkingController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }
}