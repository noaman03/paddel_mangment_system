import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/controller/filter_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

Future<void> showFiltersBottomSheet(BuildContext context) {
  final controller = CourtBrowseController.to;

  return showAppSheet<void>(
    context,
    title: 'Filters',
    subtitle: 'Price, court type and facilities',
    icon: Icons.tune_rounded,
    heightFactor: 0.85,
    actions: [
      TextButton(
        onPressed: controller.clearAllFilters,
        child: const Text('Clear all'),
      ),
    ],
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PriceSection(controller: controller),
          const SizedBox(height: ASizes.spaceBtwSections),
          _ChipSection(
            title: 'Court type',
            controller: controller,
            optionsBuilder: () => controller.filterController.courtTypes,
            isSelected: (value) =>
                controller.filterController.selectedCourtTypes.contains(value),
            onToggle: controller.toggleCourtType,
          ),
          const SizedBox(height: ASizes.spaceBtwSections),
          _ChipSection(
            title: 'Facilities',
            controller: controller,
            optionsBuilder: () => controller.filterController.facilities,
            isSelected: (value) =>
                controller.filterController.selectedFacilities.contains(value),
            onToggle: controller.toggleFacility,
          ),
          const SizedBox(height: ASizes.spaceBtwSections),
          _DistanceSection(controller: controller),
        ],
      ),
    ),
    footer: Builder(
      builder: (sheetContext) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(sheetContext),
          child: Obx(
            () => Text('Show ${controller.filteredCourtsCount} courts'),
          ),
        ),
      ),
    ),
  );
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
        ),
        const SizedBox(height: ASizes.spaceBtwItems),
        child,
      ],
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final filter = controller.filterController;

    return _SectionShell(
      title: 'Price per hour',
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
          border: Border.all(color: c.border),
        ),
        // Reads live inside this Obx so dragging the handles updates the labels.
        child: Obx(
          () => Column(
            children: [
              RangeSlider(
                values: RangeValues(
                  filter.minPrice.value,
                  filter.maxPrice.value,
                ),
                min: 0,
                max: FilterController.maxPriceLimit,
                divisions: 50,
                labels: RangeLabels(
                  'EGP ${filter.minPrice.value.round()}',
                  'EGP ${filter.maxPrice.value.round()}',
                ),
                onChanged: (values) =>
                    controller.updatePriceRange(values.start, values.end),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EGP ${filter.minPrice.value.round()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                  ),
                  Text(
                    filter.maxPrice.value >= FilterController.maxPriceLimit
                        ? 'Any'
                        : 'EGP ${filter.maxPrice.value.round()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.controller,
    required this.optionsBuilder,
    required this.isSelected,
    required this.onToggle,
  });

  final String title;
  final CourtBrowseController controller;
  final List<String> Function() optionsBuilder;
  final bool Function(String) isSelected;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return _SectionShell(
      title: title,
      child: Obx(() {
        final options = optionsBuilder();
        if (options.isEmpty) {
          return Text(
            'No options available',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.textSecondary),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final selected = isSelected(option);
            return FilterChip(
              label: Text(option),
              selected: selected,
              onSelected: (_) => onToggle(option),
              showCheckmark: false,
              avatar: selected
                  ? Icon(Icons.check_rounded,
                      size: 16, color: c.foregroundOn(AColors.primaryDeep))
                  : null,
              labelStyle: TextStyle(
                color: selected
                    ? c.foregroundOn(AColors.primaryDeep)
                    : c.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              // The deep brand green, not the accent: the selected label is
              // white and only reaches 1.91:1 on #1DD681.
              selectedColor: AColors.primaryDeep,
              backgroundColor: c.surfaceElevated,
              side: BorderSide(
                color: selected ? AColors.primaryDeep : c.border,
              ),
            );
          }).toList(),
        );
      }),
    );
  }
}

class _DistanceSection extends StatelessWidget {
  const _DistanceSection({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final location = controller.locationController;

    return Obx(() {
      if (!location.locationPermissionGranted.value) {
        return _SectionShell(
          title: 'Distance',
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.soft(AColors.info),
              borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
              border: Border.all(color: AColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: c.onSurfaceAccent(AColors.info)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Set your location from the Nearest button to filter by distance.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: c.onSurfaceAccent(AColors.info),
                          height: 1.3,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return _SectionShell(
        title: 'Maximum distance',
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          decoration: BoxDecoration(
            color: c.surfaceElevated,
            borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Within ${location.maxDistance.value.round()} km of ${location.currentLocation.value}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
              ),
              Slider(
                value: location.maxDistance.value,
                min: 1,
                max: 100,
                divisions: 99,
                label: '${location.maxDistance.value.round()} km',
                onChanged: controller.updateMaxDistance,
              ),
            ],
          ),
        ),
      );
    });
  }
}
