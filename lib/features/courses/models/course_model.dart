class CourseModel {
  final int id;
  final String title;
  final String tag;
  final String imageUrl;
  final DateTime? createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.tag,
    required this.imageUrl,
    this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      title: json['title'] as String,
      tag: json['tag'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'tag': tag, 'image_url': imageUrl};
  }
}
