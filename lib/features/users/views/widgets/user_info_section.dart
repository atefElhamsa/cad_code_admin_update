import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';

class UserInfoSection extends StatelessWidget {
  final UserProfile user;

  const UserInfoSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.1),
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName ?? 'Unknown User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.email_outlined,
                user.email ?? 'No email provided',
              ),
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.phone_outlined,
                user.phone ?? 'No phone provided',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (user.role == 'admin'
                              ? Colors.orange
                              : AppTheme.primaryAccent)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (user.role == 'admin'
                                ? Colors.orange
                                : AppTheme.primaryAccent)
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  (user.role ?? 'User').toUpperCase(),
                  style: TextStyle(
                    color: user.role == 'admin'
                        ? Colors.orange
                        : AppTheme.primaryAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textGray, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
