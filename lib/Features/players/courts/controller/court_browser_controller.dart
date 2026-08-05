import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/players/courts/controller/area_controller.dart';
import 'package:padel_management_system/Features/players/courts/controller/court_data_controller.dart';
import 'package:padel_management_system/Features/players/courts/controller/filter_controller.dart';
import 'package:padel_management_system/Features/players/courts/controller/location_controller.dart';
import 'package:padel_management_system/Features/players/courts/data/court_booking.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Reuses an already registered controller instead of building a second one.
T _shared<T>(T Function() create) =>
    Get.isRegistered<T>() ? Get.find<T>() : Get.put<T>(create());

class CourtBrowseController extends GetxController {
  static CourtBrowseController get to => _shared(() => CourtBrowseController());

  // Sub-controllers. `late final` so they are created on first use rather than
  // on every construction of this controller.
  late final LocationController locationController =
      _shared(() => LocationController());
  late final FilterController filterController =
      _shared(() => FilterController());
  late final AreaController areaController = _shared(() => AreaController());
  late final CourtDataController courtDataController =
      _shared(() => CourtDataController());

  /// Owned here so "Clear all filters" can actually empty the search box —
  /// a bare `PlayerSearchBar` keeps its own editing state that nothing can reach.
  final TextEditingController searchTextController = TextEditingController();

