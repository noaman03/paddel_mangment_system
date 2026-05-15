import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/utils/helpers/helper_func.dart';

Widget buildFilterButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  bool hasActiveFilters = false,
}) {
  final bool dark = AHelperFunction.isDarkMode(Get.context!);

  return Container(
    height: 48,
    decoration: BoxDecoration(
      color: hasActiveFilters
          ? AColors.primaryColor.withOpacity(0.1)
          : (dark ? AColors.containerDark : AColors.containerLight),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: hasActiveFilters
            ? AColors.primaryColor
            : (dark ? AColors.grey.withOpacity(0.3) : AColors.borderPrimary),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: hasActiveFilters
                    ? AColors.primaryColor
                    : (dark ? AColors.white : AColors.textprimary),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: ASizes.fontSizeSm,
                    fontWeight:
                        hasActiveFilters ? FontWeight.w600 : FontWeight.w500,
                    color: hasActiveFilters
                        ? AColors.primaryColor
                        : (dark ? AColors.white : AColors.textprimary),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
