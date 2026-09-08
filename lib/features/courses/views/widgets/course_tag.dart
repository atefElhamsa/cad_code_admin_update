import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CourseTag extends StatelessWidget {
  final String tag;

  const CourseTag({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.2)),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: AppTheme.primaryAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
