class TaskModel {
  final int id;
  final int folderId;
  final String title;
  final String? description;
  final String driveUrl;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.folderId,
    required this.title,
    this.description,
    required this.driveUrl,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as int,
      folderId: json['folder_id'] as int,
      title: json['title'],
      description: json['description'],
      driveUrl: json['drive_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder_id': folderId,
      'title': title,
      if (description != null) 'description': description,
      'drive_url': driveUrl,
    };
  }
}
