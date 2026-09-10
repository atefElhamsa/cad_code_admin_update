class TaskSubmissionModel {
  final int id;
  final int taskId;
  final String studentId;
  final String fileUrl;
  final DateTime? createdAt;
  final String? studentName;
  final String? studentEmail;

  TaskSubmissionModel({
    required this.id,
    required this.taskId,
    required this.studentId,
    required this.fileUrl,
    this.createdAt,
    this.studentName,
    this.studentEmail,
  });

  factory TaskSubmissionModel.fromJson(Map<String, dynamic> json) {
    String? name;
    String? email;
    if (json['profiles'] != null) {
      name = json['profiles']['full_name'] as String?;
      email = json['profiles']['email'] as String?;
    }

    return TaskSubmissionModel(
      id: json['id'] as int,
      taskId: json['task_id'] as int,
      studentId: json['student_id'] as String,
      fileUrl: json['file_url'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      studentName: name,
      studentEmail: email,
    );
  }
}
