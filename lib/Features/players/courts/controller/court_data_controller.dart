import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/Features/players/courts/data/padel_court_repository.dart';
import 'package:padel_management_system/core/const/colors.dart';

class CourtDataController extends GetxController {
  final PadelCourtRepository _repository = PadelCourtRepository();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Courts data
  final RxList<PadelCourt> allCourts = <PadelCourt>[].obs;
  final RxList<PadelCourt> activeCourts = <PadelCourt>[].obs;

  // Load all courts from Firebase
  Future<void> loadCourts() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final courts = await _repository.getPadelCourts();
      allCourts.value = courts;

      if (courts.isNotEmpty) {
        Get.snackbar(
          'Courts Loaded',
          'Found ${courts.length} courts',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AColors.success,
          colorText: AColors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to load courts: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.error,
        colorText: AColors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load only active courts
  Future<void> loadActiveCourts() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final courts = await _repository.getActiveCourts();
      activeCourts.value = courts;
      allCourts.value = courts;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to load active courts: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.error,
        colorText: AColors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get court by ID
  Future<PadelCourt?> getCourtById(String courtId) async {
    try {
      isLoading.value = true;
      return await _repository.getCourtById(courtId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load court details: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.error,
        colorText: AColors.white,
        margin: const EdgeInsets.all(16),
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Book a court
  Future<void> bookCourt(String courtId, DateTime dateTime) async {
    try {
      isLoading.value = true;

      await _repository.bookCourt(courtId, dateTime);

      Get.snackbar(
        'Success',
        'Court booked successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.success,
        colorText: AColors.white,
        margin: const EdgeInsets.all(16),
      );

      // Refresh courts to update availability
      await loadCourts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to book court: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.error,
        colorText: AColors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshCourts() async {
    await loadCourts();
  }

  // Get statistics
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

  // Get courts by specific criteria
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
}
