import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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

          LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 900) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildChartSection()),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildRecentUsersSection()),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildChartSection(),
                        const SizedBox(height: 24),
                        _buildRecentUsersSection(),
                      ],
                    );
                  }
                },
              )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.1),

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
          StatCard(
            title: 'Active Courses',
            value: state.isLoading ? '...' : state.totalCourses.toString(),
            icon: Icons.book,
            iconColor: Colors.blueAccent,
          ),
          StatCard(
            title: 'Completion Rate',
            value: state.isLoading
                ? '...'
                : '${state.completionRate.toStringAsFixed(1)}%',
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

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Growth (This Month)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 300,
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildLineChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    if (state.userGrowthData.isEmpty) {
      return const Center(
        child: Text(
          'No data available for this month.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final spots = <FlSpot>[];
    int maxCount = 0;

    // Sort keys and create spots
    final sortedDays = state.userGrowthData.keys.toList()..sort();

    // Cumulative count to show growth
    int cumulative = 0;
    for (var day in sortedDays) {
      cumulative += state.userGrowthData[day]!;
      spots.add(FlSpot(day.toDouble(), cumulative.toDouble()));
      if (cumulative > maxCount) maxCount = cumulative;
    }

    // If we only have one data point, add a dummy one at day 1 so the line draws
    if (spots.length == 1) {
      spots.insert(0, FlSpot(1, 0));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxCount > 5 ? (maxCount / 5) : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxCount > 5 ? (maxCount / 5) : 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 31,
        minY: 0,
        maxY: (maxCount * 1.2).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots.isEmpty ? [const FlSpot(1, 0)] : spots,
            isCurved: true,
            color: AppTheme.primaryAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryAccent.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsersSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.recentUsers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.recentUsers.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
              itemBuilder: (context, index) {
                final user = state.recentUsers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                    child: Text(
                      (user.fullName?.isNotEmpty ?? false)
                          ? user.fullName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppTheme.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    (user.fullName?.isNotEmpty ?? false)
                        ? user.fullName!
                        : 'Unknown User',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    user.email ?? 'No Email',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: user.createdAt != null
                      ? Text(
                          DateFormat('MMM d').format(user.createdAt!),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
