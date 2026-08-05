import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// Models shared by every screen in the owner panel.
///
/// These used to live inside the individual screens, which meant the dashboard,
/// the courts tab and the tournaments tab each owned a private copy of the demo
/// data and none of them could see the others' edits.

/// The player side of the app prices everything in EGP, so the owner panel does
/// too. (It used to print raw doubles behind a `$`, e.g. "Prize Pool: $25000.0".)
final NumberFormat _egp =
    NumberFormat.currency(symbol: 'EGP ', decimalDigits: 0);

String formatEgp(num value) => _egp.format(value);

/// Court photos are either a seeded remote URL or a path picked from the
/// gallery; the two need different `Image` constructors.
bool isRemoteImage(String source) =>
    source.startsWith('http://') || source.startsWith('https://');

// ---------------------------------------------------------------------------
// Courts
// ---------------------------------------------------------------------------

@immutable
class OwnerCourt {
  const OwnerCourt({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerHour,
    required this.description,
    required this.facilities,
    required this.images,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String location;
  final double pricePerHour;
  final String description;
  final List<String> facilities;
  final List<String> images;
  final bool isActive;

  String get priceLabel => '${formatEgp(pricePerHour)} / hour';

  OwnerCourt copyWith({
    String? name,
    String? location,
    double? pricePerHour,
    String? description,
    List<String>? facilities,
    List<String>? images,
    bool? isActive,
  }) {
    return OwnerCourt(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
    );
  }
}

// ---------------------------------------------------------------------------
// Tournaments
// ---------------------------------------------------------------------------

enum TournamentStatus { upcoming, ongoing, completed, cancelled }

extension TournamentStatusX on TournamentStatus {
  String get label {
    switch (this) {
      case TournamentStatus.upcoming:
        return 'Upcoming';
      case TournamentStatus.ongoing:
        return 'Ongoing';
      case TournamentStatus.completed:
        return 'Completed';
      case TournamentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TournamentStatus.upcoming:
        return AColors.info;
      case TournamentStatus.ongoing:
        return AColors.warning;
      case TournamentStatus.completed:
        return AColors.success;
      case TournamentStatus.cancelled:
        return AColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case TournamentStatus.upcoming:
        return Icons.event_available_rounded;
      case TournamentStatus.ongoing:
        return Icons.play_circle_fill_rounded;
      case TournamentStatus.completed:
        return Icons.emoji_events_rounded;
      case TournamentStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  /// Whether the tournament still belongs on the "Active" tab.
  bool get isLive =>
      this == TournamentStatus.upcoming || this == TournamentStatus.ongoing;
}

/// The formats an owner can run. Free text used to be accepted here, so a typo
/// like "sinlges" was saved verbatim and shown on the card.
const List<String> kTournamentTypes = <String>[
  'Singles',
  'Doubles',
  'Mixed Doubles',
];

@immutable
class OwnerTournament {
  const OwnerTournament({
    required this.id,
    required this.name,
    required this.type,
    required this.courtName,
    required this.startDate,
    required this.endDate,
    required this.maxTeams,
    required this.description,
    required this.status,
    this.prizePool,
    this.entryFee = 0,
    this.teams = const <String>[],
    this.pendingTeams = const <String>[],
  });

  final String id;
  final String name;
  final String type;
  final String courtName;
  final DateTime startDate;
  final DateTime endDate;
  final int maxTeams;
  final String description;
  final TournamentStatus status;
  final double? prizePool;
  final double entryFee;

  /// Confirmed entries. Replaces the old free-floating `teamsRegistered` int so
  /// accepting or removing a team actually moves the counter on the card.
  final List<String> teams;

  /// Entries waiting for the owner to accept or decline.
  final List<String> pendingTeams;

  int get teamsRegistered => teams.length;

  bool get isFull => teams.length >= maxTeams;

  int get durationInDays => endDate.difference(startDate).inDays + 1;

  String get durationLabel =>
      durationInDays == 1 ? '1 day' : '$durationInDays days';

  String get dateLabel {
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      if (startDate.day == endDate.day) {
        return DateFormat('MMMM d, y').format(startDate);
      }
      return '${DateFormat('MMMM d').format(startDate)} – '
          '${endDate.day}, ${endDate.year}';
    }
    if (startDate.year == endDate.year) {
      return '${DateFormat('MMM d').format(startDate)} – '
          '${DateFormat('MMM d').format(endDate)}, ${endDate.year}';
    }
    return '${DateFormat('MMM d, y').format(startDate)} – '
        '${DateFormat('MMM d, y').format(endDate)}';
  }

  String get prizeLabel =>
      prizePool == null ? 'No prize pool' : formatEgp(prizePool!);

  String get entryFeeLabel =>
      entryFee <= 0 ? 'Free entry' : formatEgp(entryFee);

  OwnerTournament copyWith({
    String? name,
    String? type,
    String? courtName,
    DateTime? startDate,
    DateTime? endDate,
    int? maxTeams,
    String? description,
    TournamentStatus? status,
    double? prizePool,
    bool clearPrizePool = false,
    double? entryFee,
    List<String>? teams,
    List<String>? pendingTeams,
  }) {
    return OwnerTournament(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      courtName: courtName ?? this.courtName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxTeams: maxTeams ?? this.maxTeams,
      description: description ?? this.description,
      status: status ?? this.status,
      prizePool: clearPrizePool ? null : (prizePool ?? this.prizePool),
      entryFee: entryFee ?? this.entryFee,
      teams: teams ?? this.teams,
      pendingTeams: pendingTeams ?? this.pendingTeams,
    );
  }
}

// ---------------------------------------------------------------------------
// Bookings
// ---------------------------------------------------------------------------

enum BookingStatus { confirmed, pending, cancelled }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.confirmed:
        return AColors.success;
      case BookingStatus.pending:
        return AColors.warning;
      case BookingStatus.cancelled:
        return AColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.confirmed:
        return Icons.check_circle_rounded;
      case BookingStatus.pending:
        return Icons.hourglass_bottom_rounded;
      case BookingStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }
}

@immutable
class OwnerBooking {
  const OwnerBooking({
    required this.id,
    required this.courtName,
    required this.playerName,
    required this.start,
    required this.hours,
    required this.amount,
    required this.status,
  });

  final String id;
  final String courtName;
  final String playerName;
  final DateTime start;
  final int hours;
  final double amount;
  final BookingStatus status;

  DateTime get end => start.add(Duration(hours: hours));

  String get timeLabel =>
      '${DateFormat.Hm().format(start)} – ${DateFormat.Hm().format(end)}';

  String get dayLabel => DateFormat('EEE, MMM d').format(start);

  String get amountLabel => formatEgp(amount);

  bool isOnDay(DateTime day) =>
      start.year == day.year &&
      start.month == day.month &&
      start.day == day.day;

  OwnerBooking copyWith({BookingStatus? status}) {
    return OwnerBooking(
      id: id,
      courtName: courtName,
      playerName: playerName,
      start: start,
      hours: hours,
      amount: amount,
      status: status ?? this.status,
    );
  }
}
