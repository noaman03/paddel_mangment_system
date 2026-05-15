import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:padelsystem/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padelsystem/Features/players/open_matches/widgets/openmatc_colors.dart';
import 'package:padelsystem/Features/players/open_matches/widgets/openmatches_showdetails.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';

Widget buildMatchCard(Map<String, dynamic> match, bool isDark) {
  final controller = Get.find<OpenMatchesController>();
  return Container(
    margin: const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
    decoration: BoxDecoration(
      color: isDark ? AColors.containerDark : Colors.white,
      borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
    ),
    child: Padding(
      padding: const EdgeInsets.all(ASizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
              // Skill Level Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ASizes.paddingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getSkillLevelColor(match['skillLevel']),
                  borderRadius: BorderRadius.circular(ASizes.borderRadiusSm),
                ),
                child: Text(
                  match['skillLevel'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

          // Court and Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: ASizes.iconSm,
                color: isDark ? AColors.grey : AColors.darkGrey,
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

          const SizedBox(height: ASizes.paddingSm),

          // Date and Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: ASizes.iconSm,
                color: isDark ? AColors.grey : AColors.darkGrey,
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

          // Players Info
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
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: isDark ? AColors.dark : AColors.darkGrey,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ASizes.paddingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AColors.warning,
                    borderRadius: BorderRadius.circular(ASizes.borderRadiusSm),
                  ),
                  child: Text(
                    '${match['joinRequests']} requests',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                        color:
                            isDark ? AColors.darkGrey : AColors.primaryColor),
                  ),
                  child: Text(
                    'View Details',
                    style: Theme.of(Get.context!).textTheme.bodyMedium,
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
    ),
  );
}
