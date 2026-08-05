import 'package:intl/intl.dart';

/// Display formatting helpers.
///
/// Prices across the app are Egyptian pounds, so [formatCurrency] is the single
/// place that decides how money is rendered — checkout, the reservations list
/// and the chat share-sheet all go through it instead of writing `'$...'` by
/// hand.
class AFormatter {
  AFormatter._();

  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// e.g. `Sat, 9 Aug`
  static String formatDayMonth(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('EEE, d MMM').format(date);
  }

  /// e.g. `9 Aug 2026`
  static String formatFullDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Egyptian pounds. Whole amounts drop the decimals so a card reads
  /// `EGP 250` rather than `$250.0`.
  static String formatCurrency(double? amount, {int? decimalDigits}) {
    if (amount == null) return '';
    final digits = decimalDigits ?? (amount == amount.roundToDouble() ? 0 : 2);
    final formatter = NumberFormat.currency(
      locale: 'en_EG',
      symbol: 'EGP ',
      decimalDigits: digits,
    );
    return formatter.format(amount);
  }

  static String formatPhoneNumber(String? phoneNumber) {
    final regex = RegExp(r'^01[0125][0-9]{8}$');
    if (regex.hasMatch(phoneNumber ?? '')) {
      return '+20$phoneNumber';
    } else {
      return 'Invalid phone number';
    }
  }

  /// Strips the country/trunk prefix from an Egyptian mobile number.
  ///
  /// The previous chained `replaceFirst('+20', '').replaceFirst('0', '')`
  /// deleted the *interior* zero of `+201012345678`, silently corrupting the
  /// number; the regex group is the only safe way to do this.
  static String internalFormatPhoneNumber(String? phoneNumber) {
    final regex = RegExp(r'^(\+20|0)?(1[0125][0-9]{8})$');
    final match = regex.firstMatch(phoneNumber ?? '');
    if (match == null) return 'Invalid phone number';
    return match.group(2)!;
  }
}
