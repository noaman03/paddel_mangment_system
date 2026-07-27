// Create: lib/Features/players/tournaments/controller/tournaments_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/core/const/colors.dart';

class TournamentsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var currentTab = 0.obs;
  var allTournaments = <Map<String, dynamic>>[].obs;
  var filteredTournaments = <Map<String, dynamic>>[].obs;
  var myTournaments = <Map<String, dynamic>>[].obs;
  var entryRequests = <Map<String, dynamic>>[].obs;
  var searchQuery = ''.obs;
  var selectedTournamentType = 'All'.obs;
  var selectedSkillLevel = 'All'.obs;
  var selectedPrizeType = 'All'.obs;

  // Filter options
  final List<String> tournamentTypes = ['All', 'Official', 'Player Created'];
  final List<String> skillLevels = [
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Pro'
  ];
  final List<String> prizeTypes = ['All', 'Cash Prize', 'Trophies', 'Fun Only'];

  @override
  void onInit() {
    super.onInit();
    loadSampleTournaments();
    loadMyTournaments();
    loadEntryRequests();
    filteredTournaments.value = allTournaments;
  }

  void loadSampleTournaments() {
    allTournaments.value = [
      {
        'id': '1',
        'title': 'Cairo Open Championship',
        'description':
            'Official championship with cash prizes and professional referees',
        'organizer': 'Cairo Padel Club',
        'organizerType': 'Official',
        'organizerAvatar': 'assets/images/club_logo.png',
        'courtName': 'Cairo Padel Club',
        'location': 'New Cairo',
        'startDate': DateTime.now().add(const Duration(days: 15)),
        'endDate': DateTime.now().add(const Duration(days: 17)),
        'registrationDeadline': DateTime.now().add(const Duration(days: 10)),
        'entryFee': 500,
        'prizePool': 15000,
        'maxParticipants': 32,
        'currentParticipants': 18,
        'skillLevel': 'Advanced',
        'prizeType': 'Cash Prize',
        'status': 'open',
        'format': 'Elimination',
        'categories': ['Men Singles', 'Women Singles', 'Mixed Doubles'],
        'entryRequests': 8,
        'features': [
          'Professional Referees',
          'Live Streaming',
          'Medical Support'
        ],
      },
      {
        'id': '2',
        'title': 'Weekend Warriors Cup',
        'description':
            'Fun tournament for recreational players with trophy prizes',
        'organizer': 'Ahmed Hassan',
        'organizerType': 'Player',
        'organizerAvatar': 'assets/images/avatar1.jpg',
        'courtName': 'Elite Sports Center',
        'location': 'Maadi',
        'startDate': DateTime.now().add(const Duration(days: 8)),
        'endDate': DateTime.now().add(const Duration(days: 8)),
        'registrationDeadline': DateTime.now().add(const Duration(days: 5)),
        'entryFee': 100,
        'prizePool': 0,
        'maxParticipants': 16,
        'currentParticipants': 12,
        'skillLevel': 'Intermediate',
        'prizeType': 'Trophies',
        'status': 'open',
        'format': 'Round Robin',
        'categories': ['Doubles Only'],
        'entryRequests': 4,
        'features': ['Refreshments', 'Photography'],
      },
      {
        'id': '3',
        'title': 'Beginner Friendly Cup',
        'description': 'Perfect for new players to get tournament experience',
        'organizer': 'Sara Mohamed',
        'organizerType': 'Player',
        'organizerAvatar': 'assets/images/avatar2.jpg',
        'courtName': 'Downtown Sports',
        'location': 'Downtown Cairo',
        'startDate': DateTime.now().add(const Duration(days: 12)),
        'endDate': DateTime.now().add(const Duration(days: 12)),
        'registrationDeadline': DateTime.now().add(const Duration(days: 7)),
        'entryFee': 50,
        'prizePool': 0,
        'maxParticipants': 12,
        'currentParticipants': 8,
        'skillLevel': 'Beginner',
        'prizeType': 'Fun Only',
        'status': 'open',
        'format': 'Round Robin',
        'categories': ['Mixed Doubles'],
        'entryRequests': 2,
        'features': ['Coaching Tips', 'Beginner Equipment'],
      },
      {
        'id': '4',
        'title': 'Pro League Championship',
        'description': 'Elite tournament for professional players only',
        'organizer': 'Egyptian Padel Federation',
        'organizerType': 'Official',
        'organizerAvatar': 'assets/images/federation_logo.png',
        'courtName': 'Premium Padel Arena',
        'location': 'Zamalek',
        'startDate': DateTime.now().add(const Duration(days: 25)),
        'endDate': DateTime.now().add(const Duration(days: 27)),
        'registrationDeadline': DateTime.now().add(const Duration(days: 20)),
        'entryFee': 1000,
        'prizePool': 50000,
        'maxParticipants': 24,
        'currentParticipants': 16,
        'skillLevel': 'Pro',
        'prizeType': 'Cash Prize',
        'status': 'open',
        'format': 'Elimination',
        'categories': ['Men Singles', 'Women Singles'],
        'entryRequests': 15,
        'features': ['International Referees', 'TV Coverage', 'VIP Lounge'],
      },
    ];
  }

  void loadMyTournaments() {
    myTournaments.value = [
      {
        'id': 'my1',
        'title': 'My Local Cup',
        'startDate': DateTime.now().add(const Duration(days: 6)),
        'status': 'registered',
        'entryFee': 100,
        'position': 'Registered',
      },
    ];
  }

  void loadEntryRequests() {
    entryRequests.value = [
      {
        'id': 'req1',
        'tournamentTitle': 'Weekend Warriors Cup',
        'playerName': 'Omar Khaled',
        'playerAvatar': 'assets/images/avatar3.jpg',
        'skillLevel': 'Intermediate',
        'experience': '2 years playing',
        'message': 'Excited to participate in this tournament!',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        'category': 'Doubles',
      },
      {
        'id': 'req2',
        'tournamentTitle': 'Beginner Friendly Cup',
        'playerName': 'Layla Ahmed',
        'playerAvatar': 'assets/images/avatar4.jpg',
        'skillLevel': 'Beginner',
        'experience': '6 months playing',
        'message': 'This would be my first tournament!',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'category': 'Mixed Doubles',
      },
    ];
  }

  void updateTab(int index) {
    currentTab.value = index;
  }

  void searchTournaments(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void updateTournamentType(String type) {
    selectedTournamentType.value = type;
    applyFilters();
  }

  void updateSkillLevel(String level) {
    selectedSkillLevel.value = level;
    applyFilters();
  }

  void updatePrizeType(String type) {
    selectedPrizeType.value = type;
    applyFilters();
  }

  void applyFilters() {
    filteredTournaments.value = allTournaments.where((tournament) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!tournament['title'].toLowerCase().contains(query) &&
            !tournament['location'].toLowerCase().contains(query) &&
            !tournament['organizer'].toLowerCase().contains(query)) {
          return false;
        }
      }

      // Tournament type filter
      if (selectedTournamentType.value != 'All' &&
          tournament['organizerType'] != selectedTournamentType.value) {
        return false;
      }

      // Skill level filter
      if (selectedSkillLevel.value != 'All' &&
          tournament['skillLevel'] != selectedSkillLevel.value) {
        return false;
      }

      // Prize type filter
      if (selectedPrizeType.value != 'All' &&
          tournament['prizeType'] != selectedPrizeType.value) {
        return false;
      }

      return true;
    }).toList();
  }

  void joinTournament(String tournamentId) {
    isLoading.value = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;

      Get.snackbar(
        'Entry Request Sent!',
        'Your tournament entry request has been submitted. You\'ll be notified once it\'s reviewed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    });
  }

  void acceptEntryRequest(String requestId) {
    final request = entryRequests.firstWhere((req) => req['id'] == requestId);
    entryRequests.removeWhere((request) => request['id'] == requestId);

    Get.snackbar(
      'Entry Accepted!',
      '${request['playerName']} has been accepted to your tournament',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.person_add, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void rejectEntryRequest(String requestId) {
    final request = entryRequests.firstWhere((req) => req['id'] == requestId);
    entryRequests.removeWhere((request) => request['id'] == requestId);

    Get.snackbar(
      'Entry Declined',
      'Entry request from ${request['playerName']} has been declined',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AColors.warning,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.person_remove, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void clearAllRequests() {
    entryRequests.clear();
  }
}
