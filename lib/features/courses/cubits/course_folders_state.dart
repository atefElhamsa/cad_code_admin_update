import '../models/course_folder_model.dart';

abstract class CourseFoldersState {}

class CourseFoldersInitial extends CourseFoldersState {}

class CourseFoldersLoading extends CourseFoldersState {}

class CourseFoldersLoaded extends CourseFoldersState {
  final List<CourseFolderModel> folders;

  CourseFoldersLoaded(this.folders);
}

class CourseFoldersError extends CourseFoldersState {
  final String message;

  CourseFoldersError(this.message);
}

class CourseFolderActionSuccess extends CourseFoldersState {
  final String message;

  CourseFolderActionSuccess(this.message);
}
