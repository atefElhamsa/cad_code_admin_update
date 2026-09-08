import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class CourseDateText extends StatelessWidget {
  final DateTime? date;

  const CourseDateText({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final dateString = date != null
        ? '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'
        : 'N/A';

    return Text(
      dateString,
      style: const TextStyle(
        color: AppTheme.textGray,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
