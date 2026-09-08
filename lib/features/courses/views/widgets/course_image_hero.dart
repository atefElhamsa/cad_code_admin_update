import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/course_model.dart';

class CourseImageHero extends StatelessWidget {
  final CourseModel course;

  const CourseImageHero({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'course_image_${course.id}',
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderLight),
          image: course.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(course.imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: course.imageUrl.isEmpty
            ? const Icon(Icons.school, color: AppTheme.textGray, size: 28)
            : null,
      ),
    );
  }
}
