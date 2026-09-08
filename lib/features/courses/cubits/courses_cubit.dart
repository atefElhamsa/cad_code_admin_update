import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

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
      // 1. Fetch and delete folder images
      final response = await _supabase
          .from('course_folders')
          .select('image_url')
          .eq('course_id', course.id);
      final foldersData = response as List;
      for (var folderData in foldersData) {
        final imgUrl = folderData['image_url'] as String?;
        if (imgUrl != null && imgUrl.isNotEmpty) {
          final uri = Uri.tryParse(imgUrl);
          if (uri != null) {
            final pathSegments = uri.pathSegments;
            final bucketIndex = pathSegments.indexOf('course_folders');
            if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
              final fileName = pathSegments.sublist(bucketIndex + 1).join('/');
              await _supabase.storage.from('course_folders').remove([fileName]);
            }
          }
        }
      }

      // 2. Delete course image
      if (course.imageUrl.isNotEmpty) {
        final uri = Uri.tryParse(course.imageUrl);
        if (uri != null) {
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('courses');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final fileName = pathSegments.sublist(bucketIndex + 1).join('/');
            await _supabase.storage.from('courses').remove([fileName]);
          }
        }
      }

      // 3. Delete course row (cascade should delete folder rows)
      await _supabase.from('courses').delete().eq('id', course.id);

      emit(CourseActionSuccess('Course deleted successfully'));
      await fetchCourses();
    } catch (e) {
      emit(CoursesError(e.toString()));
    }
  }
}
