import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import 'user_row_card.dart';

class UsersTable extends StatelessWidget {
  final List<UserProfile> users;

  const UsersTable({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Text(
                  'USER',
                  style: TextStyle(
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: const [
                    Icon(Icons.phone, size: 14, color: AppTheme.textGray),
                    SizedBox(width: 8),
                    Text(
                      'PHONE',
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 1,
                child: Text(
                  'ROLE',
                  style: TextStyle(
                    color: AppTheme.textGray,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: const [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.textGray,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'JOINED',
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Space for action button
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.borderLight),
        // Table Body
        Expanded(
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppTheme.borderLight),
            itemBuilder: (context, index) {
              return UserRowCard(user: users[index]);
            },
          ),
        ),
      ],
    );
  }
}
