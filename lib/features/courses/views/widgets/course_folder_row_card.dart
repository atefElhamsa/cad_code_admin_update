import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../models/course_folder_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../cubits/course_folders_cubit.dart';

class CourseFolderRowCard extends StatefulWidget {
  final CourseFolderModel folder;

  const CourseFolderRowCard({super.key, required this.folder});

  @override
  State<CourseFolderRowCard> createState() => _CourseFolderRowCardState();
}

class _CourseFolderRowCardState extends State<CourseFolderRowCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isHovered
            ? AppTheme.primaryAccent.withOpacity(0.03)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Hero(
                    tag: 'folder_image_${widget.folder.id}',
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                        image: widget.folder.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.folder.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.folder.imageUrl.isEmpty
                          ? const Icon(
                              Icons.folder,
                              color: AppTheme.textGray,
                              size: 28,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.folder.title,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.folder.description != null &&
                            widget.folder.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.folder.description!,
                            style: const TextStyle(
                              color: AppTheme.textGray,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.folder.createdAt != null
                      ? DateFormat('MMM d, yyyy')
                            .format(widget.folder.createdAt!)
                      : 'Unknown',
                  style: const TextStyle(
                    color: AppTheme.textGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: isHovered
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Delete Folder'),
                              content: Text(
                                'Are you sure you want to delete "${widget.folder.title}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context
                                        .read<CourseFoldersCubit>()
                                        .deleteFolder(widget.folder);
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      tooltip: 'Delete folder',
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
