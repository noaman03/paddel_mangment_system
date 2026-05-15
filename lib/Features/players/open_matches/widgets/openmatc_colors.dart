import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/core/const/colors.dart';

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
      return AColors.grey;
  }
}

Color getStatusColor(String status) {
  switch (status) {
    case 'confirmed':
      return AColors.success;
    case 'pending':
      return AColors.warning;
    case 'cancelled':
      return AColors.error;
    default:
      return AColors.grey;
  }
}

void createMatch() {
  Get.snackbar(
    'Success',
    'Match created successfully!',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AColors.success,
    colorText: Colors.white,
  );
}
