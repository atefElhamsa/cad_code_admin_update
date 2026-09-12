import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../../../../core/services/google_drive_service.dart';
import '../models/course_folder_model.dart';
import 'course_folders_state.dart';

class CourseFoldersCubit extends Cubit<CourseFoldersState> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final int courseId;

  CourseFoldersCubit({required this.courseId}) : super(CourseFoldersInitial()) {
    fetchFolders();
  }

  Future<void> fetchFolders() async {
    emit(CourseFoldersLoading());
    try {
      final response = await _supabase
          .from('course_folders')
          .select()
          .eq('course_id', courseId)
          .order('created_at', ascending: true);

      final folders = (response as List)
          .map((e) => CourseFolderModel.fromJson(e))
          .toList();

      emit(CourseFoldersLoaded(folders));
    } catch (e) {
      emit(CourseFoldersError(e.toString()));
    }
  }

  Future<void> addFolder(
    String title,
    String? description,
    File? imageFile,
  ) async {
    emit(CourseFoldersLoading());
    try {
      String? imageUrl;

      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';
        await _supabase.storage
            .from('course_folders')
            .upload(fileName, imageFile);
        imageUrl = _supabase.storage
            .from('course_folders')
            .getPublicUrl(fileName);
      }

      await _supabase.from('course_folders').insert({
        'course_id': courseId,
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
        'image_url': imageUrl,
      });

      emit(CourseFolderActionSuccess('Folder added successfully'));
      await fetchFolders();
    } catch (e) {
      emit(CourseFoldersError(e.toString()));
    }
  }

  Future<void> deleteFolder(CourseFolderModel folder) async {
    emit(CourseFoldersLoading());
    try {
      final driveService = GoogleDriveService();

      // 1. جيب كل السيشنات وامسحها من Drive
      final sessionsResponse = await _supabase
          .from('sessions')
          .select('drive_url, drive_folder_id')
          .eq('folder_id', folder.id);

      for (final s in (sessionsResponse as List)) {
        final driveFolderId = s['drive_folder_id'] as String?;
        if (driveFolderId != null && driveFolderId.isNotEmpty) {
          // امسح فولدر السيشن كله (بيمسح الفيديو والملفات جوّاه)
          try {
            await driveService.deleteFile(driveFolderId);
          } catch (_) {}
        } else {
          // fallback: امسح الفيديو بنفسه
          final fileId = GoogleDriveService.extractFileId(
            s['drive_url'] as String? ?? '',
          );
          if (fileId.isNotEmpty) {
            try {
              await driveService.deleteFile(fileId);
            } catch (_) {}
          }
        }
      }

      // 2. جيب الملفات المنفردة وامسحها من Drive
      final filesResponse = await _supabase
          .from('course_files')
          .select('drive_url')
          .eq('folder_id', folder.id);

      for (final f in (filesResponse as List)) {
        final fileId = GoogleDriveService.extractFileId(
          f['drive_url'] as String? ?? '',
        );
        if (fileId.isNotEmpty) {
          try {
            await driveService.deleteFile(fileId);
          } catch (_) {}
        }
      }

      // 3. جيب التاسكات وامسحها من Drive
      final tasksResponse = await _supabase
          .from('tasks')
          .select('drive_url')
          .eq('folder_id', folder.id);

      for (final t in (tasksResponse as List)) {
        final fileId = GoogleDriveService.extractFileId(
          t['drive_url'] as String? ?? '',
        );
        if (fileId.isNotEmpty) {
          try {
            await driveService.deleteFile(fileId);
          } catch (_) {}
        }
      }

      // 4. امسح صورة الفولدر من Supabase Storage
      if (folder.imageUrl.isNotEmpty) {
        final uri = Uri.tryParse(folder.imageUrl);
        if (uri != null) {
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('course_folders');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final fileName = pathSegments.sublist(bucketIndex + 1).join('/');
            try {
              await _supabase.storage.from('course_folders').remove([fileName]);
            } catch (_) {}
          }
        }
      }

      // 5. امسح كل السجلات من Supabase (sessions, files, tasks, folder)
      await _supabase.from('sessions').delete().eq('folder_id', folder.id);
      await _supabase.from('course_files').delete().eq('folder_id', folder.id);
      await _supabase.from('tasks').delete().eq('folder_id', folder.id);
      await _supabase.from('course_folders').delete().eq('id', folder.id);

      emit(CourseFolderActionSuccess('Folder deleted successfully'));
      await fetchFolders();
    } catch (e) {
      emit(CourseFoldersError(e.toString()));
    }
  }

  // ignore: unused_element
  String _extractFileId(String url) {
    if (url.contains('/file/d/')) {
      final parts = url.split('/file/d/');
      if (parts.length > 1) return parts[1].split('/')[0];
    }
    final uri = Uri.tryParse(url);
    if (uri != null && uri.queryParameters.containsKey('id')) {
      return uri.queryParameters['id']!;
    }
    return '';
  }
}
