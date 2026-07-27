import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

Widget buildDropdownField({
  required String label,
  required String value,
  required List<String> items,
  required bool isDark,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: ASizes.fontSizeMd,
          fontWeight: FontWeight.w600,
          color: isDark ? AColors.white : AColors.textprimary,
        ),
      ),
      const SizedBox(height: ASizes.paddingSm),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: ASizes.paddingMd),
        decoration: BoxDecoration(
          color: isDark ? AColors.containerDark : AColors.containerLight,
          border: Border.all(
            color: isDark ? AColors.grey : AColors.borderPrimary,
          ),
          borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: isDark ? AColors.white : AColors.textprimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              // Handle value change
            },
            dropdownColor: isDark ? AColors.dark : Colors.white,
          ),
        ),
      ),
      const SizedBox(height: ASizes.spaceBtwInputFields),
    ],
  );
}
