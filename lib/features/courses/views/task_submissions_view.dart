import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../cubits/task_submissions_cubit.dart';
import '../cubits/task_submissions_state.dart';
import 'widgets/native_file_viewer_view.dart';

class TaskSubmissionsView extends StatelessWidget {
  final TaskModel task;

  const TaskSubmissionsView({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskSubmissionsCubit()..fetchSubmissions(task.id),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: Text('Submissions for: ${task.title}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<TaskSubmissionsCubit, TaskSubmissionsState>(
          builder: (context, state) {
            if (state is TaskSubmissionsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryAccent),
              );
            } else if (state is TaskSubmissionsLoaded) {
              if (state.submissions.isEmpty) {
                return const Center(
                  child: Text(
                    'No submissions yet for this task.',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 16),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: state.submissions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final submission = state.submissions[index];
                  final submittedAt = submission.createdAt != null
                      ? DateFormat('MMM dd, yyyy - hh:mm a')
                            .format(submission.createdAt!)
                      : 'Unknown date';

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryAccentLight,
                        foregroundColor: AppTheme.primaryAccent,
                        child: Text(
                          submission.studentName?.isNotEmpty == true
                              ? submission.studentName![0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        submission.studentName ?? 'Unknown Student',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (submission.studentEmail != null)
                              Text(
                                submission.studentEmail!,
                                style: const TextStyle(
                                  color: AppTheme.textGray,
                                  fontSize: 13,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Submitted on: $submittedAt',
                              style: const TextStyle(
                                color: AppTheme.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        color: AppTheme.primaryAccent,
                        tooltip: 'View Submission File',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NativeFileViewerView(
                                driveUrl: submission.fileUrl,
                                fileName:
                                    'Submission - ${submission.studentName}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            } else if (state is TaskSubmissionsError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
