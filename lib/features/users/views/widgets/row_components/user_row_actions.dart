import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../models/user_profile.dart';
import '../../../cubits/users_cubit.dart';

class UserRowActions extends StatelessWidget {
  final UserProfile user;
  final bool isHovered;

  const UserRowActions({super.key, required this.user, required this.isHovered});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_horiz,
          color: isHovered ? AppTheme.primaryAccent : AppTheme.textGray,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onSelected: (value) {
          if (value == 'ban') {
            context.read<UsersCubit>().toggleUserBan(
              user.id,
              user.isBanned,
            );
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'ban',
            child: Row(
              children: [
                Icon(
                  user.isBanned
                      ? Icons.check_circle_outline
                      : Icons.block,
                  color: user.isBanned ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  user.isBanned ? 'Unban User' : 'Ban User',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
