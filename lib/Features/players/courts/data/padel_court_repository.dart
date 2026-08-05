import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padel_management_system/Models/padel_court.dart';

class PadelCourtRepository {
  static const String _courtsCollection = 'courts';

  /// This build ships without a live backend, so every Firestore read is capped
  /// instead of being allowed to hang forever behind a user-visible spinner.
  static const Duration _networkTimeout = Duration(seconds: 4);

  FirebaseFirestore? _firestore;
  bool _firestoreResolved = false;

  /// `FirebaseFirestore.instance` throws `[core/no-app]` when
  /// `Firebase.initializeApp` failed — which main.dart deliberately swallows to
  /// keep the offline demo running — and `UnimplementedError` on platforms with
  /// no cloud_firestore plugin. This repository is built in a field initializer
  /// of `CourtDataController`, so a throw here took down the whole Courts tab
  /// before the seeded catalogue could load. Resolve it lazily instead, and
  /// report "no backend" the same way a failed query does.
  FirebaseFirestore get _db {
    if (!_firestoreResolved) {
      _firestoreResolved = true;
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (_) {
        _firestore = null;
      }
    }
    final db = _firestore;
    if (db == null) throw Exception('no Firestore app in this build');
    return db;
  }

  /// Null while Firebase is unavailable, so the stream getters can degrade to
  /// an empty stream instead of throwing at the call site.
  FirebaseFirestore? get _dbOrNull {
    try {
      return _db;
    } catch (_) {
      return null;
    }
  }

  // Get all padel courts
  Future<List<PadelCourt>> getPadelCourts() async {
    try {
      final snapshot = await _db
          .collection(_courtsCollection)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(_networkTimeout);

      return snapshot.docs
          .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch padel courts: $e');
    }
  }

  // Get court by ID
  Future<PadelCourt?> getCourtById(String courtId) async {
    try {
      final doc = await _db
          .collection(_courtsCollection)
          .doc(courtId)
          .get()
          .timeout(_networkTimeout);

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return PadelCourt.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch padel court: $e');
    }
  }

  // Get only active courts
  Future<List<PadelCourt>> getActiveCourts() async {
    try {
      final snapshot = await _db
          .collection(_courtsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get()
          .timeout(_networkTimeout);

      return snapshot.docs
          .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active courts: $e');
    }
  }

  // Get courts by location
  Future<List<PadelCourt>> getCourtsByLocation(String location) async {
    try {
      final snapshot = await _db
          .collection(_courtsCollection)
          .where('location', isEqualTo: location)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch courts by location: $e');
    }
  }

  // Get courts by price range
  Future<List<PadelCourt>> getCourtsByPriceRange(
      double minPrice, double maxPrice) async {
    try {
      final snapshot = await _db
          .collection(_courtsCollection)
          .where('pricePerHour', isGreaterThanOrEqualTo: minPrice)
          .where('pricePerHour', isLessThanOrEqualTo: maxPrice)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch courts by price range: $e');
    }
  }

  // Search courts by name or description
  Future<List<PadelCourt>> searchCourts(String searchTerm) async {
    try {
      final snapshot = await _db
          .collection(_courtsCollection)
          .where('isActive', isEqualTo: true)
          .get();

      final searchTermLower = searchTerm.toLowerCase();
      final filteredCourts = snapshot.docs
          .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
          .where((court) =>
              court.name.toLowerCase().contains(searchTermLower) ||
              court.description.toLowerCase().contains(searchTermLower) ||
              court.location.toLowerCase().contains(searchTermLower))
          .toList();

      return filteredCourts;
    } catch (e) {
      throw Exception('Failed to search courts: $e');
    }
  }

  // NOTE: the old `bookCourt` wrote to a `bookings` collection nothing ever
  // read, and updated court documents that do not exist for the demo courts, so
  // it always threw NOT_FOUND. Bookings are now made in memory by
  // `CourtDataController.bookCourt`, which is the single booking path.

  // Get real-time courts stream
  Stream<List<PadelCourt>> getCourtsStream() {
    final db = _dbOrNull;
    if (db == null) return Stream.value(const <PadelCourt>[]);
    return db
        .collection(_courtsCollection)
        .where('isActive', isEqualTo: true)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Get real-time court by ID stream
  Stream<PadelCourt?> getCourtStreamById(String courtId) {
    final db = _dbOrNull;
    if (db == null) return Stream.value(null);
    return db.collection(_courtsCollection).doc(courtId).snapshots().map(
        (doc) => doc.exists && doc.data() != null
            ? PadelCourt.fromJson(doc.data()!, doc.id)
            : null);
  }

  // Update court rating
  Future<void> updateCourtRating(String courtId, double rating) async {
    try {
      await _db.collection(_courtsCollection).doc(courtId).update({
        'rating': rating,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update court rating: $e');
    }
  }

  // Get court statistics
  Future<Map<String, dynamic>> getCourtStatistics() async {
    try {
      final snapshot = await _db.collection(_courtsCollection).get();
      final courts = snapshot.docs
          .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
          .toList();

      final totalCourts = courts.length;
      final activeCourts = courts.where((court) => court.isActive).length;
      final averagePrice = courts.isNotEmpty
          ? courts.fold<double>(
                  0.0, (total, court) => total + court.pricePerHour) /
              courts.length
          : 0.0;
      final averageRating = courts.isNotEmpty
          ? courts.fold<double>(0.0, (total, court) => total + court.rating) /
              courts.length
          : 0.0;

      // Group by location
      final locationCounts = <String, int>{};
      for (final court in courts) {
        locationCounts[court.location] =
            (locationCounts[court.location] ?? 0) + 1;
      }

      return {
        'totalCourts': totalCourts,
        'activeCourts': activeCourts,
        'averagePrice': averagePrice,
        'averageRating': averageRating,
        'locationCounts': locationCounts,
      };
    } catch (e) {
      throw Exception('Failed to get court statistics: $e');
    }
  }
}
