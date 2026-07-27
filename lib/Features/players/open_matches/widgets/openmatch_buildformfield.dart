import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

Widget buildFormField({
  required String label,
  required String hint,
  required bool isDark,
  int maxLines = 1,
  IconData? suffixIcon,
  TextInputType? keyboardType,
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
      TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? AColors.white : AColors.textprimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? AColors.grey : AColors.darkGrey,
          ),
          suffixIcon: suffixIcon != null
              ? Icon(
                  suffixIcon,
                  color: isDark ? AColors.grey : AColors.darkGrey,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
            borderSide: BorderSide(
              color: isDark ? AColors.grey : AColors.borderPrimary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
            borderSide: BorderSide(
              color: isDark ? AColors.grey : AColors.borderPrimary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
            borderSide: const BorderSide(color: AColors.primaryColor),
          ),
          filled: true,
          fillColor: isDark ? AColors.darkerGrey : AColors.containerLight,
        ),
      ),
      const SizedBox(height: ASizes.spaceBtwInputFields),
    ],
  );
}
