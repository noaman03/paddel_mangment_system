import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:padel_management_system/core/widgets/filled_text_field.dart';

class NameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const NameTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return FilledTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Iconsax.user,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      validator: validator,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: [
        // Any Unicode letter plus combining marks, spaces, apostrophes and
        // hyphens. The old `[a-zA-Z\s]` filter silently swallowed Arabic and
        // accented names, and names like "Anne-Marie" or "O'Brien".
        FilteringTextInputFormatter.allow(
          RegExp(r"[\p{L}\p{M}\s'\-]", unicode: true),
        ),
        LengthLimitingTextInputFormatter(30),
      ],
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const PhoneTextField({
    super.key,
    required this.controller,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return FilledTextField(
      controller: controller,
      hintText: 'Phone number',
      helperText: 'Format: 01xxxxxxxxx',
      prefixIcon: Icons.phone_android_rounded,
      keyboardType: TextInputType.phone,
      validator: validator,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      // digitsOnly + a length cap already enforce the whole rule. The old
      // custom formatter added nothing except forcing the caret to the end of
      // the field on every keystroke, so mid-number corrections were
      // impossible.
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final Widget? additionalSuffixIcon;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.onChanged,
    this.additionalSuffixIcon,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return FilledTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.lock_outline,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      errorMaxLines: 3,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (additionalSuffixIcon != null) ...[
            additionalSuffixIcon!,
            const SizedBox(width: 4),
          ],
          IconButton(
            onPressed: onToggleVisibility,
            tooltip: obscureText ? 'Show password' : 'Hide password',
            // No hardcoded colour: the InputDecorator supplies the theme's
            // suffixIconColor for both brightnesses.
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const EmailTextField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return FilledTextField(
      controller: controller,
      hintText: 'Email address',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
      ],
    );
  }
}
