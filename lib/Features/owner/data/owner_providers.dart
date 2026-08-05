import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:padel_management_system/Features/owner/data/owner_models.dart';
import 'package:padel_management_system/core/const/court_images.dart';

/// In-memory demo state for the whole owner panel.
///
/// This build ships without a backend — Firestore calls hang offline — so the
/// seed data below *is* the database. Every owner action mutates it through one
/// of the notifiers here, which is why a tournament created from the dashboard
/// quick action shows up in the Tournaments tab (it previously did not: each
/// screen kept its own private `List` in `initState`).

DateTime _atHour(DateTime day, int hour) =>
    DateTime(day.year, day.month, day.day, hour);

DateTime _dayOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

// ---------------------------------------------------------------------------
// Courts
// ---------------------------------------------------------------------------

class OwnerCourtsNotifier extends StateNotifier<List<OwnerCourt>> {
  OwnerCourtsNotifier() : super(_seed());

  void add(OwnerCourt court) => state = <OwnerCourt>[...state, court];

  void update(OwnerCourt court) => state = <OwnerCourt>[
        for (final item in state)
          if (item.id == court.id) court else item,
      ];

  void remove(String id) =>
      state = state.where((court) => court.id != id).toList();

  void toggleActive(String id) => state = <OwnerCourt>[
        for (final item in state)
          if (item.id == id) item.copyWith(isActive: !item.isActive) else item,
      ];

  void addImage(String id, String source) => state = <OwnerCourt>[
        for (final item in state)
          if (item.id == id)
            item.copyWith(images: <String>[...item.images, source])
          else
            item,
      ];

  void removeImageAt(String id, int index) => state = <OwnerCourt>[
        for (final item in state)
          if (item.id == id)
            item.copyWith(
              images: <String>[
                for (var i = 0; i < item.images.length; i++)
                  if (i != index) item.images[i],
              ],
            )
          else
            item,
      ];

  static List<OwnerCourt> _seed() => const <OwnerCourt>[
        OwnerCourt(
          id: 'court-1',
          name: 'Al Noor Padel Club',
          location: 'Downtown Cairo',
          pricePerHour: 250,
          description:
              'Premium padel courts with professional lighting and excellent '
              'facilities. Perfect for tournament play and training sessions.',
          facilities: <String>[
            'Air Conditioning',
            'Professional Lighting',
            'Cafe',
            'Parking',
            'Locker Rooms',
          ],
          images: <String>[CourtImages.alNoor, CourtImages.alNoorAlt],
        ),
        OwnerCourt(
          id: 'court-2',
          name: 'Al Ahmar Padel Club',
          location: 'New Cairo',
          pricePerHour: 300,
          description:
              'Modern courts in a strategic location with professional staff, '
              'a full restaurant and VIP facilities.',
          facilities: <String>[
            'Advanced Air Conditioning',
            'International Courts',
            'Restaurant & Cafe',
            'Parking',
            'VIP Rooms',
            'Training Hall',
          ],
          images: <String>[CourtImages.alAhmar, CourtImages.alAhmarAlt],
        ),
        OwnerCourt(
          id: 'court-3',
          name: 'Athletes Club',
          location: 'Giza',
          pricePerHour: 200,
          description:
              'Sports padel courts at competitive prices with professional '
              'standards, suitable for pros and hobbyists alike.',
          facilities: <String>[
            'Air Conditioning',
            'Professional Lighting',
            'Reception',
            'Parking',
            'Changing Rooms',
          ],
          images: <String>[CourtImages.athletes, CourtImages.athletesAlt],
        ),
        OwnerCourt(
          id: 'court-4',
          name: 'Alexandria Courts',
          location: 'Alexandria',
          pricePerHour: 180,
          description:
              'Courts overlooking the Mediterranean with excellent facilities '
              'and a professional setup.',
          facilities: <String>[
            'Air Conditioning',
            'Seafood Restaurant',
            'Parking',
            'Locker Rooms',
            'Private Beach',
            'Swimming Pool',
          ],
          images: <String>[CourtImages.alexandria, CourtImages.alexandriaAlt],
          isActive: false,
        ),
      ];
}

final ownerCourtsProvider =
    StateNotifierProvider<OwnerCourtsNotifier, List<OwnerCourt>>(
  (ref) => OwnerCourtsNotifier(),
);

// ---------------------------------------------------------------------------
// Tournaments
// ---------------------------------------------------------------------------

class OwnerTournamentsNotifier extends StateNotifier<List<OwnerTournament>> {
  OwnerTournamentsNotifier() : super(_seed());

  void add(OwnerTournament tournament) =>
      state = <OwnerTournament>[tournament, ...state];

  /// The edit path used to be an empty `else { // Edit existing }` block, so
  /// every change an owner made was silently thrown away.
  void update(OwnerTournament tournament) => state = <OwnerTournament>[
        for (final item in state)
          if (item.id == tournament.id) tournament else item,
      ];

