import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../cubits/courses_cubit.dart';
import '../../cubits/courses_state.dart';
import '../../models/course_model.dart';
import '../../../../core/theme/app_theme.dart';
import 'course_row_card.dart';

class CoursesTable extends StatelessWidget {
  const CoursesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoursesCubit, CoursesState>(
      buildWhen: (previous, current) =>
          current is CoursesLoading ||
          current is CoursesLoaded ||
          current is CoursesError && previous is! CoursesLoaded,
      builder: (context, state) {
        if (state is CoursesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryAccent),
          );
        } else if (state is CoursesLoaded) {
          if (state.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: AppTheme.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No courses found.',
                    style: TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildCoursesTable(state.courses);
        }
        return const SizedBox();
      },
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05);
  }

  Widget _buildCoursesTable(List<CourseModel> courses) {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(color: AppTheme.borderLight, width: 1),
            ),
          ),
          child: Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  'COURSE TITLE',
                  style: TextStyle(
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'TAG',
                  style: TextStyle(
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'CREATED AT',
                  style: TextStyle(
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(width: 48), // Actions
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: courses.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppTheme.borderLight),
            itemBuilder: (context, index) {
              return CourseRowCard(course: courses[index]);
            },
          ),
        ),
      ],
    );
  }
}
