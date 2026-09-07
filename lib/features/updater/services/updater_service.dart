import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdaterService {
  static String get _versionUrl =>
      'https://raw.githubusercontent.com/atefElhamsa/cad_code_admin_update/main/version.json?t=${DateTime.now().millisecondsSinceEpoch}';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await http
          .get(Uri.parse(_versionUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = data['version'] as String;
        final forceUpdate = data['force'] as bool? ?? false;

        final info = await PackageInfo.fromPlatform();
        final currentVersion = info.version;

        // force=true -> Any different version gets blocked | force=false -> Only if there's a newer version
        final bool shouldUpdate = forceUpdate
            ? _isDifferent(latestVersion, currentVersion)
            : _isNewer(latestVersion, currentVersion);

        if (shouldUpdate) {
          if (context.mounted) {
            await _showForcedUpdateDialog(context, latestVersion, forceUpdate);
          }
        }
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }
  }

  static bool _isDifferent(String latest, String current) {
    String cleanLatest = latest.split('+')[0].split('-')[0].trim();
    String cleanCurrent = current.split('+')[0].split('-')[0].trim();
    return cleanLatest != cleanCurrent;
  }

  static bool _isNewer(String latest, String current) {
    try {
      String cleanLatest = latest.split('+')[0].split('-')[0].trim();
      String cleanCurrent = current.split('+')[0].split('-')[0].trim();

      if (cleanLatest == cleanCurrent) return false;

      final l = cleanLatest
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final c = cleanCurrent
          .split('.')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      int len = l.length > c.length ? l.length : c.length;
      for (int i = 0; i < len; i++) {
        int lVal = i < l.length ? l[i] : 0;
        int cVal = i < c.length ? c[i] : 0;
        if (lVal > cVal) return true;
        if (lVal < cVal) return false;
      }
    } catch (_) {}
    return false;
  }

  static Future<void> _showForcedUpdateDialog(
    BuildContext context,
    String latestVersion,
    bool isForced,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: _UpdateDialogWidget(
          latestVersion: latestVersion,
          isForced: isForced,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Widget
// ─────────────────────────────────────────────
class _UpdateDialogWidget extends StatefulWidget {
  final String latestVersion;
  final bool isForced;

  const _UpdateDialogWidget({
    required this.latestVersion,
    required this.isForced,
  });

  @override
  State<_UpdateDialogWidget> createState() => _UpdateDialogWidgetState();
}

class _UpdateDialogWidgetState extends State<_UpdateDialogWidget>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = '';
  bool _hasError = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startDownloadAndInstall() async {
    setState(() {
      _isDownloading = true;
      _hasError = false;
      _statusText = 'جاري التحميل...';
    });

    try {
      final exeUrl =
          'https://github.com/atefElhamsa/cad_code_admin_update/releases/download/v${widget.latestVersion}/cad_code_admin_setup.exe';

      final tempDir = await getTemporaryDirectory();
      final savePath =
          '${tempDir.path}\\cad_code_admin_setup_v${widget.latestVersion}.exe';

      final dio = Dio();
      int lastUpdateTime = 0;

      await dio.download(
        exeUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - lastUpdateTime > 100 || received == total) {
              lastUpdateTime = now;
              if (mounted) {
                setState(() {
                  _progress = received / total;
                  final mb = (received / 1024 / 1024).toStringAsFixed(1);
                  final totalMb = (total / 1024 / 1024).toStringAsFixed(1);
                  _statusText = '$mb MB / $totalMb MB';
                });
              }
            }
          }
        },
      );

      if (mounted) {
        setState(() => _statusText = 'اكتمل التحميل، جاري التثبيت...');
      }

      await Process.start(savePath, [], mode: ProcessStartMode.detached);
      exit(0);
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'فشل التحميل، حاول مرة أخرى';
          _isDownloading = false;
          _hasError = true;
          _progress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 440,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.25),
            blurRadius: 60,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header gradient ──────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Animated icon
                ScaleTransition(
                  scale: _isDownloading
                      ? const AlwaysStoppedAnimation(1.0)
                      : _pulseAnim,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'تحديث جديد متاح',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'الإصدار ${widget.latestVersion}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Warning message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isForced
                              ? 'لا يمكنك الاستمرار في استخدام التطبيق بدون تحديثه إلى آخر إصدار.'
                              : 'يتوفر إصدار جديد يتضمن تحسينات وإصلاحات مهمة.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFCBD5E1),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Download progress ───────────────────────
                if (_isDownloading) ...[
                  _buildProgressSection(),
                ] else ...[
                  // ── Button ──────────────────────────────────
                  _buildUpdateButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final percent = (_progress * 100).toInt();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _hasError
                  ? 'خطأ'
                  : (_progress == 0 ? 'جاري التحضير...' : 'جاري التحميل'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _hasError
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF94A3B8),
              ),
            ),
            if (_progress > 0 && !_hasError)
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF60A5FA),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _progress > 0 ? _progress : null,
            backgroundColor: const Color(0xFF1E293B),
            valueColor: AlwaysStoppedAnimation<Color>(
              _hasError ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _statusText,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _startDownloadAndInstall,
          icon: const Icon(Icons.download_rounded, size: 20),
          label: const Text(
            'تحديث الآن',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
