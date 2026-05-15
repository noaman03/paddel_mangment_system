import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:padelsystem/Models/padel_court.dart';

class PadelCourtRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _courtsCollection = 'courts';
  static const String _bookingsCollection = 'bookings';

  // Get all padel courts
  Future<List<PadelCourt>> getPadelCourts() async {
    try {
      final snapshot = await _firestore
          .collection(_courtsCollection)
          .orderBy('createdAt', descending: true)
          .get();

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
      final doc =
          await _firestore.collection(_courtsCollection).doc(courtId).get();

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
      final snapshot = await _firestore
          .collection(_courtsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();

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
      final snapshot = await _firestore
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
      final snapshot = await _firestore
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
      final snapshot = await _firestore
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

  // Book a court
  Future<void> bookCourt(String courtId, DateTime dateTime) async {
    try {
      // Add booking record
      await _firestore.collection(_bookingsCollection).add({
        'courtId': courtId,
        'dateTime': dateTime.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'confirmed',
      });

      // Update court booking count
      await _firestore.collection(_courtsCollection).doc(courtId).update({
        'totalBookings': FieldValue.increment(1),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to book court: $e');
    }
  }

  // Get real-time courts stream
  Stream<List<PadelCourt>> getCourtsStream() {
    return _firestore
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
    return _firestore
        .collection(_courtsCollection)
        .doc(courtId)
        .snapshots()
        .map((doc) => doc.exists && doc.data() != null
            ? PadelCourt.fromJson(doc.data()!, doc.id)
            : null);
  }

  // Update court rating
  Future<void> updateCourtRating(String courtId, double rating) async {
    try {
      await _firestore.collection(_courtsCollection).doc(courtId).update({
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
      final snapshot = await _firestore.collection(_courtsCollection).get();
      final courts = snapshot.docs
          .map((doc) => PadelCourt.fromJson(doc.data(), doc.id))
          .toList();

      final totalCourts = courts.length;
      final activeCourts = courts.where((court) => court.isActive).length;
      final averagePrice = courts.isNotEmpty
          ? courts.fold<double>(0.0, (sum, court) => sum + court.pricePerHour) /
              courts.length
          : 0.0;
      final averageRating = courts.isNotEmpty
          ? courts.fold<double>(0.0, (sum, court) => sum + court.rating) /
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
