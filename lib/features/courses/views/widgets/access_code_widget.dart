import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../access_codes/cubits/access_codes_cubit.dart';
import '../../../access_codes/cubits/access_codes_state.dart';

class AccessCodeWidget extends StatelessWidget {
  final int folderId;

  const AccessCodeWidget({super.key, required this.folderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccessCodesCubit(folderId: folderId),
      child: const AccessCodeContent(),
    );
  }
}

class AccessCodeContent extends StatelessWidget {
  const AccessCodeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AccessCodesCubit, AccessCodesState>(
      listener: (context, state) {
        if (state is AccessCodesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is AccessCodesLoading) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryAccent,
            ),
          );
        }

        if (state is AccessCodesLoaded) {
          if (state.isUsed) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Used! Generating...',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.green,
                  ),
                ),
              ],
            ).animate().fadeIn();
          }

          if (state.activeCode != null) {
            return Container(
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primaryAccent,
                    Color(0xFF6366F1),
                  ], // Indigo to lighter indigo
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 12),
                      child: Text(
                        state.activeCode!,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    Tooltip(
                      message: 'Copy Code',
                      child: InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: state.activeCode!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Code copied to clipboard!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppTheme.primaryAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 24,
                              ),
                              elevation: 4,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Regenerate Code',
                      child: InkWell(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        onTap: () {
                          context.read<AccessCodesCubit>().generateCode();
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8, right: 16),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
          }

          return ElevatedButton.icon(
            onPressed: () {
              context.read<AccessCodesCubit>().generateCode();
            },
            icon: const Icon(
              Icons.add_circle_outline,
              size: 18,
              color: AppTheme.primaryAccent,
            ),
            label: const Text(
              'Generate Code',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.primaryAccent,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccentLight.withValues(
                alpha: 0.5,
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ).animate().fadeIn();
        }

        return const SizedBox();
      },
    );
  }
}
