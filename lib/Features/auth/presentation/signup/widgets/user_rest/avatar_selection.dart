import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class AvatarSelection extends StatelessWidget {
  const AvatarSelection({
    super.key,
    required this.avatarImages,
    required this.controller,
  });

  final List<String> avatarImages;
  final UserRestController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Center(
      child: Column(
        children: [
          Text(
            'Choose your avatar',
            style: TextStyle(
              fontSize: ASizes.fontSizeMd,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Selected avatar
          Obx(() {
            final selectedIndex = controller.selectedAvatarIndex.value;
            final hasAvatar =
                avatarImages.isNotEmpty && selectedIndex < avatarImages.length;

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surfaceElevated,
                border: Border.all(color: AColors.primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AColors.primaryColor.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasAvatar
                    ? Image.asset(
                        avatarImages[selectedIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, size: 60, color: c.textMuted),
                      )
                    : Icon(Icons.person, size: 60, color: c.textMuted),
              ),
            );
          }),

          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Avatar options
          SizedBox(
            height: 70,
            child: avatarImages.isEmpty
                ? Center(
                    child: Text(
                      'No avatars available',
                      style: TextStyle(color: c.textSecondary),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: avatarImages.length,
                    itemBuilder: (context, index) {
                      // Each tile needs its OWN Obx: a `.value` read inside a
                      // child widget is not tracked by an ancestor Obx.
                      return Obx(() {
                        final isSelected =
                            controller.selectedAvatarIndex.value == index;

                        return GestureDetector(
                          onTap: () => controller.updateSelectedAvatar(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AColors.primaryColor
                                    : c.border,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: c.surfaceElevated,
                              backgroundImage: AssetImage(avatarImages[index]),
                              onBackgroundImageError: (exception, stackTrace) =>
                                  debugPrint(
                                      'Avatar asset failed to load: $exception'),
                            ),
                          ),
                        );
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
