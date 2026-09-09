import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../models/user_profile.dart';

class UserRowInfo extends StatelessWidget {
  final UserProfile user;

  const UserRowInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    (user.fullName?.isNotEmpty == true
                        ? user.fullName![0].toUpperCase()
                        : '?'),
                    style: const TextStyle(
                      color: AppTheme.primaryAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName ?? 'Unknown User',
                        style: TextStyle(
                          color: user.isBanned
                              ? Colors.redAccent
                              : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: user.isBanned
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isBanned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'BANNED',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 12,
                      color: AppTheme.textGray,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        user.email ?? 'No email',
                        style: const TextStyle(
                          color: AppTheme.textGray,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
