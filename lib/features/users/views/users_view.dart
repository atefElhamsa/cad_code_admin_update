import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../cubits/users_cubit.dart';
import '../cubits/users_state.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/users_table.dart';

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
                  return UsersTable(users: state.users);
                }
                return const SizedBox();
              },
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}
