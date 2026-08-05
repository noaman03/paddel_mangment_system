import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// A single row of one of the admin tables.
///
/// Rows are treated as immutable so that replacing an entry in an [RxList] is
/// always seen as a change by GetX — mutating a `List<String>` in place would
/// not notify.
class AdminRecord {
  AdminRecord(List<String> cells) : cells = List<String>.unmodifiable(cells);

  final List<String> cells;

  AdminRecord withCell(int index, String value) {
    final next = List<String>.from(cells);
    next[index] = value;
    return AdminRecord(next);
  }
}

/// An item in the admin notification tray.
class AdminNotice {
  AdminNotice({
    required this.title,
    required this.body,
    required this.icon,
    required this.tone,
    this.read = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color tone;
  bool read;
}

/// Maps a free-text status cell onto a semantic colour.
Color adminStatusTone(String status) {
  switch (status.trim().toLowerCase()) {
    case 'approved':
    case 'ready':
    case 'active':
    case 'open':
    case 'confirmed':
    case 'paid':
      return AColors.success;
    case 'pending':
    case 'hold':
    case 'in review':
    case 'needs review':
    case 'maintenance':
      return AColors.warning;
    case 'cancelled':
    case 'refunded':
    case 'rejected':
    case 'suspended':
      return AColors.error;
    case 'invited':
    case 'new':
      return AColors.info;
    default:
      return AColors.primaryColor;
  }
}

/// State for the admin panel.
///
/// This build ships without a backend, so the panel seeds realistic sample
/// data and mutates it in memory: approving an item, inviting a player or
/// adding a court immediately changes the tables *and* the dashboard metrics.
class AdminController extends GetxController {
  static AdminController get to => Get.find<AdminController>();

  final RxInt selectedIndex = 0.obs;

  /// Column index that holds the status value, per section.
  static const int opsStatusColumn = 2;
  static const int playerStatusColumn = 3;
  static const int courtStatusColumn = 3;
  static const int bookingStatusColumn = 3;

  final RxList<AdminRecord> operations = <AdminRecord>[
    AdminRecord(['Court image review', 'Smash Arena', 'Pending', 'High']),
    AdminRecord(['Refund request', 'Ahmed Hassan', 'In review', 'Medium']),
    AdminRecord(['Tournament payout', 'New Cairo Club', 'Ready', 'Low']),
    AdminRecord(['Player verification', 'Mona Ali', 'Approved', 'Low']),
  ].obs;

  final RxList<AdminRecord> players = <AdminRecord>[
    AdminRecord(['Ahmed Hassan', 'Advanced', '42', 'Active']),
    AdminRecord(['Nour Samir', 'Intermediate', '28', 'Active']),
    AdminRecord(['Youssef Adel', 'Beginner', '7', 'Needs review']),
    AdminRecord(['Laila Omar', 'Advanced', '63', 'Active']),
  ].obs;

  final RxList<AdminRecord> courts = <AdminRecord>[
    AdminRecord(['Smash Arena A', 'New Cairo', 'EGP 420/hr', 'Open']),
    AdminRecord(['Padel Pro 2', 'Maadi', 'EGP 360/hr', 'Maintenance']),
    AdminRecord(['Rally Court', 'Zayed', 'EGP 390/hr', 'Open']),
    AdminRecord(['Club House Glass', 'Heliopolis', 'EGP 450/hr', 'Open']),
  ].obs;

  final RxList<AdminRecord> bookings = <AdminRecord>[
    AdminRecord(['Ahmed - Smash Arena A', 'Today 18:00', 'Paid', 'Confirmed']),
    AdminRecord(['Nour - Rally Court', 'Today 20:00', 'Paid', 'Confirmed']),
    AdminRecord(['Laila - Club House', 'Tomorrow 19:00', 'Pending', 'Hold']),
    AdminRecord(
        ['Youssef - Padel Pro 2', 'Jun 02 17:00', 'Refunded', 'Cancelled']),
  ].obs;

  final RxList<AdminNotice> notifications = <AdminNotice>[
    AdminNotice(
      title: 'Court image flagged',
      body: 'Smash Arena uploaded a photo that needs a moderator review.',
      icon: Icons.image_outlined,
      tone: AColors.warning,
    ),
    AdminNotice(
      title: 'Refund requested',
      body: 'Ahmed Hassan asked for a refund on a cancelled 18:00 slot.',
      icon: Icons.receipt_long_outlined,
      tone: AColors.info,
    ),
    AdminNotice(
      title: 'Payout ready',
      body: 'New Cairo Club tournament payout of EGP 6,400 is ready to send.',
      icon: Icons.account_balance_wallet_outlined,
      tone: AColors.success,
    ),
  ].obs;

  int get unreadNotifications =>
      notifications.where((notice) => !notice.read).length;

  void selectSection(int index) => selectedIndex.value = index;

  // ---------------------------------------------------------------- metrics
  // Baselines keep the dashboard numbers looking like a live platform while
  // still reacting to everything the reviewer does in the tables.
  static const int _playerBaseline = 2336;
  static const int _bookingBaseline = 124;
  static const double _revenueBaselineK = 41.1;

  String get revenueLabel {
    final double value = _revenueBaselineK + bookings.length * 0.42;
    return 'EGP ${value.toStringAsFixed(1)}K';
  }

  String get bookingsLabel => '${_bookingBaseline + bookings.length}';

  String get playersLabel {
    final total = _playerBaseline + players.length;
    final thousands = total ~/ 1000;
    final rest = total % 1000;
    return thousands > 0
        ? '$thousands,${rest.toString().padLeft(3, '0')}'
        : '$total';
  }

  String get courtUsageLabel {
    if (courts.isEmpty) return '0%';
    final open = courts
        .where(
            (court) => court.cells[courtStatusColumn].toLowerCase() == 'open')
        .length;
    return '${(open / courts.length * 100).round()}%';
  }

  String get openOperations => operations
      .where((row) => row.cells[opsStatusColumn].toLowerCase() != 'approved')
      .length
      .toString();

  // ------------------------------------------------------------- mutations
  void setStatus(RxList<AdminRecord> list, int row, int column, String value) {
    if (row < 0 || row >= list.length) return;
    list[row] = list[row].withCell(column, value);
  }

  void removeRow(RxList<AdminRecord> list, int row) {
    if (row < 0 || row >= list.length) return;
    list.removeAt(row);
  }

  void addPlayer(String name, String level) {
    players.insert(0, AdminRecord([name, level, '0', 'Invited']));
  }

  void addCourt(String name, String area, String rate) {
    courts.insert(0, AdminRecord([name, area, rate, 'Open']));
  }

  void addBooking(String label, String time) {
    bookings.insert(0, AdminRecord([label, time, 'Pending', 'Hold']));
  }

  void markAllNotificationsRead() {
    for (final notice in notifications) {
      notice.read = true;
    }
    notifications.refresh();
  }

  void markNotificationRead(int index) {
    if (index < 0 || index >= notifications.length) return;
    notifications[index].read = true;
    notifications.refresh();
  }

  /// CSV preview used by the dashboard "Export" action.
  String operationsCsv() {
    final buffer = StringBuffer('Item,Owner,Status,Priority\n');
    for (final row in operations) {
      buffer.writeln(row.cells.join(','));
    }
    return buffer.toString().trim();
  }
}
