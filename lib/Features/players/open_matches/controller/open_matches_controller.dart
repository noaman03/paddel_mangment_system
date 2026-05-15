// Create: lib/Features/players/matches/controller/matches_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OpenMatchesController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var currentTab = 0.obs;
  var allMatches = <Map<String, dynamic>>[].obs;
  var filteredMatches = <Map<String, dynamic>>[].obs;
  var myMatches = <Map<String, dynamic>>[].obs;
  var joinRequests = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;
  var selectedMatchType = 'All'.obs;
  var selectedSkillLevel = 'All'.obs;

  // Match types and skill levels
  final List<String> matchTypes = [
    'All',
    'Doubles',
    'Singles',
    'Pink Matches',
  ];
  final List<String> skillLevels = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Pro'
  ];

  @override
  void onInit() {
    super.onInit();
    loadSampleMatches();
    loadMyMatches();
    loadJoinRequests();
    filteredMatches.value = allMatches;
  }

  void loadSampleMatches() {
    allMatches.value = [
      {
        'id': '1',
        'title': 'Evening Doubles Match',
        'description': 'Looking for 2 players to complete our doubles team',
        'createdBy': 'Ahmed Hassan',
        'createdByAvatar': 'assets/images/avatar1.jpg',
        'courtName': 'Cairo Padel Club',
        'location': 'New Cairo',
        'date': DateTime.now().add(const Duration(days: 2)),
        'time': '18:00',
        'duration': '2 hours',
        'playersNeeded': 2,
        'currentPlayers': 2,
        'maxPlayers': 4,
        'skillLevel': 'Intermediate',
        'matchType': 'Doubles',
        'price': 40,
        'status': 'open',
        'joinRequests': 3,
        'players': [
          {'name': 'Ahmed Hassan', 'avatar': 'assets/images/avatar1.jpg'},
          {'name': 'Sara Mohamed', 'avatar': 'assets/images/avatar2.jpg'},
        ],
      },
      {
        'id': '2',
        'title': 'Weekend Tournament Prep',
        'description': 'Practice session before the upcoming tournament',
        'createdBy': 'Mohamed Ali',
        'createdByAvatar': 'assets/images/avatar3.jpg',
        'courtName': 'Elite Sports Center',
        'location': 'Maadi',
        'date': DateTime.now().add(const Duration(days: 1)),
        'time': '16:00',
        'duration': '3 hours',
        'playersNeeded': 1,
        'currentPlayers': 3,
        'maxPlayers': 4,
        'skillLevel': 'Advanced',
        'matchType': 'Doubles',
        'price': 60,
        'status': 'open',
        'joinRequests': 5,
        'players': [
          {'name': 'Mohamed Ali', 'avatar': 'assets/images/avatar3.jpg'},
          {'name': 'Layla Ahmed', 'avatar': 'assets/images/avatar4.jpg'},
          {'name': 'Omar Khaled', 'avatar': 'assets/images/avatar5.jpg'},
        ],
      },
      {
        'id': '3',
        'title': 'Beginner Friendly Match',
        'description': 'Perfect for new players to practice and improve',
        'createdBy': 'Fatima Said',
        'createdByAvatar': 'assets/images/avatar2.jpg',
        'courtName': 'Downtown Sports',
        'location': 'Downtown Cairo',
        'date': DateTime.now().add(const Duration(days: 3)),
        'time': '10:00',
        'duration': '1.5 hours',
        'playersNeeded': 3,
        'currentPlayers': 1,
        'maxPlayers': 4,
        'skillLevel': 'Beginner',
        'matchType': 'Doubles',
        'price': 25,
        'status': 'open',
        'joinRequests': 2,
        'players': [
          {'name': 'Fatima Said', 'avatar': 'assets/images/avatar2.jpg'},
        ],
      },
    ];
  }

  void loadMyMatches() {
    myMatches.value = [
      {
        'id': 'my1',
        'title': 'My Weekend Match',
        'courtName': 'Premium Padel',
        'date': DateTime.now().add(const Duration(days: 4)),
        'time': '19:00',
        'status': 'confirmed',
        'playersJoined': 4,
        'maxPlayers': 4,
      },
    ];
  }

  void loadJoinRequests() {
    joinRequests.value = [
      {
        'id': 'req1',
        'matchTitle': 'Evening Doubles Match',
        'playerName': 'Youssef Ahmed',
        'playerAvatar': 'assets/images/avatar4.jpg',
        'skillLevel': 'Intermediate',
        'message': 'Would love to join your match!',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'req2',
        'matchTitle': 'Weekend Tournament Prep',
        'playerName': 'Nour Hassan',
        'playerAvatar': 'assets/images/avatar5.jpg',
        'skillLevel': 'Advanced',
        'message': 'Experienced player looking to join',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
    ];
  }

  void updateTab(int index) {
    currentTab.value = index;
  }

  void searchMatches(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void updateMatchType(String type) {
    selectedMatchType.value = type;
    applyFilters();
  }

  void updateSkillLevel(String level) {
    selectedSkillLevel.value = level;
    applyFilters();
  }

  void applyFilters() {
    filteredMatches.value = allMatches.where((match) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!match['title'].toLowerCase().contains(query) &&
            !match['location'].toLowerCase().contains(query) &&
            !match['courtName'].toLowerCase().contains(query)) {
          return false;
        }
      }

      // Match type filter
      if (selectedMatchType.value != 'All' &&
          match['matchType'] != selectedMatchType.value) {
        return false;
      }

      // Skill level filter
      if (selectedSkillLevel.value != 'All' &&
          match['skillLevel'] != selectedSkillLevel.value) {
        return false;
      }

      return true;
    }).toList();
  }

  void joinMatch(String matchId) {
    // Implement join match logic
    Get.snackbar(
      'Success',
      'Join request sent successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void acceptJoinRequest(String requestId) {
    joinRequests.removeWhere((request) => request['id'] == requestId);
    Get.snackbar(
      'Request Accepted',
      'Player has been added to your match',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void rejectJoinRequest(String requestId) {
    joinRequests.removeWhere((request) => request['id'] == requestId);
    Get.snackbar(
      'Request Rejected',
      'Join request has been declined',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
