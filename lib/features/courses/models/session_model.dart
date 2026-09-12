import 'package:equatable/equatable.dart';

class SessionModel extends Equatable {
  final int id;
  final int folderId;
  final String title;
  final String? duration;
  final String driveUrl;
  final int? orderIndex;
  /// The Google Drive folder ID that holds this session's video + files.
  final String? driveFolderId;
  final DateTime? createdAt;

  const SessionModel({
    required this.id,
    required this.folderId,
    required this.title,
    this.duration,
    required this.driveUrl,
    this.orderIndex,
    this.driveFolderId,
    this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int,
      folderId: json['folder_id'] as int,
      title: json['title'] as String,
      duration: json['duration'] as String?,
      driveUrl: json['drive_url'] as String,
      orderIndex: json['order_index'] as int?,
      driveFolderId: json['drive_folder_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder_id': folderId,
      'title': title,
      'duration': duration,
      'drive_url': driveUrl,
      'order_index': orderIndex,
      'drive_folder_id': driveFolderId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    folderId,
    title,
    duration,
    driveUrl,
    orderIndex,
    driveFolderId,
    createdAt,
  ];
}
