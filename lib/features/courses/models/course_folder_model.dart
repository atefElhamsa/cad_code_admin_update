class CourseFolderModel {
  final int id;
  final int courseId;
  final String title;
  final String? description;
  final String imageUrl;
  final DateTime? createdAt;

  CourseFolderModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    required this.imageUrl,
    this.createdAt,
  });

  factory CourseFolderModel.fromJson(Map<String, dynamic> json) {
    return CourseFolderModel(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId, 
      'title': title, 
      'description': description,
      'image_url': imageUrl
    };
  }
}
