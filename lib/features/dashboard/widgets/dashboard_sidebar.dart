import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import 'nav_item.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;

  const DashboardSidebar({super.key, required this.selectedIndex});

  static const _itemColors = [
    AppTheme.primaryAccent,
    Color(0xFF0EA5E9),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
  ];

  static const _itemIcons = [
    // Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.auto_stories_rounded,
    Icons.settings_rounded,
  ];

  static const _itemLabels = [
    // 'Dashboard',
    'Users',
    'Courses',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(6, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Logo area ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x554F46E5),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/logo.jpg',
                      height: 44,
                      width: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'C&C Academy',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFA5B4FC),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Section label ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'MENU',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.3),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // ── Nav items ───────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _itemLabels.length,
              itemBuilder: (context, i) => NavItem(
                index: i,
                icon: _itemIcons[i],
                label: _itemLabels[i],
                color: _itemColors[i],
                isSelected: i == selectedIndex,
              ),
            ),
          ),
        ],
      ),
    ).animate().slideX(begin: -1, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}
