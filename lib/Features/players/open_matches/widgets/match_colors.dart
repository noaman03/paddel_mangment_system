import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// Accent colour for a match skill level. Used for badges across the feature.
Color getSkillLevelColor(String skillLevel) {
  switch (skillLevel) {
    case 'Beginner':
      return AColors.success;
    case 'Intermediate':
      return AColors.warning;
    case 'Advanced':
      return AColors.info;
    case 'Pro':
      return AColors.error;
    default:
      return AColors.primaryColor;
  }
}

/// Accent colour for a match lifecycle status.
Color getStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return AColors.success;
    case 'pending':
      return AColors.warning;
    case 'full':
      return AColors.info;
    case 'cancelled':
      return AColors.error;
    default:
      return AColors.primaryColor;
  }
}

/// Human-readable "2h ago" style label for a join-request timestamp.
String formatTimestamp(DateTime timestamp) {
  final difference = DateTime.now().difference(timestamp);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  return '${difference.inDays}d ago';
}
