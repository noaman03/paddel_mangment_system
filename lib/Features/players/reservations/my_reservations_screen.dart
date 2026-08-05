import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/court_details/court_details_screen.dart';
import 'package:padel_management_system/Models/booking_model.dart';
import 'package:padel_management_system/core/Service/reservations/reservation_store.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/utils/formatters/formatter.dart';
import 'package:padel_management_system/core/utils/helpers/pricing_calc.dart';

enum ReservationFilter { all, upcoming, completed, cancelled }

extension on ReservationFilter {
  String get label {
    switch (this) {
      case ReservationFilter.all:
        return 'All';
      case ReservationFilter.upcoming:
        return 'Upcoming';
      case ReservationFilter.completed:
        return 'Completed';
      case ReservationFilter.cancelled:
        return 'Cancelled';
    }
  }
}

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final ReservationStore _store = ReservationStore.to;
  ReservationFilter _filter = ReservationFilter.all;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Divider(height: 1, color: c.divider),
          Expanded(
            child: Obx(() {
              // Read the reactive list inside the Obx so cancelling or adding a
              // booking rebuilds this screen.
              final bookings = _apply(_store.all);
              if (bookings.isEmpty) return _buildEmptyState(context);
              return ListView.builder(
                padding: const EdgeInsets.all(ASizes.md),
                itemCount: bookings.length,
                itemBuilder: (context, index) => _ReservationCard(
                  booking: bookings[index],
                  onOpen: () => _openDetails(bookings[index]),
                  onCancel: () => _cancel(bookings[index]),
                  onRebook: () => _rebook(bookings[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final c = context.padel;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: ASizes.md,
        vertical: ASizes.sm,
      ),
      child: Row(
        children: ReservationFilter.values.map((filter) {
          final selected = filter == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: ASizes.sm),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: selected,
              onSelected: (_) => setState(() => _filter = filter),
              showCheckmark: false,
              selectedColor: c.primarySoft,
              side: BorderSide(
                color: selected ? AColors.primaryColor : c.border,
              ),
              labelStyle: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? c.onSurfaceAccent(AColors.primaryDark)
                    : c.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ASizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy_rounded,
                  size: ASizes.iconLg, color: c.textMuted),
            ),
            const SizedBox(height: ASizes.md),
            Text(
              _filter == ReservationFilter.all
                  ? 'No reservations yet'
                  : 'Nothing in "${_filter.label}"',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Book a court and it will show up here straight away.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  List<Booking> _apply(List<Booking> bookings) {
    switch (_filter) {
      case ReservationFilter.all:
        return bookings;
      case ReservationFilter.upcoming:
        return bookings
            .where((b) => b.effectiveStatus == BookingStatus.confirmed)
            .toList();
      case ReservationFilter.completed:
        return bookings
            .where((b) => b.effectiveStatus == BookingStatus.completed)
            .toList();
      case ReservationFilter.cancelled:
        return bookings
            .where((b) => b.effectiveStatus == BookingStatus.cancelled)
            .toList();
    }
  }

  // ------------------------------------------------------------------ actions

  Future<void> _cancel(Booking booking) async {
    final refund = PadelPricingCalc.calculateRefundAmount(
      originalPrice: booking.totalPrice,
      reservationTime: booking.startsAt,
      cancellationTime: DateTime.now(),
    );
    final policy = PadelPricingCalc.refundPolicyLabel(
      reservationTime: booking.startsAt,
      cancellationTime: DateTime.now(),
    );

    final confirmed = await AppFeedback.confirm(
      context,
      title: 'Cancel this booking?',
      message: '${booking.courtName} on '
          '${AFormatter.formatDayMonth(booking.bookingDate)} at '
          '${Booking.formatTime(booking.startTime)}.\n\n$policy — you would get '
          'back ${AFormatter.formatCurrency(refund)}.',
      confirmLabel: 'Cancel booking',
      cancelLabel: 'Keep it',
      icon: Icons.event_busy_rounded,
      destructive: true,
    );
    if (!confirmed) return;

    final refunded = _store.cancel(booking.id);
    AppFeedback.success(
      'Reservation cancelled',
      refunded > 0
          ? '${AFormatter.formatCurrency(refunded)} will be returned to your card.'
          : 'This slot was inside the no-refund window.',
    );
  }

  void _rebook(Booking booking) {
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

  String _durationLabel(Booking booking) {
    final hours = booking.durationInHours;
    if (hours == hours.roundToDouble()) {
      final whole = hours.round();
      return whole == 1 ? '1 hour' : '$whole hours';
    }
    return '${hours.toStringAsFixed(1)} hours';
  }

  void _openDetails(Booking booking) {
    final court = ReservationStore.courtFor(booking);
    final upcoming = booking.effectiveStatus == BookingStatus.confirmed;

    showAppSheet<void>(
      context,
      title: booking.courtName,
      subtitle: booking.courtLocation,
      icon: Icons.confirmation_number_outlined,
      heightFactor: 0.72,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          _StatusPill(status: booking.effectiveStatus),
          const SizedBox(height: ASizes.md),
          _SheetRow(
            label: 'Date',
            value: AFormatter.formatFullDate(booking.bookingDate),
          ),
          _SheetRow(label: 'Time', value: booking.timeRangeLabel),
          _SheetRow(label: 'Duration', value: _durationLabel(booking)),
          if (court != null)
            _SheetRow(
              label: 'Court rate',
              value: '${AFormatter.formatCurrency(court.pricePerHour)} / hour',
            ),
          _SheetRow(
            label: 'Booked on',
            value: AFormatter.formatFullDate(booking.createdAt),
          ),
          if (booking.notes != null && booking.notes!.isNotEmpty)
            _SheetRow(label: 'Notes', value: booking.notes!),
          _SheetRow(
            label: 'Total',
            value: AFormatter.formatCurrency(booking.totalPrice),
            emphasised: true,
          ),
          if (booking.effectiveStatus == BookingStatus.cancelled)
            _SheetRow(
              label: 'Refunded',
              value: AFormatter.formatCurrency(booking.refundAmount),
            ),
          if (upcoming) ...[
            const SizedBox(height: ASizes.sm),
            _PolicyNote(booking: booking),
          ],
          if (court != null) ...[
            const SizedBox(height: ASizes.md),
            Text(
              court.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.padel.textSecondary,
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _rebook(booking);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Book again'),
            ),
          ),
          if (upcoming) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.error,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _cancel(booking);
                },
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancel'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.booking,
    required this.onOpen,
    required this.onCancel,
    required this.onRebook,
  });

  final Booking booking;
  final VoidCallback onOpen;
  final VoidCallback onCancel;
  final VoidCallback onRebook;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final status = booking.effectiveStatus;
    final upcoming = status == BookingStatus.confirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: ASizes.md),
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
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(ASizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.courtName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(status: status),
                  ],
                ),
                const SizedBox(height: ASizes.sm),
                _IconLine(
                  icon: Icons.location_on,
                  text: booking.courtLocation,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _IconLine(
                        icon: Icons.calendar_today,
                        text: AFormatter.formatDayMonth(booking.bookingDate),
                      ),
                    ),
                    Expanded(
                      child: _IconLine(
                        icon: Icons.schedule,
                        text: booking.timeRangeLabel,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ASizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status == BookingStatus.cancelled ? 'Refunded' : 'Total',
                      style: text.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    Text(
                      AFormatter.formatCurrency(
                        status == BookingStatus.cancelled
                            ? booking.refundAmount
                            : booking.totalPrice,
                      ),
                      // Pale brand green on white was unreadable; this stays on
                      // brand while clearing 4.5:1 in both themes.
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: c.onSurfaceAccent(AColors.primaryDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ASizes.sm),
                Divider(height: 1, color: c.divider),
                const SizedBox(height: 4),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Details'),
                    ),
                    const Spacer(),
                    if (upcoming)
                      TextButton.icon(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: c.onSurfaceAccent(AColors.error),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Cancel'),
                      )
                    else
                      TextButton.icon(
                        onPressed: onRebook,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Book again'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    return Row(
      children: [
        Icon(icon, size: ASizes.iconSm, color: AColors.primaryColor),
        const SizedBox(width: ASizes.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final Color tone;
    switch (status) {
      case BookingStatus.confirmed:
      case BookingStatus.pending:
        tone = AColors.primaryColor;
        break;
      case BookingStatus.completed:
        tone = AColors.success;
        break;
      case BookingStatus.cancelled:
        tone = AColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ASizes.sm,
        vertical: ASizes.xs,
      ),
      decoration: BoxDecoration(
        color: c.soft(tone),
        borderRadius: BorderRadius.circular(ASizes.borderRadiusMd),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: c.onSurfaceAccent(tone),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: text.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  (emphasised ? text.titleMedium : text.bodyMedium)?.copyWith(
                fontWeight: emphasised ? FontWeight.w900 : FontWeight.w600,
                color: emphasised
                    ? c.onSurfaceAccent(AColors.primaryDark)
                    : c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyNote extends StatelessWidget {
  const _PolicyNote({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final now = DateTime.now();
    final refund = PadelPricingCalc.calculateRefundAmount(
      originalPrice: booking.totalPrice,
      reservationTime: booking.startsAt,
      cancellationTime: now,
    );

    return Container(
      padding: const EdgeInsets.all(ASizes.md),
      decoration: BoxDecoration(
        color: c.soft(AColors.info),
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 18, color: c.onSurfaceAccent(AColors.info)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${PadelPricingCalc.refundPolicyLabel(
                reservationTime: booking.startsAt,
                cancellationTime: now,
              )} — cancelling now returns '
              '${AFormatter.formatCurrency(refund)}.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.textSecondary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
