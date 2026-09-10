import 'package:equatable/equatable.dart';

import '../models/task_submission_model.dart';

abstract class TaskSubmissionsState extends Equatable {
  const TaskSubmissionsState();

  @override
  List<Object> get props => [];
}

class TaskSubmissionsInitial extends TaskSubmissionsState {}

class TaskSubmissionsLoading extends TaskSubmissionsState {}

class TaskSubmissionsLoaded extends TaskSubmissionsState {
  final List<TaskSubmissionModel> submissions;

  const TaskSubmissionsLoaded(this.submissions);

  @override
  List<Object> get props => [submissions];
}

class TaskSubmissionsError extends TaskSubmissionsState {
  final String message;

  const TaskSubmissionsError(this.message);

  @override
  List<Object> get props => [message];
}