  void remove(String id) =>
      state = state.where((tournament) => tournament.id != id).toList();

  OwnerTournament? byId(String id) {
    for (final tournament in state) {
      if (tournament.id == id) return tournament;
    }
    return null;
  }

  void setStatus(String id, TournamentStatus status) =>
      state = <OwnerTournament>[
        for (final item in state)
          if (item.id == id) item.copyWith(status: status) else item,
      ];

  /// Moves a pending entry into the confirmed list. Returns false when the
  /// tournament is already full, so the caller can explain why nothing changed.
  bool acceptTeam(String id, String team) {
    final tournament = byId(id);
    if (tournament == null) return false;
    if (tournament.isFull) return false;
    update(
      tournament.copyWith(
        teams: <String>[...tournament.teams, team],
        pendingTeams:
            tournament.pendingTeams.where((item) => item != team).toList(),
      ),
    );
    return true;
  }

  void declineTeam(String id, String team) {
    final tournament = byId(id);
    if (tournament == null) return;
    update(
      tournament.copyWith(
        pendingTeams:
            tournament.pendingTeams.where((item) => item != team).toList(),
      ),
    );
  }

  void withdrawTeam(String id, String team) {
    final tournament = byId(id);
    if (tournament == null) return;
    update(
      tournament.copyWith(
        teams: tournament.teams.where((item) => item != team).toList(),
      ),
    );
  }

  static List<String> _teams(int count) => <String>[
        'Hassan & Karim',
        'Nour & Salma',
        'Omar & Youssef',
        'Mariam & Dina',
        'Adel & Tarek',
        'Laila & Farida',
        'Sherif & Amr',
        'Rana & Habiba',
        'Ziad & Marwan',
        'Nadia & Menna',
        'Kareem & Seif',
        'Hana & Jana',
        'Bassem & Rami',
        'Yara & Malak',
        'Fady & Peter',
        'Aya & Sara',
      ].take(count).toList();

  static List<OwnerTournament> _seed() {
    final today = _dayOnly(DateTime.now());
    return <OwnerTournament>[
      OwnerTournament(
        id: 'tour-1',
        name: 'Spring Championship',
        type: 'Doubles',
        courtName: 'Al Noor Padel Club',
        startDate: today.add(const Duration(days: 21)),
        endDate: today.add(const Duration(days: 28)),
        maxTeams: 16,
        description:
            'Our flagship spring tournament: eight days of group stages and '
            'knockouts, open to every level with a seeded pro bracket.',
        status: TournamentStatus.upcoming,
        prizePool: 25000,
        entryFee: 600,
        teams: _teams(14),
        pendingTeams: const <String>['Mostafa & Wael', 'Injy & Farah'],
      ),
      OwnerTournament(
        id: 'tour-2',
        name: 'Weekend Warriors Cup',
        type: 'Mixed Doubles',
        courtName: 'Al Ahmar Padel Club',
        startDate: today.add(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 4)),
        maxTeams: 12,
        description:
            'A relaxed two-day mixed tournament for amateurs, with a barbecue '
            'and a prize ceremony on the Saturday evening.',
        status: TournamentStatus.upcoming,
        prizePool: 8000,
        entryFee: 250,
        teams: _teams(10),
        pendingTeams: const <String>['Sara & Hazem'],
      ),
      OwnerTournament(
        id: 'tour-3',
        name: 'Summer Grand Slam',
        type: 'Singles',
        courtName: 'Athletes Club',
        startDate: today.subtract(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 6)),
        maxTeams: 24,
        description:
            'The largest singles event of the season, with live scoring, media '
            'coverage and a qualifying weekend.',
        status: TournamentStatus.ongoing,
        prizePool: 50000,
        entryFee: 900,
        teams: _teams(16),
      ),
      OwnerTournament(
        id: 'tour-4',
        name: 'Winter Championship',
        type: 'Doubles',
        courtName: 'Alexandria Courts',
        startDate: today.subtract(const Duration(days: 60)),
        endDate: today.subtract(const Duration(days: 51)),
        maxTeams: 16,
        description:
            'Ten days of seaside padel in Alexandria. Won by Hassan & Karim '
            'after a three-set final.',
        status: TournamentStatus.completed,
        prizePool: 35000,
        entryFee: 500,
        teams: _teams(16),
      ),
    ];
  }
}

final ownerTournamentsProvider =
    StateNotifierProvider<OwnerTournamentsNotifier, List<OwnerTournament>>(
  (ref) => OwnerTournamentsNotifier(),
);

// ---------------------------------------------------------------------------
// Bookings
// ---------------------------------------------------------------------------

class OwnerBookingsNotifier extends StateNotifier<List<OwnerBooking>> {
  OwnerBookingsNotifier() : super(_seed());

  void setStatus(String id, BookingStatus status) => state = <OwnerBooking>[
        for (final item in state)
          if (item.id == id) item.copyWith(status: status) else item,
      ];

