import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Extracts the duration from a video file and returns it as a formatted string.
/// e.g. "01:23" or "1:23:45"
Future<String?> extractVideoDuration(File file) async {
  try {
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final mm = twoDigits(duration.inMinutes.remainder(60));
    final ss = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '${duration.inHours}:$mm:$ss';
    }
    return '$mm:$ss';
  } catch (e) {
    debugPrint('Failed to extract duration: $e');
    return null;
  }
}
