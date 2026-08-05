import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_colors.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_details_sheet.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/match_pieces.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

/// A single card in the "Open Matches" list.
///
/// Previously two near-identical implementations existed (`buildMatchCard` and
/// `buildEnhancedMatchCard`); this is the single surviving one.
class OpenMatchCard extends StatelessWidget {
  const OpenMatchCard({super.key, required this.match});

  final Map<String, dynamic> match;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final DateTime date = match['date'] as DateTime;

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
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showMatchDetailsSheet(context, match),
          child: Padding(
            padding: const EdgeInsets.all(ASizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Host + skill badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: c.surfaceElevated,
                      backgroundImage:
                          AssetImage(match['createdByAvatar'] as String),
                    ),
                    const SizedBox(width: ASizes.paddingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            'by ${match['createdBy']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall
                                ?.copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    MatchBadge(
                      label: match['skillLevel'] as String,
                      color: getSkillLevelColor(match['skillLevel'] as String),
                    ),
                  ],
                ),

                const SizedBox(height: ASizes.paddingSm),

                Text(
                  match['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall
                      ?.copyWith(color: c.textSecondary, height: 1.4),
                ),

                const SizedBox(height: 10),

                MatchMetaRow(
                  icon: Icons.place_rounded,
                  text: '${match['courtName']}, ${match['location']}',
                ),
                const SizedBox(height: 6),
                MatchMetaRow(
                  icon: Icons.schedule_rounded,
                  text:
                      '${DateFormat('MMM dd').format(date)} at ${match['time']}',
                  trailing: Text(
                    '\$${match['price']}/person',
                    style: text.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: c.brandText,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Players + pending requests
                Row(
                  children: [
                    MatchPlayersStrip(match: match),
                    const SizedBox(width: 4),
                    Text(
                      '${match['currentPlayers']}/${match['maxPlayers']}',
                      style: text.bodySmall?.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if ((match['joinRequests'] as int) > 0)
                      MatchBadge(
                        label: '${match['joinRequests']} requests',
                        color: AColors.warning,
                        icon: Icons.mark_email_unread_rounded,
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => showMatchDetailsSheet(context, match),
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
                    Expanded(child: MatchJoinButton(match: match)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
