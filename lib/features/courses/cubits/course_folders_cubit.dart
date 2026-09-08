import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

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

  Future<void> addFolder(String title, String? description, File? imageFile) async {
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
        if (description != null && description.isNotEmpty) 'description': description,
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
      if (folder.imageUrl.isNotEmpty) {
        final uri = Uri.tryParse(folder.imageUrl);
        if (uri != null) {
          final pathSegments = uri.pathSegments;
          final bucketIndex = pathSegments.indexOf('course_folders');
          if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
            final fileName = pathSegments.sublist(bucketIndex + 1).join('/');
            await _supabase.storage.from('course_folders').remove([fileName]);
          }
        }
      }
      await _supabase.from('course_folders').delete().eq('id', folder.id);
      emit(CourseFolderActionSuccess('Folder deleted successfully'));
      await fetchFolders();
    } catch (e) {
      emit(CourseFoldersError(e.toString()));
    }
  }
}
