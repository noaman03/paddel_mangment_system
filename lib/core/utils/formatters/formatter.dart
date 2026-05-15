import 'package:intl/intl.dart';

class AFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  static String formatCurrency(double? amount) {
    if (amount == null) return '';
    final formatter = NumberFormat.currency(
      locale: 'en_EG',
      symbol: 'EGP',
      decimalDigits: 2,
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

  static String internalFormatPhoneNumber(String? phoneNumber) {
    final regex = RegExp(r'^(\+20|0)?(1[0125][0-9]{8})$');
    if (regex.hasMatch(phoneNumber ?? '')) {
      return phoneNumber!.replaceFirst('+20', '').replaceFirst('0', '');
    } else {
      return 'Invalid phone number';
    }
  }
}
