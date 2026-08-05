import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class LoginHeader extends StatefulWidget {
  final bool isCompact;

  const LoginHeader({super.key, this.isCompact = false});

  @override
  State<LoginHeader> createState() => _LoginHeaderState();
}

class _LoginHeaderState extends State<LoginHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _bounceController.forward();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo with animation
          Center(
            child: ScaleTransition(
              scale: _bounceAnimation,
              child: Container(
                width: widget.isCompact ? 70 : 100,
                height: widget.isCompact ? 70 : 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AColors.brandGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(widget.isCompact ? 18 : 24),
                  boxShadow: [
                    BoxShadow(
                      color: AColors.primaryColor.withValues(alpha: 0.3),
                      blurRadius: widget.isCompact ? 15 : 20,
                      offset: Offset(0, widget.isCompact ? 6 : 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.sports_tennis,
                  size: widget.isCompact ? 35 : 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(
              height: widget.isCompact
                  ? ASizes.spaceBtwItems
                  : ASizes.spaceBtwItems + 8),

          // Welcome text with gradient
          Center(
            child: Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: c.brandText, fontSize: widget.isCompact ? 24 : 32),
              textAlign: TextAlign.center,
            ),
          ),

          // Only show subtitle when not compact
          if (!widget.isCompact) ...[
            const SizedBox(height: ASizes.sm),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ASizes.paddingMd,
                  vertical: ASizes.paddingSm,
                ),
                child: Text(
                  'Ready to play some padel? Let\'s get you logged in!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: c.textSecondary,
                        fontSize: 16,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          SizedBox(
              height: widget.isCompact
                  ? ASizes.spaceBtwItems
                  : ASizes.spaceBtwSections + 8),
        ],
      ),
    );
  }
}
