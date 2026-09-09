import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import 'user_details_dialog.dart';
import 'row_components/user_row_info.dart';
import 'row_components/user_row_phone.dart';
import 'row_components/user_row_role.dart';
import 'row_components/user_row_date.dart';
import 'row_components/user_row_actions.dart';

class UserRowCard extends StatefulWidget {
  final UserProfile user;

  const UserRowCard({super.key, required this.user});

  @override
  State<UserRowCard> createState() => _UserRowCardState();
}

class _UserRowCardState extends State<UserRowCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => UserDetailsDialog(user: widget.user),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: isHovered
              ? AppTheme.primaryAccent.withOpacity(0.05)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              UserRowInfo(user: widget.user),
              UserRowPhone(phone: widget.user.phone),
              UserRowRole(role: widget.user.role),
              UserRowDate(createdAt: widget.user.createdAt),
              UserRowActions(user: widget.user, isHovered: isHovered),
            ],
          ),
        ),
      ),
    );
  }
}
