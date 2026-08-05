import 'package:get/get.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// State for the player-facing "Matches" screen.
///
/// This build ships without a backend, so every action mutates the in-memory
/// seed data below. That is deliberate: joining, creating, accepting and
/// rejecting all have to produce a *visible* consequence (counters move, cards
/// change state, entries appear in "My Matches") for the demo to read as real.
class OpenMatchesController extends GetxController {
  static OpenMatchesController get to => Get.find<OpenMatchesController>();

  /// Which tab the screen is showing. Drives the search box, which only
  /// filters the "Open Matches" list.
  final RxInt currentTab = 0.obs;
  final RxList<Map<String, dynamic>> allMatches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredMatches =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> myMatches = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> joinRequests =
      <Map<String, dynamic>>[].obs;

  /// Ids of matches the signed-in player has asked to join. Drives the
  /// "Join Match" -> "Requested" button flip on every card and detail sheet.
  final RxSet<String> joinedMatchIds = <String>{}.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedMatchType = 'All'.obs;
  final RxString selectedSkillLevel = 'All'.obs;

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
    'Pro',
  ];

  /// Courts offered by the "Create Match" form. Keeps the created match's
  /// location consistent with the seeded ones so the filters keep working.
  final List<Map<String, String>> courts = const [
    {'name': 'Cairo Padel Club', 'location': 'New Cairo'},
    {'name': 'Elite Sports Center', 'location': 'Maadi'},
    {'name': 'Downtown Sports', 'location': 'Downtown Cairo'},
    {'name': 'Premium Padel', 'location': 'Sheikh Zayed'},
    {'name': 'Riverside Padel', 'location': 'Zamalek'},
  ];

  final List<String> durations = const [
    '1 hour',
    '1.5 hours',
    '2 hours',
    '3 hours',
  ];

  static const String _fallbackAvatar = 'assets/images/avatar1.jpg';

  /// Which account the seed data was built for, so a sign-out/sign-in does not
  /// leave the next player looking at the previous one's joins. Nothing calls
  /// `Get.delete` on this controller, so it has to notice the switch itself.
  String? _seededFor;

  @override
  void onInit() {
    super.onInit();
    loadForCurrentSession();
  }

  /// Seeds the demo data, and re-seeds it when the signed-in account changed.
  ///
  /// Called from the screen's `initState` as well as [onInit]: the controller
  /// outlives the screen, so this is the only place the switch is visible.
  void loadForCurrentSession() {
    final String owner = _session?.email ?? '';
    if (_seededFor == owner) return;
    _seededFor = owner;

    joinedMatchIds.clear();
    loadSampleMatches();
    loadMyMatches();
    loadJoinRequests();
    // NOTE: `filteredMatches.value = allMatches` used to alias one RxList's
    // backing store onto the other, so mutating allMatches silently mutated
    // filteredMatches too. clearFilters() -> applyFilters() always builds a
    // fresh plain list.
    clearFilters();
  }

  // ---------------------------------------------------------------------------
  // Seed data
  // ---------------------------------------------------------------------------

  void loadSampleMatches() {
    allMatches.assignAll([
      {
        'id': '1',
        'title': 'Evening Doubles Match',
        'description': 'Looking for 2 players to complete our doubles team',
        'createdBy': 'Sara Mohamed',
        'createdByAvatar': 'assets/images/avatar2.jpg',
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
          {'name': 'Sara Mohamed', 'avatar': 'assets/images/avatar2.jpg'},
          {'name': 'Hana Adel', 'avatar': 'assets/images/avatar4.jpg'},
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
      {
        // Hosted by the signed-in player, so "My Matches" has a real source
        // match behind it (View Details / Cancel both resolve).
        'id': 'my1',
        'title': 'My Weekend Match',
        'description': 'Friendly doubles with the usual crew. Squad complete.',
        'createdBy': currentPlayerName,
        'createdByAvatar': currentPlayerAvatar,
        'courtName': 'Premium Padel',
        'location': 'Sheikh Zayed',
        'date': DateTime.now().add(const Duration(days: 4)),
        'time': '19:00',
        'duration': '2 hours',
        'playersNeeded': 0,
        'currentPlayers': 4,
        'maxPlayers': 4,
        'skillLevel': 'Intermediate',
        'matchType': 'Doubles',
        'price': 45,
        'status': 'full',
        'joinRequests': 0,
        'players': [
          {'name': currentPlayerName, 'avatar': currentPlayerAvatar},
          {'name': 'Sara Mohamed', 'avatar': 'assets/images/avatar2.jpg'},
          {'name': 'Omar Khaled', 'avatar': 'assets/images/avatar5.jpg'},
          {'name': 'Layla Ahmed', 'avatar': 'assets/images/avatar4.jpg'},
        ],
      },
      {
        'id': '4',
        'title': 'Sunrise Singles Duel',
        'description': 'Fast-paced singles before work. One slot open.',
        'createdBy': 'Nour Hassan',
        'createdByAvatar': 'assets/images/avatar5.jpg',
        'courtName': 'Riverside Padel',
        'location': 'Zamalek',
        'date': DateTime.now().add(const Duration(days: 1)),
        'time': '07:30',
        'duration': '1 hour',
        'playersNeeded': 1,
        'currentPlayers': 1,
        'maxPlayers': 2,
        'skillLevel': 'Pro',
        'matchType': 'Singles',
        'price': 35,
        'status': 'open',
        'joinRequests': 0,
        'players': [
          {'name': 'Nour Hassan', 'avatar': 'assets/images/avatar5.jpg'},
        ],
      },
    ]);
  }

  void loadMyMatches() {
    myMatches.assignAll([
      {
        'id': 'my1',
        'title': 'My Weekend Match',
        'courtName': 'Premium Padel',
        'location': 'Sheikh Zayed',
        'date': DateTime.now().add(const Duration(days: 4)),
        'time': '19:00',
        'status': 'confirmed',
        'playersJoined': 4,
        'maxPlayers': 4,
        'role': 'host',
      },
    ]);
  }

  void loadJoinRequests() {
    joinRequests.assignAll([
      {
        'id': 'req1',
        'matchId': '1',
        'matchTitle': 'Evening Doubles Match',
        'playerName': 'Youssef Ahmed',
        'playerAvatar': 'assets/images/avatar4.jpg',
        'skillLevel': 'Intermediate',
        'message': 'Would love to join your match!',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 'req2',
        'matchId': '2',
        'matchTitle': 'Weekend Tournament Prep',
        'playerName': 'Nour Hassan',
        'playerAvatar': 'assets/images/avatar5.jpg',
        'skillLevel': 'Advanced',
        'message': 'Experienced player looking to join',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      },
    ]);
  }

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  void updateTab(int index) => currentTab.value = index;

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

  void clearFilters() {
    searchQuery.value = '';
    selectedMatchType.value = 'All';
    selectedSkillLevel.value = 'All';
    applyFilters();
  }

  bool get hasActiveFilters =>
      searchQuery.value.isNotEmpty ||
      selectedMatchType.value != 'All' ||
      selectedSkillLevel.value != 'All';

  void applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();

    filteredMatches.assignAll(
      allMatches.where((match) {
        if (query.isNotEmpty) {
          final haystack = [
            match['title'],
            match['location'],
            match['courtName'],
            match['createdBy'],
          ].join(' ').toLowerCase();
          if (!haystack.contains(query)) return false;
        }

        if (selectedMatchType.value != 'All' &&
            match['matchType'] != selectedMatchType.value) {
          return false;
        }

        if (selectedSkillLevel.value != 'All' &&
            match['skillLevel'] != selectedSkillLevel.value) {
          return false;
        }

        return true;
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Current player
  // ---------------------------------------------------------------------------

  SessionController? get _session =>
      Get.isRegistered<SessionController>() ? SessionController.to : null;

  String get currentPlayerName {
    final session = _session;
    if (session != null && session.isSignedIn) return session.displayName;
    return 'You';
  }

  String get currentPlayerAvatar =>
      _session?.current?.avatarAsset ?? _fallbackAvatar;

  Map<String, dynamic>? matchById(String matchId) {
    final index = allMatches.indexWhere((m) => m['id'] == matchId);
    return index == -1 ? null : allMatches[index];
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Adds the signed-in player to [matchId] and mirrors it into "My Matches".
  void joinMatch(String matchId) {
    final match = matchById(matchId);
    if (match == null) {
      AppFeedback.error('Match unavailable', 'This match no longer exists.');
      return;
    }

    if (joinedMatchIds.contains(matchId)) {
      AppFeedback.info(
        'Already requested',
        'You are on the list for "${match['title']}".',
      );
      return;
    }

    final int needed = match['playersNeeded'] as int;
    if (needed <= 0) {
      AppFeedback.warning(
        'Match is full',
        'All ${match['maxPlayers']} slots for "${match['title']}" are taken.',
      );
      return;
    }

    match['playersNeeded'] = needed - 1;
    match['currentPlayers'] = (match['currentPlayers'] as int) + 1;
    (match['players'] as List).add({
      'name': currentPlayerName,
      'avatar': currentPlayerAvatar,
    });
    if (match['playersNeeded'] == 0) match['status'] = 'full';

    joinedMatchIds.add(matchId);
    myMatches.insert(0, _myMatchEntry(match, role: 'player'));

    allMatches.refresh();
    applyFilters();

    AppFeedback.success(
      'You are in!',
      '"${match['title']}" was added to My Matches.',
    );
  }

  /// Removes the signed-in player from a match they joined.
  void leaveMatch(String matchId) {
    if (!joinedMatchIds.contains(matchId)) return;

    final match = matchById(matchId);
    if (match != null) {
      match['playersNeeded'] = (match['playersNeeded'] as int) + 1;
      match['currentPlayers'] = (match['currentPlayers'] as int) - 1;
      (match['players'] as List)
          .removeWhere((player) => player['name'] == currentPlayerName);
      match['status'] = 'open';
    }

    joinedMatchIds.remove(matchId);
    myMatches.removeWhere((entry) => entry['id'] == matchId);

    allMatches.refresh();
    applyFilters();

    AppFeedback.info(
      'Left the match',
      'Your slot in "${match?['title'] ?? 'the match'}" is open again.',
    );
  }

  /// Cancels a match the player hosts, removing it everywhere.
  void cancelMatch(String matchId) {
    final index = myMatches.indexWhere((entry) => entry['id'] == matchId);
    final String title =
        index == -1 ? 'Match' : myMatches[index]['title'] as String;

    allMatches.removeWhere((match) => match['id'] == matchId);
    myMatches.removeWhere((entry) => entry['id'] == matchId);
    joinRequests.removeWhere((request) => request['matchId'] == matchId);
    joinedMatchIds.remove(matchId);

    applyFilters();
    AppFeedback.warning('Match cancelled', '"$title" was removed.');
  }

  /// Builds a new match from the Create Match form and publishes it.
  ///
  /// Returns the created match so the caller can report on it.
  Map<String, dynamic> createMatch({
    required String title,
    required String description,
    required String courtName,
    required String location,
    required DateTime date,
    required String time,
    required String duration,
    required int playersNeeded,
    required String skillLevel,
    required String matchType,
    required int price,
  }) {
    // The format decides how many players fit on the court — a Doubles match
    // seats four whether the host opened one slot or three. Deriving it from
    // playersNeeded used to publish a "Doubles" match that filled at 1/3.
    final int maxPlayers = matchType == 'Singles' ? 2 : 4;
    final int openSlots = playersNeeded.clamp(1, maxPlayers - 1);

    final match = <String, dynamic>{
      'id': 'm${DateTime.now().microsecondsSinceEpoch}',
      'title': title,
      'description': description,
      'createdBy': currentPlayerName,
      'createdByAvatar': currentPlayerAvatar,
      'courtName': courtName,
      'location': location,
      'date': date,
      'time': time,
      'duration': duration,
      'playersNeeded': openSlots,
      'currentPlayers': 1,
      'maxPlayers': maxPlayers,
      'skillLevel': skillLevel,
      'matchType': matchType,
      'price': price,
      'status': 'open',
      'joinRequests': 0,
      'players': [
        {'name': currentPlayerName, 'avatar': currentPlayerAvatar},
      ],
    };

    allMatches.insert(0, match);
    myMatches.insert(0, _myMatchEntry(match, role: 'host'));

    // A brand new match must survive whatever filters are active, otherwise it
    // is created and instantly invisible.
    clearFilters();

    return match;
  }

  void acceptJoinRequest(String requestId) {
    final index = joinRequests.indexWhere((r) => r['id'] == requestId);
    if (index == -1) return;
    final request = joinRequests[index];

    final match = _matchForRequest(request);
    if (match != null) {
      final int needed = match['playersNeeded'] as int;
      if (needed <= 0) {
        AppFeedback.warning(
          'Match is full',
          '"${match['title']}" has no free slot for ${request['playerName']}.',
        );
        return;
      }

      match['playersNeeded'] = needed - 1;
      match['currentPlayers'] = (match['currentPlayers'] as int) + 1;
      (match['players'] as List).add({
        'name': request['playerName'],
        'avatar': request['playerAvatar'],
      });
      match['joinRequests'] =
          ((match['joinRequests'] as int) - 1).clamp(0, 1 << 30);
      if (match['playersNeeded'] == 0) match['status'] = 'full';

      _syncMyMatch(match);
      allMatches.refresh();
      applyFilters();
    }

    joinRequests.removeAt(index);
    AppFeedback.success(
      'Request accepted',
      '${request['playerName']} joined "${request['matchTitle']}".',
    );
  }

  void rejectJoinRequest(String requestId) {
    final index = joinRequests.indexWhere((r) => r['id'] == requestId);
    if (index == -1) return;
    final request = joinRequests[index];

    final match = _matchForRequest(request);
    if (match != null) {
      match['joinRequests'] =
          ((match['joinRequests'] as int) - 1).clamp(0, 1 << 30);
      allMatches.refresh();
      applyFilters();
    }

    joinRequests.removeAt(index);
    AppFeedback.info(
      'Request declined',
      '${request['playerName']} was not added to the match.',
    );
  }

  void clearJoinRequests() {
    if (joinRequests.isEmpty) return;
    final int count = joinRequests.length;

    for (final request in joinRequests) {
      final match = _matchForRequest(request);
      if (match == null) continue;
      match['joinRequests'] =
          ((match['joinRequests'] as int) - 1).clamp(0, 1 << 30);
    }

    joinRequests.clear();
    allMatches.refresh();
    applyFilters();

    AppFeedback.info(
      'Inbox cleared',
      '$count join ${count == 1 ? 'request was' : 'requests were'} dismissed.',
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Map<String, dynamic>? _matchForRequest(Map<String, dynamic> request) {
    final byId = matchById(request['matchId'] as String? ?? '');
    if (byId != null) return byId;
    final index =
        allMatches.indexWhere((m) => m['title'] == request['matchTitle']);
    return index == -1 ? null : allMatches[index];
  }

  Map<String, dynamic> _myMatchEntry(
    Map<String, dynamic> match, {
    required String role,
  }) {
    return {
      'id': match['id'],
      'title': match['title'],
      'courtName': match['courtName'],
      'location': match['location'],
      'date': match['date'],
      'time': match['time'],
      'status': role == 'host' ? 'confirmed' : 'pending',
      'playersJoined': match['currentPlayers'],
      'maxPlayers': match['maxPlayers'],
      'role': role,
    };
  }

  /// Keeps the "My Matches" summary in step with the source match after other
  /// players are added to it.
  void _syncMyMatch(Map<String, dynamic> match) {
    final index = myMatches.indexWhere((entry) => entry['id'] == match['id']);
    if (index == -1) return;
    myMatches[index] = {
      ...myMatches[index],
      'playersJoined': match['currentPlayers'],
      'maxPlayers': match['maxPlayers'],
    };
  }
}
