import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:padelsystem/core/const/colors.dart';

Widget buildBackgroundDecoration(bool isDark) {
  return Positioned.fill(
    child: Stack(
      children: [
        // Top right circle
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AColors.primaryColor.withOpacity(0.12)
                  : AColors.primaryColor.withOpacity(0.25),
            ),
          ),
        ),

        // Bottom left circle
        Positioned(
          bottom: -150,
          left: -150,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AColors.primaryColor.withOpacity(0.08)
                  : AColors.primaryColor.withOpacity(0.18),
            ),
          ),
        ),

        // Middle right small circle
        Positioned(
          top: MediaQuery.of(Get.context!).size.height * 0.4,
          right: -50,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AColors.primaryColor.withOpacity(0.15)
                  : AColors.primaryColor.withOpacity(0.30),
            ),
          ),
        ),
      ],
    ),
  );
}
