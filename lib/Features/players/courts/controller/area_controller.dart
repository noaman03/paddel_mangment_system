import 'package:get/get.dart';
import 'package:padelsystem/Features/players/courts/controller/court_data_controller.dart';
import 'package:padelsystem/Models/padel_court.dart';

class AreaController extends GetxController {
  final RxList<Map<String, dynamic>> filteredAreas =
      <Map<String, dynamic>>[].obs;

  final List<Map<String, dynamic>> areas = [
    {'name': 'Downtown Cairo', 'courtCount': 0},
    {'name': 'New Cairo', 'courtCount': 0},
    {'name': 'Maadi', 'courtCount': 0},
    {'name': 'Zamalek', 'courtCount': 0},
    {'name': 'Heliopolis', 'courtCount': 0},
    {'name': 'Giza', 'courtCount': 0},
    {'name': '6th of October', 'courtCount': 0},
    {'name': 'Nasr City', 'courtCount': 0},
  ];

  @override
  void onInit() {
    super.onInit();
    filteredAreas.value = areas;
  }

  // Update court counts for each area
  void updateAreaCounts(List<PadelCourt> courts) {
    final areasCounts = <String, int>{};

    // Initialize all areas with 0 count
    for (final area in areas) {
      areasCounts[area['name']] = 0;
    }

    // Count courts in each area
    for (final court in courts) {
      final location = court.location;
      if (areasCounts.containsKey(location)) {
        areasCounts[location] = areasCounts[location]! + 1;
      } else {
        // Add new area if not in predefined list
        areasCounts[location] = 1;
      }
    }

    // Update filteredAreas with counts
    final updatedAreas = <Map<String, dynamic>>[];
    areasCounts.forEach((name, count) {
      updatedAreas.add({'name': name, 'courtCount': count});
    });

    // Sort by court count (descending) then by name
    updatedAreas.sort((a, b) {
      final countCompare = b['courtCount'].compareTo(a['courtCount']);
      return countCompare != 0 ? countCompare : a['name'].compareTo(b['name']);
    });

    filteredAreas.value = updatedAreas;
  }

  // Search areas
  void searchAreas(String query) {
    if (query.isEmpty) {
      // Reset to full list with current counts instead of static areas
      updateAreaCounts(_getCurrentCourts());
    } else {
      final filtered = filteredAreas
          .where((area) => area['name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      filteredAreas.value = filtered;
    }
  }

  // Helper method to get current courts (this should be injected or passed)
  List<PadelCourt> _getCurrentCourts() {
    // This is a temporary solution - ideally this should be injected
    try {
      final courtDataController = Get.find<CourtDataController>();
      return courtDataController.allCourts;
    } catch (e) {
      return [];
    }
  }

  // Get areas by court count
  List<Map<String, dynamic>> getAreasByCourtCount({bool ascending = false}) {
    final sorted = List<Map<String, dynamic>>.from(filteredAreas);
    sorted.sort((a, b) => ascending
        ? a['courtCount'].compareTo(b['courtCount'])
        : b['courtCount'].compareTo(a['courtCount']));
    return sorted;
  }

  // Get areas with courts only
  List<Map<String, dynamic>> getAreasWithCourts() {
    return filteredAreas.where((area) => area['courtCount'] > 0).toList();
  }
}
