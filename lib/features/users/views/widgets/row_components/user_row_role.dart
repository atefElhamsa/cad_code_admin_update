import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class UserRowRole extends StatelessWidget {
  final String? role;

  const UserRowRole({super.key, this.role});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: (role == 'admin'
                    ? Colors.orange
                    : AppTheme.primaryAccent)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (role == 'admin'
                      ? Colors.orange
                      : AppTheme.primaryAccent)
                  .withOpacity(0.3),
            ),
          ),
          child: Text(
            (role ?? 'User').toUpperCase(),
            style: TextStyle(
              color: role == 'admin'
                  ? Colors.orange
                  : AppTheme.primaryAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
