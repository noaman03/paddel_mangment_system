import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/text_strings.dart';
import 'package:padelsystem/core/widgets/filled_text_field.dart';

class NameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  const NameTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
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
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
        LengthLimitingTextInputFormatter(30),
      ],
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const PhoneTextField({
    super.key,
    required this.controller,
    this.validator,
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
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
        _PhoneNumberFormatter(),
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

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.onChanged,
    this.additionalSuffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return FilledTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icons.lock_outline,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      errorMaxLines: 3,
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (additionalSuffixIcon != null) ...[
            additionalSuffixIcon!,
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: isDark ? AColors.grey : Colors.grey.shade600,
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

  const EmailTextField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
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
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
      ],
    );
  }
}

// Custom phone number formatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.length > 11) {
      return oldValue;
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
