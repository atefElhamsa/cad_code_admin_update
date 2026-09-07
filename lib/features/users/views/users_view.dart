import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../cubits/users_cubit.dart';
import '../cubits/users_state.dart';
import '../models/user_profile.dart';
import '../../../core/theme/app_theme.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersCubit(),
      child: const _UsersContent(),
    );
  }
}

class _UsersContent extends StatelessWidget {
  const _UsersContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Users Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.read<UsersCubit>().fetchUsers(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                  foregroundColor: AppTheme.primaryAccent,
                  elevation: 0,
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<UsersCubit, UsersState>(
              builder: (context, state) {
                if (state is UsersLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UsersError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load users:\n${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Make sure you replaced the Supabase keys in main.dart!',
                          style: TextStyle(color: AppTheme.textGray),
                        ),
                      ],
                    ),
                  );
                } else if (state is UsersLoaded) {
                  if (state.users.isEmpty) {
                    return const Center(
                      child: Text(
                        'No users found in the profiles table.',
                        style: TextStyle(color: AppTheme.textGray),
                      ),
                    );
                  }
                  return _buildUsersTable(state.users);
                }
                return const SizedBox();
              },
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildUsersTable(List<UserProfile> users) {
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
              return _UserRowCard(user: users[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _UserRowCard extends StatefulWidget {
  final UserProfile user;

  const _UserRowCard({required this.user});

  @override
  State<_UserRowCard> createState() => _UserRowCardState();
}

class _UserRowCardState extends State<_UserRowCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isHovered
            ? AppTheme.primaryAccent.withOpacity(0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            // User Info (Avatar + Name + Email)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                    backgroundImage: widget.user.avatarUrl != null
                        ? NetworkImage(widget.user.avatarUrl!)
                        : null,
                    child: widget.user.avatarUrl == null
                        ? Text(
                            (widget.user.fullName?.isNotEmpty == true
                                ? widget.user.fullName![0].toUpperCase()
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
                                widget.user.fullName ?? 'Unknown User',
                                style: TextStyle(
                                  color: widget.user.isBanned
                                      ? Colors.redAccent
                                      : AppTheme.textDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: widget.user.isBanned
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.user.isBanned) ...[
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
                                widget.user.email ?? 'No email',
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
            ),

            // Phone
            Expanded(
              flex: 2,
              child: Text(
                widget.user.phone ?? '-',
                style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
              ),
            ),

            // Role Badge
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (widget.user.role == 'admin'
                                ? Colors.orange
                                : AppTheme.primaryAccent)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          (widget.user.role == 'admin'
                                  ? Colors.orange
                                  : AppTheme.primaryAccent)
                              .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    (widget.user.role ?? 'User').toUpperCase(),
                    style: TextStyle(
                      color: widget.user.role == 'admin'
                          ? Colors.orange
                          : AppTheme.primaryAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Date
            Expanded(
              flex: 2,
              child: Text(
                widget.user.createdAt != null
                    ? '${widget.user.createdAt!.year}-${widget.user.createdAt!.month.toString().padLeft(2, '0')}-${widget.user.createdAt!.day.toString().padLeft(2, '0')}'
                    : 'N/A',
                style: const TextStyle(color: AppTheme.textGray, fontSize: 14),
              ),
            ),

            // Actions
            SizedBox(
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
                      widget.user.id,
                      widget.user.isBanned,
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'ban',
                    child: Row(
                      children: [
                        Icon(
                          widget.user.isBanned
                              ? Icons.check_circle_outline
                              : Icons.block,
                          color: widget.user.isBanned
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(widget.user.isBanned ? 'Unban User' : 'Ban User'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