  List<OwnerBooking> onDay(DateTime day) =>
      state.where((booking) => booking.isOnDay(day)).toList();

  static List<OwnerBooking> _seed() {
    final today = _dayOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    return <OwnerBooking>[
      OwnerBooking(
        id: 'bk-1',
        courtName: 'Al Noor Padel Club',
        playerName: 'Ahmed Hassan',
        start: _atHour(today, 18),
        hours: 2,
        amount: 500,
        status: BookingStatus.confirmed,
      ),
      OwnerBooking(
        id: 'bk-2',
        courtName: 'Al Ahmar Padel Club',
        playerName: 'Nour Ibrahim',
        start: _atHour(today, 20),
        hours: 1,
        amount: 300,
        status: BookingStatus.pending,
      ),
      OwnerBooking(
        id: 'bk-3',
        courtName: 'Athletes Club',
        playerName: 'Omar Fathy',
        start: _atHour(today, 16),
        hours: 1,
        amount: 200,
        status: BookingStatus.confirmed,
      ),
      OwnerBooking(
        id: 'bk-4',
        courtName: 'Al Noor Padel Club',
        playerName: 'Mariam Adel',
        start: _atHour(today, 14),
        hours: 2,
        amount: 500,
        status: BookingStatus.confirmed,
      ),
      OwnerBooking(
        id: 'bk-5',
        courtName: 'Al Ahmar Padel Club',
        playerName: 'Youssef Nabil',
        start: _atHour(today, 9),
        hours: 1,
        amount: 300,
        status: BookingStatus.cancelled,
      ),
      OwnerBooking(
        id: 'bk-6',
        courtName: 'Athletes Club',
        playerName: 'Salma Reda',
        start: _atHour(today, 11),
        hours: 2,
        amount: 400,
        status: BookingStatus.confirmed,
      ),
      OwnerBooking(
        id: 'bk-7',
        courtName: 'Al Noor Padel Club',
        playerName: 'Karim Sabry',
        start: _atHour(tomorrow, 19),
        hours: 1,
        amount: 250,
        status: BookingStatus.pending,
      ),
      OwnerBooking(
        id: 'bk-8',
        courtName: 'Athletes Club',
        playerName: 'Dina Wagdy',
        start: _atHour(tomorrow, 17),
        hours: 2,
        amount: 400,
        status: BookingStatus.confirmed,
      ),
      OwnerBooking(
        id: 'bk-9',
        courtName: 'Al Ahmar Padel Club',
        playerName: 'Tarek Mounir',
        start: _atHour(yesterday, 18),
        hours: 2,
        amount: 600,
        status: BookingStatus.confirmed,
      ),
      OwnerBooking(
        id: 'bk-10',
        courtName: 'Al Noor Padel Club',
        playerName: 'Habiba Sherif',
        start: _atHour(yesterday, 20),
        hours: 1,
        amount: 250,
        status: BookingStatus.confirmed,
      ),
    ];
  }
}

final ownerBookingsProvider =
    StateNotifierProvider<OwnerBookingsNotifier, List<OwnerBooking>>(
  (ref) => OwnerBookingsNotifier(),
);

/// Aggregated numbers the dashboard shows. Derived so the tiles move the moment
/// a court is deactivated or a booking is confirmed/cancelled.
class OwnerStats {
  const OwnerStats({
    required this.activeCourts,
    required this.totalCourts,
    required this.bookingsToday,
    required this.pendingToday,
    required this.totalBookings,
    required this.revenueToday,
    required this.liveTournaments,
    required this.pendingEntries,
  });

  final int activeCourts;
  final int totalCourts;
  final int bookingsToday;
  final int pendingToday;
  final int totalBookings;
  final double revenueToday;
  final int liveTournaments;
  final int pendingEntries;
}

final ownerStatsProvider = Provider<OwnerStats>((ref) {
  final courts = ref.watch(ownerCourtsProvider);
  final bookings = ref.watch(ownerBookingsProvider);
  final tournaments = ref.watch(ownerTournamentsProvider);
  final today = _dayOnly(DateTime.now());

  final todays = bookings.where((booking) => booking.isOnDay(today)).toList();
  final billable = todays
      .where((booking) => booking.status != BookingStatus.cancelled)
      .toList();

  return OwnerStats(
    activeCourts: courts.where((court) => court.isActive).length,
    totalCourts: courts.length,
    bookingsToday: billable.length,
    pendingToday: todays.where((b) => b.status == BookingStatus.pending).length,
    totalBookings: bookings
        .where((booking) => booking.status != BookingStatus.cancelled)
        .length,
    revenueToday: billable.fold<double>(0, (sum, b) => sum + b.amount),
    liveTournaments: tournaments.where((t) => t.status.isLive).length,
    pendingEntries:
        tournaments.fold<int>(0, (sum, t) => sum + t.pendingTeams.length),
  );
});
