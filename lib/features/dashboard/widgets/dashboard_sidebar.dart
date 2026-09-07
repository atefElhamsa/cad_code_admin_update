import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../cubits/dashboard_cubit.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;

  const DashboardSidebar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Material(
        color: AppTheme.surfaceWhite,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'C&C Academy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            _buildNavItem(context, 0, Icons.dashboard, 'Dashboard'),
            _buildNavItem(context, 1, Icons.people, 'Users'),
            _buildNavItem(context, 2, Icons.book, 'Courses'),
            _buildNavItem(context, 3, Icons.settings, 'Settings'),
          ],
        ),
      ).animate().slideX(
        begin: -1,
        duration: 500.ms,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String title) {
    final isSelected = index == selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            leading: Icon(
              icon,
              color: isSelected ? AppTheme.surfaceWhite : AppTheme.textGray,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppTheme.surfaceWhite : AppTheme.textGray,
              ),
            ),
            selected: isSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              context.read<DashboardCubit>().changeTab(index);
            },
          ),
        ),
      ),
    );
  }
}
