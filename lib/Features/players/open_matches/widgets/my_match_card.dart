import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_colors.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_details_sheet.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_pieces.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// A card in the "My Matches" tab: a match the player hosts or has joined.
class MyMatchCard extends StatelessWidget {
  const MyMatchCard({super.key, required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final controller = Get.find<OpenMatchesController>();

    final String status = entry['status'] as String;
    final bool isHost = entry['role'] == 'host';
    final DateTime date = entry['date'] as DateTime;
    final Map<String, dynamic>? source =
        controller.matchById(entry['id'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(ASizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry['title'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                MatchBadge(
                  label: status.toUpperCase(),
                  color: getStatusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MatchMetaRow(
              icon: Icons.place_rounded,
              text: entry['location'] == null
                  ? entry['courtName'] as String
                  : '${entry['courtName']}, ${entry['location']}',
            ),
            const SizedBox(height: 6),
            MatchMetaRow(
              icon: Icons.schedule_rounded,
              text:
                  '${DateFormat('EEE, MMM dd').format(date)} at ${entry['time']}',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                MatchBadge(
                  label: isHost ? 'Hosting' : 'Joined',
                  color: isHost ? AColors.primaryColor : AColors.info,
                  icon: isHost
                      ? Icons.workspace_premium_rounded
                      : Icons.how_to_reg_rounded,
                ),
                const Spacer(),
                Text(
                  'Players ${entry['playersJoined']}/${entry['maxPlayers']}',
                  style: text.bodySmall?.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (source == null) {
                        AppFeedback.info(
                          'Nothing to show',
                          'This match is no longer listed in Open Matches.',
                        );
                        return;
                      }
                      showMatchDetailsSheet(context, source);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: c.border),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ASizes.borderRadiusLg),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ASizes.paddingSm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmExit(context, controller, isHost),
                    icon: Icon(
                      isHost
                          ? Icons.delete_outline_rounded
                          : Icons.logout_rounded,
                      size: 18,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.soft(AColors.error),
                      foregroundColor: c.onSurfaceAccent(AColors.error),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(ASizes.borderRadiusLg),
                        side: BorderSide(
                          color: AColors.error.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    label: Text(
                      isHost ? 'Cancel' : 'Leave',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit(
    BuildContext context,
    OpenMatchesController controller,
    bool isHost,
  ) async {
    final String id = entry['id'] as String;
    final String title = entry['title'] as String;

    final ok = await AppFeedback.confirm(
      context,
      title: isHost ? 'Cancel this match?' : 'Leave this match?',
      message: isHost
          ? '"$title" will be removed from Open Matches and everyone in it '
              'will lose their slot.'
          : 'Your slot in "$title" will open up again.',
      confirmLabel: isHost ? 'Cancel match' : 'Leave',
      icon: isHost ? Icons.delete_outline_rounded : Icons.logout_rounded,
      destructive: true,
    );
    if (!ok) return;

    if (isHost) {
      controller.cancelMatch(id);
    } else {
      controller.leaveMatch(id);
    }
  }
}
