import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_colors.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_pieces.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Full detail sheet for an open match.
///
/// Replaces the old placeholder sheet, which rendered a hardcoded white panel
/// with the literal text "Match details would go here...".
Future<void> showMatchDetailsSheet(
  BuildContext context,
  Map<String, dynamic> match,
) {
  final controller = Get.find<OpenMatchesController>();
  final String matchId = match['id'] as String;

  // Anything that both mutates state and raises a toast has to run AFTER the
  // sheet is gone: showAppSheet installs a ScaffoldMessenger that lives and
  // dies with the sheet, so feedback raised on the way out is destroyed before
  // the user can read it ("press join, nothing happens"). Record the intent,
  // close, then run it against the root messenger.
  VoidCallback? afterClose;

  return showAppSheet<void>(
    context,
    title: match['title'] as String,
    subtitle: '${match['courtName']} · ${match['location']}',
    icon: Icons.sports_tennis_rounded,
    heightFactor: 0.85,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: _MatchDetailsBody(match: match),
    ),
    footer: Row(
      children: [
        Expanded(
          child: Obx(() {
            final bool joined = controller.joinedMatchIds.contains(matchId);
            return OutlinedButton.icon(
              onPressed: () async {
                if (joined) {
                  // Captured before the await so the sheet can be dismissed
                  // without touching a possibly-stale BuildContext after it.
                  final navigator = Navigator.of(context);
                  final ok = await AppFeedback.confirm(
                    context,
                    title: 'Leave this match?',
                    message:
                        'Your slot in "${match['title']}" will open up again.',
                    confirmLabel: 'Leave',
                    icon: Icons.logout_rounded,
                    destructive: true,
                  );
                  if (ok) {
                    afterClose = () => controller.leaveMatch(matchId);
                    navigator.maybePop();
                  }
                } else {
                  AppFeedback.info(
                    'Host contacted',
                    'A message to ${match['createdBy']} would open the chat '
                        'thread for this match.',
                  );
                }
              },
              icon: Icon(
                joined
                    ? Icons.logout_rounded
                    : Icons.chat_bubble_outline_rounded,
                size: 18,
              ),
              label: Text(joined ? 'Leave' : 'Message host'),
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MatchJoinButton(
            match: match,
            onJoinPressed: () {
              afterClose = () => controller.joinMatch(matchId);
              Navigator.of(context).maybePop();
            },
          ),
        ),
      ],
    ),
  ).whenComplete(() => afterClose?.call());
}

class _MatchDetailsBody extends StatelessWidget {
  const _MatchDetailsBody({required this.match});

  final Map<String, dynamic> match;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final DateTime date = match['date'] as DateTime;
    final int free = match['playersNeeded'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Host
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: c.surfaceElevated,
              backgroundImage: AssetImage(match['createdByAvatar'] as String),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match['createdBy'] as String,
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Match host',
                    style: text.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            MatchBadge(
              label: match['skillLevel'] as String,
              color: getSkillLevelColor(match['skillLevel'] as String),
            ),
          ],
        ),

        const SizedBox(height: ASizes.spaceBtwItems),

        Text(
          match['description'] as String,
          style: text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.5),
        ),

        const SizedBox(height: ASizes.spaceBtwItems),

        // Fact grid. A Wrap, not a Row of Expandeds, so it reflows instead of
        // overflowing when the system font scale is turned up.
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _FactTile(
              icon: Icons.calendar_month_rounded,
              label: 'Date',
              value: DateFormat('EEE, MMM dd').format(date),
            ),
            _FactTile(
              icon: Icons.schedule_rounded,
              label: 'Time',
              value: '${match['time']} · ${match['duration']}',
            ),
            _FactTile(
              icon: Icons.place_rounded,
              label: 'Court',
              value: match['courtName'] as String,
            ),
            _FactTile(
              icon: Icons.payments_rounded,
              label: 'Price',
              value: '\$${match['price']} / player',
            ),
          ],
        ),

        const SizedBox(height: ASizes.spaceBtwSections),

        Row(
          children: [
            Text(
              'Players',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            MatchBadge(
              label: '${match['currentPlayers']}/${match['maxPlayers']}',
              color: free > 0 ? AColors.primaryColor : AColors.info,
              icon: Icons.groups_rounded,
            ),
          ],
        ),

        const SizedBox(height: 12),

        ...List.generate((match['players'] as List).length, (index) {
          final player = (match['players'] as List)[index] as Map;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: c.fill,
                  backgroundImage: AssetImage(player['avatar'] as String),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    player['name'] as String,
                    style:
                        text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (index == 0)
                  const MatchBadge(
                    label: 'Host',
                    color: AColors.primaryColor,
                  ),
              ],
            ),
          );
        }),

        if (free > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c.soft(AColors.primaryColor),
              borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
              border: Border.all(
                color: AColors.primaryColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                MatchPlayersStrip(match: match, radius: 14),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$free ${free == 1 ? 'slot' : 'slots'} still open',
                    style: text.bodyMedium?.copyWith(
                      color: c.onSurfaceAccent(AColors.primaryColor),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MatchBadge(
              label: match['matchType'] as String,
              color: AColors.info,
              icon: Icons.style_rounded,
            ),
            if ((match['joinRequests'] as int) > 0)
              MatchBadge(
                label: '${match['joinRequests']} pending requests',
                color: AColors.warning,
                icon: Icons.mark_email_unread_rounded,
              ),
          ],
        ),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    // Two per row, minus the sheet's horizontal padding and the Wrap spacing.
    final double width = (MediaQuery.sizeOf(context).width - 40 - 12) / 2;

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: c.brandText),
              const SizedBox(width: 6),
              Text(
                label,
                style: text.bodySmall?.copyWith(color: c.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
