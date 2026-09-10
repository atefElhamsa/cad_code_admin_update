import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/task_submission_model.dart';
import 'task_submissions_state.dart';

class TaskSubmissionsCubit extends Cubit<TaskSubmissionsState> {
  final _supabase = Supabase.instance.client;

  TaskSubmissionsCubit() : super(TaskSubmissionsInitial());

  Future<void> fetchSubmissions(int taskId) async {
    emit(TaskSubmissionsLoading());
    try {
      // Fetch submissions without foreign key join
      final response = await _supabase
          .from('task_submissions')
          .select()
          .eq('task_id', taskId)
          .order('created_at', ascending: false);

      final List submissionsData = response as List;

      // Extract unique student IDs
      final studentIds = submissionsData
          .map((e) => e['student_id'] as String)
          .toSet()
          .toList();

      // Fetch profiles for those students
      Map<String, Map<String, dynamic>> profilesMap = {};
      if (studentIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profiles')
            .select('id, full_name, email')
            .inFilter('id', studentIds);

        for (var profile in profilesResponse as List) {
          profilesMap[profile['id']] = profile;
        }
      }

      // Map data to models
      final submissions = submissionsData.map((json) {
        final studentId = json['student_id'] as String;
        if (profilesMap.containsKey(studentId)) {
          json['profiles'] = profilesMap[studentId];
        }
        return TaskSubmissionModel.fromJson(json);
      }).toList();

      emit(TaskSubmissionsLoaded(submissions));
    } catch (e) {
      emit(TaskSubmissionsError('Failed to fetch submissions: $e'));
    }
  }
}
