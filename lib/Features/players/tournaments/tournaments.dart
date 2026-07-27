import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/tournaments/controller/tournament_controller.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/const/text_strings.dart';
import 'package:intl/intl.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final TournamentsController controller = Get.put(TournamentsController());

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
                  title: 'Tournaments',
                  notificationCount: controller.entryRequests.length,
                  onNotificationTap: showEntryRequests,
                )),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(ASizes.paddingMd),
                child: Column(
                  children: [
                    // Search Bar
                    PlayerSearchBar(
                      hintText: 'Search tournaments, organizers, locations...',
                      onChanged: controller.searchTournaments,
                    ),

                    const SizedBox(height: ASizes.spaceBtwItems),

                    // Tab Bar
                    PlayerTabBar(
                      controller: tabController,
                      tabs: const [
                        'All Tournaments',
                        'My Tournaments',
                        'Create Tournament'
                      ],
                    ),

                    const SizedBox(height: ASizes.spaceBtwItems),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          buildAllTournamentsTab(isDark),
                          buildMyTournamentsTab(isDark),
                          buildCreateTournamentTab(isDark),
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

  Widget buildAllTournamentsTab(bool isDark) {
    return Column(
      children: [
        // Filters Row - Using consistent filter buttons
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Tournament Type Filter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: ASizes.paddingSm),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AColors.grey.withOpacity(0.5)
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? AColors.containerDark : Colors.white,
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedTournamentType.value,
                        items: controller.tournamentTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isDark
                                    ? AColors.white
                                    : AColors.textprimary,
                                fontSize: ASizes.fontSizeSm,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            controller.updateTournamentType(value!),
                        dropdownColor: isDark ? AColors.dark : Colors.white,
                      ),
                    )),
              ),

              const SizedBox(width: ASizes.spaceBtwItems),

              // Skill Level Filter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: ASizes.paddingSm),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AColors.grey.withOpacity(0.5)
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? AColors.containerDark : Colors.white,
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedSkillLevel.value,
                        items: controller.skillLevels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(
                              level,
                              style: TextStyle(
                                color: isDark
                                    ? AColors.white
                                    : AColors.textprimary,
                                fontSize: ASizes.fontSizeSm,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            controller.updateSkillLevel(value!),
                        dropdownColor: isDark ? AColors.dark : Colors.white,
                      ),
                    )),
              ),

              const SizedBox(width: ASizes.spaceBtwItems),

              // Prize Type Filter
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: ASizes.paddingSm),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark
                        ? AColors.grey.withOpacity(0.5)
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? AColors.containerDark : Colors.white,
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedPrizeType.value,
                        items: controller.prizeTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: TextStyle(
                                color: isDark
                                    ? AColors.white
                                    : AColors.textprimary,
                                fontSize: ASizes.fontSizeSm,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            controller.updatePrizeType(value!),
                        dropdownColor: isDark ? AColors.dark : Colors.white,
                      ),
                    )),
              ),
            ],
          ),
        ),

        const SizedBox(height: ASizes.spaceBtwItems),

        // Tournaments List
        Expanded(
          child: Obx(() => controller.filteredTournaments.isEmpty
              ? PlayerEmptyState(
                  icon: Icons.emoji_events,
                  title: 'No tournaments found',
                  subtitle: 'Try adjusting your filters or check back later',
                )
              : ListView.builder(
                  itemCount: controller.filteredTournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = controller.filteredTournaments[index];
                    return buildTournamentCard(tournament, isDark);
                  },
                )),
        ),
      ],
    );
  }

  Widget buildMyTournamentsTab(bool isDark) {
    return Obx(() => controller.myTournaments.isEmpty
        ? PlayerEmptyState(
            icon: Icons.calendar_today,
            title: 'No tournaments yet',
            subtitle: 'Join some tournaments to see them here',
            action: ElevatedButton(
              onPressed: () => tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Browse Tournaments',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : ListView.builder(
            itemCount: controller.myTournaments.length,
            itemBuilder: (context, index) {
              final tournament = controller.myTournaments[index];
              return buildMyTournamentCard(tournament, isDark);
            },
          ));
  }

  Widget buildTournamentCard(Map<String, dynamic> tournament, bool isDark) {
    final bool isOfficial = tournament['organizerType'] == 'Official';

    return PlayerCard(
      showBorder: isOfficial,
      borderColor: AColors.primaryColor,
      onTap: () => showTournamentDetails(tournament),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with badges
          Row(
            children: [
              PlayerStatusBadge(
                text: isOfficial ? 'OFFICIAL' : 'PLAYER',
                color: isOfficial ? AColors.primaryColor : AColors.info,
                icon: isOfficial ? Icons.verified : Icons.person,
              ),
              const Spacer(),
              if (tournament['prizePool'] > 0)
                PlayerStatusBadge(
                  text: 'EGP ${tournament['prizePool']}',
                  color: AColors.warning,
                  icon: Icons.monetization_on,
                )
              else
                PlayerStatusBadge(
                  text: tournament['prizeType'].toUpperCase(),
                  color: getPrizeTypeColor(tournament['prizeType']),
                ),
            ],
          ),

          const SizedBox(height: ASizes.paddingSm),

          // Tournament Title
          Text(
            tournament['title'],
            style: TextStyle(
              fontSize: ASizes.fontSizeMd,
              fontWeight: FontWeight.bold,
              color: isDark ? AColors.white : AColors.textprimary,
            ),
          ),

          const SizedBox(height: 4),

          // Organizer
          Text(
            'by ${tournament['organizer']}',
            style: TextStyle(
              fontSize: ASizes.fontSizeSm,
              color: isDark ? AColors.grey : AColors.textsecondarry,
            ),
          ),

          const SizedBox(height: ASizes.paddingSm),

          // Description
          Text(
            tournament['description'],
            style: TextStyle(
              fontSize: ASizes.fontSizeSm,
              color: isDark ? AColors.grey : AColors.textsecondarry,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: ASizes.paddingSm),

          // Location and Date info
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: ASizes.iconSm,
                color: AColors.primaryColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${tournament['courtName']}, ${tournament['location']}',
                  style: TextStyle(
                    fontSize: ASizes.fontSizeSm,
                    color: isDark ? AColors.grey : AColors.textsecondarry,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: ASizes.iconSm,
                color: AColors.primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('MMM dd').format(tournament['startDate'])} - ${DateFormat('MMM dd').format(tournament['endDate'])}',
                style: TextStyle(
                  fontSize: ASizes.fontSizeSm,
                  color: isDark ? AColors.grey : AColors.textsecondarry,
                ),
              ),
              const Spacer(),
              if (tournament['entryFee'] > 0)
                Text(
                  'EGP ${tournament['entryFee']} entry',
                  style: const TextStyle(
                    fontSize: ASizes.fontSizeSm,
                    fontWeight: FontWeight.w600,
                    color: AColors.primaryColor,
                  ),
                )
              else
                const Text(
                  'FREE',
                  style: TextStyle(
                    fontSize: ASizes.fontSizeSm,
                    fontWeight: FontWeight.w600,
                    color: AColors.success,
                  ),
                ),
            ],
          ),

          const SizedBox(height: ASizes.paddingSm),

          // Participants and Skill Level
          Row(
            children: [
              PlayerStatusBadge(
                text: tournament['skillLevel'],
                color: getSkillLevelColor(tournament['skillLevel']),
              ),
              const SizedBox(width: ASizes.paddingSm),
              Text(
                '${tournament['currentParticipants']}/${tournament['maxParticipants']} participants',
                style: TextStyle(
                  fontSize: ASizes.fontSizeSm,
                  color: isDark ? AColors.grey : AColors.textsecondarry,
                ),
              ),
              const Spacer(),
              if (tournament['entryRequests'] > 0)
                PlayerStatusBadge(
                  text: '${tournament['entryRequests']} requests',
                  color: AColors.info,
                ),
            ],
          ),

          const SizedBox(height: ASizes.paddingSm),

          // Registration Deadline
          Container(
            padding: const EdgeInsets.all(ASizes.paddingSm),
            decoration: BoxDecoration(
              color: (isDark ? AColors.containerDark : AColors.containerLight)
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
              border: Border.all(
                color: AColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: ASizes.iconSm,
                  color: AColors.warning,
                ),
                const SizedBox(width: 4),
                Text(
                  'Registration closes: ${DateFormat('MMM dd, yyyy').format(tournament['registrationDeadline'])}',
                  style: TextStyle(
                    fontSize: ASizes.fontSizeSm - 2,
                    color: isDark ? AColors.grey : AColors.textsecondarry,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: ASizes.paddingSm),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => showTournamentDetails(tournament),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color:
                            isDark ? AColors.darkGrey : AColors.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: isDark ? AColors.white : AColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: ASizes.paddingSm),
              Expanded(
                child: Obx(() => ElevatedButton(
                      onPressed: tournament['currentParticipants'] <
                                  tournament['maxParticipants'] &&
                              !controller.isLoading.value
                          ? () => controller.joinTournament(tournament['id'])
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AColors.primaryColor,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              tournament['currentParticipants'] <
                                      tournament['maxParticipants']
                                  ? 'Join Tournament'
                                  : 'Full',
                              style: const TextStyle(color: Colors.white),
                            ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods remain the same...
  Color getSkillLevelColor(String skillLevel) {
    switch (skillLevel) {
      case 'Beginner':
        return AColors.success;
      case 'Intermediate':
        return AColors.warning;
      case 'Advanced':
        return AColors.info;
      case 'Pro':
        return AColors.error;
      default:
        return AColors.grey;
    }
  }

  Color getPrizeTypeColor(String prizeType) {
    switch (prizeType) {
      case 'Cash Prize':
        return AColors.warning;
      case 'Trophies':
        return AColors.info;
      case 'Fun Only':
        return AColors.success;
      default:
        return AColors.grey;
    }
  }

  // Rest of the methods remain the same but with updated card styling...
  void showEntryRequests() {
    // Implementation with updated PlayerCard styling
  }

  void showTournamentDetails(Map<String, dynamic> tournament) {
    // Implementation with updated styling
  }

  Widget buildCreateTournamentTab(bool isDark) {
    // Implementation with consistent form styling
    return Container(); // Placeholder
  }

  Widget buildMyTournamentCard(Map<String, dynamic> tournament, bool isDark) {
    return PlayerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  tournament['title'],
                  style: TextStyle(
                    fontSize: ASizes.fontSizeMd,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AColors.white : AColors.textprimary,
                  ),
                ),
              ),
              PlayerStatusBadge(
                text: tournament['status'].toUpperCase(),
                color: getStatusColor(tournament['status']),
              ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm),
          Text(
            DateFormat('MMM dd, yyyy').format(tournament['startDate']),
            style: TextStyle(
              color: isDark ? AColors.grey : AColors.textsecondarry,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Entry Fee: EGP ${tournament['entryFee']}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? AColors.white : AColors.textprimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Status: ${tournament['position']}',
            style: const TextStyle(
              color: AColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'registered':
        return AColors.success;
      case 'pending':
        return AColors.warning;
      case 'rejected':
        return AColors.error;
      default:
        return AColors.grey;
    }
  }
}
