import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../../../../core/services/google_drive_service.dart';
import '../models/course_model.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final SupabaseClient _supabase = Supabase.instance.client;

  CoursesCubit() : super(CoursesInitial()) {
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    emit(CoursesLoading());
    try {
      final response = await _supabase
          .from('courses')
          .select()
          .order('created_at', ascending: false);
      final courses = (response as List)
          .map((e) => CourseModel.fromJson(e))
          .toList();
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> addCourse(String title, String tag, File? imageFile) async {
    emit(CoursesLoading());
    try {
      String? imageUrl;

      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageFile.path)}';
        await _supabase.storage.from('courses').upload(fileName, imageFile);
        imageUrl = _supabase.storage.from('courses').getPublicUrl(fileName);
      }

      await _supabase.from('courses').insert({
        'title': title,
        'tag': tag,
        'image_url': imageUrl,
      });
      emit(CourseActionSuccess('Course added successfully'));
      await fetchCourses();
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }

  Future<void> deleteCourse(CourseModel course) async {
    emit(CoursesLoading());
    try {
      final driveService = GoogleDriveService();

      // 1. Delete course folder and all subfolders/files from Google Drive
      try {
        await driveService.deleteFolderByName(course.title);
      } catch (e) {
        print('Error deleting course folder from Drive: $e');
      }

      // 2. Fetch all course_folders to clean up Supabase storage and records
      final foldersResponse = await _supabase
          .from('course_folders')
          .select('id, image_url')
          .eq('course_id', course.id);
      final foldersData = foldersResponse as List;

      final folderIds = foldersData.map((f) => f['id'] as int).toList();

      if (folderIds.isNotEmpty) {
        // Delete session/file/task records from Supabase
        try { await _supabase.from('sessions').delete().inFilter('folder_id', folderIds); } catch (_) {}
        try { await _supabase.from('course_files').delete().inFilter('folder_id', folderIds); } catch (_) {}
        try { await _supabase.from('tasks').delete().inFilter('folder_id', folderIds); } catch (_) {}
      }

      for (var folderData in foldersData) {
        final imgUrl = folderData['image_url'] as String?;
        if (imgUrl != null && imgUrl.isNotEmpty) {
          final uri = Uri.tryParse(imgUrl);
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
      }

      await _supabase.from('course_folders').delete().eq('course_id', course.id);

      // 3. Delete course image from Supabase storage
      if (course.imageUrl.isNotEmpty) {
        final uri = Uri.tryParse(course.imageUrl);
        if (uri != null) {
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('courses');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final fileName = pathSegments.sublist(bucketIndex + 1).join('/');
            try {
              await _supabase.storage.from('courses').remove([fileName]);
            } catch (_) {}
          }
        }
      }

      // 4. Delete course row from Supabase
      await _supabase.from('courses').delete().eq('id', course.id);

      emit(CourseActionSuccess('Course deleted successfully'));
      await fetchCourses();
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
