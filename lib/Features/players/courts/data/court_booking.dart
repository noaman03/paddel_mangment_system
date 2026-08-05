/// A court reservation made in this demo build.
///
/// The app has no backend, so bookings live in memory inside
/// [CourtDataController]. Keeping them in a model (instead of a loose map)
/// means the courts list, the details screen and the slot grid can all agree on
/// what "already booked" means.
class CourtBooking {
  CourtBooking({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.courtLocation,
    required this.date,
    required this.timeLabel,
    required this.price,
    required this.createdAt,
  });

  final String id;
  final String courtId;
  final String courtName;
  final String courtLocation;

  /// Day of the reservation (time part is ignored).
  final DateTime date;

  /// Human readable slot, e.g. `7:00 PM`.
  final String timeLabel;
  final double price;
  final DateTime createdAt;

  /// Identity of the exact slot this booking occupies.
  String get slotKey => slotKeyFor(courtId, date, timeLabel);

  static String slotKeyFor(String courtId, DateTime date, String timeLabel) =>
      '$courtId|${date.year}-${date.month}-${date.day}|$timeLabel';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CourtBooking && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
