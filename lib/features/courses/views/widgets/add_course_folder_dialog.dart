import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';

import '../../cubits/course_folders_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import 'course_image_picker.dart';
import 'custom_dialog_text_field.dart';
import 'dialog_header.dart';
import 'primary_submit_button.dart';

class AddCourseFolderDialog extends StatefulWidget {
  final CourseFoldersCubit cubit;
  const AddCourseFolderDialog({super.key, required this.cubit});

  @override
  State<AddCourseFolderDialog> createState() => _AddCourseFolderDialogState();
}

class _AddCourseFolderDialogState extends State<AddCourseFolderDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    PlatformFile? result = await FilePicker.pickFile(type: FileType.image);

    if (result != null && result.path != null) {
      setState(() {
        _selectedImage = File(result.path!);
      });
    }
  }

  void _submit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Folder title is required')));
      return;
    }

    setState(() => _isLoading = true);
    await widget.cubit.addFolder(title, description, _selectedImage);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DialogHeader(
                  title: 'Add New Folder',
                  subtitle: 'Fill in the details below to create a new folder inside this course.',
                ),
                const SizedBox(height: 32),
                CustomDialogTextField(
                  controller: _titleController,
                  label: 'Folder Title',
                  hint: 'e.g. Chapter 1: Introduction',
                  icon: Icons.folder,
                ),
                const SizedBox(height: 20),
                CustomDialogTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  hint: 'e.g. Learn the basics of C++',
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Folder Cover Image',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                CourseImagePicker(
                  selectedImage: _selectedImage,
                  onTap: _pickImage,
                  onClear: () => setState(() => _selectedImage = null),
                ),
                const SizedBox(height: 32),
                PrimarySubmitButton(
                  isLoading: _isLoading,
                  onPressed: _submit,
                  text: 'Create Folder',
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuad);
  }
}
