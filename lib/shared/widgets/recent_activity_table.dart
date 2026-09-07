import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/users/models/user_profile.dart';

class RecentActivityTable extends StatelessWidget {
  final List<UserProfile> recentUsers;
  final bool isLoading;

  const RecentActivityTable({
    super.key,
    required this.recentUsers,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Recent Registrations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderLight),
          
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recentUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(
                child: Text(
                  'No recent registrations found.',
                  style: TextStyle(color: AppTheme.textGray, fontSize: 16),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textGray,
                  fontSize: 13,
                ),
                dataTextStyle: const TextStyle(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500,
                ),
                dataRowMaxHeight: 64,
                dataRowMinHeight: 56,
                columns: const [
                  DataColumn(label: Text('USER')),
                  DataColumn(label: Text('EMAIL')),
                  DataColumn(label: Text('ROLE')),
                  DataColumn(label: Text('JOINED')),
                ],
                rows: recentUsers.map((user) => _buildRow(user)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildRow(UserProfile user) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl == null
                    ? Text(
                        (user.fullName?.isNotEmpty == true ? user.fullName![0].toUpperCase() : '?'),
                        style: const TextStyle(
                          color: AppTheme.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(user.fullName ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        DataCell(Text(user.email ?? 'No Email')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (user.role == 'admin' ? Colors.orange : AppTheme.primaryAccent).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (user.role ?? 'User').toUpperCase(),
              style: TextStyle(
                color: user.role == 'admin' ? Colors.orange : AppTheme.primaryAccent,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        DataCell(Text(user.createdAt != null ? _formatDate(user.createdAt!) : 'N/A')),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
