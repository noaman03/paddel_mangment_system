import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/players/checkout/checkout_screen.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_data_controller.dart';
import 'package:padel_management_system/Features/players/courts/data/court_booking.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/core/Service/reservations/reservation_store.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/utils/formatters/formatter.dart';

/// One bookable hour in the slot grid.
///
/// Named `_SlotOption` (not `TimeSlot`) so it cannot shadow the `TimeSlot`
/// declared in `Models/padel_court.dart`, which this file also imports.
class _SlotOption {
  const _SlotOption({required this.label, required this.price});

  final String label;
  final double price;
}

class CourtDetailsScreen extends ConsumerStatefulWidget {
  final PadelCourt court;

  const CourtDetailsScreen({super.key, required this.court});

  @override
  ConsumerState<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends ConsumerState<CourtDetailsScreen> {
  late final CourtDataController _courtData;
  late DateTime _selectedDate;
  String? _selectedSlot;
  int _currentImageIndex = 0;

  /// Listens for the reservation checkout writes, so the slot is only marked
  /// booked once payment actually completes. Held as a field so it cannot
  /// outlive the screen when the route is torn down mid-checkout.
  Worker? _paymentWatcher;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // Shared in-memory booking store: this screen is reachable from Home as
    // well as from the Courts tab, so the controller may not exist yet.
    _courtData = Get.isRegistered<CourtDataController>()
        ? Get.find<CourtDataController>()
        : Get.put(CourtDataController());
  }

