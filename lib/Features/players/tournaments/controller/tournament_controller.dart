import 'package:get/get.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// Outcome of a join attempt, so the screen can react (e.g. hop to the
/// "My Tournaments" tab) without re-deriving the reason from the state.
enum TournamentJoinResult { joined, alreadyRequested, full, notFound }

class TournamentsController extends GetxController {
  static TournamentsController get to => Get.find<TournamentsController>();

  // ---------------------------------------------------------------- state
  /// Id of the tournament whose join request is in flight. This used to be a
  /// single global `isLoading`, which spun *every* card's join button at once.
  final RxnString joiningId = RxnString();

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

  /// Options offered by the "Create Tournament" form.
  final List<String> formatOptions = [
    'Elimination',
    'Round Robin',
    'Groups + Knockout',
  ];

  /// Which account the seed data was built for. `null` until the first seed.
  String? _seededFor;

  @override
  void onInit() {
    super.onInit();
    loadForCurrentSession();
  }

  /// Seeds the demo data once per signed-in account. The screen re-uses a
  /// permanent instance, so re-entering the tab must not wipe joins the user
  /// already made — but nothing calls `Get.delete` on sign-out either, so a
  /// different account has to get a clean set instead of inheriting the
  /// previous player's registrations.
  void loadForCurrentSession() {
    final String owner =
        Get.isRegistered<SessionController>() ? SessionController.to.email : '';
    if (_seededFor == owner) return;
    _seededFor = owner;

    loadSampleTournaments();
    loadMyTournaments();
    loadEntryRequests();
    resetFilters();
  }

  void loadSampleTournaments() {
    allTournaments.assignAll([
      {
        'id': '1',
        'title': 'Cairo Open Championship',
        'description':
            'Official championship with cash prizes and professional referees. '
                'Three days of competitive padel across singles and mixed doubles, '
                'played on eight glass courts with full live scoring.',
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
        'hasJoined': false,
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
            'Fun tournament for recreational players with trophy prizes. '
                'One long Saturday, guaranteed three matches per pair, and a '
                'barbecue while the final is played.',
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
        // Already on the entry list — demonstrates the "Requested" button state.
        'hasJoined': true,
        'features': ['Refreshments', 'Photography'],
      },
      {
        'id': '3',
        'title': 'Beginner Friendly Cup',
        'description': 'Perfect for new players to get tournament experience. '
            'Every pair gets a short warm-up with a coach and a rules briefing '
            'before the first serve.',
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
        'hasJoined': false,
        'features': ['Coaching Tips', 'Beginner Equipment'],
      },
      {
        'id': '4',
        'title': 'Pro League Championship',
        'description': 'Elite tournament for professional players only. '
            'Seeded draw, hawk-eye review on centre court and a televised final.',
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
        'currentParticipants': 24,
        'skillLevel': 'Pro',
        'prizeType': 'Cash Prize',
        'status': 'open',
        'format': 'Elimination',
        'categories': ['Men Singles', 'Women Singles'],
        'entryRequests': 15,
        'hasJoined': false,
        'features': ['International Referees', 'TV Coverage', 'VIP Lounge'],
      },
    ]);
  }

  void loadMyTournaments() {
    myTournaments.assignAll([
      {
        'id': 'my-2',
        'tournamentId': '2',
        'title': 'Weekend Warriors Cup',
        'startDate': DateTime.now().add(const Duration(days: 8)),
        'status': 'registered',
        'entryFee': 100,
        'position': 'Registered',
      },
    ]);
  }

  void loadEntryRequests() {
    entryRequests.assignAll([
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
    ]);
  }

  // ------------------------------------------------------------- lookups
  /// Reads through the observable list so callers inside an `Obx` re-run when
  /// a tournament is mutated and `allTournaments.refresh()` fires.
  Map<String, dynamic>? tournamentById(String? id) {
    if (id == null) return null;
    final index = allTournaments.indexWhere((t) => t['id'] == id);
    return index == -1 ? null : allTournaments[index];
  }

