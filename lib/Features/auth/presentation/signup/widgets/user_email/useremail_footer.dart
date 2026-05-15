import 'package:flutter/material.dart';
import 'package:padelsystem/Features/auth/presentation/login/login_screen.dart';
import 'package:padelsystem/Features/auth/presentation/login/widgets/divide_socialbutton.dart';
import 'package:padelsystem/core/const/colors.dart';

class SignUpFooter extends StatelessWidget {
  const SignUpFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DividerSocialButtons(),

        //login option
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  ' Log in',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AColors.primaryColor,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 150),

        // Terms & Privacy
        Center(
          child: Text.rich(
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AColors.primaryColor,
                      ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AColors.primaryColor,
                      ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
