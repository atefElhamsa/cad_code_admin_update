import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  static const _gold1 = Color(0xFFD4A017);
  static const _gold2 = Color(0xFFF5C842);
  static const _gold3 = Color(0xFFB8860B);
  static const _darkBg = Color(0xFF0F1923);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Icon ──────────────────────────────────────────────────
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [_gold2, _gold1, _gold3],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x88D4A017),
                blurRadius: 18,
                spreadRadius: 1,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3), // border thickness
            child: Container(
              decoration: BoxDecoration(
                color: _darkBg,
                borderRadius: BorderRadius.circular(17),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [_gold2, _gold1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Text(
                  'C',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_gold2, _gold1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Text(
            'C&C Academy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white, // masked by ShaderMask
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // ── Sub-label ─────────────────────────────────────────────
        Text(
          'Admin Panel',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.35),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
