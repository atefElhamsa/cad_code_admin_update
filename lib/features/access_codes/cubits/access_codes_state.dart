import 'package:equatable/equatable.dart';

abstract class AccessCodesState extends Equatable {
  const AccessCodesState();

  @override
  List<Object?> get props => [];
}

class AccessCodesInitial extends AccessCodesState {}

class AccessCodesLoading extends AccessCodesState {}

class AccessCodesLoaded extends AccessCodesState {
  final List<Map<String, dynamic>> folders;
  final int? selectedFolderId;
  final String? activeCode;
  final bool isUsed;

  const AccessCodesLoaded({
    required this.folders,
    this.selectedFolderId,
    this.activeCode,
    this.isUsed = false,
  });

  AccessCodesLoaded copyWith({
    List<Map<String, dynamic>>? folders,
    int? selectedFolderId,
    String? activeCode,
    bool? isUsed,
  }) {
    return AccessCodesLoaded(
      folders: folders ?? this.folders,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
      activeCode: activeCode ?? this.activeCode,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  @override
  List<Object?> get props => [folders, selectedFolderId, activeCode, isUsed];
}

class AccessCodesError extends AccessCodesState {
  final String message;

  const AccessCodesError(this.message);

  @override
  List<Object?> get props => [message];
}
