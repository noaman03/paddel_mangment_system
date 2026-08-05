import 'package:get/get.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/Features/players/courts/data/court_booking.dart';
import 'package:padel_management_system/Features/players/courts/data/padel_court_repository.dart';
import 'package:padel_management_system/core/const/court_images.dart';

class CourtDataController extends GetxController {
  final PadelCourtRepository _repository = PadelCourtRepository();

  /// Starts as `true` so the very first frame shows a spinner instead of a
  /// flash of the "No courts found" empty state.
  final RxBool isLoading = true.obs;

  // Courts data
  final RxList<PadelCourt> allCourts = <PadelCourt>[].obs;

  /// Reservations made in this session. There is no backend, so this is the
  /// source of truth for "already booked" everywhere in the courts feature.
  final RxList<CourtBooking> bookings = <CourtBooking>[].obs;

  int _bookingSeed = 0;

  /// Loads the catalogue. The seeded data is applied synchronously so the list
  /// is never blocked on Firestore (which has no project behind it here); a
  /// remote refresh is attempted in the background and simply ignored on
  /// failure.
  Future<void> loadCourts() async {
    isLoading.value = true;
    allCourts.value = _applyLocalBookings(_demoCourts);
    isLoading.value = false;
    _tryRemoteRefresh();
  }

  Future<void> refreshCourts() => loadCourts();

  Future<void> _tryRemoteRefresh() async {
    try {
      final courts = await _repository.getPadelCourts();
      if (courts.isEmpty) return;
      allCourts.value = _applyLocalBookings(courts);
    } catch (_) {
      // Offline demo build: the seeded catalogue stays on screen.
    }
  }

