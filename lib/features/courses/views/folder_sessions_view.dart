import 'package:cad_code_desktop/features/courses/models/course_folder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubits/sessions_cubit.dart';
import '../cubits/sessions_state.dart';

class FolderSessionsView extends StatelessWidget {
  final CourseFolderModel folder;
  final bool isTab;

  const FolderSessionsView({
    super.key,
    required this.folder,
    this.isTab = false,
  });

  @override
  Widget build(BuildContext context) {
    return _FolderSessionsContent(folder: folder, isTab: isTab);
  }
}

class _FolderSessionsContent extends StatelessWidget {
  final CourseFolderModel folder;
  final bool isTab;

  const _FolderSessionsContent({required this.folder, required this.isTab});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTab ? 20.0 : 40.0,
          vertical: isTab ? 16.0 : 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isTab) ...[
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textDark,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${folder.title} - Sessions',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ],
            if (isTab) ...[
              Row(
                children: [
                  const Text(
                    'Session Videos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<SessionsCubit>().fetchSessions(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textGray,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            Expanded(
              child: BlocBuilder<SessionsCubit, SessionsState>(
                buildWhen: (previous, current) =>
                    current is SessionsLoading ||
                    current is SessionsLoaded ||
                    current is SessionsError && previous is! SessionsLoaded,
                builder: (context, state) {
                  if (state is SessionsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SessionsLoaded) {
                    if (state.sessions.isEmpty) {
                      return const Center(
                        child: Text(
                          'No sessions found. Upload a video to get started.',
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.sessions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final session = state.sessions[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.play_circle_fill,
                            color: AppTheme.primaryAccent,
                            size: 40,
                          ),
                          title: Text(
                            session.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Duration: ${session.duration ?? "N/A"} | Order: ${session.orderIndex ?? "N/A"}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.link),
                                tooltip: 'Open Drive Link',
                                onPressed: () async {
                                  final url = Uri.parse(session.driveUrl);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Delete Session',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete Session'),
                                      content: const Text(
                                        'Are you sure you want to delete this session?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                            context
                                                .read<SessionsCubit>()
                                                .deleteSession(session);
                                          },
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
