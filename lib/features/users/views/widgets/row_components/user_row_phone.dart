import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class UserRowPhone extends StatelessWidget {
  final String? phone;

  const UserRowPhone({super.key, this.phone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Text(
        phone ?? '-',
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 14,
        ),
      ),
    );
  }
}
