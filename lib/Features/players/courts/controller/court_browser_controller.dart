import 'package:get/get.dart';
import 'package:padelsystem/Features/players/courts/controller/location_controller.dart';
import 'package:padelsystem/Features/players/courts/controller/filter_controller.dart';
import 'package:padelsystem/Features/players/courts/controller/area_controller.dart';
import 'package:padelsystem/Features/players/courts/controller/court_data_controller.dart';
import 'package:padelsystem/Models/padel_court.dart';

class CourtBrowseController extends GetxController {
  // Inject sub-controllers
  final LocationController locationController = Get.put(LocationController());
  final FilterController filterController = Get.put(FilterController());
  final AreaController areaController = Get.put(AreaController());
  final CourtDataController courtDataController =
      Get.put(CourtDataController());

  // Filtered results
  final RxList<PadelCourt> filteredCourts = <PadelCourt>[].obs;
  final RxList<PadelCourt> nearbyCourts = <PadelCourt>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
    _setupListeners();
  }

  // Initialize app
  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await courtDataController.loadCourts();
      _updateDependentData();
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  // Setup reactive listeners
  void _setupListeners() {
    // Listen to filter changes
    ever(filterController.searchQuery, (_) => applyFilters());
    ever(filterController.minPrice, (_) => applyFilters());
    ever(filterController.maxPrice, (_) => applyFilters());
    ever(filterController.selectedCourtTypes, (_) => applyFilters());
    ever(filterController.selectedFacilities, (_) => applyFilters());
    ever(filterController.selectedArea, (_) => applyFilters());

    // Listen to location changes
    ever(locationController.currentLatitude, (_) => _onLocationChanged());
    ever(locationController.currentLongitude, (_) => _onLocationChanged());
    ever(locationController.maxDistance, (_) => _onLocationChanged());

    // Listen to court data changes
    ever(courtDataController.allCourts, (_) => _updateDependentData());
  }

  // Handle location changes
  void _onLocationChanged() {
    applyFilters();
    if (locationController.locationPermissionGranted.value) {
      findNearbyCourts();
    }
  }

  // Update dependent data when courts change
  void _updateDependentData() {
    filterController.updateAvailableOptions(courtDataController.allCourts);
    areaController.updateAreaCounts(courtDataController.allCourts);

    if (locationController.locationPermissionGranted.value) {
      findNearbyCourts();
    }

    applyFilters();
  }

  // Find nearby courts
  Future<void> findNearbyCourts() async {
    if (!locationController.locationPermissionGranted.value) return;

    try {
      final nearby = <PadelCourt>[];

      for (final court in courtDataController.allCourts) {
        if (court.latitude != null && court.longitude != null) {
          final distance = locationController.calculateDistance(
            locationController.currentLatitude.value,
            locationController.currentLongitude.value,
            court.latitude!,
            court.longitude!,
          );

          if (distance <= locationController.maxDistance.value) {
            final courtWithDistance =
                court.copyWith(distanceFromUser: distance);
            nearby.add(courtWithDistance);
          }
        }
      }

      // Sort by distance
      nearby.sort((a, b) => a.distanceFromUser!.compareTo(b.distanceFromUser!));
      nearbyCourts.value = nearby;
    } catch (e) {
      print('Error finding nearby courts: $e');
    }
  }

  // Apply all filters
  void applyFilters() {
    var filtered = filterController.applyFilters(
      courtDataController.allCourts,
      currentLat: locationController.locationPermissionGranted.value
          ? locationController.currentLatitude.value
          : null,
      currentLon: locationController.locationPermissionGranted.value
          ? locationController.currentLongitude.value
          : null,
      maxDistance: locationController.maxDistance.value,
      calculateDistance: locationController.calculateDistance,
    );

    // Sort filtered results
    filtered.sort((a, b) {
      if (locationController.locationPermissionGranted.value &&
          a.latitude != null &&
          a.longitude != null &&
          b.latitude != null &&
          b.longitude != null) {
        final distanceA = locationController.calculateDistance(
          locationController.currentLatitude.value,
          locationController.currentLongitude.value,
          a.latitude!,
          a.longitude!,
        );
        final distanceB = locationController.calculateDistance(
          locationController.currentLatitude.value,
          locationController.currentLongitude.value,
          b.latitude!,
          b.longitude!,
        );
        final distanceCompare = distanceA.compareTo(distanceB);
        if (distanceCompare != 0) return distanceCompare;
      }

      // Fall back to rating comparison
      final ratingCompare = b.rating.compareTo(a.rating);
      return ratingCompare != 0 ? ratingCompare : a.name.compareTo(b.name);
    });

    filteredCourts.value = filtered;
  }

  // Update max distance
  void updateMaxDistance(double distance) {
    locationController.maxDistance.value = distance;
    if (locationController.locationPermissionGranted.value) {
      findNearbyCourts();
    }
  }

  // Convenience getters
  int get filteredCourtsCount => filteredCourts.length;
  int get nearbyCourtsCount => nearbyCourts.length;

  // Delegate methods to sub-controllers
  void searchCourts(String query) => filterController.searchCourts(query);
  void clearSearch() => filterController.clearSearch();
  void updatePriceRange(double min, double max) =>
      filterController.updatePriceRange(min, max);
  void toggleCourtType(String type) => filterController.toggleCourtType(type);
  void toggleFacility(String facility) =>
      filterController.toggleFacility(facility);
  void selectArea(String area) => filterController.selectArea(area);
  void clearAllFilters() => filterController.clearAllFilters();
  void clearAreaFilter() => filterController.clearAreaFilter();
  void searchAreas(String query) => areaController.searchAreas(query);

  // Location methods
  Future<void> requestLocationPermission() =>
      locationController.requestLocationPermission();
  Future<void> updateLocation() => locationController.updateLocation();

  // Court data methods
  Future<void> loadCourts() => courtDataController.loadCourts();
  Future<void> loadActiveCourts() => courtDataController.loadActiveCourts();
  Future<PadelCourt?> getCourtById(String courtId) =>
      courtDataController.getCourtById(courtId);
  Future<void> bookCourt(String courtId, DateTime dateTime) =>
      courtDataController.bookCourt(courtId, dateTime);
  Future<void> refreshCourts() => courtDataController.refreshCourts();

  @override
  void onClose() {
    // Controllers will be disposed automatically by GetX
    super.onClose();
  }
}
