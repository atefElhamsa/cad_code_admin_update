import 'package:cad_code_desktop/features/courses/models/course_file_model.dart';

abstract class FilesState {}

class FilesInitial extends FilesState {}

class FilesLoading extends FilesState {}

class FilesLoaded extends FilesState {
  final List<CourseFile> files;
  FilesLoaded(this.files);
}

class FilesError extends FilesState {
  final String message;
  FilesError(this.message);
}
