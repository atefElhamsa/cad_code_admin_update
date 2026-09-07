import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../cubits/dashboard_cubit.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../core/theme/app_theme.dart';

class DashboardOverview extends StatelessWidget {
  final DashboardState state;
  const DashboardOverview({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<DashboardCubit>().fetchDashboardData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                  foregroundColor: AppTheme.primaryAccent,
                  elevation: 0,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),

          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Error: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),

          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          StatCard(
            title: 'Total Users',
            value: state.isLoading ? '...' : state.totalUsers.toString(),
            icon: Icons.people,
            iconColor: AppTheme.primaryAccent,
          ),
          const StatCard(
            title: 'Active Courses',
            value: '42',
            icon: Icons.book,
            iconColor: Colors.blueAccent,
          ),
          const StatCard(
            title: 'Completion Rate',
            value: '87%',
            icon: Icons.trending_up,
            iconColor: Colors.orangeAccent,
          ),
        ];

        if (constraints.maxWidth > 900) {
          return Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 24),
              Expanded(child: cards[1]),
              const SizedBox(width: 24),
              Expanded(child: cards[2]),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
        } else {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 24),
              cards[1],
              const SizedBox(height: 24),
              cards[2],
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
        }
      },
    );
  }
}
