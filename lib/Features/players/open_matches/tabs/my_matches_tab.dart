import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/my_match_card.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class MyMatchesTab extends StatelessWidget {
  const MyMatchesTab({super.key, required this.onBrowseOpenMatches});

  /// Sends the user back to the "Open Matches" tab from the empty state.
  final VoidCallback onBrowseOpenMatches;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OpenMatchesController>();

    return Obx(
      () => controller.myMatches.isEmpty
          ? _NoMyMatches(onBrowse: onBrowseOpenMatches)
          : ListView.builder(
              padding: const EdgeInsets.only(
                top: ASizes.paddingSm,
                bottom: ASizes.paddingLg,
              ),
              itemCount: controller.myMatches.length,
              itemBuilder: (_, index) =>
                  MyMatchCard(entry: controller.myMatches[index]),
            ),
    );
  }
}

class _NoMyMatches extends StatelessWidget {
  const _NoMyMatches({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASizes.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 52,
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: ASizes.spaceBtwItems),
            Text(
              'No matches yet',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Matches you join or create will show up here.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: ASizes.spaceBtwItems),
            ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.search_rounded, size: 18),
              style: ElevatedButton.styleFrom(
                // The vivid accent cannot carry white text (1.91:1).
                backgroundColor: AColors.primaryDeep,
                foregroundColor: AColors.foregroundOn(AColors.primaryDeep),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: ASizes.paddingLg,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ASizes.borderRadiusLg),
                ),
              ),
              label: const Text(
                'Browse open matches',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