  bool isFull(Map<String, dynamic> tournament) =>
      (tournament['currentParticipants'] as int) >=
      (tournament['maxParticipants'] as int);

  bool hasJoined(Map<String, dynamic> tournament) =>
      tournament['hasJoined'] == true;

  // ------------------------------------------------------------- filtering
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

  void resetFilters() {
    searchQuery.value = '';
    selectedTournamentType.value = 'All';
    selectedSkillLevel.value = 'All';
    selectedPrizeType.value = 'All';
    applyFilters();
  }

  void applyFilters() {
    final result = allTournaments.where((tournament) {
      // Search filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        if (!'${tournament['title']}'.toLowerCase().contains(query) &&
            !'${tournament['location']}'.toLowerCase().contains(query) &&
            !'${tournament['organizer']}'.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Tournament type filter. The dropdown says "Player Created" while the
      // data says "Player", so normalise before comparing.
      if (selectedTournamentType.value != 'All') {
        final wanted = selectedTournamentType.value == 'Player Created'
            ? 'Player'
            : 'Official';
        if (tournament['organizerType'] != wanted) return false;
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

    // A fresh list instance: never hand `allTournaments` itself to
    // `filteredTournaments`, or in-place edits would hit both lists.
    filteredTournaments.assignAll(result);
  }

  // ------------------------------------------------------------- join flow
  Future<TournamentJoinResult> joinTournament(String tournamentId) async {
    final tournament = tournamentById(tournamentId);

    if (tournament == null) {
      AppFeedback.error(
        'Tournament unavailable',
        'We could not find that tournament any more.',
      );
      return TournamentJoinResult.notFound;
    }

    if (hasJoined(tournament)) {
      AppFeedback.info(
        'Already requested',
        'Your entry for "${tournament['title']}" is waiting for the organizer.',
      );
      return TournamentJoinResult.alreadyRequested;
    }

    if (isFull(tournament)) {
      AppFeedback.warning(
        'Tournament is full',
        '${tournament['title']} has reached ${tournament['maxParticipants']} players.',
      );
      return TournamentJoinResult.full;
    }

    // Offline demo: a short delay stands in for the network round trip.
    joiningId.value = tournamentId;
    await Future.delayed(const Duration(milliseconds: 600));

    tournament['currentParticipants'] =
        (tournament['currentParticipants'] as int) + 1;
    tournament['hasJoined'] = true;

    myTournaments.insert(0, {
      'id': 'my-$tournamentId',
      'tournamentId': tournamentId,
      'title': tournament['title'],
      'startDate': tournament['startDate'],
      'status': 'pending',
      'entryFee': tournament['entryFee'],
      'position': 'Awaiting approval',
    });

    // The cards are built from plain Map snapshots, so mutating the map is not
    // enough — refresh + re-filter is what actually rebuilds the list.
    allTournaments.refresh();
    applyFilters();
    joiningId.value = null;

    AppFeedback.success(
      'Entry request sent',
      'You are on the list for ${tournament['title']}. Find it under "My Tournaments".',
    );
    return TournamentJoinResult.joined;
  }

  /// Cancels a registration made from "My Tournaments" and frees the slot.
  void withdrawFromTournament(String myTournamentId) {
    final index = myTournaments.indexWhere((t) => t['id'] == myTournamentId);
    if (index == -1) return;

    final entry = myTournaments.removeAt(index);
    final tournament = tournamentById(entry['tournamentId'] as String?);
    if (tournament != null) {
      final current = tournament['currentParticipants'] as int;
      if (current > 0) tournament['currentParticipants'] = current - 1;
      tournament['hasJoined'] = false;
      allTournaments.refresh();
      applyFilters();
    }

    AppFeedback.info(
      'Registration withdrawn',
      'You left ${entry['title']}. Your slot is back in the pool.',
    );
  }

  // --------------------------------------------------------- entry requests
  /// Accepts a request and gives the player a slot in the matching tournament.
  /// Returns the removed request, or `null` if it was already handled — the old
  /// `firstWhere` without `orElse` threw a StateError in that case.
  Map<String, dynamic>? acceptEntryRequest(String requestId) {
    final index = entryRequests.indexWhere((req) => req['id'] == requestId);
    if (index == -1) return null;

    final request = entryRequests.removeAt(index);
    _consumePendingRequest(request, seatPlayer: true);

    AppFeedback.success(
      'Entry accepted',
      '${request['playerName']} is now in ${request['tournamentTitle']}.',
    );
    return request;
  }

  Map<String, dynamic>? rejectEntryRequest(String requestId) {
    final index = entryRequests.indexWhere((req) => req['id'] == requestId);
    if (index == -1) return null;

    final request = entryRequests.removeAt(index);
    _consumePendingRequest(request, seatPlayer: false);

    AppFeedback.warning(
      'Entry declined',
      '${request['playerName']} was not added to ${request['tournamentTitle']}.',
    );
    return request;
  }

  void _consumePendingRequest(
    Map<String, dynamic> request, {
    required bool seatPlayer,
  }) {
    final index = allTournaments
        .indexWhere((t) => t['title'] == request['tournamentTitle']);
    if (index == -1) return;

    final tournament = allTournaments[index];
    final pending = tournament['entryRequests'] as int;
    if (pending > 0) tournament['entryRequests'] = pending - 1;
    if (seatPlayer && !isFull(tournament)) {
      tournament['currentParticipants'] =
          (tournament['currentParticipants'] as int) + 1;
    }
    allTournaments.refresh();
    applyFilters();
  }

  void clearAllRequests() {
    if (entryRequests.isEmpty) return;
    final count = entryRequests.length;
    for (final request in entryRequests.toList()) {
      _consumePendingRequest(request, seatPlayer: false);
    }
    entryRequests.clear();
    AppFeedback.info(
      'Inbox cleared',
      '$count pending ${count == 1 ? 'request' : 'requests'} dismissed.',
    );
  }

  // ------------------------------------------------------------- creation
  /// Adds a player-created tournament to the top of the list and registers the
  /// creator for it, so the new entry is visible in both tabs immediately.
  Map<String, dynamic> createTournament({
    required String title,
    required String description,
    required String courtName,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime registrationDeadline,
    required int entryFee,
    required int prizePool,
    required int maxParticipants,
    required String skillLevel,
    required String prizeType,
    required String format,
  }) {
    final organizer = Get.isRegistered<SessionController>()
        ? SessionController.to.displayName
        : 'You';

    final tournament = <String, dynamic>{
      'id': 't${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'description': description,
      'organizer': organizer,
      'organizerType': 'Player',
      'organizerAvatar': '',
      'courtName': courtName,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'registrationDeadline': registrationDeadline,
      'entryFee': entryFee,
      'prizePool': prizePool,
      'maxParticipants': maxParticipants,
      'currentParticipants': 1,
      'skillLevel': skillLevel,
      'prizeType': prizeType,
      'status': 'open',
      'format': format,
      'categories': const ['Open Draw'],
      'entryRequests': 0,
      'hasJoined': true,
      'features': const ['Organized by a player', 'Flexible scheduling'],
    };

    allTournaments.insert(0, tournament);
    myTournaments.insert(0, {
      'id': 'my-${tournament['id']}',
      'tournamentId': tournament['id'],
      'title': title,
      'startDate': startDate,
      'status': 'registered',
      'entryFee': entryFee,
      'position': 'Organizer',
    });

    // Clear any active filter so the brand new tournament is not hidden.
    resetFilters();

    AppFeedback.success(
      'Tournament created',
      '$title is live and open for entries.',
    );
    return tournament;
  }
}
