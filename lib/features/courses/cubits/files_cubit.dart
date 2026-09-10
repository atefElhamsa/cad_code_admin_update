import 'dart:io';

import 'package:cad_code_desktop/features/courses/cubits/files_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course_file_model.dart';
import '../../../core/services/google_drive_service.dart';

class FilesCubit extends Cubit<FilesState> {
  final int folderId;
  final _supabase = Supabase.instance.client;
  final _driveService = GoogleDriveService();

  FilesCubit({required this.folderId}) : super(FilesInitial()) {
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    emit(FilesLoading());
    try {
      final response = await _supabase
          .from('course_files')
          .select()
          .eq('folder_id', folderId)
          .order('created_at', ascending: true);

      final files = (response as List)
          .map((json) => CourseFile.fromJson(json))
          .toList();
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FilesError('Error fetching files: $e'));
    }
  }

  Future<void> uploadFile(String filePath, String title) async {
    emit(FilesLoading());
    try {
      // 1. Upload to Google Drive
      final driveUrl = await _driveService.uploadFile(File(filePath), title);

      // 2. Save to Supabase
      final newFile = {
        'folder_id': folderId,
        'title': title,
        'drive_url': driveUrl,
      };

      await _supabase.from('course_files').insert(newFile);

      // Refresh list
      fetchFiles();
    } catch (e) {
      emit(FilesError('Error uploading file: $e'));
      fetchFiles();
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

  Future<void> deleteFile(CourseFile file) async {
    emit(FilesLoading());
    try {
      final fileId = _extractFileId(file.driveUrl);
      if (fileId.isNotEmpty) {
        try {
          await _driveService.deleteFile(fileId);
        } catch (e) {
          print('Warning: Failed to delete file from Drive: $e');
        }
      }

      await _supabase.from('course_files').delete().eq('id', file.id);
      fetchFiles();
    } catch (e) {
      emit(FilesError('Error deleting file: $e'));
      fetchFiles();
    }
  }
}
