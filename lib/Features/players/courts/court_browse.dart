import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/widgets/area_bottomsheet.dart';
import 'package:padel_management_system/Features/players/courts/widgets/court_list.dart';
import 'package:padel_management_system/Features/players/courts/widgets/filter_bottomsheet.dart';
import 'package:padel_management_system/Features/players/courts/widgets/nearest_filter.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/widgets/player_screen_components.dart';

class CourtBrowseScreen extends StatefulWidget {
  const CourtBrowseScreen({super.key});

  @override
  State<CourtBrowseScreen> createState() => _CourtBrowseScreenState();
}

class _CourtBrowseScreenState extends State<CourtBrowseScreen> {
  late final CourtBrowseController controller;

  @override
  void initState() {
    super.initState();
    // Registered once here: calling `Get.put(CourtBrowseController())` inside
    // build() rebuilt the whole controller graph on every keystroke.
    controller = CourtBrowseController.to;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            const PlayerScreenHeader(
              title: 'Courts',
              showNotifications: false,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: ASizes.paddingMd, vertical: ASizes.paddingSm),
                child: Column(
                  children: [
                    // Rebuilds when the text changes (including the programmatic
                    // clear from "Clear all filters") so the field and its clear
                    // button always agree with the filter state.
                    ListenableBuilder(
                      listenable: controller.searchTextController,
                      builder: (context, _) => PlayerSearchBar(
                        hintText: 'Search courts, areas, or clubs...',
                        controller: controller.searchTextController,
                        onChanged: controller.searchCourts,
                      ),
                    ),
                    const SizedBox(height: ASizes.spaceBtwItems),
                    _FilterRow(controller: controller),
                    const SizedBox(height: ASizes.spaceBtwItems),
                    _ResultsRow(controller: controller),
                    const SizedBox(height: ASizes.paddingSm),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.refreshCourts,
                        color: c.brandText,
                        child: const CourtsList(),
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
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    // `PlayerFilterButton` is a plain AnimatedContainer, so each one needs its
    // own `Expanded`: unconstrained Row children size to intrinsic width, the
    // labels can never ellipsis, and the row overflows once a count badge
    // widens a button.
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: PlayerFilterButton(
              icon: Icons.tune,
              label: 'Filters',
              onPressed: () => showFiltersBottomSheet(context),
              hasActiveFilters: controller.filterController.hasSheetFilters,
            ),
          ),
          const SizedBox(width: ASizes.paddingSm),
          Expanded(
            child: PlayerFilterButton(
              icon: Icons.location_on,
              label: 'Areas',
              onPressed: () => showAreasBottomSheet(context),
              hasActiveFilters: controller.filterController.hasAreaFilter,
            ),
          ),
          const SizedBox(width: ASizes.paddingSm),
          Expanded(
            child: PlayerFilterButton(
              icon: Icons.my_location,
              label: 'Nearest',
              onPressed: () => showNearestBottomSheet(context),
              hasActiveFilters:
                  controller.hasLocation || controller.hasDistanceFilter,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsRow extends StatelessWidget {
  const _ResultsRow({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);

    return Obx(() {
      final count = controller.filteredCourtsCount;

      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count == 1 ? '1 court found' : '$count courts found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.sortLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          if (controller.hasAnyFilter)
            TextButton.icon(
              onPressed: controller.clearAllFilters,
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: const Text('Clear all'),
              style: TextButton.styleFrom(
                foregroundColor: c.brandText,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(
                  fontSize: ASizes.fontSizeSm,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      );
    });
  }
}
