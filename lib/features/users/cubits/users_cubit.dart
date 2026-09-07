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
      // NOTE: This assumes a table named 'profiles' exists.
      final response = await _supabase.from('profiles').select();

      final users = (response as List)
          .map((e) => UserProfile.fromJson(e))
          .toList();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersError(e.toString()));
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
