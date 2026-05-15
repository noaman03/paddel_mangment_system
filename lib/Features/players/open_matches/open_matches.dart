// Replace your existing MatchesScreen in player_home.dart with this:
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padelsystem/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padelsystem/Features/players/open_matches/tabs/openmatch_creatematch.dart';
import 'package:padelsystem/Features/players/open_matches/tabs/openmatches_mymatch.dart';
import 'package:padelsystem/Features/players/open_matches/tabs/openmatches_tab.dart';
import 'package:padelsystem/core/widgets/player_screen_components.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';
import 'package:padelsystem/core/const/text_strings.dart';

class OpenMatchesScreen extends StatefulWidget {
  const OpenMatchesScreen({super.key});

  @override
  State<OpenMatchesScreen> createState() => _OpenMatchesScreenState();
}

class _OpenMatchesScreenState extends State<OpenMatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final OpenMatchesController controller = Get.put(OpenMatchesController());

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = ADeviceutils.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? AColors.dark : AColors.light,
      body: SafeArea(
        child: Column(
          children: [
            // Unified Header
            Obx(() => PlayerScreenHeader(
                  title: 'Matches',
                  notificationCount: controller.joinRequests.length,
                  onNotificationTap: showNotifications,
                )),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ASizes.paddingMd),
                child: Column(
                  children: [
                    // Search Bar
                    PlayerSearchBar(
                      hintText: 'Search matches, courts, locations...',
                      onChanged: controller.searchMatches,
                    ),

                    const SizedBox(height: ASizes.spaceBtwItems),

                    // Tab Bar
                    PlayerTabBar(
                      controller: tabController,
                      tabs: const [
                        'Open Matches',
                        'My Matches',
                        'Create Match'
                      ],
                    ),

                    const SizedBox(height: ASizes.spaceBtwItems),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          buildOpenMatchesTab(isDark),
                          buildMyMatchesTab(isDark),
                          buildCreateMatchTab(isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showNotifications() {
    // Implementation remains the same but with updated styling
  }
}
