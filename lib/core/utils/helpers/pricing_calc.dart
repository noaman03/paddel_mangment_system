import 'package:padel_management_system/core/utils/formatters/formatter.dart';

/// Pricing engine for court reservations.
///
/// This used to be dead code while checkout hardcoded "price + 10% tax"; the
/// checkout screen now renders the breakdown produced here, so a weekend
/// evening slot in Downtown Cairo genuinely costs more than a Tuesday morning
/// slot in Giza. All amounts are Egyptian pounds.
class PadelPricingCalc {
  PadelPricingCalc._();

  /// Service fee + VAT applied on top of the court fee.
  static const double serviceFeeRate = 0.10;

  static double calculateServiceFee(double subtotal) =>
      subtotal * serviceFeeRate;

  /// Calculate total reservation price including court fee, peak hours, and
  /// additional services.
  static double calculateTotalReservationPrice({
    required double basePricePerHour,
    required double durationInHours,
    required DateTime reservationTime,
    String location = '',
    bool includeEquipmentRental = false,
    bool includeCoaching = false,
    int numberOfPlayers = 4,
  }) {
    return calculatePriceBreakdown(
          basePricePerHour: basePricePerHour,
          durationInHours: durationInHours,
          reservationTime: reservationTime,
          location: location,
          includeEquipmentRental: includeEquipmentRental,
          includeCoaching: includeCoaching,
          numberOfPlayers: numberOfPlayers,
        )['totalPrice'] ??
        0.0;
  }

  /// Price breakdown for display. Keys: basePrice, peakHourSurcharge,
  /// locationSurcharge, equipmentCost, coachingCost, totalPrice.
  static Map<String, double> calculatePriceBreakdown({
    required double basePricePerHour,
    required double durationInHours,
    required DateTime reservationTime,
    String location = '',
    bool includeEquipmentRental = false,
    bool includeCoaching = false,
    int numberOfPlayers = 4,
  }) {
    final double hours = durationInHours <= 0 ? 1 : durationInHours;
    final double basePrice = basePricePerHour * hours;
    final double peakHourMultiplier = getPeakHourMultiplier(reservationTime);
    final double locationMultiplier = getLocationMultiplier(location);
    final double equipmentCost =
        includeEquipmentRental ? getEquipmentRentalCost(numberOfPlayers) : 0.0;
    final double coachingCost = includeCoaching ? getCoachingCost(hours) : 0.0;

    final double peakHourSurcharge = basePrice * (peakHourMultiplier - 1.0);
    final double locationSurcharge = basePrice * (locationMultiplier - 1.0);
    final double adjustedBasePrice =
        basePrice + peakHourSurcharge + locationSurcharge;

    return {
      'basePrice': basePrice,
      'peakHourSurcharge': peakHourSurcharge,
      'locationSurcharge': locationSurcharge,
      'equipmentCost': equipmentCost,
      'coachingCost': coachingCost,
      'totalPrice': adjustedBasePrice + equipmentCost + coachingCost,
    };
  }

  /// Peak hour multiplier based on time of day and day of week.
  static double getPeakHourMultiplier(DateTime reservationTime) {
    final int hour = reservationTime.hour;
    final int weekday = reservationTime.weekday; // 1 = Monday, 7 = Sunday

    // Weekend premium (Friday & Saturday are the Egyptian weekend).
    if (weekday == DateTime.friday || weekday == DateTime.saturday) {
      if (hour >= 8 && hour <= 22) return 1.3;
      return 1.15;
    }

    // Weekday peak hours (6-9 AM and 6-10 PM).
    if ((hour >= 6 && hour <= 9) || (hour >= 18 && hour <= 22)) return 1.2;

    return 1.0;
  }

  static bool isPeak(DateTime reservationTime) =>
      getPeakHourMultiplier(reservationTime) > 1.0;

  /// Location-based pricing multiplier.
  static double getLocationMultiplier(String location) {
    switch (location.toLowerCase()) {
      case 'premium':
      case 'downtown':
      case 'city center':
        return 1.25;
      case 'suburban':
      case 'standard':
        return 1.0;
      case 'budget':
      case 'community':
        return 0.85;
      default:
        return 1.0;
    }
  }

  /// Maps a human-readable club location ("Downtown Cairo", "Giza") onto one of
  /// the pricing tiers understood by [getLocationMultiplier].
  static String locationKeyFor(String location) {
    final value = location.toLowerCase();
    if (value.contains('downtown') ||
        value.contains('zamalek') ||
        value.contains('city center')) {
      return 'downtown';
    }
    if (value.contains('new cairo') ||
        value.contains('sheikh zayed') ||
        value.contains('north coast')) {
      return 'premium';
    }
    if (value.contains('giza') || value.contains('shubra')) {
      return 'community';
    }
    return 'standard';
  }

  /// Equipment rental (rackets + balls) for a session.
  static double getEquipmentRentalCost(int numberOfPlayers) {
    const double racketRentalPerPlayer = 60.0;
    const double ballsCost = 40.0;
    return (racketRentalPerPlayer * numberOfPlayers) + ballsCost;
  }

  /// Coaching cost for the session.
  static double getCoachingCost(double durationInHours) =>
      400.0 * durationInHours;

  /// Tournament entry fee.
  static double calculateTournamentFee({
    required String tournamentType,
    required int numberOfPlayers,
  }) {
    switch (tournamentType.toLowerCase()) {
      case 'beginner':
        return 150.0 * numberOfPlayers;
      case 'intermediate':
        return 250.0 * numberOfPlayers;
      case 'advanced':
        return 350.0 * numberOfPlayers;
      case 'professional':
        return 500.0 * numberOfPlayers;
      default:
        return 200.0 * numberOfPlayers;
    }
  }

  /// Membership discount.
  static double applyMembershipDiscount(
      double totalPrice, String membershipType) {
    switch (membershipType.toLowerCase()) {
      case 'premium':
        return totalPrice * 0.8;
      case 'standard':
        return totalPrice * 0.9;
      case 'basic':
        return totalPrice * 0.95;
      case 'none':
      default:
        return totalPrice;
    }
  }

  /// Formats a price for display in the app's currency.
  static String formatPrice(double price) => AFormatter.formatCurrency(price);

  /// Refund allowed by the cancellation policy. Mirrored in the terms sheet on
  /// the checkout screen and in the cancel-reservation confirmation.
  static double calculateRefundAmount({
    required double originalPrice,
    required DateTime reservationTime,
    required DateTime cancellationTime,
  }) {
    final int hoursUntilReservation =
        reservationTime.difference(cancellationTime).inHours;

    if (hoursUntilReservation >= 24) return originalPrice;
    if (hoursUntilReservation >= 12) return originalPrice * 0.75;
    if (hoursUntilReservation >= 2) return originalPrice * 0.5;
    return 0.0;
  }

  /// Human-readable summary of what cancelling right now would return.
  static String refundPolicyLabel({
    required DateTime reservationTime,
    required DateTime cancellationTime,
  }) {
    final int hours = reservationTime.difference(cancellationTime).inHours;
    if (hours >= 24) return 'Full refund (more than 24 hours notice)';
    if (hours >= 12) return '75% refund (12-24 hours notice)';
    if (hours >= 2) return '50% refund (2-12 hours notice)';
    return 'No refund (less than 2 hours notice)';
  }

  /// Group booking discount.
  static double applyGroupDiscount(double totalPrice, int numberOfCourts) {
    if (numberOfCourts >= 4) return totalPrice * 0.85;
    if (numberOfCourts >= 2) return totalPrice * 0.92;
    return totalPrice;
  }
}
