import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/court_details/court_details_screen.dart';
import 'package:padel_management_system/Features/players/reservations/my_reservations_screen.dart';
import 'package:padel_management_system/Models/booking_model.dart';
import 'package:padel_management_system/core/Service/reservations/reservation_store.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/utils/formatters/formatter.dart';

/// Horizontal carousel of the player's latest reservations on the home screen.
class RecentReservationsWidget extends StatelessWidget {
  const RecentReservationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final store = ReservationStore.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Reservations',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyReservationsScreen(),
                  ),
                ),
                style: TextButton.styleFrom(
                  // The plain brand green was ~1.9:1 on the white page.
                  foregroundColor: c.onSurfaceAccent(AColors.primaryDark),
                  backgroundColor: c.primarySoft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: ASizes.md,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: Obx(() {
            final bookings = store.recent(limit: 6);
            if (bookings.isEmpty) {
              return Center(
                child: Text(
                  'No recent reservations',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: c.textSecondary),
                ),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: bookings.length,
              itemBuilder: (context, index) =>
                  _ReservationCard(booking: bookings[index]),
            );
          }),
        ),
      ],
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final court = ReservationStore.courtFor(booking);
    final image = court?.image ?? booking.courtImage;
    final upcoming = booking.effectiveStatus == BookingStatus.confirmed;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
          onTap: () => _openCourt(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ASizes.cardRadiusLg),
                ),
                child: SizedBox(
                  height: 104,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (image.isEmpty)
                        const _CourtImageFallback()
                      else
                        Image.network(
                          image,
                          fit: BoxFit.cover,
                          // Demo images are remote: without these the offline
                          // build shows a red error box.
                          errorBuilder: (_, __, ___) =>
                              const _CourtImageFallback(),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const _CourtImageFallback(loading: true);
                          },
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.02),
                              Colors.black.withValues(alpha: 0.42),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: ASizes.sm,
                        bottom: ASizes.sm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ASizes.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius:
                                BorderRadius.circular(ASizes.borderRadiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sports_tennis_rounded,
                                size: 13,
                                color: AColors.primaryDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AFormatter.formatCurrency(booking.totalPrice),
                                style: const TextStyle(
                                  color: AColors.textprimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: ASizes.sm,
                        top: ASizes.sm,
                        child: _StatusBadge(status: booking.effectiveStatus),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    ASizes.sm,
                    ASizes.sm,
                    ASizes.sm,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.courtName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: ASizes.xs),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 13, color: c.textMuted),
                          const SizedBox(width: ASizes.xs),
                          Expanded(
                            child: Text(
                              booking.courtLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall
                                  ?.copyWith(color: c.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ASizes.xs),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 13, color: c.textMuted),
                          const SizedBox(width: ASizes.xs),
                          Expanded(
                            child: Text(
                              '${AFormatter.formatDayMonth(booking.bookingDate)} · '
                              '${Booking.formatTime(booking.startTime)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall
                                  ?.copyWith(color: c.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(ASizes.sm),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (upcoming) {
                        _openReservations(context);
                      } else {
                        _openCourt(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          upcoming ? c.surfaceElevated : AColors.primaryDark,
                      foregroundColor: upcoming ? c.textPrimary : Colors.white,
                      elevation: upcoming ? 0 : 1,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        side: upcoming
                            ? BorderSide(color: c.border)
                            : BorderSide.none,
                        borderRadius:
                            BorderRadius.circular(ASizes.borderRadiusMd),
                      ),
                    ),
                    icon: Icon(
                      upcoming
                          ? Icons.event_available_rounded
                          : Icons.refresh_rounded,
                      size: 16,
                    ),
                    label: Text(
                      upcoming ? 'View booking' : 'Rebook',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openReservations(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyReservationsScreen()),
    );
  }

  /// Opens the *real* court from the catalogue instead of synthesising one with
  /// an invented 250/hour price and a canned facilities list.
  void _openCourt(BuildContext context) {
    final court = ReservationStore.courtFor(booking);
    if (court == null) {
      AppFeedback.warning(
        'Court unavailable',
        '${booking.courtName} is no longer listed in the demo catalogue.',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourtDetailsScreen(court: court.toPadelCourt()),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final Color tone;
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.pending:
        tone = AColors.primaryDark;
        break;
      case BookingStatus.completed:
        tone = AColors.success;
        break;
      case BookingStatus.cancelled:
        tone = AColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(ASizes.borderRadiusSm),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Branded stand-in for a court photo that failed to load (or is still
/// loading) — the offline demo has no bundled court imagery.
class _CourtImageFallback extends StatelessWidget {
  const _CourtImageFallback({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF21D982), Color(0xFF078351)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -20,
            child: Icon(
              Icons.sports_tennis_rounded,
              size: 100,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Center(
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.sports_tennis_rounded,
                    size: 32,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
          ),
        ],
      ),
    );
  }
}
