import 'package:cad_code_desktop/features/users/models/user_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState());

  final _supabase = Supabase.instance.client;

  void incrementCounter() {
    emit(state.copyWith(counter: state.counter + 1));
  }

  void changeTab(int index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      // Use a proven select query (same as UsersCubit) to avoid RLS/Count API issues
      final response = await _supabase.from('profiles').select();
      final allUsers = (response as List)
          .map((e) => UserProfile.fromJson(e))
          .toList();

      final totalUsers = allUsers.length;

      // Sort in Dart by date descending (safest approach if DB indexing or RLS acts up)
      allUsers.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      final recentUsers = allUsers.take(5).toList();

      emit(
        state.copyWith(
          isLoading: false,
          totalUsers: totalUsers,
          recentUsers: recentUsers,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
