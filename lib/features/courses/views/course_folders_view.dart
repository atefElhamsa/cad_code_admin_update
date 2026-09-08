import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';

import '../cubits/course_folders_cubit.dart';
import '../cubits/course_folders_state.dart';
import '../models/course_model.dart';
import 'widgets/course_folders_header.dart';
import 'widgets/course_folders_table.dart';

class CourseFoldersView extends StatelessWidget {
  final CourseModel course;

  const CourseFoldersView({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseFoldersCubit(courseId: course.id),
      child: _CourseFoldersContent(course: course),
    );
  }
}

class _CourseFoldersContent extends StatelessWidget {
  final CourseModel course;

  const _CourseFoldersContent({required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: BlocListener<CourseFoldersCubit, CourseFoldersState>(
        listener: (context, state) {
          if (state is CourseFolderActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          } else if (state is CourseFoldersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CourseFoldersHeader(course: course),
              const SizedBox(height: 32),
              const Expanded(child: CourseFoldersTable()),
            ],
          ),
        ),
      ),
    );
  }
}
