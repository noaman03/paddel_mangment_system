import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/openmatc_colors.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/openmatches_timestamp.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/text_strings.dart';

void showNotifications() {
  final bool isDark = ADeviceutils.isDarkMode(Get.context!);
  final controller = Get.find<OpenMatchesController>();

  Get.bottomSheet(
    Container(
      height: MediaQuery.of(Get.context!).size.height * 0.6,
      decoration: BoxDecoration(
        color: isDark ? AColors.dark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AColors.grey : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Join Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AColors.white : AColors.textprimary,
                  ),
                ),
                if (controller.joinRequests.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Clear all notifications
                      controller.joinRequests.clear();
                      Get.back();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: AColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(
            color: isDark ? AColors.grey : Colors.grey.shade300,
          ),

          // Content
          Expanded(
            child: Obx(() => controller.joinRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 64,
                          color: isDark ? AColors.grey : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AColors.grey : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join requests will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AColors.grey : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.joinRequests.length,
                    itemBuilder: (context, index) {
                      final request = controller.joinRequests[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AColors.containerDark
                              : AColors.containerLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AColors.grey.withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundImage:
                                AssetImage(request['playerAvatar']),
                          ),
                          title: Text(
                            request['playerName'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? AColors.white : AColors.textprimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'wants to join: ${request['matchTitle']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AColors.grey
                                      : AColors.textsecondarry,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      getSkillLevelColor(request['skillLevel']),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  request['skillLevel'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '"${request['message']}"',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? AColors.grey
                                      : AColors.textsecondarry,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatTimestamp(request['timestamp']),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AColors.grey
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Accept Button
                              Container(
                                decoration: BoxDecoration(
                                  color: AColors.success,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: () => controller
                                      .acceptJoinRequest(request['id']),
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Reject Button
                              Container(
                                decoration: BoxDecoration(
                                  color: AColors.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  onPressed: () => controller
                                      .rejectJoinRequest(request['id']),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}
