import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Models/booking_model.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/core/const/court_images.dart';
import 'package:padel_management_system/core/utils/helpers/pricing_calc.dart';

/// A club in the offline demo catalogue.
///
/// Recent-reservation cards used to synthesise a `PadelCourt` with a hardcoded
/// 250/hour price and a canned facilities list, so every card opened the same
/// invented venue. The catalogue below is the single source of truth instead.
class DemoCourt {
  const DemoCourt({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.image,
    required this.pricePerHour,
    required this.facilities,
    this.type = CourtType.indoor,
    this.rating = 4.6,
    this.totalBookings = 120,
  });

  final String id;
  final String name;
  final String location;
  final String description;
  final String image;
  final double pricePerHour;
  final List<String> facilities;
  final CourtType type;
  final double rating;
  final int totalBookings;

  PadelCourt toPadelCourt() => PadelCourt(
        id: id,
        name: name,
        location: location,
        description: description,
        pricePerHour: pricePerHour,
        photos: [image],
        facilities: facilities,
        type: type,
        rating: rating,
        totalBookings: totalBookings,
        createdAt: DateTime(2024, 1, 1),
      );
}

/// In-memory reservation repository shared by checkout, "My Reservations" and
/// the home-screen carousel.
///
/// This build has no backend, so a booking made at checkout has to land
/// somewhere the other screens read — otherwise the app shows "Booking
/// Confirmed!" and then an unchanged reservations list. Everything here is
/// process-local and reactive: mutate [bookings] and every `Obx` updates.
class ReservationStore extends GetxController {
  /// Registered lazily so no screen depends on main.dart wiring it up.
  static ReservationStore get to => Get.isRegistered<ReservationStore>()
      ? Get.find<ReservationStore>()
      : Get.put(ReservationStore(), permanent: true);

  ReservationStore() {
    bookings.assignAll(_seedBookings());
  }

  final RxList<Booking> bookings = <Booking>[].obs;

  int _sequence = 0;

  static const List<DemoCourt> catalogue = [
    DemoCourt(
      id: 'al-noor',
      name: 'Al Noor Club',
      location: 'Downtown Cairo',
      description:
          'Glass-backed indoor courts in the heart of Downtown, with a coaching '
          'academy and a rooftop lounge overlooking the Nile.',
      image: CourtImages.alNoor,
      pricePerHour: 250,
      facilities: ['Air Conditioning', 'Pro Shop', 'Cafe', 'Parking'],
      rating: 4.8,
      totalBookings: 182,
    ),
    DemoCourt(
      id: 'al-ahmar',
      name: 'Al Ahmar Club',
      location: 'New Cairo',
      description:
          'Six panoramic courts with tournament-grade lighting, a physio room '
          'and a restaurant terrace.',
      image: CourtImages.alAhmar,
      pricePerHour: 300,
      facilities: [
        'Professional Lighting',
        'Restaurant',
        'Locker Rooms',
        'Physio',
      ],
      rating: 4.9,
      totalBookings: 214,
    ),
    DemoCourt(
      id: 'athletes',
      name: 'Athletes Club',
      location: 'Giza',
      description:
          'Covered community courts a few minutes from the Ring Road, popular '
          'for weekday morning doubles.',
      image: CourtImages.athletes,
      pricePerHour: 200,
      facilities: ['Covered Courts', 'Racket Rental', 'Parking'],
      type: CourtType.covered,
      rating: 4.5,
      totalBookings: 96,
    ),
    DemoCourt(
      id: 'alexandria',
      name: 'Alexandria Courts',
      location: 'Alexandria',
      description:
          'Outdoor seafront courts in Smouha with sea breeze, night lighting '
          'and a beach cafe.',
      image: CourtImages.alexandria,
      pricePerHour: 180,
      facilities: ['Sea View', 'Night Lighting', 'Beach Cafe'],
      type: CourtType.outdoor,
      rating: 4.4,
      totalBookings: 74,
    ),
  ];

  static DemoCourt? courtById(String id) {
    for (final court in catalogue) {
      if (court.id == id) return court;
    }
    return null;
  }

  /// Falls back to a name match so bookings created from a court that is not in
  /// the demo catalogue still resolve to something sensible.
  static DemoCourt? courtFor(Booking booking) {
    final byId = courtById(booking.courtId);
    if (byId != null) return byId;
    for (final court in catalogue) {
      if (court.name.toLowerCase() == booking.courtName.toLowerCase()) {
        return court;
      }
    }
    return null;
  }

