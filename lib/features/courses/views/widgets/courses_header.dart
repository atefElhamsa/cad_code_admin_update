import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../cubits/courses_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import 'add_course_dialog.dart';

class CoursesHeader extends StatelessWidget {
  const CoursesHeader({super.key});

  void _showAddCourseDialog(BuildContext context, CoursesCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AddCourseDialog(cubit: cubit);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Courses Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage and add new courses for the academy.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textGray.withOpacity(0.8),
              ),
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => context.read<CoursesCubit>().fetchCourses(),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryAccent,
                side: const BorderSide(color: AppTheme.primaryAccent),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  _showAddCourseDialog(context, context.read<CoursesCubit>()),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Course'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.05);
  }
}
