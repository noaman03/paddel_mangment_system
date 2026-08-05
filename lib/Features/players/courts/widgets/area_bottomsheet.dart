import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

Future<void> showAreasBottomSheet(BuildContext context) async {
  final controller = CourtBrowseController.to;
  final searchController = TextEditingController(
    text: controller.areaController.searchQuery.value,
  );

  await showAppSheet<void>(
    context,
    title: 'Areas',
    subtitle: 'Browse courts by neighbourhood',
    icon: Icons.location_on_rounded,
    heightFactor: 0.82,
    actions: [
      TextButton(
        onPressed: () {
          searchController.clear();
          controller.areaController.resetSearch();
          controller.clearAreaFilter();
        },
        child: const Text('Clear'),
      ),
    ],
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            controller: searchController,
            onChanged: controller.searchAreas,
            decoration: const InputDecoration(
              hintText: 'Search areas...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
        ),
        Expanded(child: _AreaList(controller: controller)),
      ],
    ),
  );

  searchController.dispose();
  controller.areaController.resetSearch();
}

class _AreaList extends StatelessWidget {
  const _AreaList({required this.controller});

  final CourtBrowseController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Obx(() {
      final areas = controller.areaController.filteredAreas.toList();
      // Read inside the Obx closure: `itemBuilder` runs lazily during layout,
      // so a read in there would never be tracked.
      final selected = controller.filterController.selectedArea.value;

      if (areas.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No area matches that search.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: c.textSecondary),
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
        itemCount: areas.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (listContext, index) {
          if (index == 0) {
            return _AreaTile(
              name: 'All areas',
              subtitle:
                  '${controller.courtDataController.allCourts.length} courts in total',
              icon: Icons.public_rounded,
              isSelected: selected.isEmpty,
              onTap: () {
                controller.clearAreaFilter();
                Navigator.pop(listContext);
              },
            );
          }

          final area = areas[index - 1];
          return _AreaTile(
            name: area.name,
            subtitle: area.courtCount == 1
                ? '1 court available'
                : '${area.courtCount} courts available',
            icon: Icons.location_city_rounded,
            isSelected: selected == area.name,
            enabled: area.courtCount > 0,
            onTap: () {
              if (area.courtCount == 0) {
                AppFeedback.info(
                  area.name,
                  'No courts listed in this area yet.',
                );
                return;
              }
              controller.selectArea(area.name);
              Navigator.pop(listContext);
            },
          );
        },
      );
    });
  }
}

class _AreaTile extends StatelessWidget {
  const _AreaTile({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.enabled = true,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? c.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected ? AColors.primaryDeep : c.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? c.foregroundOn(AColors.primaryDeep)
                      : (enabled ? c.brandText : c.textMuted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: enabled ? c.textPrimary : c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.chevron_right,
                size: isSelected ? 22 : 20,
                color: isSelected ? c.brandText : c.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
