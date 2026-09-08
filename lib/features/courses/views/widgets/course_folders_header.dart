import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/course_folders_cubit.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/course_model.dart';
import 'add_course_folder_dialog.dart';

class CourseFoldersHeader extends StatelessWidget {
  final CourseModel course;

  const CourseFoldersHeader({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Text(
              '${course.title} Folders',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AddCourseFolderDialog(
                cubit: context.read<CourseFoldersCubit>(),
              ),
            );
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'New Folder',
            style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
