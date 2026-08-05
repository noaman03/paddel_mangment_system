import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Features/players/courts/controller/location_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// "Nearest" sheet.
///
/// Every reactive read below lives inside an `Obx` that belongs to the widget
/// doing the reading — the previous version read `maxDistance.value` and
/// `currentLocation.value` in child `build()` methods, outside the ancestor
/// `Obx`, so the slider snapped back and the address never refreshed.
Future<void> showNearestBottomSheet(BuildContext context) {
  final controller = CourtBrowseController.to;

  return showAppSheet<void>(
    context,
    title: 'Nearest courts',
    subtitle: 'Sort and filter the list by distance',
    icon: Icons.my_location_rounded,
    heightFactor: 0.88,
    actions: [
      TextButton(
        // Stays open on purpose so the (now reactive) slider and location card
        // visibly reset. Resetting the radius alone used to *narrow* the search
        // for anyone who had widened it past 50 km while leaving the location —
        // and so the distance filter — in place.
        onPressed: () => _clearLocation(controller),
        child: const Text('Reset'),
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        _LocationCard(controller: controller),
        const SizedBox(height: ASizes.spaceBtwItems),
        _AreaPicker(controller: controller),
        const SizedBox(height: ASizes.spaceBtwItems),
        _DistanceSection(controller: controller),
        const SizedBox(height: ASizes.spaceBtwItems),
        _NearestPreview(controller: controller),
      ],
    ),
    footer: Builder(
      builder: (sheetContext) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(sheetContext),
          child: Obx(
            () => Text(
              controller.hasLocation
                  ? 'Show ${controller.filteredCourtsCount} courts nearby'
                  : 'Show ${controller.filteredCourtsCount} courts',
            ),
          ),
        ),
      ),
    ),
  );
}

/// The undo for a location: shared by "Reset", the "Clear location" button and
/// tapping the already-selected area chip.
void _clearLocation(CourtBrowseController controller) {
  controller.clearLocationFilter();
  AppFeedback.info('Location cleared', 'Courts are sorted by rating again');
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);
    final location = controller.locationController;

    return Obx(() {
      final hasLocation = location.locationPermissionGranted.value;
      final busy = location.isRequestingPermission.value;
      final accent = hasLocation ? AColors.success : AColors.warning;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.soft(accent),
          borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(location.locationStatusIcon,
                    color: c.onSurfaceAccent(accent)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasLocation ? 'Searching from' : 'Location not set',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: c.onSurfaceAccent(accent),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        // Without a location the heading above already says
                        // "Location not set"; repeating it here read as a bug.
                        hasLocation
                            ? location.locationStatusText
                            : 'Pick a starting point below to sort by distance.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      if (location.usingPickedArea.value) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Demo location — picked from the list below',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (location.statusMessage.value.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                location.statusMessage.value,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: c.textSecondary, height: 1.3),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: busy ? null : location.requestLocationPermission,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                    label: Text(
                      busy
                          ? 'Locating...'
                          : (hasLocation
                              ? 'Use my real location'
                              : 'Use my location'),
                    ),
                  ),
                ),
                if (location.permissionBlocked.value) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: location.openLocationSettings,
                    child: const Text('Settings'),
                  ),
                ],
              ],
            ),
            // The only control that can take the app back out of "nearest"
            // mode once a location has been set.
            if (hasLocation)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _clearLocation(controller),
                  icon: const Icon(Icons.location_off_rounded, size: 18),
                  label: const Text('Clear location'),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _AreaPicker extends StatelessWidget {
  const _AreaPicker({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);
    final location = controller.locationController;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Or search from an area',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Device location is unavailable on some platforms — pick a starting '
            'point and distance sorting works right away.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: c.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LocationController.demoAreas.map((area) {
                final selected = location.isSelectedArea(area);
                return ChoiceChip(
                  label: Text(area.name),
                  selected: selected,
                  showCheckmark: false,
                  // Tapping the selected chip clears the location — it used to
                  // re-apply the same area and re-fire the toast, which read as
                  // a dead control and left no way out of "nearest" mode.
                  onSelected: (_) => selected
                      ? _clearLocation(controller)
                      : location.useDemoArea(area),
                  labelStyle: TextStyle(
                    color: selected
                        ? c.foregroundOn(AColors.primaryDeep)
                        : c.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  selectedColor: AColors.primaryDeep,
                  backgroundColor: c.surface,
                  side: BorderSide(
                    color: selected ? AColors.primaryDeep : c.border,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceSection extends StatelessWidget {
  const _DistanceSection({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);
    final location = controller.locationController;

    return Obx(() {
      if (!location.locationPermissionGranted.value) {
        return const SizedBox.shrink();
      }

      final distance = location.maxDistance.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search distance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Within ${distance.round()} km',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: c.brandText,
                    ),
                  ),
                ),
                Text(
                  '${controller.nearbyCourtsCount} courts found',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
            Slider(
              value: distance,
              min: 1,
              max: 100,
              divisions: 99,
              label: '${distance.round()} km',
              onChanged: controller.updateMaxDistance,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 km',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary)),
                  Text('100 km',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _NearestPreview extends StatelessWidget {
  const _NearestPreview({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);

    return Obx(() {
      if (!controller.hasLocation) return const SizedBox.shrink();

      final nearest = controller.nearbyCourts.take(3).toList();
      if (nearest.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.soft(AColors.warning),
            borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
          ),
          child: Text(
            'No courts within ${controller.locationController.maxDistance.value.round()} km. Widen the search distance.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: c.onSurfaceAccent(AColors.warning),
              height: 1.3,
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Closest to you',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...nearest.map(
            (court) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: c.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(Icons.sports_tennis, size: 17, color: c.brandText),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          court.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: c.textPrimary,
                          ),
                        ),
                        Text(
                          court.location,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    controller.locationController
                        .getFormattedDistance(court.distanceFromUser ?? 0),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: c.brandText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
