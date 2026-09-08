import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';

import '../../cubits/courses_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import 'course_image_picker.dart';
import 'custom_dialog_text_field.dart';
import 'dialog_header.dart';
import 'primary_submit_button.dart';

class AddCourseDialog extends StatefulWidget {
  final CoursesCubit cubit;
  const AddCourseDialog({super.key, required this.cubit});

  @override
  State<AddCourseDialog> createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _titleController = TextEditingController();
  final _tagController = TextEditingController();
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
    final tag = _tagController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Course title is required')));
      return;
    }

    setState(() => _isLoading = true);
    await widget.cubit.addCourse(title, tag, _selectedImage);
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
                  title: 'Add New Course',
                  subtitle: 'Fill in the details below to create a new course.',
                ),
                const SizedBox(height: 32),
                CustomDialogTextField(
                  controller: _titleController,
                  label: 'Course Title',
                  hint: 'e.g. Master Flutter in 30 Days',
                  icon: Icons.title,
                ),
                const SizedBox(height: 20),
                CustomDialogTextField(
                  controller: _tagController,
                  label: 'Course Tag',
                  hint: 'e.g. Mobile Dev, AI, Design',
                  icon: Icons.local_offer_outlined,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Course Cover Image',
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
                  text: 'Create Course',
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
