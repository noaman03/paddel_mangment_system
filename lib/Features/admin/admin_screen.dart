import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/Features/admin/controller/admin_controller.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/Features/auth/presentation/login/login_screen.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/controllers/theme_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late final AdminController controller;

  static const _sections = [
    _AdminSection(title: 'Dashboard', icon: Icons.dashboard_outlined),
    _AdminSection(title: 'Players', icon: Icons.groups_2_outlined),
    _AdminSection(title: 'Courts', icon: Icons.sports_tennis_outlined),
    _AdminSection(title: 'Bookings', icon: Icons.calendar_month_outlined),
  ];

  @override
  void initState() {
    super.initState();
    // Registered here rather than in build(): a Get.put inside build() would
    // throw away the panel's seeded data on every rebuild.
    controller = Get.isRegistered<AdminController>()
        ? Get.find<AdminController>()
        : Get.put(AdminController());
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Row(
          children: [
            if (isWide)
              Obx(
                () => _AdminRail(
                  selectedIndex: controller.selectedIndex.value,
                  onChanged: controller.selectSection,
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Obx(
                    () => _AdminTopBar(
                      section: _sections[controller.selectedIndex.value].title,
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: _buildSection(controller.selectedIndex.value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : Obx(
              () => NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: c.surface,
                  indicatorColor: c.primarySoft,
                  labelTextStyle: WidgetStateProperty.resolveWith(
                    (states) => TextStyle(
                      fontSize: 12,
                      // brandText, not the accent green: the bar sits on
                      // c.surface, which is white in light mode.
                      color: states.contains(WidgetState.selected)
                          ? c.brandText
                          : c.textSecondary,
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  iconTheme: WidgetStateProperty.resolveWith(
                    (states) => IconThemeData(
                      color: states.contains(WidgetState.selected)
                          ? c.brandText
                          : c.textSecondary,
                    ),
                  ),
                ),
                child: NavigationBar(
                  height: 68,
                  selectedIndex: controller.selectedIndex.value,
                  onDestinationSelected: controller.selectSection,
                  destinations: _sections
                      .map(
                        (section) => NavigationDestination(
                          icon: Icon(section.icon),
                          label: section.title,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildSection(int index) {
    switch (index) {
      case 1:
        return const _PlayersSection();
      case 2:
        return const _CourtsSection();
      case 3:
        return const _BookingsSection();
      default:
        return const _DashboardSection();
    }
  }
}

class _AdminSection {
  const _AdminSection({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class _AdminRail extends StatelessWidget {
  const _AdminRail({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // The rail is a deliberate brand surface — it stays dark in both themes,
    // so white-on-gradient text here is intentional.
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101820), Color(0xFF0B231A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.sports_tennis, color: AColors.primaryColor),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Padelit Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < _AdminScreenState._sections.length; i++)
            _RailItem(
              section: _AdminScreenState._sections[i],
              selected: selectedIndex == i,
              onTap: () => onChanged(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Obx(() {
              final account = SessionController.to.account.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signed in as',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    account?.displayName ?? 'Administrator',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final _AdminSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Unselected items are white on the dark rail. The selected one is a vivid
    // green pill, so its foreground is picked against that fill — white on
    // #1DD681 is 1.91:1, which hid the one item that shows where you are.
    final Color foreground =
        selected ? AColors.foregroundOn(AColors.primaryColor) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected ? AColors.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(section.icon, color: foreground),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget {
  const _AdminTopBar({required this.section});

  final String section;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 620;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AColors.brandGradient,
        ),
        boxShadow: [
          BoxShadow(
            color: AColors.primaryColor.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 20 : 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Live operations, bookings, courts and player quality control',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  // Opaque white: even on the deep gradient, fading the
                  // subtitle to 82% drops it under 4.5:1. Size and weight
                  // carry the de-emphasis instead.
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 11.5 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const _PanelSwitchButton(),
          const _AppearanceButton(),
          const _NotificationsButton(),
          const SizedBox(width: 4),
          if (compact)
            IconButton(
              tooltip: 'Sign out',
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout, color: Colors.white),
            )
          else
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                // The button is white in both themes, so this is the literal
                // brand ink (5.8:1 on white) rather than the theme-aware
                // c.brandText, which would be the vivid green in dark mode.
                foregroundColor: AColors.primaryInk,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.2),
              ),
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign out'),
            ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final ok = await AppFeedback.confirm(
      context,
      title: 'Sign out of the admin panel?',
      message: 'You will be returned to the login screen.',
      confirmLabel: 'Sign out',
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (!ok) return;

    SessionController.to.signOut();
    AppFeedback.info('Signed out', 'Pick another demo account to continue.');
    Get.offAll(() => const LoginScreen());
  }
}

/// Hops to another panel without signing out, mirroring the player drawer's
/// "Switch panel" section. Without it the admin panel is a one-way door: the
/// only way back to the player app was sign out and re-authenticate.
class _PanelSwitchButton extends StatelessWidget {
  const _PanelSwitchButton();

  static const _targets = <AppRole>[AppRole.player, AppRole.owner];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppRole>(
      tooltip: 'Switch panel',
      icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
      onSelected: (role) {
        final account = DemoAccounts.all.firstWhere((a) => a.role == role);
        SessionController.to.signIn(account);
        Get.offAll(() => LoginController.homeForRole(role));
        AppFeedback.info('${role.label} panel', account.description);
      },
      itemBuilder: (menuContext) => [
        for (final role in _targets)
          PopupMenuItem<AppRole>(
            value: role,
            child: Row(
              children: [
                Icon(
                  role.icon,
                  size: 18,
                  color: menuContext.padel.textSecondary,
                ),
                const SizedBox(width: 10),
                Text('${role.label} panel'),
              ],
            ),
          ),
      ],
    );
  }
}

/// System → Light → Dark cycler. Dark mode used to be reachable only by
/// changing the operating-system setting.
class _AppearanceButton extends StatelessWidget {
  const _AppearanceButton();

  @override
  Widget build(BuildContext context) {
    final theme = ThemeController.to;
    return Obx(
      () => IconButton(
        tooltip: 'Appearance: ${theme.label}',
        onPressed: () {
          theme.cycle();
          AppFeedback.info('Appearance', 'Switched to ${theme.label} mode.');
        },
        icon: Icon(theme.icon, color: Colors.white),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  @override
  Widget build(BuildContext context) {
    final controller = AdminController.to;

    return Obx(() {
      final unread = controller.unreadNotifications;
      return IconButton(
        tooltip: 'Notifications',
        onPressed: () => _openTray(context, controller),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_outlined, color: Colors.white),
            if (unread > 0)
              Positioned(
                right: -3,
                top: -3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AColors.error,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Text(
                    '$unread',
                    style: TextStyle(
                      color: AColors.foregroundOn(AColors.error),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Future<void> _openTray(
    BuildContext context,
    AdminController controller,
  ) async {
    await showAppSheet<void>(
      context,
      title: 'Operations notifications',
      subtitle: 'Everything waiting on a moderator',
      icon: Icons.notifications_active_outlined,
      heightFactor: 0.6,
      child: Obx(() {
        final notices = controller.notifications;
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          itemCount: notices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (itemContext, index) {
            final c = itemContext.padel;
            final notice = notices[index];
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                controller.markNotificationRead(index);
                AppFeedback.success('Marked as read', notice.title);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: notice.read ? c.surface : c.soft(notice.tone),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: notice.read
                        ? c.border
                        : notice.tone.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(notice.icon, color: notice.tone, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notice.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            notice.body,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.35,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!notice.read) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: notice.tone,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            controller.markAllNotificationsRead();
            AppFeedback.success(
                'Tray cleared', 'All notifications marked read.');
            Navigator.pop(context);
          },
          icon: const Icon(Icons.done_all_rounded, size: 18),
          label: const Text('Mark all as read'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- sections

class _DashboardSection extends StatelessWidget {
  const _DashboardSection();

  @override
  Widget build(BuildContext context) {
    final controller = AdminController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 760 ? 4 : 2;
            return Obx(
              () => GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: constraints.maxWidth > 760 ? 1.55 : 1.15,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _MetricCard('Revenue', controller.revenueLabel, '+18%',
                      Icons.payments_outlined, AColors.info),
                  _MetricCard('Bookings', controller.bookingsLabel, '+24',
                      Icons.event_available_outlined, AColors.success),
                  _MetricCard('Players', controller.playersLabel, '+96',
                      Icons.groups_2_outlined, AColors.warning),
                  _MetricCard('Court usage', controller.courtUsageLabel, '+7%',
                      Icons.query_stats_outlined, const Color(0xFF7C3AED)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        Obx(
          () => _SectionHeader(
            title: 'Operations queue',
            subtitle: '${controller.openOperations} item(s) still open',
            actionLabel: 'Export',
            actionIcon: Icons.ios_share_rounded,
            onAction: () => _exportQueue(context, controller),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _AdminTable(
            headers: const ['Item', 'Owner', 'Status', 'Priority'],
            // `.toList()` iterates the RxList *inside* this Obx closure, which
            // is what registers the dependency — passing the RxList itself
            // would only be read later, in _AdminTable.build, and the table
            // would never refresh.
            rows: controller.operations.toList(),
            statusColumn: AdminController.opsStatusColumn,
            emptyLabel: 'The operations queue is clear.',
            actions: [
              _RowAction(
                label: 'Approve',
                icon: Icons.check_circle_outline,
                onSelected: (row) {
                  controller.setStatus(controller.operations, row,
                      AdminController.opsStatusColumn, 'Approved');
                  AppFeedback.success('Approved', 'The item left the queue.');
                },
              ),
              _RowAction(
                label: 'Send back for review',
                icon: Icons.history_rounded,
                onSelected: (row) {
                  controller.setStatus(controller.operations, row,
                      AdminController.opsStatusColumn, 'In review');
                  AppFeedback.warning(
                      'Back in review', 'The owner has been notified.');
                },
              ),
              _RowAction(
                label: 'Dismiss',
                icon: Icons.delete_outline_rounded,
                destructive: true,
                onSelected: (row) {
                  controller.removeRow(controller.operations, row);
                  AppFeedback.info('Dismissed', 'Removed from the queue.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _exportQueue(
    BuildContext context,
    AdminController controller,
  ) async {
    final csv = controller.operationsCsv();
    await showAppSheet<void>(
      context,
      title: 'Export operations queue',
      subtitle: 'CSV preview — offline demo, nothing leaves the device',
      icon: Icons.ios_share_rounded,
      heightFactor: 0.6,
      child: Builder(
        builder: (sheetContext) {
          final c = sheetContext.padel;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.fill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border),
              ),
              child: SelectableText(
                csv,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.6,
                  color: c.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
      footer: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: csv));
            AppFeedback.success('Copied', 'The CSV is on your clipboard.');
            Navigator.pop(context);
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
          label: const Text('Copy CSV'),
        ),
      ),
    );
  }
}

class _PlayersSection extends StatelessWidget {
  const _PlayersSection();

  @override
  Widget build(BuildContext context) {
    final controller = AdminController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => _SectionHeader(
            title: 'Player management',
            subtitle: '${controller.players.length} player(s) on this page',
            actionLabel: 'Invite player',
            actionIcon: Icons.person_add_alt_1_outlined,
            onAction: () => _invite(context, controller),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _AdminTable(
            headers: const ['Player', 'Level', 'Matches', 'Status'],
            rows: controller.players.toList(),
            statusColumn: AdminController.playerStatusColumn,
            emptyLabel: 'No players yet — invite one to get started.',
            actions: [
              _RowAction(
                label: 'Mark active',
                icon: Icons.verified_outlined,
                onSelected: (row) {
                  controller.setStatus(controller.players, row,
                      AdminController.playerStatusColumn, 'Active');
                  AppFeedback.success('Player activated');
                },
              ),
              _RowAction(
                label: 'Suspend',
                icon: Icons.pause_circle_outline,
                onSelected: (row) {
                  controller.setStatus(controller.players, row,
                      AdminController.playerStatusColumn, 'Suspended');
                  AppFeedback.warning(
                      'Player suspended', 'They can no longer book courts.');
                },
              ),
              _RowAction(
                label: 'Remove',
                icon: Icons.person_remove_outlined,
                destructive: true,
                onSelected: (row) {
                  controller.removeRow(controller.players, row);
                  AppFeedback.info('Player removed');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _invite(
    BuildContext context,
    AdminController controller,
  ) async {
    final values = await _promptRecord(
      context,
      title: 'Invite a player',
      icon: Icons.person_add_alt_1_outlined,
      confirmLabel: 'Send invite',
      fields: const [
        _RecordField(label: 'Full name', hint: 'e.g. Salma Fathy'),
        _RecordField(
            label: 'Level', hint: 'Beginner / Intermediate / Advanced'),
      ],
    );
    if (values == null) return;

    controller.addPlayer(values[0], values[1]);
    AppFeedback.success('Invite sent', '${values[0]} was added as Invited.');
  }
}

class _CourtsSection extends StatelessWidget {
  const _CourtsSection();

  @override
  Widget build(BuildContext context) {
    final controller = AdminController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => _SectionHeader(
            title: 'Court inventory',
            subtitle: '${controller.courtUsageLabel} of courts are bookable',
            actionLabel: 'Add court',
            actionIcon: Icons.add_business_outlined,
            onAction: () => _addCourt(context, controller),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _AdminTable(
            headers: const ['Court', 'Area', 'Rate', 'Availability'],
            rows: controller.courts.toList(),
            statusColumn: AdminController.courtStatusColumn,
            emptyLabel: 'No courts listed yet.',
            actions: [
              _RowAction(
                label: 'Open for booking',
                icon: Icons.lock_open_rounded,
                onSelected: (row) {
                  controller.setStatus(controller.courts, row,
                      AdminController.courtStatusColumn, 'Open');
                  AppFeedback.success(
                      'Court opened', 'Players can book it now.');
                },
              ),
              _RowAction(
                label: 'Send to maintenance',
                icon: Icons.build_outlined,
                onSelected: (row) {
                  controller.setStatus(controller.courts, row,
                      AdminController.courtStatusColumn, 'Maintenance');
                  AppFeedback.warning(
                      'Court closed', 'It is hidden from the booking flow.');
                },
              ),
              _RowAction(
                label: 'Delist',
                icon: Icons.delete_outline_rounded,
                destructive: true,
                onSelected: (row) {
                  controller.removeRow(controller.courts, row);
                  AppFeedback.info('Court delisted');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addCourt(
    BuildContext context,
    AdminController controller,
  ) async {
    final values = await _promptRecord(
      context,
      title: 'Add a court',
      icon: Icons.add_business_outlined,
      confirmLabel: 'Add court',
      fields: const [
        _RecordField(label: 'Court name', hint: 'e.g. Sky Padel 1'),
        _RecordField(label: 'Area', hint: 'e.g. Nasr City'),
        _RecordField(
          label: 'Hourly rate',
          hint: 'e.g. 400',
          numeric: true,
          prefix: 'EGP ',
        ),
      ],
    );
    if (values == null) return;

    controller.addCourt(values[0], values[1], 'EGP ${values[2]}/hr');
    AppFeedback.success('Court added', '${values[0]} is now open for booking.');
  }
}

class _BookingsSection extends StatelessWidget {
  const _BookingsSection();

  @override
  Widget build(BuildContext context) {
    final controller = AdminController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => _SectionHeader(
            title: 'Booking control',
            subtitle: '${controller.bookings.length} booking(s) in this view',
            actionLabel: 'Create booking',
            actionIcon: Icons.event_available_outlined,
            onAction: () => _createBooking(context, controller),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _AdminTable(
            headers: const ['Booking', 'Time', 'Payment', 'State'],
            rows: controller.bookings.toList(),
            statusColumn: AdminController.bookingStatusColumn,
            emptyLabel: 'Nothing booked in this window.',
            actions: [
              _RowAction(
                label: 'Confirm',
                icon: Icons.check_circle_outline,
                onSelected: (row) {
                  controller.setStatus(controller.bookings, row,
                      AdminController.bookingStatusColumn, 'Confirmed');
                  controller.setStatus(controller.bookings, row, 2, 'Paid');
                  AppFeedback.success(
                      'Booking confirmed', 'The player has been notified.');
                },
              ),
              _RowAction(
                label: 'Put on hold',
                icon: Icons.pause_circle_outline,
                onSelected: (row) {
                  controller.setStatus(controller.bookings, row,
                      AdminController.bookingStatusColumn, 'Hold');
                  AppFeedback.warning('Booking on hold');
                },
              ),
              _RowAction(
                label: 'Cancel and refund',
                icon: Icons.cancel_outlined,
                destructive: true,
                onSelected: (row) {
                  controller.setStatus(controller.bookings, row,
                      AdminController.bookingStatusColumn, 'Cancelled');
                  controller.setStatus(controller.bookings, row, 2, 'Refunded');
                  AppFeedback.info('Booking cancelled',
                      'A refund was queued for the player.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createBooking(
    BuildContext context,
    AdminController controller,
  ) async {
    final values = await _promptRecord(
      context,
      title: 'Create a booking',
      icon: Icons.event_available_outlined,
      confirmLabel: 'Create booking',
      fields: const [
        _RecordField(
            label: 'Player and court', hint: 'e.g. Salma - Rally Court'),
        _RecordField(label: 'Slot', hint: 'e.g. Tomorrow 21:00'),
      ],
    );
    if (values == null) return;

    controller.addBooking(values[0], values[1]);
    AppFeedback.success(
      'Booking created',
      'It is on hold until the payment clears.',
    );
  }
}

// ------------------------------------------------------------------ pieces

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.title, this.value, this.delta, this.icon, this.color);

  final String title;
  final String value;
  final String delta;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: c.shadow, blurRadius: 14, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: c.soft(color),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                delta,
                style: TextStyle(
                  color: c.onSurfaceAccent(AColors.success),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.textSecondary, fontSize: 12.5),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.textSecondary, fontSize: 12.5),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onAction,
          style: OutlinedButton.styleFrom(
            foregroundColor: c.textPrimary,
            side: BorderSide(color: c.border),
            backgroundColor: c.surface,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          icon: Icon(actionIcon, size: 18, color: c.brandText),
          label: Text(
            actionLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// A menu entry offered on every table row.
class _RowAction {
  const _RowAction({
    required this.label,
    required this.icon,
    required this.onSelected,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final void Function(int rowIndex) onSelected;
  final bool destructive;
}

class _AdminTable extends StatelessWidget {
  const _AdminTable({
    required this.headers,
    required this.rows,
    required this.statusColumn,
    required this.emptyLabel,
    this.actions = const [],
  });

  final List<String> headers;
  final List<AdminRecord> rows;
  final int statusColumn;
  final String emptyLabel;
  final List<_RowAction> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: c.textMuted, size: 30),
            const SizedBox(height: 10),
            Text(
              emptyLabel,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary),
            ),
          ],
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll<Color>(c.surfaceElevated),
          dividerThickness: 1,
          horizontalMargin: 16,
          columnSpacing: 26,
          headingTextStyle: TextStyle(
            color: c.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
          dataTextStyle: TextStyle(color: c.textPrimary, fontSize: 13.5),
          columns: [
            for (final header in headers) DataColumn(label: Text(header)),
            if (actions.isNotEmpty) const DataColumn(label: Text('')),
          ],
          rows: [
            for (var i = 0; i < rows.length; i++)
              DataRow(
                cells: [
                  for (var col = 0; col < rows[i].cells.length; col++)
                    DataCell(
                      col == statusColumn
                          ? _StatusChip(rows[i].cells[col])
                          : Text(
                              rows[i].cells[col],
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  if (actions.isNotEmpty)
                    DataCell(
                      PopupMenuButton<int>(
                        tooltip: 'Row actions',
                        icon: Icon(Icons.more_horiz, color: c.textSecondary),
                        onSelected: (actionIndex) =>
                            actions[actionIndex].onSelected(i),
                        itemBuilder: (menuContext) => [
                          for (var a = 0; a < actions.length; a++)
                            PopupMenuItem<int>(
                              value: a,
                              child: Row(
                                children: [
                                  Icon(
                                    actions[a].icon,
                                    size: 18,
                                    color: actions[a].destructive
                                        ? AColors.error
                                        : menuContext.padel.textSecondary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(actions[a].label),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final tone = adminStatusTone(value);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.soft(tone),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: c.onSurfaceAccent(tone),
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- record dialogs

class _RecordField {
  const _RecordField({
    required this.label,
    required this.hint,
    this.numeric = false,
    this.prefix,
  });

  final String label;
  final String hint;
  final bool numeric;
  final String? prefix;
}

/// Small themed form dialog used by the four section actions.
Future<List<String>?> _promptRecord(
  BuildContext context, {
  required String title,
  required IconData icon,
  required String confirmLabel,
  required List<_RecordField> fields,
}) {
  return showDialog<List<String>>(
    context: context,
    builder: (dialogContext) => _RecordDialog(
      title: title,
      icon: icon,
      confirmLabel: confirmLabel,
      fields: fields,
    ),
  );
}

class _RecordDialog extends StatefulWidget {
  const _RecordDialog({
    required this.title,
    required this.icon,
    required this.confirmLabel,
    required this.fields,
  });

  final String title;
  final IconData icon;
  final String confirmLabel;
  final List<_RecordField> fields;

  @override
  State<_RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<_RecordDialog> {
  late final List<TextEditingController> _controllers;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.fields.length,
      (_) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final values = _controllers.map((c) => c.text.trim()).toList();
    final missing = values.indexWhere((value) => value.isEmpty);
    if (missing != -1) {
      setState(() => _error = '${widget.fields[missing].label} is required.');
      return;
    }
    Navigator.pop(context, values);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(widget.icon, color: c.brandText, size: 24),
      ),
      title: Text(widget.title, textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < widget.fields.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              TextField(
                controller: _controllers[i],
                keyboardType: widget.fields[i].numeric
                    ? TextInputType.number
                    : TextInputType.text,
                textInputAction: i == widget.fields.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                onSubmitted: (_) {
                  if (i == widget.fields.length - 1) _submit();
                },
                decoration: InputDecoration(
                  labelText: widget.fields[i].label,
                  hintText: widget.fields[i].hint,
                  prefixText: widget.fields[i].prefix,
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: AColors.error,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      // NOTE: `actions` is an OverflowBar, not a Flex — an `Expanded` directly
      // in this list throws "Incorrect use of ParentDataWidget".
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(widget.confirmLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
