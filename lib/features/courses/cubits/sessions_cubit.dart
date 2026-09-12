import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/google_drive_service.dart';
import '../models/session_model.dart';
import 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  final int folderId;
  final String courseName;
  final String folderName;
  final _supabase = Supabase.instance.client;
  final GoogleDriveService _driveService = GoogleDriveService();

  SessionsCubit({
    required this.folderId,
    required this.courseName,
    required this.folderName,
  }) : super(SessionsInitial()) {
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    emit(SessionsLoading());
    try {
      final response = await _supabase
          .from('sessions')
          .select()
          .eq('folder_id', folderId)
          .order('order_index', ascending: true);

      final sessions = (response as List)
          .map((json) => SessionModel.fromJson(json))
          .toList();

      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionsError('Failed to fetch sessions: $e'));
    }
  }

  Future<void> uploadSession({
    required File videoFile,
    required String title,
    String? duration,
    int? orderIndex,
    List<File> extraFiles = const [],
    List<String> extraFileTitles = const [],
    List<String> extraFileTypes = const [], // 'task' | 'file'
  }) async {
    emit(SessionUploading());
    try {
      // 1. Get or create course folder → session subfolder using SESSION TITLE
      final courseFolderId = await _driveService.getOrCreateFolder(courseName);
      final sessionFolderId = await _driveService.getOrCreateFolder(
        title,
        parentFolderId: courseFolderId,
      );

      // 2. Upload video inside the session folder
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$title.mp4';
      final driveUrl = await _driveService.uploadFile(
        videoFile,
        fileName,
        driveFolderId: sessionFolderId,
      );

      if (driveUrl == null) {
        throw Exception('Failed to get Drive URL after upload.');
      }

      // 3. Insert session with drive_folder_id
      final newSession = SessionModel(
        id: 0,
        folderId: folderId,
        title: title,
        duration: duration,
        driveUrl: driveUrl,
        orderIndex: orderIndex,
        driveFolderId: sessionFolderId,
      );
      await _supabase.from('sessions').insert(newSession.toJson());

      // 4. Upload extra files into the session folder
      //    type 'task' → tasks table | type 'file' → course_files table
      for (int i = 0; i < extraFiles.length; i++) {
        final fileTitle =
            i < extraFileTitles.length && extraFileTitles[i].isNotEmpty
                ? extraFileTitles[i]
                : 'File ${i + 1}';
        final fileType =
            i < extraFileTypes.length ? extraFileTypes[i] : 'file';

        final fileUrl = await _driveService.uploadFile(
          extraFiles[i],
          fileTitle,
          driveFolderId: sessionFolderId,
        );

        if (fileUrl != null) {
          if (fileType == 'task') {
            // → Tasks tab
            await _supabase.from('tasks').insert({
              'folder_id': folderId,
              'title': fileTitle,
              'drive_url': fileUrl,
            });
          } else {
            // → Files tab
            await _supabase.from('course_files').insert({
              'folder_id': folderId,
              'title': fileTitle,
              'drive_url': fileUrl,
            });
          }
        }
      }

      emit(const SessionUploadSuccess('Session uploaded successfully!'));
      fetchSessions();
    } catch (e) {
      emit(SessionsError('Error uploading session: $e'));
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

  Future<void> deleteSession(SessionModel session) async {
    emit(SessionsLoading());
    try {
      final fileId = _extractFileId(session.driveUrl);
      if (fileId.isNotEmpty) {
        try {
          await _driveService.deleteFile(fileId);
        } catch (e) {}
      }

      await _supabase.from('sessions').delete().eq('id', session.id);
      fetchSessions();
    } catch (e) {
      emit(SessionsError('Error deleting session: $e'));
      fetchSessions();
    }
  }
}
