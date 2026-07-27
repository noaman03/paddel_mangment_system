import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Use this import instead
import 'package:padel_management_system/Features/auth/presentation/signup/controller/datebirth_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

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
    final dark = ADeviceutils.isDarkMode(context);
    return Center(
      child: Column(
        children: [
          Text(
            'Choose your avatar',
            style: TextStyle(
              fontSize: ASizes.fontSizeMd,
              fontWeight: FontWeight.w600,
              color: dark ? AColors.light : AColors.dark,
            ),
          ),
          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Selected Avatar with reactive updates - Fixed Obx
          Obx(() {
            // Ensure we're accessing the observable value properly
            final selectedIndex = controller.selectedAvatarIndex.value;

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AColors.primaryColor,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: avatarImages.isNotEmpty &&
                        selectedIndex < avatarImages.length
                    ? Image.asset(
                        avatarImages[selectedIndex],
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
              ),
            );
          }),

          const SizedBox(height: ASizes.spaceBtwInputFields),

          // Avatar options with GetX - Fixed Obx
          SizedBox(
            height: 70,
            child: avatarImages.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: avatarImages.length,
                    itemBuilder: (context, index) {
                      return Obx(() {
                        // Each item should have its own Obx for better performance
                        final isSelected =
                            controller.selectedAvatarIndex.value == index;

                        return GestureDetector(
                          onTap: () => controller.updateSelectedAvatar(index),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AColors.primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(avatarImages[index]),
                              onBackgroundImageError: (exception, stackTrace) {
                                // Handle image loading errors
                                print('Error loading avatar image: $exception');
                              },
                            ),
                          ),
                        );
                      });
                    },
                  )
                : const Center(
                    child: Text(
                      'No avatars available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
