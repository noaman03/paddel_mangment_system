import 'package:flutter/material.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/text_strings.dart';

class UserEmailForm extends StatelessWidget {
  const UserEmailForm({
    super.key,
    required this.emailController,
  });

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    bool dark = ADeviceutils.isDarkMode(context);
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      style:
          TextStyle(fontSize: 16, color: dark ? AColors.light : AColors.dark),
      decoration: InputDecoration(
        filled: true,
        fillColor: dark ? AColors.containerDark : AColors.containerLight,
        hintText: 'Your email address',
        hintStyle: TextStyle(
          color: dark ? AColors.light : AColors.dark,
          fontSize: 16,
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: dark ? AColors.light : AColors.dark,
        ),
      ),
    );
  }
}