  // Get court by ID (falls back to the in-memory catalogue).
  Future<PadelCourt?> getCourtById(String courtId) async {
    final index = allCourts.indexWhere((court) => court.id == courtId);
    if (index != -1) return allCourts[index];
    try {
      return await _repository.getCourtById(courtId);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------- bookings

  /// Records a reservation locally and increments the court's booking count so
  /// the action has a visible consequence in the list.
  CourtBooking bookCourt({
    required PadelCourt court,
    required DateTime date,
    required String timeLabel,
  }) {
    final booking = CourtBooking(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}-${_bookingSeed++}',
      courtId: court.id,
      courtName: court.name,
      courtLocation: court.location,
      date: DateTime(date.year, date.month, date.day),
      timeLabel: timeLabel,
      price: court.pricePerHour,
      createdAt: DateTime.now(),
    );
    bookings.add(booking);

    final index = allCourts.indexWhere((item) => item.id == court.id);
    if (index != -1) {
      allCourts[index] = allCourts[index]
          .copyWith(totalBookings: allCourts[index].totalBookings + 1);
      allCourts.refresh();
    }
    return booking;
  }

  bool isSlotBooked(String courtId, DateTime date, String timeLabel) {
    final key = CourtBooking.slotKeyFor(courtId, date, timeLabel);
    return bookings.any((booking) => booking.slotKey == key);
  }

  List<CourtBooking> bookingsForCourt(String courtId) =>
      bookings.where((booking) => booking.courtId == courtId).toList();

  /// Re-applies session bookings after the catalogue is rebuilt or refreshed.
  List<PadelCourt> _applyLocalBookings(List<PadelCourt> courts) {
    if (bookings.isEmpty) return courts;
    final counts = <String, int>{};
    for (final booking in bookings) {
      counts[booking.courtId] = (counts[booking.courtId] ?? 0) + 1;
    }
    return courts
        .map((court) => counts.containsKey(court.id)
            ? court.copyWith(
                totalBookings: court.totalBookings + counts[court.id]!)
            : court)
        .toList();
  }

  // -------------------------------------------------------------- statistics

  int get totalCourtsCount => allCourts.length;
  int get activeCourtsCount =>
      allCourts.where((court) => court.isActive).length;

  double get averagePrice {
    if (allCourts.isEmpty) return 0.0;
    final total =
        allCourts.fold<double>(0.0, (sum, court) => sum + court.pricePerHour);
    return total / allCourts.length;
  }

  double get averageRating {
    if (allCourts.isEmpty) return 0.0;
    final total =
        allCourts.fold<double>(0.0, (sum, court) => sum + court.rating);
    return total / allCourts.length;
  }

  List<PadelCourt> getTopRatedCourts({int limit = 5}) {
    final sorted = allCourts.where((court) => court.isActive).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  List<PadelCourt> getMostBookedCourts({int limit = 5}) {
    final sorted = allCourts.where((court) => court.isActive).toList()
      ..sort((a, b) => b.totalBookings.compareTo(a.totalBookings));
    return sorted.take(limit).toList();
  }

  List<PadelCourt> getCourtsByPriceRange(double min, double max) {
    return allCourts
        .where((court) =>
            court.isActive &&
            court.pricePerHour >= min &&
            court.pricePerHour <= max)
        .toList();
  }

  List<PadelCourt> getCourtsByLocation(String location) {
    return allCourts
        .where((court) =>
            court.isActive &&
            court.location.toLowerCase() == location.toLowerCase())
        .toList();
  }

  // ------------------------------------------------------------- demo seeding

  /// Nine courts spread across the Cairo areas the Areas sheet lists, with a
  /// wide price / type / facility spread so every filter visibly changes the
  /// result set.
  List<PadelCourt> get _demoCourts => [
        PadelCourt(
          id: 'smash-arena-a',
          name: 'Smash Arena A',
          location: 'New Cairo',
          description:
              'Premium indoor glass court with pro lighting, lockers, cafe, and coach support.',
          pricePerHour: 420,
          photos: const [CourtImages.alNoor, CourtImages.alNoorAlt],
          facilities: const [
            'Parking',
            'Changing Rooms',
            'Air Conditioning',
            'Restaurant',
          ],
          type: CourtType.indoor,
          rating: 4.9,
          totalBookings: 214,
          latitude: 30.032,
          longitude: 31.47,
          createdAt: DateTime(2026, 1, 10),
        ),
        PadelCourt(
          id: 'rally-court-zayed',
          name: 'Rally Court',
          location: 'Sheikh Zayed',
          description:
              'Outdoor court with evening lights, match recording, and a social lounge.',
          pricePerHour: 390,
          photos: const [CourtImages.athletes, CourtImages.athletesAlt],
          facilities: const [
            'Lighting',
            'Showers',
            'Equipment Rental',
            'Parking',
          ],
          type: CourtType.outdoor,
          rating: 4.8,
          totalBookings: 176,
          latitude: 30.013,
          longitude: 30.976,
          createdAt: DateTime(2026, 1, 12),
        ),
        PadelCourt(
          id: 'club-house-glass',
          name: 'Club House Glass',
          location: 'Heliopolis',
          description:
              'Covered panoramic court built for competitive doubles and private events.',
          pricePerHour: 450,
          photos: const [CourtImages.alAhmar, CourtImages.alAhmarAlt],
          facilities: const [
            'Pro Shop',
            'Parking',
            'Restaurant',
            'Spectator Seating',
          ],
          type: CourtType.covered,
          rating: 4.7,
          totalBookings: 143,
          latitude: 30.091,
          longitude: 31.33,
          createdAt: DateTime(2026, 1, 14),
        ),
        PadelCourt(
          id: 'nile-view-padel',
          name: 'Nile View Padel',
          location: 'Zamalek',
          description:
              'Rooftop court overlooking the Nile, with a terrace lounge and river breeze.',
          pricePerHour: 520,
          photos: const [CourtImages.alexandria, CourtImages.alexandriaAlt],
          facilities: const [
            'Restaurant',
            'WiFi',
            'Showers',
            'Spectator Seating',
          ],
          type: CourtType.outdoor,
          rating: 4.6,
          totalBookings: 98,
          latitude: 30.061,
          longitude: 31.22,
          createdAt: DateTime(2026, 1, 16),
        ),
        PadelCourt(
          id: 'maadi-padel-hub',
          name: 'Maadi Padel Hub',
          location: 'Maadi',
          description:
              'Air-conditioned indoor hall with three panoramic courts and a coaching academy.',
          pricePerHour: 300,
          photos: const [CourtImages.alNoorAlt, CourtImages.alNoor],
          facilities: const [
            'Air Conditioning',
            'Changing Rooms',
            'WiFi',
            'Parking',
          ],
          type: CourtType.indoor,
          rating: 4.5,
          totalBookings: 132,
          latitude: 29.96,
          longitude: 31.257,
          createdAt: DateTime(2026, 1, 18),
        ),
        PadelCourt(
          id: 'downtown-court-01',
          name: 'Downtown Court 01',
          location: 'Downtown Cairo',
          description:
              'Compact covered court in the heart of the city, perfect for a quick evening game.',
          pricePerHour: 260,
          photos: const [CourtImages.alAhmarAlt, CourtImages.alAhmar],
          facilities: const [
            'Lighting',
            'First Aid',
            'Equipment Rental',
          ],
          type: CourtType.covered,
          rating: 4.3,
          totalBookings: 87,
          latitude: 30.0444,
          longitude: 31.2357,
          createdAt: DateTime(2026, 1, 20),
        ),
        PadelCourt(
          id: 'nasr-city-arena',
          name: 'Nasr City Arena',
          location: 'Nasr City',
          description:
              'Floodlit outdoor courts with a live sound system and weekly club nights.',
          pricePerHour: 340,
          photos: const [CourtImages.athletesAlt, CourtImages.athletes],
          facilities: const [
            'Parking',
            'Lighting',
            'Sound System',
            'Showers',
          ],
          type: CourtType.outdoor,
          rating: 4.4,
          totalBookings: 121,
          latitude: 30.06,
          longitude: 31.34,
          createdAt: DateTime(2026, 1, 22),
        ),
        PadelCourt(
          id: 'pyramids-padel',
          name: 'Pyramids Padel',
          location: 'Giza',
          description:
              'Flagship indoor club with tournament-grade glass courts and a pro shop.',
          pricePerHour: 610,
          photos: const [CourtImages.alexandriaAlt, CourtImages.alexandria],
          facilities: const [
            'Air Conditioning',
            'Pro Shop',
            'Restaurant',
            'Parking',
            'Spectator Seating',
          ],
          type: CourtType.indoor,
          rating: 4.9,
          totalBookings: 64,
          latitude: 30.013,
          longitude: 31.209,
          createdAt: DateTime(2026, 1, 24),
        ),
        PadelCourt(
          id: 'october-smash-club',
          name: 'October Smash Club',
          location: '6th of October',
          description:
              'Friendly neighbourhood club with two outdoor courts and free racket loan.',
          pricePerHour: 280,
          photos: const [CourtImages.uploadFallback, CourtImages.alNoor],
          facilities: const [
            'Parking',
            'Equipment Rental',
            'First Aid',
          ],
          type: CourtType.outdoor,
          rating: 4.2,
          totalBookings: 75,
          latitude: 29.939,
          longitude: 30.914,
          createdAt: DateTime(2026, 1, 26),
        ),
      ];
}
