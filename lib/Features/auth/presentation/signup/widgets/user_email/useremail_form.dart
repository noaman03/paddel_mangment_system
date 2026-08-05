import 'package:flutter/material.dart';

class UserEmailForm extends StatelessWidget {
  const UserEmailForm({super.key, required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    // Fill, hint and icon colours come from `inputDecorationTheme`. They used
    // to be hand-rolled here with the hint painted the same colour as the
    // typed text, so the field looked pre-filled.
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autocorrect: false,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
      decoration: const InputDecoration(
        hintText: 'Your email address',
        prefixIcon: Icon(Icons.email_outlined, size: 20),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}
