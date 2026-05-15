class PadelPricingCalc {
  /// Calculate total reservation price including court fee, peak hours, and additional services
  static double calculateTotalReservationPrice({
    required double basePricePerHour,
    required int durationInHours,
    required DateTime reservationTime,
    String location = '',
    bool includeEquipmentRental = false,
    bool includeCoaching = false,
    int numberOfPlayers = 4,
  }) {
    double basePrice = basePricePerHour * durationInHours;
    double peakHourMultiplier = getPeakHourMultiplier(reservationTime);
    double locationMultiplier = getLocationMultiplier(location);
    double equipmentCost =
        includeEquipmentRental ? getEquipmentRentalCost(numberOfPlayers) : 0.0;
    double coachingCost =
        includeCoaching ? getCoachingCost(durationInHours) : 0.0;

    double adjustedBasePrice =
        basePrice * peakHourMultiplier * locationMultiplier;
    double totalPrice = adjustedBasePrice + equipmentCost + coachingCost;

    return totalPrice;
  }

  /// Calculate price breakdown for display
  static Map<String, double> calculatePriceBreakdown({
    required double basePricePerHour,
    required int durationInHours,
    required DateTime reservationTime,
    String location = '',
    bool includeEquipmentRental = false,
    bool includeCoaching = false,
    int numberOfPlayers = 4,
  }) {
    double basePrice = basePricePerHour * durationInHours;
    double peakHourMultiplier = getPeakHourMultiplier(reservationTime);
    double locationMultiplier = getLocationMultiplier(location);
    double equipmentCost =
        includeEquipmentRental ? getEquipmentRentalCost(numberOfPlayers) : 0.0;
    double coachingCost =
        includeCoaching ? getCoachingCost(durationInHours) : 0.0;

    double peakHourSurcharge = basePrice * (peakHourMultiplier - 1.0);
    double locationSurcharge = basePrice * (locationMultiplier - 1.0);
    double adjustedBasePrice =
        basePrice * peakHourMultiplier * locationMultiplier;

    return {
      'basePrice': basePrice,
      'peakHourSurcharge': peakHourSurcharge,
      'locationSurcharge': locationSurcharge,
      'equipmentCost': equipmentCost,
      'coachingCost': coachingCost,
      'totalPrice': adjustedBasePrice + equipmentCost + coachingCost,
    };
  }

  /// Get peak hour multiplier based on time of day and day of week
  static double getPeakHourMultiplier(DateTime reservationTime) {
    int hour = reservationTime.hour;
    int weekday = reservationTime.weekday; // 1 = Monday, 7 = Sunday

    // Weekend premium (Saturday & Sunday)
    if (weekday == 6 || weekday == 7) {
      if (hour >= 8 && hour <= 22) {
        return 1.3; // 30% surcharge for weekend daytime
      }
      return 1.15; // 15% surcharge for weekend off-hours
    }

    // Weekday peak hours (6-9 AM and 6-10 PM)
    if ((hour >= 6 && hour <= 9) || (hour >= 18 && hour <= 22)) {
      return 1.2; // 20% surcharge for weekday peak hours
    }

    // Regular weekday hours
    return 1.0; // No surcharge
  }

  /// Get location-based pricing multiplier
  static double getLocationMultiplier(String location) {
    switch (location.toLowerCase()) {
      case 'premium':
      case 'downtown':
      case 'city center':
        return 1.25; // 25% premium for prime locations
      case 'suburban':
      case 'standard':
        return 1.0; // Base price
      case 'budget':
      case 'community':
        return 0.85; // 15% discount for community centers
      default:
        return 1.0; // Default to base price
    }
  }

  /// Calculate equipment rental cost (rackets, balls)
  static double getEquipmentRentalCost(int numberOfPlayers) {
    double racketRentalPerPlayer = 5.0; // $5 per racket
    double ballsCost = 3.0; // $3 for balls per session

    return (racketRentalPerPlayer * numberOfPlayers) + ballsCost;
  }

  /// Calculate coaching cost
  static double getCoachingCost(int durationInHours) {
    double coachHourlyRate = 40.0; // $40 per hour for coaching
    return coachHourlyRate * durationInHours;
  }

  /// Calculate tournament entry fee
  static double calculateTournamentFee({
    required String tournamentType,
    required int numberOfPlayers,
  }) {
    switch (tournamentType.toLowerCase()) {
      case 'beginner':
        return 15.0 * numberOfPlayers;
      case 'intermediate':
        return 25.0 * numberOfPlayers;
      case 'advanced':
        return 35.0 * numberOfPlayers;
      case 'professional':
        return 50.0 * numberOfPlayers;
      default:
        return 20.0 * numberOfPlayers;
    }
  }

  /// Calculate membership discount
  static double applyMembershipDiscount(
      double totalPrice, String membershipType) {
    switch (membershipType.toLowerCase()) {
      case 'premium':
        return totalPrice * 0.8; // 20% discount
      case 'standard':
        return totalPrice * 0.9; // 10% discount
      case 'basic':
        return totalPrice * 0.95; // 5% discount
      case 'none':
      default:
        return totalPrice; // No discount
    }
  }

  /// Format price for display
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  /// Calculate refund amount based on cancellation policy
  static double calculateRefundAmount({
    required double originalPrice,
    required DateTime reservationTime,
    required DateTime cancellationTime,
  }) {
    Duration timeDifference = reservationTime.difference(cancellationTime);
    int hoursUntilReservation = timeDifference.inHours;

    if (hoursUntilReservation >= 24) {
      return originalPrice; // Full refund
    } else if (hoursUntilReservation >= 12) {
      return originalPrice * 0.75; // 75% refund
    } else if (hoursUntilReservation >= 2) {
      return originalPrice * 0.5; // 50% refund
    } else {
      return 0.0; // No refund
    }
  }

  /// Calculate group booking discount
  static double applyGroupDiscount(double totalPrice, int numberOfCourts) {
    if (numberOfCourts >= 4) {
      return totalPrice * 0.85; // 15% discount for 4+ courts
    } else if (numberOfCourts >= 2) {
      return totalPrice * 0.92; // 8% discount for 2-3 courts
    }
    return totalPrice; // No discount for single court
  }
}
