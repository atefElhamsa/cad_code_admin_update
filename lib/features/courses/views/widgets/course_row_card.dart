import 'package:flutter/material.dart';
import '../course_folders_view.dart';

import '../../models/course_model.dart';
import '../../../../core/theme/app_theme.dart';

import 'course_image_hero.dart';
import 'course_tag.dart';
import 'course_date_text.dart';
import 'course_delete_action.dart';

class CourseRowCard extends StatefulWidget {
  final CourseModel course;

  const CourseRowCard({super.key, required this.course});

  @override
  State<CourseRowCard> createState() => _CourseRowCardState();
}

class _CourseRowCardState extends State<CourseRowCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseFoldersView(course: widget.course),
            ),
          );
        },
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
                    CourseImageHero(course: widget.course),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        widget.course.title,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CourseTag(tag: widget.course.tag),
                ),
              ),
              Expanded(
                flex: 2,
                child: CourseDateText(date: widget.course.createdAt),
              ),
              SizedBox(
                width: 48,
                child: isHovered
                    ? CourseDeleteAction(course: widget.course)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
