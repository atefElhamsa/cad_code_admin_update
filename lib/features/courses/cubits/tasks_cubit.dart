import 'dart:io';

import 'package:cad_code_desktop/features/courses/cubits/tasks_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task_model.dart';
import '../../../core/services/google_drive_service.dart';

class TasksCubit extends Cubit<TasksState> {
  final int folderId;
  final _supabase = Supabase.instance.client;
  final _driveService = GoogleDriveService();

  TasksCubit({required this.folderId}) : super(TasksInitial()) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    emit(TasksLoading());
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('folder_id', folderId)
          .order('created_at', ascending: true);

      final tasks = (response as List)
          .map((json) => TaskModel.fromJson(json))
          .toList();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TasksError('Error fetching tasks: $e'));
    }
  }

  Future<void> uploadTask(
    String filePath,
    String title,
    String description,
  ) async {
    emit(TasksLoading());
    try {
      // 1. Upload to Google Drive
      final driveUrl = await _driveService.uploadFile(File(filePath), title);

      // 2. Save to Supabase
      final newTask = {
        'folder_id': folderId,
        'title': title,
        'description': description,
        'drive_url': driveUrl,
      };

      await _supabase.from('tasks').insert(newTask);

      // Refresh list
      fetchTasks();
    } catch (e) {
      emit(TasksError('Error uploading task: $e'));
      fetchTasks();
    }
  }

  String _extractFileId(String url) {
    if (url.contains('/file/d/')) {
      final parts = url.split('/file/d/');
      if (parts.length > 1) {
        return parts[1].split('/')[0];
      }
    }
    final uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters.containsKey('id')) {
      return uri.queryParameters['id']!;
    }
    return '';
  }

  Future<void> deleteTask(TaskModel task) async {
    emit(TasksLoading());
    try {
      final fileId = _extractFileId(task.driveUrl);
      if (fileId.isNotEmpty) {
        try {
          await _driveService.deleteFile(fileId);
        } catch (e) {
          print('Warning: Failed to delete file from Drive: $e');
        }
      }

      // Delete from Supabase
      await _supabase.from('tasks').delete().eq('id', task.id);
      fetchTasks();
    } catch (e) {
      emit(TasksError('Error deleting task: $e'));
      fetchTasks();
    }
  }
}
