import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/players/tournaments/controller/tournament_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  late final TournamentsController controller;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    // Re-use the existing instance so joins survive leaving and re-entering the
    // tab; `Get.put` in a field initializer used to re-seed the demo data.
    controller = Get.isRegistered<TournamentsController>()
        ? Get.find<TournamentsController>()
        : Get.put(TournamentsController(), permanent: true);
    // A no-op unless the signed-in account changed since the data was seeded.
    controller.loadForCurrentSession();
  }

  @override
  void dispose() {
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No inner Scaffold: PlayerHome already provides one, and a second
    // background colour showed up as a mismatched panel behind the app bar.
    return Column(
      children: [
        Obx(() => PlayerScreenHeader(
              title: 'Tournaments',
              notificationCount: controller.entryRequests.length,
              onNotificationTap: showEntryRequests,
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              ASizes.paddingMd,
              0,
              ASizes.paddingMd,
              ASizes.paddingMd,
            ),
            child: Column(
              children: [
                // AnimatedBuilder so the search field's clear (X) button, which
                // is gated on `controller.text.isNotEmpty`, actually appears.
                AnimatedBuilder(
                  animation: searchController,
                  builder: (context, _) => PlayerSearchBar(
                    controller: searchController,
                    hintText: 'Search tournaments, organizers, locations...',
                    onChanged: controller.searchTournaments,
                  ),
                ),
                const SizedBox(height: ASizes.spaceBtwItems),
                PlayerTabBar(
                  controller: tabController,
                  tabs: const [
                    'All Tournaments',
                    'My Tournaments',
                    'Create',
                  ],
                ),
                const SizedBox(height: ASizes.spaceBtwItems),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      buildAllTournamentsTab(),
                      buildMyTournamentsTab(),
                      _CreateTournamentForm(
                        controller: controller,
                        onCreated: () {
                          searchController.clear();
                          tabController.animateTo(0);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ all tab
  Widget buildAllTournamentsTab() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterDropdown(
                icon: Icons.workspace_premium_outlined,
                value: controller.selectedTournamentType,
                options: controller.tournamentTypes,
                onChanged: controller.updateTournamentType,
              ),
              const SizedBox(width: ASizes.paddingSm),
              _buildFilterDropdown(
                icon: Icons.bar_chart_rounded,
                value: controller.selectedSkillLevel,
                options: controller.skillLevels,
                onChanged: controller.updateSkillLevel,
              ),
              const SizedBox(width: ASizes.paddingSm),
              _buildFilterDropdown(
                icon: Icons.emoji_events_outlined,
                value: controller.selectedPrizeType,
                options: controller.prizeTypes,
                onChanged: controller.updatePrizeType,
              ),
            ],
          ),
        ),
        const SizedBox(height: ASizes.spaceBtwItems),
        Expanded(
          child: Obx(() {
            final tournaments = controller.filteredTournaments;
            if (tournaments.isEmpty) {
              return PlayerEmptyState(
                icon: Icons.emoji_events,
                title: 'No tournaments found',
                subtitle: 'Try adjusting your filters or check back later',
                action: OutlinedButton.icon(
                  onPressed: () {
                    searchController.clear();
                    controller.resetFilters();
                    AppFeedback.info(
                        'Filters cleared', 'Showing every tournament again.');
                  },
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: const Text('Clear filters'),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: tournaments.length,
              itemBuilder: (context, index) =>
                  buildTournamentCard(tournaments[index]),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required RxString value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final c = context.padel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: ASizes.paddingSm),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(14),
        color: c.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c.textSecondary),
          const SizedBox(width: 6),
          Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value.value,
                  isDense: true,
                  borderRadius: BorderRadius.circular(14),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                  items: options
                      .map((option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ))
                      .toList(),
                  onChanged: (selected) {
                    if (selected != null) onChanged(selected);
                  },
                ),
              )),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- my tab
  Widget buildMyTournamentsTab() {
    return Obx(() {
      final mine = controller.myTournaments;
      if (mine.isEmpty) {
        return PlayerEmptyState(
          icon: Icons.calendar_today,
          title: 'No tournaments yet',
          subtitle: 'Join some tournaments to see them here',
          action: ElevatedButton.icon(
            onPressed: () => tabController.animateTo(0),
            icon: const Icon(Icons.search_rounded, size: 18),
            label: const Text('Browse tournaments'),
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: mine.length,
        itemBuilder: (context, index) => buildMyTournamentCard(mine[index]),
      );
    });
  }

  // -------------------------------------------------------------- cards
  Widget buildTournamentCard(Map<String, dynamic> tournament) {
    final c = context.padel;
    final theme = Theme.of(context);
    final bool isOfficial = tournament['organizerType'] == 'Official';
    final int current = tournament['currentParticipants'] as int;
    final int max = tournament['maxParticipants'] as int;

    return PlayerCard(
      showBorder: isOfficial,
      borderColor: AColors.primaryColor,
      onTap: () => showTournamentDetails(tournament),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PlayerStatusBadge(
                text: isOfficial ? 'OFFICIAL' : 'PLAYER',
                color: isOfficial ? AColors.primaryColor : AColors.info,
                icon: isOfficial ? Icons.verified : Icons.person,
              ),
              const Spacer(),
              if ((tournament['prizePool'] as int) > 0)
                PlayerStatusBadge(
                  text: 'EGP ${tournament['prizePool']}',
                  color: AColors.warning,
                  icon: Icons.monetization_on,
                )
              else
                PlayerStatusBadge(
                  text: '${tournament['prizeType']}'.toUpperCase(),
                  color: getPrizeTypeColor(tournament['prizeType']),
                ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm),
          Text(
            tournament['title'],
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'by ${tournament['organizer']}',
            style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: ASizes.paddingSm),
          Text(
            tournament['description'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: c.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: ASizes.paddingSm),
          Row(
            children: [
              Icon(Icons.location_on, size: ASizes.iconSm, color: c.brandText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${tournament['courtName']}, ${tournament['location']}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: c.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: ASizes.iconSm, color: c.brandText),
              const SizedBox(width: 4),
              Text(
                _dateRange(tournament['startDate'], tournament['endDate']),
                style:
                    theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const Spacer(),
              Text(
                (tournament['entryFee'] as int) > 0
                    ? 'EGP ${tournament['entryFee']} entry'
                    : 'FREE ENTRY',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  // A raw AColors.success here was near-invisible on the dark
                  // card; onSurfaceAccent lifts it until it is readable.
                  color: (tournament['entryFee'] as int) > 0
                      ? c.onSurfaceAccent(c.primary)
                      : c.onSurfaceAccent(c.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm),
          Row(
            children: [
              PlayerStatusBadge(
                text: tournament['skillLevel'],
                color: getSkillLevelColor(tournament['skillLevel']),
              ),
              const SizedBox(width: ASizes.paddingSm),
              Expanded(
                child: Text(
                  '$current/$max participants',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: c.textSecondary),
                ),
              ),
              if ((tournament['entryRequests'] as int) > 0)
                PlayerStatusBadge(
                  text: '${tournament['entryRequests']} requests',
                  color: AColors.info,
                ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm),
          _participantsBar(current, max),
          const SizedBox(height: ASizes.paddingSm),
          Container(
            padding: const EdgeInsets.all(ASizes.paddingSm),
            decoration: BoxDecoration(
              color: c.soft(AColors.warning),
              borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
              border: Border.all(
                color: AColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: ASizes.iconSm,
                    color: c.onSurfaceAccent(AColors.warning)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Registration closes ${DateFormat('MMM dd, yyyy').format(tournament['registrationDeadline'])}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: c.onSurfaceAccent(AColors.warning),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ASizes.paddingSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => showTournamentDetails(tournament),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: ASizes.paddingSm),
              Expanded(child: _joinButton(tournament['id'] as String)),
            ],
          ),
        ],
      ),
    );
  }

  /// The join control, in its own [Obx] so only the pressed card shows a
  /// spinner and only that card flips to "Requested".
  ///
  /// [onJoinPressed] replaces the direct join. The details sheet passes it so
  /// it can close first and join afterwards — see [showTournamentDetails].
  Widget _joinButton(
    String tournamentId, {
    bool dense = true,
    VoidCallback? onJoinPressed,
  }) {
    return Obx(() {
      final live = controller.tournamentById(tournamentId);
      final bool joining = controller.joiningId.value == tournamentId;
      final bool joined = live != null && controller.hasJoined(live);
      final bool full = live != null && controller.isFull(live);

      final String label = joined
          ? 'Requested'
          : full
              ? 'Full'
              : 'Join';

      return ElevatedButton(
        onPressed: (joining || joined || full || live == null)
            ? null
            : (onJoinPressed ?? () => controller.joinTournament(tournamentId)),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: dense ? 12 : 15),
          // The global theme sets fontSize 16, which made "Join Tournament"
          // clip on 360dp phones next to the Details button.
          textStyle: TextStyle(
            fontSize: dense ? 13.5 : 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: joining
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    joined
                        ? Icons.check_circle_rounded
                        : full
                            ? Icons.block_rounded
                            : Icons.add_rounded,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
      );
    });
  }

  Widget _participantsBar(int current, int max) {
    final c = context.padel;
    final double ratio = max == 0 ? 0 : (current / max).clamp(0.0, 1.0);
    final Color tone = ratio >= 1
        ? AColors.error
        : ratio >= 0.8
            ? AColors.warning
            : AColors.primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: ratio,
        minHeight: 7,
        backgroundColor: c.fill,
        color: tone,
      ),
    );
  }

  Widget buildMyTournamentCard(Map<String, dynamic> entry) {
    final c = context.padel;
    final theme = Theme.of(context);
    final linked = controller.tournamentById(entry['tournamentId'] as String?);

    return PlayerCard(
      onTap: () {
        if (linked != null) {
          showTournamentDetails(linked);
        } else {
          AppFeedback.info(
            'Registration only',
            'This entry was archived, so there is no live tournament page.',
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry['title'],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: c.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: ASizes.paddingSm),
              PlayerStatusBadge(
                text: '${entry['status']}'.toUpperCase(),
                color: getStatusColor(entry['status']),
              ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm),
          _iconLine(
            Icons.event_outlined,
            DateFormat('EEE, MMM dd, yyyy').format(entry['startDate']),
          ),
          const SizedBox(height: 6),
          _iconLine(
            Icons.payments_outlined,
            (entry['entryFee'] as int) > 0
                ? 'Entry fee EGP ${entry['entryFee']}'
                : 'Free entry',
          ),
          const SizedBox(height: 6),
          _iconLine(Icons.flag_outlined, '${entry['position']}'),
          const SizedBox(height: ASizes.paddingSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (linked != null) {
                      showTournamentDetails(linked);
                    } else {
                      AppFeedback.info(
                        'Registration only',
                        'This entry was archived, so there is no live tournament page.',
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: ASizes.paddingSm),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmWithdraw(entry),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.onSurfaceAccent(AColors.error),
                    side: BorderSide(
                      color: AColors.error.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Withdraw'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmWithdraw(Map<String, dynamic> entry) async {
    final ok = await AppFeedback.confirm(
      context,
      title: 'Withdraw registration?',
      message:
          'You will lose your slot in ${entry['title']} and can re-apply while '
          'registration is open.',
      confirmLabel: 'Withdraw',
      icon: Icons.exit_to_app_rounded,
      destructive: true,
    );
    if (!ok) return;
    controller.withdrawFromTournament(entry['id'] as String);
  }

  Widget _iconLine(IconData icon, String text) {
    final c = context.padel;
    return Row(
      children: [
        Icon(icon, size: ASizes.iconSm, color: c.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- helpers
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
        return AColors.darkGrey;
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
        return AColors.darkGrey;
    }
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
        return AColors.darkGrey;
    }
  }

  String _dateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('MMM dd');
    return start.difference(end).inDays == 0 &&
            start.day == end.day &&
            start.month == end.month
        ? formatter.format(start)
        : '${formatter.format(start)} - ${formatter.format(end)}';
  }

  // ------------------------------------------------------- entry requests
  void showEntryRequests() {
    showAppSheet<void>(
      context,
      title: 'Entry requests',
      subtitle: 'Players asking to join your tournaments',
      icon: Icons.how_to_reg_rounded,
      heightFactor: 0.85,
      child: Obx(() {
        final requests = controller.entryRequests;
        if (requests.isEmpty) {
          return const PlayerEmptyState(
            icon: Icons.inbox_outlined,
            title: 'All caught up',
            subtitle: 'Every entry request has been handled.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          itemCount: requests.length,
          itemBuilder: (context, index) => _entryRequestTile(requests[index]),
        );
      }),
      // SizedBox keeps the footer full width — a bare button would shrink-wrap
      // and leave the sheet's footer divider hanging half way across.
      footer: SizedBox(
        width: double.infinity,
        child: Obx(() {
          final bool empty = controller.entryRequests.isEmpty;
          return OutlinedButton.icon(
            onPressed: empty ? null : _confirmClearRequests,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(empty ? 'Nothing to clear' : 'Clear all requests'),
          );
        }),
      ),
    );
  }

  Future<void> _confirmClearRequests() async {
    final ok = await AppFeedback.confirm(
      context,
      title: 'Clear all requests?',
      message:
          'Every pending entry request will be dismissed without accepting it.',
      confirmLabel: 'Clear all',
      icon: Icons.delete_sweep_outlined,
      destructive: true,
    );
    if (!ok) return;
    controller.clearAllRequests();
  }

  Widget _entryRequestTile(Map<String, dynamic> request) {
    final c = context.padel;
    final theme = Theme.of(context);
    final Color skillTone = getSkillLevelColor(request['skillLevel']);

    return PlayerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _initials(request['playerName']),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: c.onSurfaceAccent(AColors.primaryColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['playerName'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request['tournamentTitle']} · ${request['category']}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                _relativeTime(request['timestamp']),
                style: theme.textTheme.labelSmall?.copyWith(color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PlayerStatusBadge(
                text: '${request['skillLevel']}'.toUpperCase(),
                color: skillTone,
              ),
              _softChip(Icons.timeline_rounded, request['experience']),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ASizes.paddingSm + 2),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
              border: Border.all(color: c.border),
            ),
            child: Text(
              '"${request['message']}"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: c.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: ASizes.paddingSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      controller.rejectEntryRequest(request['id'] as String),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: c.onSurfaceAccent(AColors.error),
                    side: BorderSide(
                      color: AColors.error.withValues(alpha: 0.55),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: ASizes.paddingSm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      controller.acceptEntryRequest(request['id'] as String),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- details sheet
  void showTournamentDetails(Map<String, dynamic> tournament) {
    final String id = tournament['id'] as String;
    // showAppSheet installs a ScaffoldMessenger that is torn down with the
    // sheet, so joining while the sheet closes destroys "Entry request sent"
    // before it can be read. Remember the intent, close, then join against the
    // root messenger.
    bool joinOnClose = false;

    showAppSheet<void>(
      context,
      title: tournament['title'],
      subtitle: '${tournament['courtName']} · ${tournament['location']}',
      icon: Icons.emoji_events_rounded,
      heightFactor: 0.9,
      child: Obx(() {
        // Read through the controller so the sheet re-renders after a join.
        final data = controller.tournamentById(id) ?? tournament;
        return _detailsBody(data);
      }),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Close'),
            ),
          ),
          const SizedBox(width: ASizes.paddingSm + 2),
          Expanded(
            flex: 2,
            child: _joinButton(
              id,
              dense: false,
              onJoinPressed: () {
                joinOnClose = true;
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    ).whenComplete(() async {
      if (!joinOnClose || !mounted) return;
      final result = await controller.joinTournament(id);
      // From the details sheet, hand the user straight to the tab where the new
      // registration now lives.
      if (mounted && result == TournamentJoinResult.joined) {
        tabController.animateTo(1);
      }
    });
  }

  Widget _detailsBody(Map<String, dynamic> t) {
    final c = context.padel;
    final theme = Theme.of(context);
    final bool isOfficial = t['organizerType'] == 'Official';
    final int current = t['currentParticipants'] as int;
    final int max = t['maxParticipants'] as int;
    final int left = (max - current).clamp(0, max);
    final List<String> categories = List<String>.from(t['categories'] as List);
    final List<String> features = List<String>.from(t['features'] as List);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ASizes.paddingMd),
            decoration: BoxDecoration(
              gradient: AColors.lineargradient,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: AColors.primaryColor.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        _initials(t['organizer']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['organizer'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: ASizes.fontSizeMd,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                isOfficial
                                    ? Icons.verified_rounded
                                    : Icons.person_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOfficial
                                    ? 'Official organizer'
                                    : 'Player organized',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ASizes.paddingMd),
                Row(
                  children: [
                    Expanded(
                      child: _heroStat(
                        'Prize pool',
                        (t['prizePool'] as int) > 0
                            ? 'EGP ${t['prizePool']}'
                            : t['prizeType'],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 34,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                    Expanded(
                      child: _heroStat(
                        'Entry fee',
                        (t['entryFee'] as int) > 0
                            ? 'EGP ${t['entryFee']}'
                            : 'Free',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: ASizes.spaceBtwItems),
          _sectionTitle('About this tournament'),
          const SizedBox(height: 6),
          Text(
            t['description'],
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: c.textSecondary, height: 1.45),
          ),

          const SizedBox(height: ASizes.spaceBtwItems),
          _sectionTitle('Registration'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current of $max players',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              Text(
                left == 0
                    ? 'Full'
                    : '$left ${left == 1 ? 'slot' : 'slots'} left',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: left == 0
                      ? c.onSurfaceAccent(AColors.error)
                      : c.onSurfaceAccent(AColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _participantsBar(current, max),
          const SizedBox(height: ASizes.paddingSm + 2),
          _detailRow(Icons.play_circle_outline, 'Starts',
              DateFormat('EEE, MMM dd, yyyy').format(t['startDate'])),
          _detailRow(Icons.flag_outlined, 'Ends',
              DateFormat('EEE, MMM dd, yyyy').format(t['endDate'])),
          _detailRow(
              Icons.access_time_rounded,
              'Registration closes',
              DateFormat('EEE, MMM dd, yyyy')
                  .format(t['registrationDeadline'])),

          const SizedBox(height: ASizes.spaceBtwItems),
          _sectionTitle('Format & level'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statTile(
                    Icons.account_tree_outlined, 'Format', t['format']),
              ),
              const SizedBox(width: ASizes.paddingSm + 2),
              Expanded(
                child: _statTile(
                  Icons.bar_chart_rounded,
                  'Skill level',
                  t['skillLevel'],
                  tone: getSkillLevelColor(t['skillLevel']),
                ),
              ),
            ],
          ),
          const SizedBox(height: ASizes.paddingSm + 2),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories
                .map((category) =>
                    _softChip(Icons.sports_tennis_rounded, category))
                .toList(),
          ),

          if (features.isNotEmpty) ...[
            const SizedBox(height: ASizes.spaceBtwItems),
            _sectionTitle("What's included"),
            const SizedBox(height: 8),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 17, color: c.onSurfaceAccent(AColors.success)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: c.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: ASizes.paddingSm),
          Container(
            padding: const EdgeInsets.all(ASizes.paddingSm + 4),
            decoration: BoxDecoration(
              color: c.soft(AColors.info),
              borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
              border: Border.all(color: AColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: c.onSurfaceAccent(AColors.info)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Requests are reviewed by the organizer. You will find the '
                    'tournament under "My Tournaments" as soon as you apply.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: c.onSurfaceAccent(AColors.info),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: ASizes.fontSizeMd,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: context.padel.textPrimary,
          ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    final c = context.padel;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: c.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(IconData icon, String label, String value, {Color? tone}) {
    final c = context.padel;
    final theme = Theme.of(context);
    final Color accent = tone ?? AColors.primaryColor;
    return Container(
      padding: const EdgeInsets.all(ASizes.paddingSm + 4),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.onSurfaceAccent(accent)),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: c.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _softChip(IconData icon, String text) {
    final c = context.padel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: c.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(time);
  }
}

/// The third tab: a real, validated tournament creation form.
///
/// Kept as its own StatefulWidget so the TextEditingControllers have a place to
/// live (and get disposed) instead of being rebuilt on every parent rebuild.
class _CreateTournamentForm extends StatefulWidget {
  const _CreateTournamentForm({
    required this.controller,
    required this.onCreated,
  });

  final TournamentsController controller;
  final VoidCallback onCreated;

  @override
  State<_CreateTournamentForm> createState() => _CreateTournamentFormState();
}

class _CreateTournamentFormState extends State<_CreateTournamentForm> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _court = TextEditingController();
  final _location = TextEditingController();
  final _entryFee = TextEditingController(text: '100');
  final _prizePool = TextEditingController(text: '0');
  final _maxParticipants = TextEditingController(text: '16');
  final _startField = TextEditingController();
  final _endField = TextEditingController();
  final _deadlineField = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _deadline;

  String _skillLevel = 'Intermediate';
  String _prizeType = 'Trophies';
  String _format = 'Round Robin';
  bool _submitting = false;

  static final DateFormat _dateFormat = DateFormat('EEE, MMM dd, yyyy');

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _court.dispose();
    _location.dispose();
    _entryFee.dispose();
    _prizePool.dispose();
    _maxParticipants.dispose();
    _startField.dispose();
    _endField.dispose();
    _deadlineField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.all(ASizes.paddingMd),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
              border: Border.all(
                color: AColors.primaryColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AColors.lineargradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Host your own tournament and let players send entry '
                    'requests from this screen.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.onSurfaceAccent(AColors.primaryColor),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ASizes.spaceBtwItems),
          _label('Basics'),
          _text(
            controller: _title,
            label: 'Tournament title',
            hint: 'e.g. Maadi Summer Slam',
            icon: Icons.emoji_events_outlined,
            validator: (value) => _requireText(value, 'a title', min: 4),
          ),
          _text(
            controller: _description,
            label: 'Description',
            hint: 'What makes this tournament worth joining?',
            icon: Icons.notes_rounded,
            maxLines: 3,
            validator: (value) =>
                _requireText(value, 'a short description', min: 15),
          ),
          _text(
            controller: _court,
            label: 'Court / venue',
            hint: 'e.g. Elite Sports Center',
            icon: Icons.stadium_outlined,
            validator: (value) => _requireText(value, 'a court name', min: 3),
          ),
          _text(
            controller: _location,
            label: 'Location',
            hint: 'e.g. Maadi, Cairo',
            icon: Icons.location_on_outlined,
            validator: (value) => _requireText(value, 'a location', min: 3),
          ),
          const SizedBox(height: ASizes.paddingSm),
          _label('Schedule'),
          _dateField(
            controller: _startField,
            label: 'Start date',
            onPick: () => _pickDate(
              initial:
                  _startDate ?? DateTime.now().add(const Duration(days: 7)),
              first: DateTime.now(),
              onPicked: (picked) {
                setState(() {
                  _startDate = picked;
                  _startField.text = _dateFormat.format(picked);
                  // Keep the dependent dates coherent instead of failing later.
                  if (_endDate == null || _endDate!.isBefore(picked)) {
                    _endDate = picked;
                    _endField.text = _dateFormat.format(picked);
                  }
                  if (_deadline == null || _deadline!.isAfter(picked)) {
                    final today = DateUtils.dateOnly(DateTime.now());
                    final suggested = picked.subtract(const Duration(days: 2));
                    _deadline = suggested.isBefore(today) ? today : suggested;
                    _deadlineField.text = _dateFormat.format(_deadline!);
                  }
                });
              },
            ),
          ),
          _dateField(
            controller: _endField,
            label: 'End date',
            onPick: () => _pickDate(
              initial: _endDate ?? _startDate ?? DateTime.now(),
              first: _startDate ?? DateTime.now(),
              onPicked: (picked) => setState(() {
                _endDate = picked;
                _endField.text = _dateFormat.format(picked);
              }),
            ),
          ),
          _dateField(
            controller: _deadlineField,
            label: 'Registration deadline',
            onPick: () => _pickDate(
              initial: _deadline ?? DateTime.now(),
              first: DateTime.now(),
              last: _startDate,
              onPicked: (picked) => setState(() {
                _deadline = picked;
                _deadlineField.text = _dateFormat.format(picked);
              }),
            ),
          ),
          const SizedBox(height: ASizes.paddingSm),
          _label('Entry & prizes'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _text(
                  controller: _entryFee,
                  label: 'Entry fee (EGP)',
                  hint: '0 for free',
                  icon: Icons.payments_outlined,
                  numeric: true,
                  validator: (value) =>
                      _requireNumber(value, min: 0, max: 5000),
                ),
              ),
              const SizedBox(width: ASizes.paddingSm + 2),
              Expanded(
                child: _text(
                  controller: _prizePool,
                  label: 'Prize pool (EGP)',
                  hint: '0 if none',
                  icon: Icons.savings_outlined,
                  numeric: true,
                  validator: (value) =>
                      _requireNumber(value, min: 0, max: 200000),
                ),
              ),
            ],
          ),
          _dropdown(
            label: 'Prize type',
            value: _prizeType,
            icon: Icons.card_giftcard_outlined,
            options: widget.controller.prizeTypes
                .where((type) => type != 'All')
                .toList(),
            onChanged: (value) => setState(() => _prizeType = value),
          ),
          const SizedBox(height: ASizes.paddingSm),
          _label('Play settings'),
          _dropdown(
            label: 'Skill level',
            value: _skillLevel,
            icon: Icons.bar_chart_rounded,
            options: widget.controller.skillLevels
                .where((level) => level != 'All')
                .toList(),
            onChanged: (value) => setState(() => _skillLevel = value),
          ),
          _dropdown(
            label: 'Format',
            value: _format,
            icon: Icons.account_tree_outlined,
            options: widget.controller.formatOptions,
            onChanged: (value) => setState(() => _format = value),
          ),
          _text(
            controller: _maxParticipants,
            label: 'Max participants',
            hint: 'Between 4 and 64',
            icon: Icons.groups_outlined,
            numeric: true,
            validator: (value) => _requireNumber(value, min: 4, max: 64),
          ),
          const SizedBox(height: ASizes.paddingSm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.rocket_launch_outlined, size: 18),
              label: Text(_submitting ? 'Publishing...' : 'Publish tournament'),
            ),
          ),
          const SizedBox(height: ASizes.paddingSm + 2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _submitting ? null : _resetForm,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset form'),
            ),
          ),
          const SizedBox(height: ASizes.spaceBtwSections),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ form bits
  Widget _label(String text) {
    final c = context.padel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AColors.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: c.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _text({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ASizes.spaceBtwInputFields),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        textCapitalization:
            numeric ? TextCapitalization.none : TextCapitalization.sentences,
        inputFormatters:
            numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _dateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onPick,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ASizes.spaceBtwInputFields),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onPick,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Pick a $label' : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Tap to choose',
          prefixIcon: const Icon(Icons.event_outlined, size: 20),
          suffixIcon: IconButton(
            tooltip: 'Pick $label',
            icon: const Icon(Icons.calendar_month_outlined, size: 20),
            onPressed: onPick,
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ASizes.spaceBtwInputFields),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
        items: options
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: (selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    );
  }

  Future<void> _pickDate({
    required DateTime initial,
    required DateTime first,
    DateTime? last,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final DateTime firstDate = DateUtils.dateOnly(first);
    final DateTime lastDate = DateUtils.dateOnly(
        last ?? DateTime.now().add(const Duration(days: 365)));
    final DateTime safeLast =
        lastDate.isBefore(firstDate) ? firstDate : lastDate;
    DateTime safeInitial = DateUtils.dateOnly(initial);
    if (safeInitial.isBefore(firstDate)) safeInitial = firstDate;
    if (safeInitial.isAfter(safeLast)) safeInitial = safeLast;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: safeLast,
    );
    if (picked != null) onPicked(picked);
  }

  String? _requireText(String? value, String what, {int min = 3}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter $what';
    if (text.length < min) return 'Please enter at least $min characters';
    return null;
  }

  String? _requireNumber(String? value, {required int min, required int max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Required';
    final parsed = int.tryParse(text);
    if (parsed == null) return 'Numbers only';
    if (parsed < min || parsed > max) return 'Must be between $min and $max';
    return null;
  }

  // --------------------------------------------------------------- submit
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      AppFeedback.warning(
        'Check the form',
        'Some fields still need your attention.',
      );
      return;
    }

    // Dates are validated for presence by the fields; cross-check the order.
    final start = _startDate!;
    final end = _endDate!;
    final deadline = _deadline!;
    if (end.isBefore(start)) {
      AppFeedback.error(
          'Dates do not add up', 'The end date is before the start date.');
      return;
    }
    if (deadline.isAfter(start)) {
      AppFeedback.error(
        'Deadline too late',
        'Registration must close on or before the start date.',
      );
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    widget.controller.createTournament(
      title: _title.text.trim(),
      description: _description.text.trim(),
      courtName: _court.text.trim(),
      location: _location.text.trim(),
      startDate: start,
      endDate: end,
      registrationDeadline: deadline,
      entryFee: int.parse(_entryFee.text.trim()),
      prizePool: int.parse(_prizePool.text.trim()),
      maxParticipants: int.parse(_maxParticipants.text.trim()),
      skillLevel: _skillLevel,
      prizeType: _prizeType,
      format: _format,
    );

    _clearFields();
    setState(() => _submitting = false);
    // Land the user on the list so they can see what they just created.
    widget.onCreated();
  }

  void _resetForm() {
    _clearFields();
    setState(() {});
    AppFeedback.info('Form reset', 'All fields are back to their defaults.');
  }

  void _clearFields() {
    _formKey.currentState?.reset();
    _title.clear();
    _description.clear();
    _court.clear();
    _location.clear();
    _entryFee.text = '100';
    _prizePool.text = '0';
    _maxParticipants.text = '16';
    _startField.clear();
    _endField.clear();
    _deadlineField.clear();
    _startDate = null;
    _endDate = null;
    _deadline = null;
    _skillLevel = 'Intermediate';
    _prizeType = 'Trophies';
    _format = 'Round Robin';
  }
}
