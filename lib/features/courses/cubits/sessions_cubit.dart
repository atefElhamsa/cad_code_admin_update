import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/google_drive_service.dart';
import '../models/session_model.dart';
import 'sessions_state.dart';

class SessionsCubit extends Cubit<SessionsState> {
  final int folderId;
  final _supabase = Supabase.instance.client;
  final GoogleDriveService _driveService = GoogleDriveService();

  SessionsCubit({required this.folderId}) : super(SessionsInitial()) {
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
  }) async {
    emit(SessionUploading());
    try {
      // 1. Upload to Google Drive
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$title.mp4';
      final driveUrl = await _driveService.uploadFile(
        videoFile,
        fileName,
        driveFolderId: '1I9nkwCKp9JNPgBS9cyF3JfwR34RYZPEl',
      );

      if (driveUrl == null) {
        throw Exception('Failed to get Drive URL after upload.');
      }

      // 2. Insert record to Supabase
      final newSession = SessionModel(
        id: 0, // Ignored in insert
        folderId: folderId,
        title: title,
        duration: duration,
        driveUrl: driveUrl,
        orderIndex: orderIndex,
      );

      await _supabase.from('sessions').insert(newSession.toJson());

      emit(const SessionUploadSuccess('Session uploaded successfully!'));

      // Refresh the list
      fetchSessions();
    } catch (e) {
      emit(SessionsError('Error uploading session: $e'));
      // Reload sessions to revert back to loaded state
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
