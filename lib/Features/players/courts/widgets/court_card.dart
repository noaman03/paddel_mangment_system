import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/court_details/court_details_screen.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_browser_controller.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';

/// A single court row in the browse list.
///
/// Tapping it opens the same [CourtDetailsScreen] the home screen uses, so the
/// app has one court-detail surface with a working date + slot + checkout flow.
class CourtCard extends StatelessWidget {
  const CourtCard({super.key, required this.court});

  final PadelCourt court;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final theme = Theme.of(context);
    final controller = CourtBrowseController.to;

    return Container(
      margin: const EdgeInsets.only(bottom: ASizes.spaceBtwItems),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourtDetailsScreen(court: court),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ASizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CourtThumbnail(court: court),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  size: 15, color: c.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  court.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: c.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EGP ${court.pricePerHour.round()}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: c.brandText,
                          ),
                        ),
                        Text(
                          'per hour',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: c.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 17, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      court.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    Text(
                      ' (${court.totalBookings})',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(width: 10),
                    _Pill(
                      label: controller.filterController
                          .getCourtTypeDisplayName(court.type),
                      color: AColors.primaryColor,
                    ),
                    const Spacer(),
                    if (court.distanceFromUser != null)
                      _Pill(
                        icon: Icons.near_me_rounded,
                        label: controller.locationController
                            .getFormattedDistance(court.distanceFromUser!),
                        color: AColors.info,
                      )
                    else
                      _Pill(
                        label: court.isActive ? 'Available' : 'Closed',
                        color: court.isActive ? AColors.success : AColors.error,
                      ),
                  ],
                ),
                if (court.facilities.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...court.facilities.take(3).map(
                            (facility) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: c.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                facility,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: c.textSecondary),
                              ),
                            ),
                          ),
                      if (court.facilities.length > 3)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Text(
                            '+${court.facilities.length - 3} more',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: c.brandText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                // Own Obx: this read must be tracked by *this* widget, an
                // ancestor Obx would not rebuild the card when a booking lands.
                Obx(() {
                  final count = controller.courtDataController
                      .bookingsForCourt(court.id)
                      .length;
                  if (count == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            size: 15,
                            color: c.onSurfaceAccent(AColors.success)),
                        const SizedBox(width: 6),
                        Text(
                          count == 1
                              ? 'You booked this court'
                              : 'You booked this court $count times',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: c.onSurfaceAccent(AColors.success),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourtThumbnail extends StatelessWidget {
  const _CourtThumbnail({required this.court});

  final PadelCourt court;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.sports_tennis, color: Colors.white, size: 28);

    return Container(
      width: 62,
      height: 62,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AColors.brandGradient,
        ),
      ),
      child: court.photos.isEmpty
          ? const Center(child: fallback)
          : Image.network(
              court.photos.first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: fallback),
            ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.soft(color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: c.onSurfaceAccent(color)),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: c.onSurfaceAccent(color),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
