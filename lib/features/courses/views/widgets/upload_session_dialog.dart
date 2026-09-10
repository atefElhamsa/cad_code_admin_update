import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../cubits/sessions_cubit.dart';
import '../../cubits/sessions_state.dart';
import 'video_duration_helper.dart';

class UploadSessionDialog extends StatefulWidget {
  final int folderId;

  const UploadSessionDialog({super.key, required this.folderId});

  @override
  State<UploadSessionDialog> createState() => _UploadSessionDialogState();
}

class _UploadSessionDialogState extends State<UploadSessionDialog> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _orderIndexController = TextEditingController();
  File? _selectedFile;
  bool _isExtractingDuration = false;

  Future<void> _pickVideo() async {
    final result = await FilePicker.pickFiles(type: FileType.video);

    // ignore: unnecessary_null_comparison
    if (result != null && result.isNotEmpty && result.first.path != null) {
      final file = File(result.first.path!);
      setState(() {
        _selectedFile = file;
        _isExtractingDuration = true;
      });

      final formatted = await extractVideoDuration(file);
      setState(() {
        _durationController.text = formatted ?? '';
        _isExtractingDuration = false;
      });
    }
  }

  void _upload() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file')),
      );
      return;
    }

    final orderIndex = int.tryParse(_orderIndexController.text.trim());

    context.read<SessionsCubit>().uploadSession(
      videoFile: _selectedFile!,
      title: _titleController.text.trim(),
      duration: _durationController.text.trim(),
      orderIndex: orderIndex,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _orderIndexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionsCubit, SessionsState>(
      listener: (context, state) {
        if (state is SessionUploadSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (state is SessionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
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
            width: 500,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildVideoPicker(isBusy),
                const SizedBox(height: 24),
                _buildTitleField(isBusy),
                const SizedBox(height: 16),
                _buildDurationAndOrderRow(isBusy),
                if (isUploading) _buildUploadingIndicator(),
                const SizedBox(height: 32),
                _buildActionButtons(isBusy),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            color: AppTheme.primaryAccent,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Upload Video Session',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPicker(bool isBusy) {
    return InkWell(
      onTap: isBusy ? null : _pickVideo,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        decoration: BoxDecoration(
          color: isBusy ? Colors.grey.shade50 : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedFile != null
                ? AppTheme.primaryAccent
                : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFile != null
                  ? Icons.video_file
                  : Icons.video_library_outlined,
              size: 48,
              color: _selectedFile != null
                  ? AppTheme.primaryAccent
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFile != null
                  ? _selectedFile!.path.split(Platform.pathSeparator).last
                  : 'Click to select a video',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _selectedFile != null
                    ? AppTheme.textDark
                    : Colors.grey.shade600,
                fontWeight: _selectedFile != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (_isExtractingDuration) ...[
              const SizedBox(height: 16),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Extracting video duration...',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(bool isBusy) {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Session Title',
        hintText: 'e.g. Flutter Basics Part 1',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.title, color: Colors.grey),
      ),
      enabled: !isBusy,
    );
  }

  Widget _buildDurationAndOrderRow(bool isBusy) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _durationController,
            decoration: InputDecoration(
              labelText: 'Duration',
              hintText: 'Auto-detected',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.timer_outlined, color: Colors.grey),
            ),
            enabled: !isBusy,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: _orderIndexController,
            decoration: InputDecoration(
              labelText: 'Order (e.g. 1)',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                Icons.format_list_numbered,
                color: Colors.grey,
              ),
            ),
            keyboardType: TextInputType.number,
            enabled: !isBusy,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingIndicator() {
    return const Column(
      children: [
        SizedBox(height: 32),
        LinearProgressIndicator(
          backgroundColor: Color(0xFFEEEEEE),
          color: AppTheme.primaryAccent,
        ),
        SizedBox(height: 12),
        Center(
          child: Text(
            'Uploading to Google Drive... Please wait',
            style: TextStyle(
              color: AppTheme.primaryAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isBusy) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isBusy ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: isBusy ? null : _upload,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Upload Video',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
