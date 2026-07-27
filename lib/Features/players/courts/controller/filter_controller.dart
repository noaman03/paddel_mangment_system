import 'package:get/get.dart';
import 'package:padel_management_system/Models/padel_court.dart';

class FilterController extends GetxController {
  // Search
  final RxString searchQuery = ''.obs;

  // Filters
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = 1000.0.obs;
  final RxList<String> selectedCourtTypes = <String>[].obs;
  final RxList<String> selectedFacilities = <String>[].obs;
  final RxString selectedArea = ''.obs;

  // Available options (derived from actual data)
  final RxList<String> availableCourtTypes = <String>[].obs;
  final RxList<String> availableFacilities = <String>[].obs;

  // Static lists for filter UI
  final RxList<String> courtTypes =
      <String>['Indoor', 'Outdoor', 'Covered'].obs;
  final RxList<String> facilities = <String>[
    'Parking',
    'Changing Rooms',
    'Showers',
    'Equipment Rental',
    'Pro Shop',
    'Restaurant',
    'Air Conditioning',
    'Lighting',
    'Sound System',
    'First Aid',
    'WiFi',
    'Spectator Seating',
  ].obs;

  // Search functionality
  void searchCourts(String query) {
    searchQuery.value = query.trim();
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  // Filter functions
  void updatePriceRange(double min, double max) {
    minPrice.value = min;
    maxPrice.value = max;
  }

  void toggleCourtType(String type) {
    if (selectedCourtTypes.contains(type)) {
      selectedCourtTypes.remove(type);
    } else {
      selectedCourtTypes.add(type);
    }
  }

  void toggleFacility(String facility) {
    if (selectedFacilities.contains(facility)) {
      selectedFacilities.remove(facility);
    } else {
      selectedFacilities.add(facility);
    }
  }

  void selectArea(String area) {
    selectedArea.value = area;
  }

  // Clear filters
  void clearAllFilters() {
    minPrice.value = 0.0;
    maxPrice.value = 1000.0;
    selectedCourtTypes.clear();
    selectedFacilities.clear();
    selectedArea.value = '';
    searchQuery.value = '';
  }

  void clearAreaFilter() {
    selectedArea.value = '';
  }

  // Update available options based on court data
  void updateAvailableOptions(List<PadelCourt> courts) {
    final types = <String>{};
    final facilitiesSet = <String>{};

    for (final court in courts) {
      types.add(getCourtTypeDisplayName(court.type));
      facilitiesSet.addAll(court.facilities);
    }

    if (types.isNotEmpty) {
      courtTypes.value = types.toList()..sort();
    }

    if (facilitiesSet.isNotEmpty) {
      facilities.value = facilitiesSet.toList()..sort();
    }

    availableCourtTypes.value = types.toList()..sort();
    availableFacilities.value = facilitiesSet.toList()..sort();
  }

  // Helper methods
  String getCourtTypeDisplayName(CourtType type) {
    switch (type) {
      case CourtType.indoor:
        return 'Indoor';
      case CourtType.outdoor:
        return 'Outdoor';
      case CourtType.covered:
        return 'Covered';
    }
  }

  bool isCourtTypeSelected(CourtType type) {
    final displayName = getCourtTypeDisplayName(type);
    return selectedCourtTypes.contains(displayName);
  }

  bool isFacilitySelected(String facility) {
    return selectedFacilities.contains(facility);
  }

  // Apply filters to court list
  List<PadelCourt> applyFilters(List<PadelCourt> courts,
      {double? currentLat,
      double? currentLon,
      double? maxDistance,
      double Function(double, double, double, double)? calculateDistance}) {
    return courts.where((court) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!court.name.toLowerCase().contains(query) &&
            !court.location.toLowerCase().contains(query) &&
            !court.description.toLowerCase().contains(query) &&
            !court.facilities
                .any((facility) => facility.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Price filter
      if (court.pricePerHour < minPrice.value ||
          court.pricePerHour > maxPrice.value) {
        return false;
      }

      // Court type filter
      if (selectedCourtTypes.isNotEmpty) {
        final courtTypeDisplayName = getCourtTypeDisplayName(court.type);
        if (!selectedCourtTypes.contains(courtTypeDisplayName)) {
          return false;
        }
      }

      // Facilities filter
      if (selectedFacilities.isNotEmpty) {
        if (!selectedFacilities
            .every((facility) => court.facilities.contains(facility))) {
          return false;
        }
      }

      // Area filter
      if (selectedArea.value.isNotEmpty &&
          court.location != selectedArea.value) {
        return false;
      }

      // Distance filter (if location is available)
      if (currentLat != null &&
          currentLon != null &&
          maxDistance != null &&
          calculateDistance != null &&
          court.latitude != null &&
          court.longitude != null) {
        final distance = calculateDistance(
            currentLat, currentLon, court.latitude!, court.longitude!);
        if (distance > maxDistance) {
          return false;
        }
      }

      // Only show active courts by default
      if (!court.isActive) {
        return false;
      }

      return true;
    }).toList();
  }
}
