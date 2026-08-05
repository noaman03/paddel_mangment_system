import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/Features/owner/auth/owner_login_screen.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// One-tap access to the three portfolio accounts.
///
/// This replaces the old flow, where the only hint about the owner login was a
/// plain alert box buried in the player drawer telling you to type "owner"
/// twice.
class DemoAccountsCard extends StatefulWidget {
  const DemoAccountsCard({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<DemoAccountsCard> createState() => _DemoAccountsCardState();
}

class _DemoAccountsCardState extends State<DemoAccountsCard> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();
    // Registered once here, not in build(): the login screen rebuilds on every
    // keystroke, and a Get.put in build allocated (and orphaned) a fresh
    // LoginController each time.
    controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ASizes.paddingMd),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 16,
                  color: c.brandText,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo accounts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      'Tap any account to sign in instantly',
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm + 2),
          for (var i = 0; i < DemoAccounts.all.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _DemoAccountTile(
              account: DemoAccounts.all[i],
              onTap: () => _signInAs(context, controller, DemoAccounts.all[i]),
            ),
          ],
          const SizedBox(height: 10),
          // The dedicated owner portal is a real screen in the product, not
          // just a shortcut — give it a way in from the front door.
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OwnerLoginScreen()),
              ),
              icon: const Icon(Icons.business_rounded, size: 16),
              label: const Text('Run a club? Open the owner portal'),
              style: TextButton.styleFrom(
                foregroundColor: c.textSecondary,
                textStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signInAs(
    BuildContext context,
    LoginController controller,
    DemoAccount account,
  ) async {
    controller.fillDemoAccount(
      account,
      emailController: widget.emailController,
      passwordController: widget.passwordController,
    );
    await controller.login(
      context: context,
      emailController: widget.emailController,
      passwordController: widget.passwordController,
    );
  }
}

class _DemoAccountTile extends StatelessWidget {
  const _DemoAccountTile({required this.account, required this.onTap});

  final DemoAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final Color tone = account.role.color;
    // The role tones (brand green, amber) are far too light to read as a
    // foreground on the card; `onSurfaceAccent` darkens them until they clear
    // 4.5:1 while the soft tint below keeps using the raw tone.
    final Color toneInk = c.onSurfaceAccent(tone);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: c.soft(tone),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(account.role.icon, color: toneInk, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.role.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: c.soft(tone),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            account.role.shortLabel.toUpperCase(),
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: toneInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.email}  ·  ${account.password}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Copy credentials',
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '${account.email} / ${account.password}',
                    ),
                  );
                  AppFeedback.info(
                    'Copied',
                    '${account.role.label} credentials copied to clipboard.',
                  );
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: c.textSecondary,
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 17, color: toneInk),
            ],
          ),
        ),
      ),
    );
  }
}
