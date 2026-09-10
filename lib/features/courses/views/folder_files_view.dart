import 'package:cad_code_desktop/features/courses/cubits/files_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/course_folder_model.dart';
import '../cubits/files_cubit.dart';
import 'widgets/upload_dialogs.dart';
import 'widgets/native_file_viewer_view.dart';

class FolderFilesView extends StatelessWidget {
  final CourseFolderModel folder;

  const FolderFilesView({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return _FolderFilesContent(folder: folder);
  }
}

class _FolderFilesContent extends StatelessWidget {
  final CourseFolderModel folder;

  const _FolderFilesContent({required this.folder});

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<FilesCubit>(),
          child: UploadFileDialog(folderId: folder.id),
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
                  'Files',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.textGray),
                  tooltip: 'Refresh',
                  onPressed: () => context.read<FilesCubit>().fetchFiles(),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showUploadDialog(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload File'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: BlocBuilder<FilesCubit, FilesState>(
                builder: (context, state) {
                  if (state is FilesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is FilesLoaded) {
                    if (state.files.isEmpty) {
                      return const Center(
                        child: Text(
                          'No files found. Upload a file to get started.',
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: state.files.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final file = state.files[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.insert_drive_file,
                            color: AppTheme.primaryAccent,
                            size: 40,
                          ),
                          title: Text(
                            file.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                tooltip: 'View File Content',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NativeFileViewerView(
                                            driveUrl: file.driveUrl,
                                            fileName: file.title,
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
                                tooltip: 'Delete File',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('Delete File'),
                                      content: const Text(
                                        'Are you sure you want to delete this file?',
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
                                                .read<FilesCubit>()
                                                .deleteFile(file);
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
