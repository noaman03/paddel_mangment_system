import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class GenderSelection extends StatelessWidget {
  const GenderSelection({super.key, required this.controller});

  final UserRestController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: ASizes.fontSizeMd,
            fontWeight: FontWeight.w600,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwInputFields),
        Obx(() {
          final selected = controller.selectedGender.value;
          return Row(
            children: [
              Expanded(
                child: _GenderPill(
                  label: 'Male',
                  icon: Icons.male,
                  selected: selected == 'Male',
                  onTap: () => controller.updateSelectedGender('Male'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _GenderPill(
                  label: 'Female',
                  icon: Icons.female,
                  selected: selected == 'Female',
                  onTap: () => controller.updateSelectedGender('Female'),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _GenderPill extends StatelessWidget {
  const _GenderPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    // The selected pill is filled with the DEEP brand green, not the accent:
    // the accent is light enough that a white label sat at 1.91:1 on it.
    final Color fill = selected ? c.brandFill : c.surface;
    final Color foreground = selected ? c.foregroundOn(fill) : c.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? c.brandFill : c.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
