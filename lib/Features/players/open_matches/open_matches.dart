import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/tabs/create_match_tab.dart';
import 'package:padel_management_system/Features/players/open_matches/tabs/my_matches_tab.dart';
import 'package:padel_management_system/Features/players/open_matches/tabs/open_matches_tab.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/join_requests_sheet.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';

class OpenMatchesScreen extends StatefulWidget {
  const OpenMatchesScreen({super.key});

  @override
  State<OpenMatchesScreen> createState() => _OpenMatchesScreenState();
}

class _OpenMatchesScreenState extends State<OpenMatchesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late final OpenMatchesController controller;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Registered here rather than in build(): Get.put() inside build() re-runs
    // on every rebuild. Reusing an existing instance keeps joined/created
    // matches alive when the player switches bottom-nav tabs and comes back.
    controller = Get.isRegistered<OpenMatchesController>()
        ? Get.find<OpenMatchesController>()
        : Get.put(OpenMatchesController());
    // A no-op unless the signed-in account changed since the data was seeded:
    // the instance survives sign-out, and the next player must not inherit the
    // previous one's joins and hosted matches.
    controller.loadForCurrentSession();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (tabController.indexIsChanging) return;
    controller.updateTab(tabController.index);
  }

  @override
  void dispose() {
    tabController.removeListener(_handleTabChange);
    tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _goToOpenMatches() {
    tabController.animateTo(0);
    controller.updateTab(0);
  }

  /// Called by the Create Match tab once a match is published.
  void _handleMatchCreated() {
    // createMatch() clears the filters so the new card cannot be hidden; keep
    // the visible search box in step with that.
    searchController.clear();
    _goToOpenMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No backgroundColor override: the screen inherits the app-wide scaffold
      // colour so it matches the other player tabs in dark mode.
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => PlayerScreenHeader(
                title: 'Matches',
                notificationCount: controller.joinRequests.length,
                onNotificationTap: () => showJoinRequestsSheet(context),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ASizes.paddingMd,
                ),
                child: Column(
                  children: [
                    // The search box only filters the Open Matches list, so it
                    // is hidden on the other two tabs instead of sitting there
                    // accepting input that does nothing.
                    Obx(
                      () => controller.currentTab.value == 0
                          ? Padding(
                              padding: const EdgeInsets.only(
                                bottom: ASizes.spaceBtwItems,
                              ),
                              child: PlayerSearchBar(
                                hintText:
                                    'Search matches, courts, locations...',
                                controller: searchController,
                                onChanged: controller.searchMatches,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    PlayerTabBar(
                      controller: tabController,
                      tabs: const [
                        'Open Matches',
                        'My Matches',
                        'Create Match',
                      ],
                    ),
                    const SizedBox(height: ASizes.spaceBtwItems),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          const OpenMatchesTab(),
                          MyMatchesTab(
                            onBrowseOpenMatches: _goToOpenMatches,
                          ),
                          CreateMatchTab(onCreated: _handleMatchCreated),
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
}
