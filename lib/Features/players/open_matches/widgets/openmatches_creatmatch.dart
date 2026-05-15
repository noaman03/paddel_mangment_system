import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padelsystem/Features/players/open_matches/widgets/openmatc_colors.dart';
import 'package:padelsystem/core/const/colors.dart';
import 'package:padelsystem/core/const/sizes.dart';

Widget buildMyMatchCard(Map<String, dynamic> match, bool isDark) {
  return Container(
    margin: const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
    decoration: BoxDecoration(
      color: isDark ? AColors.containerDark : Colors.white,
      borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(ASizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  match['title'],
                  style: TextStyle(
                    fontSize: ASizes.fontSizeMd,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AColors.white : AColors.textprimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ASizes.paddingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(match['status']),
                  borderRadius: BorderRadius.circular(ASizes.borderRadiusSm),
                ),
                child: Text(
                  match['status'].toUpperCase(),
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
          Text(
            match['courtName'],
            style: TextStyle(
              color: isDark ? AColors.grey : AColors.textsecondarry,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat('MMM dd').format(match['date'])} at ${match['time']}',
            style: TextStyle(
              color: isDark ? AColors.grey : AColors.textsecondarry,
            ),
          ),
          const SizedBox(height: ASizes.paddingSm),
          Text(
            'Players: ${match['playersJoined']}/${match['maxPlayers']}',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? AColors.white : AColors.textprimary,
            ),
          ),
        ],
      ),
    ),
  );
}
