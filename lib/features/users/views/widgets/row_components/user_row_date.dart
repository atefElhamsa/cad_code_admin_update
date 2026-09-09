import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class UserRowDate extends StatelessWidget {
  final DateTime? createdAt;

  const UserRowDate({super.key, this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Text(
        createdAt != null
            ? '${createdAt!.year}-${createdAt!.month.toString().padLeft(2, '0')}-${createdAt!.day.toString().padLeft(2, '0')}'
            : 'N/A',
        style: const TextStyle(
          color: AppTheme.textGray,
          fontSize: 14,
        ),
      ),
    );
  }
}
