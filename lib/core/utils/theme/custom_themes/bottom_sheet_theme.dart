import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

class ABottomSheetTheme {
  ABottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    dragHandleColor: AColors.borderPrimary,
    backgroundColor: AColors.white,
    modalBackgroundColor: AColors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalBarrierColor: Colors.black.withValues(alpha: 0.42),
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );

  static BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    dragHandleColor: AColors.borderDark,
    backgroundColor: AColors.containerDark,
    modalBackgroundColor: AColors.containerDark,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalBarrierColor: Colors.black.withValues(alpha: 0.6),
    constraints: const BoxConstraints(minWidth: double.infinity),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}
