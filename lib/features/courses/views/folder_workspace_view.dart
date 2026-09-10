import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cad_code_desktop/features/courses/models/course_folder_model.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubits/sessions_cubit.dart';
import '../cubits/tasks_cubit.dart';
import '../cubits/files_cubit.dart';
import 'folder_sessions_view.dart';
import 'folder_tasks_view.dart';
import 'folder_files_view.dart';

class FolderWorkspaceView extends StatelessWidget {
  final CourseFolderModel folder;

  const FolderWorkspaceView({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SessionsCubit(folderId: folder.id)),
        BlocProvider(create: (context) => TasksCubit(folderId: folder.id)),
        BlocProvider(create: (context) => FilesCubit(folderId: folder.id)),
      ],
      child: DefaultTabController(
        length: 3,
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundLight,
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppTheme.textDark,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.folder_open,
                          color: AppTheme.primaryAccent,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${folder.title} - Workspace',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const TabBar(
                        labelColor: AppTheme.primaryAccent,
                        unselectedLabelColor: AppTheme.textGray,
                        indicatorColor: AppTheme.primaryAccent,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.video_library_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Sessions'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.assignment_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Tasks'),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.insert_drive_file_outlined,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Files'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          FolderSessionsView(folder: folder, isTab: true),
                          FolderTasksView(folder: folder),
                          FolderFilesView(folder: folder),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
