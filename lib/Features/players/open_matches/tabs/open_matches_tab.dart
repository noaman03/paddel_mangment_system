import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/open_matches/widgets/open_match_card.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

class OpenMatchesTab extends StatelessWidget {
  const OpenMatchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OpenMatchesController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ASizes.paddingSm),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => _FilterDropdown(
                    icon: Icons.style_rounded,
                    value: controller.selectedMatchType.value,
                    items: controller.matchTypes,
                    onChanged: controller.updateMatchType,
                  ),
                ),
              ),
              const SizedBox(width: ASizes.paddingSm),
              Expanded(
                child: Obx(
                  () => _FilterDropdown(
                    icon: Icons.bar_chart_rounded,
                    value: controller.selectedSkillLevel.value,
                    items: controller.skillLevels,
                    onChanged: controller.updateSkillLevel,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(
            () => controller.filteredMatches.isEmpty
                // hasActiveFilters is read here, lexically inside the Obx
                // builder, so the empty state tracks the filter Rx values.
                ? _NoMatches(
                    hasActiveFilters: controller.hasActiveFilters,
                    onClearFilters: controller.clearFilters,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: ASizes.paddingSm,
                      bottom: ASizes.paddingLg,
                    ),
                    itemCount: controller.filteredMatches.length,
                    itemBuilder: (_, index) => OpenMatchCard(
                      match: controller.filteredMatches[index],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final bool isActive = value != 'All';

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? c.primarySoft : c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AColors.primaryColor.withValues(alpha: 0.45)
              : c.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? c.brandText : c.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                // Without isExpanded the button sizes to its widest item and
                // overflows the Expanded on small screens.
                isExpanded: true,
                borderRadius: BorderRadius.circular(14),
                icon: Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: c.textSecondary,
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive ? c.onSurfaceAccent(c.primary) : null,
                    ),
                items: items
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (selected) {
                  if (selected != null) onChanged(selected);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

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
                Icons.sports_tennis_rounded,
                size: 52,
                color: c.textMuted,
              ),
            ),
            const SizedBox(height: ASizes.spaceBtwItems),
            Text(
              'No matches found',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              hasActiveFilters
                  ? 'Nothing matches your current search and filters.'
                  : 'Be the first to open a match — try the Create Match tab.',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: c.textSecondary),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: ASizes.spaceBtwItems),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
