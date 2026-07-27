import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

class FilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final bool obscureText;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? errorMaxLines;
  final bool showCounter;
  final TextStyle? style;

  const FilledTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.obscureText = false,
    this.onChanged,
    this.maxLines = 1,
    this.errorMaxLines = 2,
    this.showCounter = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      obscureText: obscureText,
      onChanged: onChanged,
      maxLines: maxLines,
      style: style ??
          TextStyle(
            color: isDark ? AColors.light : AColors.dark,
            fontSize: ASizes.fontSizeMd,
          ),
      decoration: InputDecoration(
        filled: true,
        fillColor: isDark ? AColors.containerDark : AColors.containerLight,
        hintText: hintText,
        helperText: helperText,
        helperStyle: TextStyle(
          color: AColors.darkGrey,
          fontSize: ASizes.fontSizeSm,
        ),
        hintStyle: TextStyle(
          color: isDark ? AColors.light : AColors.dark,
          fontSize: ASizes.fontSizeMd,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: isDark ? AColors.grey : Colors.grey.shade600,
              )
            : null,
        suffixIcon: suffixIcon,
        counterText: showCounter ? null : '',
        errorMaxLines: errorMaxLines,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
