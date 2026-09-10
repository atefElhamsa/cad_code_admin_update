class CourseFile {
  final int id;
  final int folderId;
  final String title;
  final String driveUrl;
  final DateTime createdAt;

  CourseFile({
    required this.id,
    required this.folderId,
    required this.title,
    required this.driveUrl,
    required this.createdAt,
  });

  factory CourseFile.fromJson(Map<String, dynamic> json) {
    return CourseFile(
      id: json['id'] as int,
      folderId: json['folder_id'] as int,
      title: json['title'],
      driveUrl: json['drive_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder_id': folderId,
      'title': title,
      'drive_url': driveUrl,
    };
  }
}
