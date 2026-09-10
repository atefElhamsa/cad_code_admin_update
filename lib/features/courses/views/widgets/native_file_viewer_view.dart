import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../../../core/theme/app_theme.dart';

class NativeFileViewerView extends StatefulWidget {
  final String driveUrl;
  final String fileName;

  const NativeFileViewerView({
    super.key,
    required this.driveUrl,
    required this.fileName,
  });

  @override
  State<NativeFileViewerView> createState() => _NativeFileViewerViewState();
}

class _NativeFileViewerViewState extends State<NativeFileViewerView>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  String? _textContent;
  Uint8List? _imageBytes;
  bool _isImage = false;
  double _fontSize = 13.0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fetchFile();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _extractFileId(String url) {
    if (url.contains('/file/d/')) {
      final parts = url.split('/file/d/');
      if (parts.length > 1) {
        return parts[1].split('/')[0];
      }
    }
    final uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters.containsKey('id')) {
      return uri.queryParameters['id']!;
    }
    return '';
  }

  String _getFileExtension() {
    final parts = widget.fileName.split('.');
    if (parts.length > 1) return parts.last.toLowerCase();
    return '';
  }

  Color _getLanguageColor() {
    final ext = _getFileExtension();
    switch (ext) {
      case 'cpp':
      case 'c':
      case 'h':
        return const Color(0xFF00B4D8);
      case 'dart':
        return const Color(0xFF54C5F8);
      case 'py':
        return const Color(0xFFFFD43B);
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'json':
        return const Color(0xFF7EE787);
      case 'html':
        return const Color(0xFFE34C26);
      case 'css':
        return const Color(0xFF264DE4);
      default:
        return AppTheme.primaryAccent;
    }
  }

  IconData _getFileIcon() {
    final ext = _getFileExtension();
    switch (ext) {
      case 'cpp':
      case 'c':
      case 'h':
      case 'dart':
      case 'py':
      case 'js':
        return Icons.code_rounded;
      case 'json':
        return Icons.data_object_rounded;
      case 'html':
      case 'css':
        return Icons.web_rounded;
      case 'jpg':
      case 'png':
      case 'jpeg':
        return Icons.image_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Future<void> _fetchFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fileId = _extractFileId(widget.driveUrl);
      if (fileId.isEmpty) {
        setState(() {
          _errorMessage = 'رابط Google Drive غير صالح';
          _isLoading = false;
        });
        return;
      }

      final downloadUrl =
          'https://drive.google.com/uc?export=download&id=$fileId';
      final response = await http.get(Uri.parse(downloadUrl));

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'] ?? '';
        final isImage = contentType.startsWith('image/');
        final ext = _getFileExtension();
        final isImageByExt = [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'webp',
        ].contains(ext);

        if (isImage || isImageByExt) {
          setState(() {
            _imageBytes = response.bodyBytes;
            _isImage = true;
            _isLoading = false;
          });
        } else {
          String content;
          try {
            content = utf8.decode(response.bodyBytes);
          } catch (_) {
            content = response.body;
          }
          setState(() {
            _textContent = content;
            _isLoading = false;
          });
        }
        _fadeController.forward();
      } else {
        setState(() {
          _errorMessage = 'فشل تحميل الملف. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل الملف: $e';
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_textContent != null) {
      Clipboard.setData(ClipboardData(text: _textContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'تم نسخ الكود بنجاح!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2EA043),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF161B22),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _getLanguageColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getFileIcon(), color: _getLanguageColor(), size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              widget.fileName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (_textContent != null) ...[
          IconButton(
            icon: const Icon(
              Icons.remove_rounded,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _fontSize = (_fontSize - 1).clamp(8.0, 24.0)),
            tooltip: 'تصغير النص',
          ),
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _fontSize = (_fontSize + 1).clamp(8.0, 24.0)),
            tooltip: 'تكبير النص',
          ),
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: _copyToClipboard,
            tooltip: 'نسخ الكود',
          ),
        ],
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.08)),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: _getLanguageColor(),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'جارٍ تحميل الملف...',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 56,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _fetchFile,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: _isImage && _imageBytes != null
          ? _buildImageViewer()
          : _buildCodeViewer(),
    );
  }

  Widget _buildImageViewer() {
    return Container(
      color: const Color(0xFF0D1117),
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(_imageBytes!, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeViewer() {
    if (_textContent == null) return const SizedBox();

    final lines = _textContent!.split('\n');
    final langColor = _getLanguageColor();

    return Column(
      children: [
        // File info bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: langColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getFileExtension().toUpperCase().isNotEmpty
                    ? _getFileExtension().toUpperCase()
                    : 'TEXT',
                style: TextStyle(
                  color: langColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${lines.length} سطر',
                style: const TextStyle(color: Colors.white30, fontSize: 11),
              ),
              const Spacer(),
              const Text(
                'UTF-8',
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
        ),
        // Code area
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: IntrinsicWidth(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      color: const Color(0xFF161B22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          lines.length,
                          (i) => SizedBox(
                            height: _fontSize * 1.7,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: _fontSize - 1,
                                fontFamily: 'monospace',
                                height: 1.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, color: Colors.white.withOpacity(0.06)),
                    // Code content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          lines.length,
                          (i) => SizedBox(
                            height: _fontSize * 1.7,
                            child: Text(
                              lines[i].isEmpty ? ' ' : lines[i],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontFamily: 'monospace',
                                fontSize: _fontSize,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