  @override
  void dispose() {
    _paymentWatcher?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final court = widget.court;
    final slots = _generateSlots();

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(court.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGallery(context, court),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, court),
                  const SizedBox(height: 20),
                  _buildPriceCard(context, court),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Description'),
                  const SizedBox(height: 8),
                  Text(
                    court.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: c.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Facilities'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: court.facilities
                        .map((facility) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: c.primarySoft,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AColors.primaryColor
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                facility,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      c.onSurfaceAccent(AColors.primaryColor),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(context, 'Select date & time'),
                  const SizedBox(height: 14),
                  _buildDateStrip(context),
                  const SizedBox(height: 20),
                  _buildSlotGrid(context, slots),
                  const SizedBox(height: 28),
                  _buildCta(context, slots),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ pieces

  Widget _buildGallery(BuildContext context, PadelCourt court) {
    final c = context.padel;

    return Stack(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: court.photos.isNotEmpty
              ? PageView.builder(
                  onPageChanged: (index) =>
                      setState(() => _currentImageIndex = index),
                  itemCount: court.photos.length,
                  itemBuilder: (_, index) => Image.network(
                    court.photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _galleryFallback(c),
                  ),
                )
              : _galleryFallback(c),
        ),
        if (court.photos.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                court.photos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentImageIndex == index ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentImageIndex == index
                        ? AColors.primaryColor
                        : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _galleryFallback(PadelPalette c) => Container(
        color: c.surfaceElevated,
        child: Icon(Icons.sports_tennis, size: 54, color: c.textMuted),
      );

  Widget _buildHeader(BuildContext context, PadelCourt court) {
    final c = context.padel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                court.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: c.brandText),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      court.location,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: c.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 18, color: c.brandText),
              const SizedBox(width: 4),
              Text(
                court.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: c.onSurfaceAccent(AColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(BuildContext context, PadelCourt court) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Price per hour',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: c.textSecondary),
          ),
          Text(
            AFormatter.formatCurrency(court.pricePerHour),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: c.brandText,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
      );

  Widget _buildDateStrip(BuildContext context) {
    final c = context.padel;
    // The selected day is a filled brand surface carrying white text, so it is
    // painted with the deep green (4.55:1) rather than the accent (1.91:1).
    const selectedFill = AColors.primaryDeep;
    final selectedText = c.foregroundOn(selectedFill);

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(_selectedDate, date);

          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = date;
              _selectedSlot = null; // availability differs per day
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 62,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? selectedFill : c.surface,
                border: Border.all(
                  color: isSelected ? selectedFill : c.border,
                ),
                borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? selectedText : c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? selectedText : c.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(date),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? selectedText.withValues(alpha: 0.8)
                          : c.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotGrid(BuildContext context, List<_SlotOption> slots) {
    final c = context.padel;

    if (slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.soft(AColors.warning),
          borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        ),
        child: Text(
          'No slots left today. Pick another date to keep booking.',
          style: TextStyle(color: c.onSurfaceAccent(AColors.warning)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available time slots',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: 10),
        // Obx: booked slots come from the shared in-memory store, so the grid
        // has to rebuild when a booking is made.
        Obx(() {
          // Read the bookings here, inside the Obx closure: `itemBuilder` runs
          // lazily during layout, so a read in there would not be tracked.
          final bookedKeys = _courtData.bookings
              .where((booking) => booking.courtId == widget.court.id)
              .map((booking) => booking.slotKey)
              .toSet();

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: slots.length,
            itemBuilder: (_, index) {
              final slot = slots[index];
              final booked = bookedKeys.contains(
                CourtBooking.slotKeyFor(
                  widget.court.id,
                  _selectedDate,
                  slot.label,
                ),
              );
              final isSelected = _selectedSlot == slot.label && !booked;

              final Color background = isSelected
                  ? AColors.primaryDeep
                  : (booked ? c.soft(AColors.error) : c.surface);
              final Color borderColor = isSelected
                  ? AColors.primaryDeep
                  : (booked ? AColors.error.withValues(alpha: 0.35) : c.border);
              // The old grid hardcoded black labels on a near-black scaffold,
              // which made every slot invisible (and unbookable) in dark mode.
              final Color labelColor = isSelected
                  ? c.foregroundOn(background)
                  : (booked ? c.onSurfaceAccent(AColors.error) : c.textPrimary);

              return GestureDetector(
                onTap: booked
                    ? () => AppFeedback.info(
                          'Slot taken',
                          '${slot.label} is already booked on this court.',
                        )
                    : () => setState(() => _selectedSlot = slot.label),
                child: Container(
                  decoration: BoxDecoration(
                    color: background,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(ASizes.cardRadiusSm),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slot.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booked
                              ? 'Booked'
                              : AFormatter.formatCurrency(slot.price),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? c.foregroundOn(background)
                                : (booked
                                    ? c.onSurfaceAccent(AColors.error)
                                    : c.brandText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildCta(BuildContext context, List<_SlotOption> slots) {
    final c = context.padel;
    final hasSlot = _selectedSlot != null;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: hasSlot ? _confirmBooking : null,
            icon: const Icon(Icons.event_available_rounded, size: 20),
            label: Text(
              hasSlot
                  ? 'Book ${DateFormat('EEE d MMM').format(_selectedDate)} · $_selectedSlot'
                  : 'Select a time slot',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: AColors.primaryDeep,
              foregroundColor: c.foregroundOn(AColors.primaryDeep),
              disabledBackgroundColor: c.surfaceElevated,
              disabledForegroundColor: c.textMuted,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        if (!hasSlot && slots.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Pick one of the slots above to continue',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.textMuted),
          ),
        ],
      ],
    );
  }

  // ----------------------------------------------------------------- booking

  Future<void> _confirmBooking() async {
    final slotLabel = _selectedSlot;
    if (slotLabel == null) return;

    final court = widget.court;
    final dateLabel = DateFormat('EEEE d MMM').format(_selectedDate);

    final confirmed = await AppFeedback.confirm(
      context,
      title: 'Confirm booking',
      message: '${court.name}\n$dateLabel at $slotLabel\n'
          '${AFormatter.formatCurrency(court.pricePerHour)} per hour',
      confirmLabel: 'Confirm & pay',
      icon: Icons.event_available_rounded,
    );
    if (!confirmed || !mounted) return;

    // Nothing is committed yet: checkout owns the reservation, and cancelling
    // there (or never ticking the terms box) must leave the slot free. Booking
    // here first used to mark the slot "Booked" forever and inflate the court's
    // counter for a reservation that was never paid for and never existed in
    // "My Reservations".
    final store = ReservationStore.to;
    final knownIds = store.bookings.map((booking) => booking.id).toSet();
    var committed = false;

    void commitIfPaid() {
      if (committed) return;
      // Checkout is the only thing that can add a reservation from here, so a
      // new entry means the payment step completed.
      if (!store.bookings.any((booking) => !knownIds.contains(booking.id))) {
        return;
      }
      committed = true;
      _courtData.bookCourt(
        court: court,
        date: _selectedDate,
        timeLabel: slotLabel,
      );
      if (mounted) setState(() => _selectedSlot = null);
    }

    // Watched rather than checked only on return: the receipt's "View my
    // reservations" replaces the checkout route, so this screen may not be
    // resumed for a long time — or at all.
    _paymentWatcher?.dispose();
    _paymentWatcher = ever(store.bookings, (_) => commitIfPaid());

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          courtName: court.name,
          courtLocation: court.location,
          selectedDate: _selectedDate,
          timeSlot: slotLabel,
          pricePerHour: court.pricePerHour,
        ),
      ),
    );

    _paymentWatcher?.dispose();
    _paymentWatcher = null;
    commitIfPaid();
  }

  /// 08:00 – 23:00, minus hours that have already passed when the selected day
  /// is today. The old version started at 12 and hardcoded every slot as
  /// available, so mornings were missing and past hours looked bookable.
  List<_SlotOption> _generateSlots() {
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(_selectedDate, now);
    final slots = <_SlotOption>[];

    for (int hour = 8; hour <= 23; hour++) {
      if (isToday && hour <= now.hour) continue;
      final period = hour < 12 ? 'AM' : 'PM';
      final display = hour % 12 == 0 ? 12 : hour % 12;
      slots.add(_SlotOption(
        label: '$display:00 $period',
        price: widget.court.pricePerHour,
      ));
    }
    return slots;
  }
}
