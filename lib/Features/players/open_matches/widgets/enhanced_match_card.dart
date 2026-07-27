import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/core/const/text_strings.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

Widget buildEnhancedMatchCard(
  Map<String, dynamic> match,
) {
  final controller = Get.find<OpenMatchesController>();
  final bool isDark = ADeviceutils.isDarkMode(Get.context!);
  return PlayerCard(
    onTap: () => showMatchDetails(match),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with avatar and badges
        Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(match['createdByAvatar']),
              radius: 20,
            ),
            const SizedBox(width: ASizes.paddingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match['title'],
                    style: TextStyle(
                      fontSize: ASizes.fontSizeMd,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AColors.white : AColors.textprimary,
                    ),
                  ),
                  Text(
                    'by ${match['createdBy']}',
                    style: TextStyle(
                      fontSize: ASizes.fontSizeSm,
                      color: isDark ? AColors.grey : AColors.textsecondarry,
                    ),
                  ),
                ],
              ),
            ),
            PlayerStatusBadge(
              text: match['skillLevel'],
              color: getSkillLevelColor(match['skillLevel']),
            ),
          ],
        ),

        const SizedBox(height: ASizes.paddingSm),

        // Description
        Text(
          match['description'],
          style: TextStyle(
            fontSize: ASizes.fontSizeSm,
            color: isDark ? AColors.grey : AColors.textsecondarry,
          ),
        ),

        const SizedBox(height: ASizes.paddingSm),

        // Location and Time info
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
                '${match['courtName']}, ${match['location']}',
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
              Icons.access_time,
              size: ASizes.iconSm,
              color: AColors.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${DateFormat('MMM dd').format(match['date'])} at ${match['time']}',
              style: TextStyle(
                fontSize: ASizes.fontSizeSm,
                color: isDark ? AColors.grey : AColors.textsecondarry,
              ),
            ),
            const Spacer(),
            Text(
              '\$${match['price']}/person',
              style: const TextStyle(
                fontSize: ASizes.fontSizeSm,
                fontWeight: FontWeight.w600,
                color: AColors.primaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: ASizes.paddingSm),

        // Players Info with avatars
        Row(
          children: [
            ...List.generate(
              match['players'].length,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: CircleAvatar(
                  radius: 12,
                  backgroundImage:
                      AssetImage(match['players'][index]['avatar']),
                ),
              ),
            ),
            if (match['playersNeeded'] > 0)
              ...List.generate(
                match['playersNeeded'],
                (index) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        isDark ? AColors.grey : AColors.borderPrimary,
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: ASizes.paddingSm),
            Text(
              '${match['currentPlayers']}/${match['maxPlayers']} players',
              style: TextStyle(
                fontSize: ASizes.fontSizeSm,
                color: isDark ? AColors.grey : AColors.textsecondarry,
              ),
            ),
            const Spacer(),
            if (match['joinRequests'] > 0)
              PlayerStatusBadge(
                text: '${match['joinRequests']} requests',
                color: AColors.warning,
              ),
          ],
        ),

        const SizedBox(height: ASizes.paddingSm),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => showMatchDetails(match),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: isDark ? AColors.darkGrey : AColors.primaryColor),
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
              child: ElevatedButton(
                onPressed: match['playersNeeded'] > 0
                    ? () => controller.joinMatch(match['id'])
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  match['playersNeeded'] > 0 ? 'Join Match' : 'Full',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

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

void showMatchDetails(Map<String, dynamic> match) {
  // Enhanced match details modal
}
