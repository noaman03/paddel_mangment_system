import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

/// The app's standard filled input.
///
/// Borders, fill colour, hint colour and error styling all come from
/// `ThemeData.inputDecorationTheme` (see `ATextFormFieldTheme`). This widget
/// used to hand-roll them, which produced two visible bugs: the hint was drawn
/// in exactly the same colour as typed text (so every empty field looked
/// pre-filled), and only *some* of the four borders were overridden, so the
/// corner radius jumped from 14 to 12 the moment a field was focused.
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

  /// Focus/keyboard plumbing so multi-field forms can chain focus instead of
  /// dismissing the keyboard on every field.
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final bool readOnly;

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
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);
    final bool isMultiline = (maxLines ?? 1) > 1;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction ??
          (isMultiline ? TextInputAction.newline : TextInputAction.next),
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      obscureText: obscureText,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      cursorColor: AColors.primaryColor,
      style: style ??
          theme.textTheme.bodyLarge?.copyWith(
            color: enabled ? c.textPrimary : c.textMuted,
            fontSize: ASizes.fontSizeMd,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        helperText: helperText,
        helperStyle: TextStyle(
          color: c.textSecondary,
          fontSize: ASizes.fontSizeSm - 2,
        ),
        // No explicit colour: the InputDecorator applies the theme's
        // prefixIconColor, so the icon follows light/dark automatically.
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        counterText: showCounter ? null : '',
        errorMaxLines: errorMaxLines,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
