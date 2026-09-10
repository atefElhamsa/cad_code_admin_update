import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'users_state.dart';
import '../models/user_profile.dart';

class UsersCubit extends Cubit<UsersState> {
  final _supabase = Supabase.instance.client;

  UsersCubit() : super(UsersInitial()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    emit(UsersLoading());
    try {
      final profilesResponse = await _supabase.from('profiles').select();
      
      // Fetch unlocked folders mapped to user_id
      final foldersResponse = await _supabase.from('user_unlocked_folders').select('''
        user_id,
        course_folders(title)
      ''');

      final Map<String, List<String>> userFoldersMap = {};
      for (var row in foldersResponse as List) {
        final userId = row['user_id'] as String;
        final folderTitle = row['course_folders']?['title'] as String?;
        if (folderTitle != null) {
          userFoldersMap.putIfAbsent(userId, () => []).add(folderTitle);
        }
      }

      final users = (profilesResponse as List).map((e) {
        final userId = e['id'] as String;
        e['unlocked_folders_injected'] = userFoldersMap[userId] ?? [];
        return UserProfile.fromJson(e);
      }).toList();
      
      if (!isClosed) emit(UsersLoaded(users));
    } catch (e) {
      if (!isClosed) emit(UsersError(e.toString()));
    }
  }

  Future<void> toggleUserBan(String id, bool currentStatus) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({'is_banned': !currentStatus})
          .eq('id', id)
          .select();

      if (response.isEmpty) {
        emit(
          const UsersError(
            "فشل الحظر: لم يتم تعديل أي بيانات. تأكد من إيقاف الـ RLS!",
          ),
        );
        return;
      }

      fetchUsers(); // Refresh the list after update
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('profiles').delete().eq('id', id);
      fetchUsers(); // Refresh the list after deletion
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }
}
