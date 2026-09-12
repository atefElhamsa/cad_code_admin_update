import 'package:cad_code_desktop/features/courses/cubits/tasks_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/course_folder_model.dart';
import '../cubits/tasks_cubit.dart';
import 'widgets/upload_dialogs.dart';
import 'widgets/native_file_viewer_view.dart';
import 'task_submissions_view.dart';

class FolderTasksView extends StatelessWidget {
  final CourseFolderModel folder;

  const FolderTasksView({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return _FolderTasksContent(folder: folder);
  }
}

class _FolderTasksContent extends StatelessWidget {
  final CourseFolderModel folder;

  const _FolderTasksContent({required this.folder});

  // ignore: unused_element
  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<TasksCubit>(),
          child: UploadTaskDialog(folderId: folder.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => context.read<TasksCubit>().fetchTasks(),
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
            const SizedBox(height: 32),
            Expanded(
              child: BlocBuilder<TasksCubit, TasksState>(
                builder: (context, state) {
                  if (state is TasksLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TasksLoaded) {
                    if (state.tasks.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tasks found. Upload a task to get started.',
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.tasks.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.assignment,
                            color: AppTheme.primaryAccent,
                            size: 40,
                          ),
                          title: Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(task.description ?? 'No description'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.inbox),
                                color: AppTheme.primaryAccent,
                                tooltip: 'View Student Submissions',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskSubmissionsView(task: task),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                tooltip: 'View File Content',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NativeFileViewerView(
                                            driveUrl: task.driveUrl,
                                            fileName: task.title,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Delete Task',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete Task'),
                                      content: const Text(
                                        'Are you sure you want to delete this task?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            context
                                                .read<TasksCubit>()
                                                .deleteTask(task);
                                            Navigator.pop(dialogContext);
                                          },
                                          child: const Text('Delete'),
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
