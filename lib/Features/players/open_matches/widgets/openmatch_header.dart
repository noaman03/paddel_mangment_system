import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/openmatch_shownoti.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.isDark,
    required this.controller,
  });

  final bool isDark;
  final OpenMatchesController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Padel Matches',
          style: TextStyle(
            fontSize: ASizes.fontSizeLg + 4,
            fontWeight: FontWeight.bold,
            color: isDark ? AColors.white : AColors.textprimary,
          ),
        ),
        // Notification Icon with Badge
        Obx(() => Stack(
              children: [
                IconButton(
                  onPressed: showNotifications,
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? AColors.white : AColors.darkerGrey,
                    size: ASizes.iconLg,
                  ),
                ),
                if (controller.joinRequests.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        controller.joinRequests.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            )),
      ],
    );
  }
}
