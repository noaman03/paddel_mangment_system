class PadelCourt {
  final String id;
  final String name;
  final String location;
  final String description;
  final double pricePerHour;
  final List<String> photos;
  final List<String> facilities;
  final CourtType type;
  final bool isActive;
  final double rating;
  final int totalBookings;
  final double? latitude;
  final double? longitude;
  final double? distanceFromUser; // For displaying distance to user
  final DateTime createdAt;
  final DateTime? updatedAt;

  PadelCourt({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.pricePerHour,
    required this.photos,
    required this.facilities,
    required this.type,
    this.isActive = true,
    this.rating = 0.0,
    this.totalBookings = 0,
    this.latitude,
    this.longitude,
    this.distanceFromUser,
    required this.createdAt,
    this.updatedAt,
  });

  // Create copy with modifications
  PadelCourt copyWith({
    String? id,
    String? name,
    String? location,
    String? description,
    double? pricePerHour,
    List<String>? photos,
    List<String>? facilities,
    CourtType? type,
    bool? isActive,
    double? rating,
    int? totalBookings,
    double? latitude,
    double? longitude,
    double? distanceFromUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PadelCourt(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      photos: photos ?? this.photos,
      facilities: facilities ?? this.facilities,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalBookings: totalBookings ?? this.totalBookings,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert from JSON
  factory PadelCourt.fromJson(Map<String, dynamic> json, String documentId) {
    return PadelCourt(
      id: documentId,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      pricePerHour: (json['pricePerHour'] ?? 0.0).toDouble(),
      photos: List<String>.from(json['photos'] ?? []),
      facilities: List<String>.from(json['facilities'] ?? []),
      type: CourtType.values.firstWhere(
        (e) => e.toString().split('.').last == (json['type'] ?? 'indoor'),
        orElse: () => CourtType.indoor,
      ),
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalBookings: json['totalBookings'] ?? 0,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'pricePerHour': pricePerHour,
      'photos': photos,
      'facilities': facilities,
      'type': type.toString().split('.').last,
      'isActive': isActive,
      'rating': rating,
      'totalBookings': totalBookings,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PadelCourt{id: $id, name: $name, location: $location, price: $pricePerHour}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PadelCourt && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum CourtType {
  indoor,
  outdoor,
  covered,
}

class CourtAvailability {
  final String courtId;
  final DateTime date;
  final List<TimeSlot> availableSlots;
  final List<TimeSlot> bookedSlots;

  CourtAvailability({
    required this.courtId,
    required this.date,
    required this.availableSlots,
    required this.bookedSlots,
  });

  factory CourtAvailability.fromJson(Map<String, dynamic> json) {
    return CourtAvailability(
      courtId: json['courtId'],
      date: DateTime.parse(json['date']),
      availableSlots: (json['availableSlots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
      bookedSlots: (json['bookedSlots'] as List)
          .map((slot) => TimeSlot.fromJson(slot))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courtId': courtId,
      'date': date.toIso8601String(),
      'availableSlots': availableSlots.map((slot) => slot.toJson()).toList(),
      'bookedSlots': bookedSlots.map((slot) => slot.toJson()).toList(),
    };
  }
}

class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.price,
    this.isAvailable = true,
  });

  Duration get duration => endTime.difference(startTime);

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      price: (json['price'] ?? 0.0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}
