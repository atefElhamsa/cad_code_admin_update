import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../cubits/files_cubit.dart';
import '../../cubits/sessions_cubit.dart';
import '../../cubits/sessions_state.dart';
import '../../cubits/tasks_cubit.dart';
import 'video_duration_helper.dart';

class UploadSessionDialog extends StatefulWidget {
  final int folderId;

  const UploadSessionDialog({super.key, required this.folderId});

  @override
  State<UploadSessionDialog> createState() => _UploadSessionDialogState();
}

class _UploadSessionDialogState extends State<UploadSessionDialog>
    with SingleTickerProviderStateMixin {
  // ─── Controllers ──────────────────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _orderIndexController = TextEditingController();
  final _taskTitleController = TextEditingController();
  final _materialTitleController = TextEditingController();
  final PageController _pageController = PageController();

  // ─── State ────────────────────────────────────────────────────────────────
  File? _selectedVideo;
  File? _taskFile;
  File? _materialFile;
  bool _isExtractingDuration = false;
  int _currentPage = 0; // 0 = Video & Info | 1 = Task & Material
  String? _titleError;
  String? _videoError;

  // ─── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickVideo() async {
    final result = await FilePicker.pickFiles(type: FileType.video);
    // ignore: unnecessary_null_comparison
    if (result != null && result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      setState(() {
        _selectedVideo = file;
        _videoError = null;
        if (_titleController.text.isEmpty) {
          _titleController.text = result.first.name.replaceAll(
            RegExp(r'\.[^.]+$'),
            '',
          );
          _titleError = null;
        }
        _isExtractingDuration = true;
      });
      final formatted = await extractVideoDuration(file);
      setState(() {
        _durationController.text = formatted ?? '';
        _isExtractingDuration = false;
      });
    }
  }

  Future<void> _pickTaskFile() async {
    final result = await FilePicker.pickFiles();
    // ignore: unnecessary_null_comparison
    if (result != null && result.isNotEmpty && result.first.path != null) {
      setState(() {
        _taskFile = File(result.first.path!);
        if (_taskTitleController.text.isEmpty) {
          _taskTitleController.text = result.first.name.replaceAll(
            RegExp(r'\.[^.]+$'),
            '',
          );
        }
      });
    }
  }

  Future<void> _pickMaterialFile() async {
    final result = await FilePicker.pickFiles();
    // ignore: unnecessary_null_comparison
    if (result != null && result.isNotEmpty && result.first.path != null) {
      setState(() {
        _materialFile = File(result.first.path!);
        if (_materialTitleController.text.isEmpty) {
          _materialTitleController.text = result.first.name.replaceAll(
            RegExp(r'\.[^.]+$'),
            '',
          );
        }
      });
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void _nextPage() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty
          ? 'Session title is required'
          : null;
      _videoError = _selectedVideo == null
          ? 'Please select a video file'
          : null;
    });

    if (_titleError != null || _videoError != null) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = 1);
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = 0);
  }

  // ─── Upload ───────────────────────────────────────────────────────────────

  void _upload() {
    final extraFiles = <File>[];
    final extraTitles = <String>[];
    final extraTypes = <String>[];

    if (_taskFile != null) {
      extraFiles.add(_taskFile!);
      extraTitles.add(_taskTitleController.text.trim());
      extraTypes.add('task');
    }
    if (_materialFile != null) {
      extraFiles.add(_materialFile!);
      extraTitles.add(_materialTitleController.text.trim());
      extraTypes.add('file');
    }

    context.read<SessionsCubit>().uploadSession(
      videoFile: _selectedVideo!,
      title: _titleController.text.trim(),
      duration: _durationController.text.trim(),
      orderIndex: int.tryParse(_orderIndexController.text.trim()),
      extraFiles: extraFiles,
      extraFileTitles: extraTitles,
      extraFileTypes: extraTypes,
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _orderIndexController.dispose();
    _taskTitleController.dispose();
    _materialTitleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionsCubit, SessionsState>(
      listener: (context, state) {
        if (state is SessionUploadSuccess) {
          Navigator.of(context).pop();
          _showSnack(state.message);
          // ← Auto-refresh التلات tabs
          context.read<SessionsCubit>().fetchSessions();
          context.read<TasksCubit>().fetchTasks();
          context.read<FilesCubit>().fetchFiles();
        } else if (state is SessionsError) {
          _showSnack(state.message, isError: true);
        }
      },
      builder: (context, state) {
        final isUploading = state is SessionUploading;
        final isBusy = isUploading || _isExtractingDuration;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 560,
            height: 630,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────
                _buildHeader(),

                // ── Step Indicator ────────────────────────────────
                _buildStepIndicator(),

                // ── Pages ─────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [_buildPage1(isBusy), _buildPage2(isBusy)],
                  ),
                ),

                // ── Upload Progress ───────────────────────────────
                if (isUploading) _buildUploadingIndicator(),

                // ── Actions ───────────────────────────────────────
                _buildActions(isBusy),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Pages ────────────────────────────────────────────────────────────────

  Widget _buildPage1(bool isBusy) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            'Session Info',
            Icons.info_outline,
            AppTheme.primaryAccent,
            badge: 'مطلوب',
            badgeColor: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildTitleField(isBusy),
          const SizedBox(height: 12),
          _buildDurationAndOrderRow(isBusy),
          const SizedBox(height: 24),
          _buildSectionLabel(
            'Video',
            Icons.videocam_outlined,
            const Color(0xFF7C3AED),
            badge: 'مطلوب',
            badgeColor: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildVideoPicker(isBusy),
          if (_videoError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                _videoError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage2(bool isBusy) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(
            'Task File',
            Icons.assignment_outlined,
            const Color(0xFFD97706),
            badge: 'Tasks Tab',
            badgeColor: const Color(0xFFD97706),
          ),
          const SizedBox(height: 6),
          Text(
            'هيظهر في تاب Tasks للطلاب يسلّموا عليه',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          _buildAttachmentRow(
            file: _taskFile,
            titleController: _taskTitleController,
            onPick: isBusy ? null : _pickTaskFile,
            accentColor: const Color(0xFFD97706),
            placeholder: 'Task title',
          ),
          const SizedBox(height: 28),
          _buildSectionLabel(
            'Course Material',
            Icons.description_outlined,
            const Color(0xFF059669),
            badge: 'Files Tab',
            badgeColor: const Color(0xFF059669),
          ),
          const SizedBox(height: 6),
          Text(
            'هيظهر في تاب Files كمادة دراسية',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          _buildAttachmentRow(
            file: _materialFile,
            titleController: _materialTitleController,
            onPick: isBusy ? null : _pickMaterialFile,
            accentColor: const Color(0xFF059669),
            placeholder: 'Material title',
          ),
        ],
      ),
    );
  }

  // ─── Widget builders ──────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAccent.withOpacity(0.07),
            AppTheme.primaryAccent.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppTheme.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Session',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                'Video + Task + Material في مكان واحد',
                style: TextStyle(fontSize: 12, color: AppTheme.textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      child: Row(
        children: [
          _stepDot(0, 'Video & Info'),
          Expanded(
            child: Container(
              height: 2,
              color: _currentPage >= 1
                  ? AppTheme.primaryAccent
                  : Colors.grey.shade200,
            ),
          ),
          _stepDot(1, 'Task & Material'),
        ],
      ),
    );
  }

  Widget _stepDot(int step, String label) {
    final isActive = _currentPage == step;
    final isDone = _currentPage > step;
    final color = (isActive || isDone)
        ? AppTheme.primaryAccent
        : Colors.grey.shade300;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (isActive || isDone)
                ? AppTheme.primaryAccent
                : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? AppTheme.primaryAccent : Colors.grey.shade400,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(
    String label,
    IconData icon,
    Color color, {
    String? badge,
    Color? badgeColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (badgeColor ?? color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: (badgeColor ?? color).withOpacity(0.3)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                color: badgeColor ?? color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoPicker(bool isBusy) {
    return InkWell(
      onTap: isBusy ? null : _pickVideo,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: _selectedVideo != null
              ? const Color(0xFF7C3AED).withOpacity(0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedVideo != null
                ? const Color(0xFF7C3AED)
                : Colors.grey.shade200,
            width: _selectedVideo != null ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedVideo != null
                    ? const Color(0xFF7C3AED).withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _selectedVideo != null
                    ? Icons.video_file
                    : Icons.video_library_outlined,
                size: 22,
                color: _selectedVideo != null
                    ? const Color(0xFF7C3AED)
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedVideo != null
                        ? _selectedVideo!.path
                              .split(Platform.pathSeparator)
                              .last
                        : 'اضغط لاختيار الفيديو',
                    style: TextStyle(
                      color: _selectedVideo != null
                          ? AppTheme.textDark
                          : Colors.grey.shade500,
                      fontWeight: _selectedVideo != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_isExtractingDuration) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Extracting duration...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_selectedVideo == null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Browse',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentRow({
    required File? file,
    required TextEditingController titleController,
    required VoidCallback? onPick,
    required Color accentColor,
    required String placeholder,
  }) {
    return Row(
      children: [
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: file != null
                  ? accentColor.withOpacity(0.08)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: file != null ? accentColor : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  file != null ? Icons.check_circle : Icons.attach_file,
                  size: 18,
                  color: file != null ? accentColor : Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Text(
                  file != null
                      ? file.path.split(Platform.pathSeparator).last
                      : 'Attach',
                  style: TextStyle(
                    fontSize: 12,
                    color: file != null ? accentColor : Colors.grey.shade600,
                    fontWeight: file != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: titleController,
            enabled: onPick != null,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField(bool isBusy) {
    return TextField(
      controller: _titleController,
      enabled: !isBusy,
      onChanged: (val) {
        if (_titleError != null) setState(() => _titleError = null);
      },
      decoration: InputDecoration(
        labelText: 'Session Title',
        hintText: 'e.g. Session 1 - Variables',
        errorText: _titleError,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryAccent,
            width: 1.5,
          ),
        ),
        prefixIcon: const Icon(Icons.title, color: Colors.grey, size: 20),
      ),
    );
  }

  Widget _buildDurationAndOrderRow(bool isBusy) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _durationController,
            enabled: !isBusy,
            decoration: InputDecoration(
              labelText: 'Duration',
              hintText: 'Auto-detected',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryAccent,
                  width: 1.5,
                ),
              ),
              prefixIcon: const Icon(
                Icons.timer_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            controller: _orderIndexController,
            enabled: !isBusy,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Order',
              hintText: 'e.g. 1',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryAccent,
                  width: 1.5,
                ),
              ),
              prefixIcon: const Icon(
                Icons.format_list_numbered,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              minHeight: 5,
              backgroundColor: Color(0xFFEEEEEE),
              color: AppTheme.primaryAccent,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Uploading to Google Drive...',
                style: TextStyle(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isBusy) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          // Cancel / Back
          if (_currentPage == 0)
            TextButton(
              onPressed: isBusy ? null : () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: isBusy ? null : _prevPage,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textGray,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          const Spacer(),

          // Next / Upload
          if (_currentPage == 0)
            ElevatedButton.icon(
              onPressed: isBusy ? null : _nextPage,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text(
                'Next',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: isBusy ? null : _upload,
              icon: const Icon(Icons.cloud_upload, size: 17),
              label: const Text(
                'Upload Session',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
