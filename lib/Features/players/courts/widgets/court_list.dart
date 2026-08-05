import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/widgets/court_card.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class CourtsList extends StatelessWidget {
  const CourtsList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = CourtBrowseController.to;

    return Obx(() {
      if (controller.courtDataController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AColors.primaryColor),
        );
      }

      if (controller.filteredCourts.isEmpty) {
        // Still a ListView so pull-to-refresh keeps working when empty.
        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          children: [_EmptyState(controller: controller)],
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: ASizes.spaceBtwSections),
        itemCount: controller.filteredCourts.length,
        itemBuilder: (context, index) =>
            CourtCard(court: controller.filteredCourts[index]),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);
    final hasCourts = controller.courtDataController.allCourts.isNotEmpty;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration:
              BoxDecoration(color: c.surfaceElevated, shape: BoxShape.circle),
          child: Icon(Icons.sports_tennis, size: 46, color: c.textMuted),
        ),
        const SizedBox(height: ASizes.spaceBtwItems),
        Text(
          'No courts found',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800, color: c.textPrimary),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            hasCourts
                ? 'Nothing matches the current filters. Widen the price range, clear the area, or increase the search distance.'
                : 'No courts are available at the moment.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ),
        if (hasCourts) ...[
          const SizedBox(height: ASizes.spaceBtwItems),
          ElevatedButton.icon(
            onPressed: controller.clearAllFilters,
            icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
            label: const Text('Clear all filters'),
          ),
        ],
      ],
    );
  }
}
