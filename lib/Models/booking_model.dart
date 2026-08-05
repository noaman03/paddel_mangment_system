import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Upcoming';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get wireName => name;
}

/// A single court reservation.
///
/// This model used to declare its own `TimeOfDay` class, which collided with
/// `material.TimeOfDay` and made the model unusable from any widget file — the
/// reason checkout could never be wired to it. It now uses material's TimeOfDay
/// and carries the denormalised court fields the reservation screens display.
class Booking {
  final String id;
  final String userId;
  final String courtId;
  final String courtName;
  final String courtLocation;
  final String courtImage;
  final DateTime bookingDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double totalPrice;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final double refundAmount;

  const Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.courtName,
    this.courtLocation = '',
    this.courtImage = '',
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    this.notes,
    required this.createdAt,
    this.cancelledAt,
    this.refundAmount = 0,
  });

  /// The absolute moment the reservation starts — used for refund rules and for
  /// deciding whether a "confirmed" booking has already been played.
  DateTime get startsAt => DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        startTime.hour,
        startTime.minute,
      );

  DateTime get endsAt => DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
        endTime.hour,
        endTime.minute,
      );

  double get durationInHours {
    final minutes = (endTime.hour * 60 + endTime.minute) -
        (startTime.hour * 60 + startTime.minute);
    return minutes <= 0 ? 1 : minutes / 60;
  }

  /// A confirmed booking whose slot is in the past reads as completed, so the
  /// demo never shows an "Upcoming" reservation dated last month.
  BookingStatus get effectiveStatus {
    if (status == BookingStatus.cancelled) return BookingStatus.cancelled;
    if (status == BookingStatus.completed) return BookingStatus.completed;
    return endsAt.isBefore(DateTime.now())
        ? BookingStatus.completed
        : BookingStatus.confirmed;
  }

  bool get isUpcoming => effectiveStatus == BookingStatus.confirmed;

  bool get isCancelled => effectiveStatus == BookingStatus.cancelled;

  String get timeRangeLabel =>
      '${formatTime(startTime)} - ${formatTime(endTime)}';

  /// 12-hour label without needing a BuildContext (TimeOfDay.format does).
  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? courtId,
    String? courtName,
    String? courtLocation,
    String? courtImage,
    DateTime? bookingDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    double? totalPrice,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? cancelledAt,
    double? refundAmount,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      courtLocation: courtLocation ?? this.courtLocation,
      courtImage: courtImage ?? this.courtImage,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      refundAmount: refundAmount ?? this.refundAmount,
    );
  }

  factory Booking.fromMap(Map<String, dynamic> map, String docId) {
    return Booking(
      id: docId,
      userId: map['userId']?.toString() ?? '',
      courtId: map['courtId']?.toString() ?? '',
      courtName: map['courtName']?.toString() ?? 'Padel court',
      courtLocation: map['courtLocation']?.toString() ?? '',
      courtImage: map['courtImage']?.toString() ?? '',
      bookingDate: parseDate(map['bookingDate']) ?? DateTime.now(),
      startTime: parseTimeOfDay(map['startTime']),
      endTime: parseTimeOfDay(map['endTime'], fallbackHour: 13),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: map['notes']?.toString(),
      createdAt: parseDate(map['createdAt']) ?? DateTime.now(),
      cancelledAt: parseDate(map['cancelledAt']),
      refundAmount: (map['refundAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courtId': courtId,
      'courtName': courtName,
      'courtLocation': courtLocation,
      'courtImage': courtImage,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'totalPrice': totalPrice,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'refundAmount': refundAmount,
    };
  }

  /// Tolerates ISO strings, DateTime and Firestore Timestamps (which expose
  /// `toDate()`), so a stored document never takes the reservations list down.
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      // ignore: avoid_dynamic_calls
      final converted = value.toDate();
      if (converted is DateTime) return converted;
    } catch (_) {
      // Not a Timestamp-like object — fall through to null.
    }
    return null;
  }

  /// Defensive: a value without a colon (e.g. '17') used to throw RangeError.
  static TimeOfDay parseTimeOfDay(dynamic value, {int fallbackHour = 12}) {
    final parts = (value?.toString() ?? '').split(':');
    if (parts.isEmpty || parts.first.isEmpty) {
      return TimeOfDay(hour: fallbackHour, minute: 0);
    }
    final hour = int.tryParse(parts[0].trim()) ?? fallbackHour;
    final minute = parts.length > 1 ? (int.tryParse(parts[1].trim()) ?? 0) : 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }
}