  // Filtered results
  final RxList<PadelCourt> filteredCourts = <PadelCourt>[].obs;
  final RxList<PadelCourt> nearbyCourts = <PadelCourt>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupListeners();
    courtDataController.loadCourts();
  }

  void _setupListeners() {
    // Filter changes
    ever(filterController.searchQuery, (_) => applyFilters());
    ever(filterController.minPrice, (_) => applyFilters());
    ever(filterController.maxPrice, (_) => applyFilters());
    ever(filterController.selectedCourtTypes, (_) => applyFilters());
    ever(filterController.selectedFacilities, (_) => applyFilters());
    ever(filterController.selectedArea, (_) => applyFilters());

    // Location changes
    ever(locationController.currentLatitude, (_) => _onLocationChanged());
    ever(locationController.currentLongitude, (_) => _onLocationChanged());
    ever(locationController.maxDistance, (_) => _onLocationChanged());
    ever(locationController.locationPermissionGranted,
        (_) => _onLocationChanged());

    // Court data changes
    ever(courtDataController.allCourts, (_) => _updateDependentData());
  }

  void _onLocationChanged() {
    findNearbyCourts();
    applyFilters();
  }

  void _updateDependentData() {
    filterController.updateAvailableOptions(courtDataController.allCourts);
    areaController.updateAreaCounts(courtDataController.allCourts);
    findNearbyCourts();
    applyFilters();
  }

  bool get hasLocation => locationController.locationPermissionGranted.value;

  /// Courts inside the current search radius, regardless of the other filters —
  /// this is what the Nearest sheet counts.
  void findNearbyCourts() {
    if (!hasLocation) {
      nearbyCourts.clear();
      return;
    }

    final nearby = <PadelCourt>[];
    for (final court in courtDataController.allCourts) {
      final distance = _distanceTo(court);
      if (distance == null) continue;
      if (distance <= locationController.maxDistance.value) {
        nearby.add(court.copyWith(distanceFromUser: distance));
      }
    }
    nearby.sort((a, b) => a.distanceFromUser!.compareTo(b.distanceFromUser!));
    nearbyCourts.value = nearby;
  }

  double? _distanceTo(PadelCourt court) {
    if (court.latitude == null || court.longitude == null) return null;
    return locationController.calculateDistance(
      locationController.currentLatitude.value,
      locationController.currentLongitude.value,
      court.latitude!,
      court.longitude!,
    );
  }

  /// Applies every filter, stamps each result with its distance and sorts —
  /// nearest first when we know where the user is, otherwise by rating.
  void applyFilters() {
    final withLocation = hasLocation;

    var filtered = filterController.applyFilters(
      courtDataController.allCourts,
      currentLat:
          withLocation ? locationController.currentLatitude.value : null,
      currentLon:
          withLocation ? locationController.currentLongitude.value : null,
      maxDistance: locationController.maxDistance.value,
      calculateDistance: locationController.calculateDistance,
    );

    if (withLocation) {
      filtered = filtered.map((court) {
        final distance = _distanceTo(court);
        return distance == null
            ? court
            : court.copyWith(distanceFromUser: distance);
      }).toList();

      filtered.sort((a, b) {
        final distanceA = a.distanceFromUser;
        final distanceB = b.distanceFromUser;
        if (distanceA != null && distanceB != null) {
          final compare = distanceA.compareTo(distanceB);
          if (compare != 0) return compare;
        } else if (distanceA != null) {
          return -1;
        } else if (distanceB != null) {
          return 1;
        }
        return b.rating.compareTo(a.rating);
      });
    } else {
      filtered.sort((a, b) {
        final ratingCompare = b.rating.compareTo(a.rating);
        return ratingCompare != 0 ? ratingCompare : a.name.compareTo(b.name);
      });
    }

    filteredCourts.value = filtered;
  }

  void updateMaxDistance(double distance) {
    locationController.maxDistance.value = distance;
  }

  // Convenience getters
  int get filteredCourtsCount => filteredCourts.length;
  int get nearbyCourtsCount => nearbyCourts.length;

  bool get hasDistanceFilter =>
      hasLocation &&
      locationController.maxDistance.value <
          LocationController.defaultMaxDistance;

  bool get hasAnyFilter =>
      filterController.hasSheetFilters ||
      filterController.hasAreaFilter ||
      filterController.hasSearch ||
      // A location on its own already narrows the list (everything outside the
      // radius is dropped) and re-sorts it, so it counts as an active filter
      // even at the default radius, where `hasDistanceFilter` is false.
      hasLocation;

  /// Label under the results counter, so "Nearest" visibly reports itself.
  String get sortLabel => hasLocation
      ? 'Nearest first from ${locationController.currentLocation.value}'
      : 'Sorted by rating';

  // Delegates
  void searchCourts(String query) => filterController.searchCourts(query);
  void updatePriceRange(double min, double max) =>
      filterController.updatePriceRange(min, max);
  void toggleCourtType(String type) => filterController.toggleCourtType(type);
  void toggleFacility(String facility) =>
      filterController.toggleFacility(facility);
  void searchAreas(String query) => areaController.searchAreas(query);
  Future<void> requestLocationPermission() =>
      locationController.requestLocationPermission();
  Future<void> refreshCourts() => courtDataController.refreshCourts();

  void selectArea(String area) {
    filterController.selectArea(area);
    applyFilters();
    AppFeedback.info(
      area.isEmpty ? 'All areas' : area,
      '$filteredCourtsCount ${filteredCourtsCount == 1 ? 'court' : 'courts'} match',
    );
  }

  void clearAreaFilter() => selectArea('');

  /// Drops the picked/detected location and the radius with it, so the list
  /// goes back to rating order. Shared by the Nearest sheet's Reset and
  /// Clear-location actions and by [clearAllFilters].
  void clearLocationFilter() {
    locationController.clearLocation();
    locationController.maxDistance.value =
        LocationController.defaultMaxDistance;
    applyFilters();
  }

  /// Resets every control the three sheets expose — including the location,
  /// the distance radius and the text sitting in the search field.
  ///
  /// The location used to survive this, which left the list quietly filtered by
  /// distance with no visible filter and nothing left to clear it with.
  void clearAllFilters() {
    filterController.clearAllFilters();
    clearLocationFilter();
    if (searchTextController.text.isNotEmpty) searchTextController.clear();
    areaController.resetSearch();
    applyFilters();
    AppFeedback.info(
      'Filters cleared',
      'Showing all $filteredCourtsCount courts',
    );
  }

  /// Books a slot locally (there is no backend) and reports the result.
  CourtBooking bookCourt({
    required PadelCourt court,
    required DateTime date,
    required String timeLabel,
  }) =>
      courtDataController.bookCourt(
        court: court,
        date: date,
        timeLabel: timeLabel,
      );

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}
