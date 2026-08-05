import 'package:flutter/material.dart';
import 'package:padel_management_system/Features/players/reservations/my_reservations_screen.dart';
import 'package:padel_management_system/Models/booking_model.dart';
import 'package:padel_management_system/core/Service/reservations/reservation_store.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';
import 'package:padel_management_system/core/utils/formatters/formatter.dart';
import 'package:padel_management_system/core/utils/helpers/pricing_calc.dart';

class CheckoutScreen extends StatefulWidget {
  final String courtName;
  final String courtLocation;
  final DateTime selectedDate;
  final String timeSlot;
  final double pricePerHour;
  final String? notes;
  final String? courtId;
  final String? courtImage;

  const CheckoutScreen({
    super.key,
    required this.courtName,
    required this.courtLocation,
    required this.selectedDate,
    required this.timeSlot,
    required this.pricePerHour,
    this.notes,
    this.courtId,
    this.courtImage,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;
  bool _agreedToTerms = false;

  /// Set once the local payment completes — the screen then renders a receipt
  /// instead of the order form.
  Booking? _receipt;

  late final TimeOfDay _startTime = _parseSlotStart(widget.timeSlot);
  late final TimeOfDay _endTime = TimeOfDay(
    hour: (_startTime.hour + 1) % 24,
    minute: _startTime.minute,
  );

  DateTime get _reservationTime => DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

  Map<String, double> get _breakdown =>
      PadelPricingCalc.calculatePriceBreakdown(
        basePricePerHour: widget.pricePerHour,
        durationInHours: 1,
        reservationTime: _reservationTime,
        location: PadelPricingCalc.locationKeyFor(widget.courtLocation),
      );

  double get _subtotal => _breakdown['totalPrice'] ?? widget.pricePerHour;

  double get _serviceFee => PadelPricingCalc.calculateServiceFee(_subtotal);

  double get _total => _subtotal + _serviceFee;

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    return Scaffold(
      appBar: AppBar(
        title: Text(receipt == null ? 'Checkout' : 'Receipt'),
        centerTitle: true,
        automaticallyImplyLeading: receipt == null,
      ),
      body: receipt == null
          ? _buildOrderForm(context)
          : _buildReceipt(context, receipt),
    );
  }

  // ---------------------------------------------------------------- order form

  Widget _buildOrderForm(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final breakdown = _breakdown;
    final peak = breakdown['peakHourSurcharge'] ?? 0;
    final location = breakdown['locationSurcharge'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order summary header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
              border: Border.all(
                color: AColors.primaryColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.soft(AColors.primaryColor),
                    borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
                  ),
                  child: const Icon(Icons.receipt_long,
                      color: AColors.primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order summary',
                        style: text.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Review your booking before paying',
                        style: text.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Booking details',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.sports_tennis,
            label: 'Court',
            value: widget.courtName,
          ),
          _DetailRow(
            icon: Icons.location_on,
            label: 'Location',
            value: widget.courtLocation,
          ),
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: AFormatter.formatFullDate(widget.selectedDate),
          ),
          _DetailRow(
            icon: Icons.access_time,
            label: 'Time',
            value: '${Booking.formatTime(_startTime)} - '
                '${Booking.formatTime(_endTime)}',
          ),
          if (widget.notes != null && widget.notes!.trim().isNotEmpty)
            _DetailRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notes',
              value: widget.notes!.trim(),
            ),
          const SizedBox(height: 24),

          // Price breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                _PriceRow(
                  label: 'Court fee (1 hour)',
                  amount: breakdown['basePrice'] ?? widget.pricePerHour,
                ),
                if (peak.abs() >= 0.01) ...[
                  const SizedBox(height: 10),
                  _PriceRow(
                    label: PadelPricingCalc.isPeak(_reservationTime)
                        ? 'Peak-hour surcharge'
                        : 'Off-peak adjustment',
                    amount: peak,
                    subtle: true,
                  ),
                ],
                if (location.abs() >= 0.01) ...[
                  const SizedBox(height: 10),
                  _PriceRow(
                    label: location > 0
                        ? 'Prime location premium'
                        : 'Community court discount',
                    amount: location,
                    subtle: true,
                  ),
                ],
                const SizedBox(height: 10),
                _PriceRow(
                  label:
                      'Service fee & VAT (${(PadelPricingCalc.serviceFeeRate * 100).round()}%)',
                  amount: _serviceFee,
                  subtle: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: c.divider),
                ),
                _PriceRow(label: 'Total', amount: _total, emphasised: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Payment method',
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: AColors.primaryColor),
              borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(ASizes.cardRadiusXs),
                  ),
                  child: const Icon(Icons.credit_card,
                      color: AColors.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit / debit card',
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '**** **** **** 4242',
                        style: text.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle, color: AColors.primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Terms — the payment button stays disabled until this is ticked.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: _isProcessing
                    ? null
                    : (value) =>
                        setState(() => _agreedToTerms = value ?? false),
                activeColor: AColors.primaryColor,
              ),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('I agree to the ', style: text.bodySmall),
                    GestureDetector(
                      onTap: _showTerms,
                      child: Text(
                        'Terms and Conditions',
                        style: text.bodySmall?.copyWith(
                          color: c.onSurfaceAccent(AColors.primaryDark),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              c.onSurfaceAccent(AColors.primaryDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Kept non-null while processing so the button keeps its brand
              // fill instead of turning into a grey slab with a white spinner.
              onPressed: _processCheckout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    _agreedToTerms ? AColors.primaryDark : c.surfaceElevated,
                foregroundColor: _agreedToTerms ? Colors.white : c.textMuted,
                elevation: _agreedToTerms ? 2 : 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Complete payment · ${AFormatter.formatCurrency(_total)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              // Disabled during processing: popping mid-payment used to leave a
              // pending callback that called setState after dispose.
              onPressed: _isProcessing ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                foregroundColor: c.textPrimary,
                side: BorderSide(color: c.border),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ receipt

  Widget _buildReceipt(BuildContext context, Booking booking) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: c.soft(AColors.success),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded,
                  size: 44, color: c.onSurfaceAccent(AColors.success)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Booking confirmed',
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${booking.courtName} is reserved for you.',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
              border: Border.all(color: c.border),
              boxShadow: [
                BoxShadow(
                    color: c.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              children: [
                _ReceiptRow(label: 'Reference', value: _reference(booking.id)),
                _ReceiptRow(label: 'Court', value: booking.courtName),
                _ReceiptRow(label: 'Location', value: booking.courtLocation),
                _ReceiptRow(
                  label: 'Date',
                  value: AFormatter.formatFullDate(booking.bookingDate),
                ),
                _ReceiptRow(label: 'Time', value: booking.timeRangeLabel),
                if (booking.notes != null && booking.notes!.isNotEmpty)
                  _ReceiptRow(label: 'Notes', value: booking.notes!),
                const _ReceiptRow(label: 'Paid with', value: 'Card •••• 4242'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: c.divider),
                ),
                _PriceRow(
                  label: 'Total paid',
                  amount: booking.totalPrice,
                  emphasised: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyReservationsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: AColors.primaryDark,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.event_available_rounded, size: 20),
            label: const Text(
              'View my reservations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: c.textPrimary,
              side: BorderSide(color: c.border),
            ),
            child: const Text('Back to court'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _reference(String id) {
    final digits = id.replaceAll(RegExp(r'[^0-9]'), '');
    final tail = digits.length >= 6
        ? digits.substring(digits.length - 6)
        : digits.padLeft(6, '0');
    return 'PDL-$tail';
  }

  // ------------------------------------------------------------------ actions

  Future<void> _processCheckout() async {
    if (_isProcessing) return;
    if (!_agreedToTerms) {
      AppFeedback.warning(
        'Accept the terms first',
        'Tick "I agree to the Terms and Conditions" to continue.',
      );
      return;
    }

    setState(() => _isProcessing = true);

    // Local-only "payment": there is no backend in this build, so nothing here
    // may await a network round trip.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final store = ReservationStore.to;
    final booking = Booking(
      id: store.newId(),
      userId: SessionController.to.email.isEmpty
          ? 'demo-player'
          : SessionController.to.email,
      courtId: widget.courtId ??
          ReservationStore.catalogue
              .firstWhere(
                (court) =>
                    court.name.toLowerCase() == widget.courtName.toLowerCase(),
                orElse: () => ReservationStore.catalogue.first,
              )
              .id,
      courtName: widget.courtName,
      courtLocation: widget.courtLocation,
      courtImage: widget.courtImage ?? '',
      bookingDate: widget.selectedDate,
      startTime: _startTime,
      endTime: _endTime,
      totalPrice: _total,
      status: BookingStatus.confirmed,
      notes: widget.notes,
      createdAt: DateTime.now(),
    );
    store.add(booking);

    setState(() {
      _isProcessing = false;
      _receipt = booking;
    });

    AppFeedback.success(
      'Payment successful',
      '${booking.courtName} · ${AFormatter.formatDayMonth(booking.bookingDate)} at ${Booking.formatTime(booking.startTime)}',
    );
  }

  void _showTerms() {
    showAppSheet<void>(
      context,
      title: 'Terms and Conditions',
      subtitle: 'Padelit booking policy',
      icon: Icons.gavel_rounded,
      heightFactor: 0.7,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: const [
          _TermsSection(
            title: '1. Court reservations',
            body: 'A slot is held for you from the moment payment completes. '
                'Please arrive 10 minutes early; courts are released to the '
                'waiting list 15 minutes after the start time.',
          ),
          _TermsSection(
            title: '2. Cancellations and refunds',
            body: 'Cancel 24 hours or more before the slot for a full refund, '
                '12-24 hours before for 75%, and 2-12 hours before for 50%. '
                'Cancellations inside 2 hours are not refundable.',
          ),
          _TermsSection(
            title: '3. Pricing',
            body: 'Prices are in Egyptian pounds and include a service fee and '
                'VAT. Peak hours (weekday evenings and weekends) and prime '
                'locations carry the surcharges shown in the breakdown.',
          ),
          _TermsSection(
            title: '4. Conduct',
            body: 'Non-marking shoes are required on all courts. Clubs may '
                'refuse entry for unsafe conduct without a refund.',
          ),
          _TermsSection(
            title: '5. Demo notice',
            body:
                'This is a portfolio build: payments are simulated locally and '
                'no card is ever charged.',
          ),
        ],
      ),
    );
  }

  /// Tolerates '5:00 PM', '17:00' and '5:00 PM - 6:00 PM'.
  static TimeOfDay _parseSlotStart(String slot) {
    final match =
        RegExp(r'(\d{1,2})(?::(\d{2}))?\s*([AaPp][Mm])?').firstMatch(slot);
    if (match == null) return const TimeOfDay(hour: 12, minute: 0);
    var hour = int.tryParse(match.group(1) ?? '') ?? 12;
    final minute = int.tryParse(match.group(2) ?? '') ?? 0;
    final meridiem = match.group(3)?.toUpperCase();
    if (meridiem == 'PM' && hour < 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusXs),
            ),
            child: Icon(icon, color: AColors.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.bodySmall?.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.amount,
    this.subtle = false,
    this.emphasised = false,
  });

  final String label;
  final double amount;
  final bool subtle;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;
    final style = (emphasised ? text.titleMedium : text.bodyMedium)?.copyWith(
      fontWeight: emphasised ? FontWeight.w800 : FontWeight.w500,
      color: subtle ? c.textSecondary : c.textPrimary,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Text(
          // Amounts used to be pale brand green on a near-white panel (~1.9:1).
          '${amount < 0 ? '-' : ''}${AFormatter.formatCurrency(amount.abs())}',
          style: style?.copyWith(
            color: emphasised
                ? c.onSurfaceAccent(AColors.primaryDark)
                : (subtle ? c.textSecondary : c.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style:
                text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
