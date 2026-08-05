import 'package:get/get.dart';
import 'package:padel_management_system/Models/padel_court.dart';

/// One selectable area plus how many courts it currently holds.
class AreaOption {
  const AreaOption(this.name, this.courtCount);

  final String name;
  final int courtCount;
}

class AreaController extends GetxController {
  /// Every known area with live counts — the authoritative list.
  final RxList<AreaOption> allAreas = <AreaOption>[].obs;

  /// What the Areas sheet renders (i.e. [allAreas] narrowed by the search box).
  final RxList<AreaOption> filteredAreas = <AreaOption>[].obs;

  final RxString searchQuery = ''.obs;

  static const List<String> knownAreas = <String>[
    'Downtown Cairo',
    'New Cairo',
    'Maadi',
    'Zamalek',
    'Heliopolis',
    'Giza',
    '6th of October',
    'Nasr City',
    'Sheikh Zayed',
  ];

  @override
  void onInit() {
    super.onInit();
    allAreas.value =
        knownAreas.map((name) => AreaOption(name, 0)).toList(growable: false);
    filteredAreas.value = allAreas;
  }

  /// Recomputes court counts per area and re-applies the active search term.
  void updateAreaCounts(List<PadelCourt> courts) {
    final counts = <String, int>{for (final name in knownAreas) name: 0};

    for (final court in courts) {
      counts[court.location] = (counts[court.location] ?? 0) + 1;
    }

    final updated = counts.entries
        .map((entry) => AreaOption(entry.key, entry.value))
        .toList()
      ..sort((a, b) {
        final countCompare = b.courtCount.compareTo(a.courtCount);
        return countCompare != 0 ? countCompare : a.name.compareTo(b.name);
      });

    allAreas.value = updated;
    _applySearch();
  }

  /// Always narrows from [allAreas]; filtering `filteredAreas` in place made the
  /// list monotonic, so deleting characters never brought areas back.
  void searchAreas(String query) {
    searchQuery.value = query.trim();
    _applySearch();
  }

  void resetSearch() {
    searchQuery.value = '';
    _applySearch();
  }

  void _applySearch() {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      filteredAreas.value = List<AreaOption>.from(allAreas);
      return;
    }
    filteredAreas.value = allAreas
        .where((area) => area.name.toLowerCase().contains(query))
        .toList();
  }

  int courtCountFor(String areaName) {
    for (final area in allAreas) {
      if (area.name == areaName) return area.courtCount;
    }
    return 0;
  }
}