  /// Newest first, upcoming reservations before played ones.
  List<Booking> get all {
    final list = bookings.toList()
      ..sort((a, b) {
        if (a.isUpcoming != b.isUpcoming) return a.isUpcoming ? -1 : 1;
        return a.isUpcoming
            ? a.startsAt.compareTo(b.startsAt)
            : b.startsAt.compareTo(a.startsAt);
      });
    return list;
  }

  List<Booking> get upcoming => all.where((b) => b.isUpcoming).toList();

  List<Booking> get history =>
      all.where((b) => !b.isUpcoming && !b.isCancelled).toList();

  /// The short list rendered by the home-screen carousel.
  List<Booking> recent({int limit = 6}) => all.take(limit).toList();

  Booking? byId(String id) {
    for (final booking in bookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  String newId() {
    _sequence++;
    return 'bk-${DateTime.now().millisecondsSinceEpoch}-$_sequence';
  }

  void add(Booking booking) => bookings.insert(0, booking);

  /// Cancels a booking and returns the refund the policy allows.
  double cancel(String bookingId) {
    final index = bookings.indexWhere((b) => b.id == bookingId);
    if (index < 0) return 0;
    final booking = bookings[index];
    final refund = PadelPricingCalc.calculateRefundAmount(
      originalPrice: booking.totalPrice,
      reservationTime: booking.startsAt,
      cancellationTime: DateTime.now(),
    );
    bookings[index] = booking.copyWith(
      status: BookingStatus.cancelled,
      cancelledAt: DateTime.now(),
      refundAmount: refund,
    );
    return refund;
  }

  List<Booking> _seedBookings() {
    final now = DateTime.now();
    DateTime day(int offset) =>
        DateTime(now.year, now.month, now.day).add(Duration(days: offset));

    Booking make({
      required String id,
      required String courtId,
      required int dayOffset,
      required int startHour,
      int startMinute = 0,
      BookingStatus status = BookingStatus.confirmed,
      String? notes,
    }) {
      final court = courtById(courtId)!;
      final date = day(dayOffset);
      final startsAt =
          DateTime(date.year, date.month, date.day, startHour, startMinute);
      // Seeded totals go through the same engine as checkout so the demo data
      // and a freshly made booking price identically.
      final subtotal = PadelPricingCalc.calculatePriceBreakdown(
            basePricePerHour: court.pricePerHour,
            durationInHours: 1,
            reservationTime: startsAt,
            location: PadelPricingCalc.locationKeyFor(court.location),
          )['totalPrice'] ??
          court.pricePerHour;
      final total = subtotal + PadelPricingCalc.calculateServiceFee(subtotal);
      return Booking(
        id: id,
        userId: 'demo-player',
        courtId: court.id,
        courtName: court.name,
        courtLocation: court.location,
        courtImage: court.image,
        bookingDate: date,
        startTime: TimeOfDay(hour: startHour, minute: startMinute),
        endTime: TimeOfDay(hour: startHour + 1, minute: startMinute),
        totalPrice: total,
        status: status,
        notes: notes,
        createdAt: date.subtract(const Duration(days: 4)),
        cancelledAt: status == BookingStatus.cancelled
            ? date.subtract(const Duration(days: 2))
            : null,
        // The cancelled seed was called off well in advance, so policy gives a
        // full refund.
        refundAmount: status == BookingStatus.cancelled ? total : 0,
      );
    }

    // Dates are relative to today so the demo never shows an "Upcoming"
    // reservation dated last year.
    return [
      make(id: 'seed-1', courtId: 'al-noor', dayOffset: 3, startHour: 17),
      make(
        id: 'seed-2',
        courtId: 'al-ahmar',
        dayOffset: 8,
        startHour: 18,
        notes: 'Bring the spare rackets for Youssef.',
      ),
      make(
        id: 'seed-3',
        courtId: 'athletes',
        dayOffset: -5,
        startHour: 16,
        status: BookingStatus.completed,
      ),
      make(
        id: 'seed-4',
        courtId: 'alexandria',
        dayOffset: -12,
        startHour: 19,
        status: BookingStatus.completed,
      ),
      make(
        id: 'seed-5',
        courtId: 'al-noor',
        dayOffset: -20,
        startHour: 17,
        startMinute: 30,
        status: BookingStatus.cancelled,
      ),
    ];
  }
}
