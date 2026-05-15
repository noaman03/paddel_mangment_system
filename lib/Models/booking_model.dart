enum BookingStatus { pending, confirmed, completed, cancelled }

class Booking {
  final String id;
  final String userId;
  final String courtId;
  final DateTime bookingDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double totalPrice;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? cancelledAt;

  Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    this.notes,
    required this.createdAt,
    this.cancelledAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map, String docId) {
    return Booking(
      id: docId,
      userId: map['userId'] ?? '',
      courtId: map['courtId'] ?? '',
      bookingDate: map['bookingDate'] != null
          ? DateTime.parse(map['bookingDate'])
          : DateTime.now(),
      startTime: _parseTimeOfDay(map['startTime']),
      endTime: _parseTimeOfDay(map['endTime']),
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (map['status'] ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.parse(map['cancelledAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courtId': courtId,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  static TimeOfDay _parseTimeOfDay(String? time) {
    if (time == null) return const TimeOfDay(hour: 12, minute: 0);
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 12,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
