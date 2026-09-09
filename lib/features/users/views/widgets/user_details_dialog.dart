import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../../courses/views/widgets/dialog_header.dart';
import 'user_info_section.dart';
import 'user_courses_section.dart';

class UserDetailsDialog extends StatelessWidget {
  final UserProfile user;

  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
              child: DialogHeader(
                title: user.fullName ?? 'User Details',
                subtitle: 'View detailed information and unlocked courses',
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserInfoSection(user: user),
                    const SizedBox(height: 32),
                    const Text(
                      'UNLOCKED COURSES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    UserCoursesSection(courses: user.unlockedFolders),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
    );
  }
}
