import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shared input decoration used across upload dialogs.
InputDecoration customInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppTheme.textGray, fontSize: 14),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primaryAccent, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
}

/// Shared file picker button used across upload dialogs.
Widget buildFilePickerButton(File? selectedFile, VoidCallback onPressed) {
  return InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: selectedFile == null
            ? AppTheme.primaryAccent.withOpacity(0.05)
            : Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedFile == null
              ? AppTheme.primaryAccent.withOpacity(0.3)
              : Colors.green.withOpacity(0.5),
          style: BorderStyle.solid,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            selectedFile == null ? Icons.upload_file : Icons.check_circle,
            color: selectedFile == null
                ? AppTheme.primaryAccent
                : Colors.green.shade600,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            selectedFile == null
                ? 'Click to Select File'
                : selectedFile.path.split('\\').last,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selectedFile == null
                  ? AppTheme.primaryAccent
                  : Colors.green.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
