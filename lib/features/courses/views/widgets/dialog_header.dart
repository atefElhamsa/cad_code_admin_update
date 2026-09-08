import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class DialogHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const DialogHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.textGray),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.textGray.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
