import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/Features/auth/presentation/login/login_screen.dart';
import 'package:padel_management_system/Features/owner/court_management/owner_court_management.dart';
import 'package:padel_management_system/Features/owner/data/owner_models.dart';
import 'package:padel_management_system/Features/owner/data/owner_providers.dart';
import 'package:padel_management_system/Features/owner/tournaments/owner_tournaments_screen.dart';
import 'package:padel_management_system/Features/owner/widgets/owner_widgets.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/const/sizes.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/controllers/theme_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class OwnerDashboard extends ConsumerStatefulWidget {
  const OwnerDashboard({super.key});

  @override
  ConsumerState<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends ConsumerState<OwnerDashboard> {
  int _selectedIndex = 0;

  void _goToTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final stats = ref.watch(ownerStatsProvider);
    final int alerts = stats.pendingToday + stats.pendingEntries;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        // A brand top bar in both themes, but painted with the *deep* gradient
        // rather than the accent green: white on #1DD681 is 1.91:1, while the
        // lightest stop of brandGradient clears 4.5:1.
        backgroundColor: AColors.primaryDeep,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AColors.brandGradient,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: Obx(() {
          final session = SessionController.to;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Owner panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                session.isSignedIn ? session.displayName : 'Demo club',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // Opaque white: any alpha here drops the club name below 4.5:1
                // even on the deep gradient. The size/weight carry the
                // de-emphasis instead.
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }),
        actions: [
          const _PanelSwitchButton(),
          const _AppearanceIconButton(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: _showNotifications,
            icon: Badge(
              isLabelVisible: alerts > 0,
              label: Text('$alerts'),
              backgroundColor: AColors.error,
              textColor: AColors.foregroundOn(AColors.error),
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          OwnerDashboardHome(
            onOpenCourts: () => _goToTab(1),
            onOpenTournaments: () => _goToTab(2),
          ),
          const OwnerCourtManagement(),
          const OwnerTournamentsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _goToTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis_outlined),
              activeIcon: Icon(Icons.sports_tennis_rounded),
              label: 'Courts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events_rounded),
              label: 'Tournaments',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotifications() async {
    final action = await showAppSheet<String>(
      context,
      title: 'Notifications',
      subtitle: 'Everything that needs your attention',
      icon: Icons.notifications_none_rounded,
      heightFactor: 0.7,
      child: const _NotificationsBody(),
    );
    if (action == null || !mounted) return;

    switch (action) {
      case 'bookings':
        await showOwnerBookingsSheet(context, todayOnly: true);
      case 'tournaments':
        _goToTab(2);
      case 'courts':
        _goToTab(1);
    }
  }

  Future<void> _signOut() async {
    final ok = await AppFeedback.confirm(
      context,
      title: 'Sign out of the owner panel?',
      message: 'You will be returned to the login screen.',
      confirmLabel: 'Sign out',
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (!ok) return;

    SessionController.to.signOut();
    Get.offAll(() => const LoginScreen());
    AppFeedback.info('Signed out', 'Pick a demo account to jump back in.');
  }
}

/// App-bar appearance cycler (System → Light → Dark), matching the player app.
class _AppearanceIconButton extends StatelessWidget {
  const _AppearanceIconButton();

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;
    return Obx(
      () => IconButton(
        tooltip: 'Appearance: ${controller.label}',
        onPressed: controller.cycle,
        icon: Icon(controller.icon),
      ),
    );
  }
}

/// Hops to another panel without signing out, mirroring the player drawer's
/// "Switch panel" section. Without it the owner panel is a one-way door: the
/// only way back to the player app was sign out and re-authenticate.
class _PanelSwitchButton extends StatelessWidget {
  const _PanelSwitchButton();

  static const _targets = <AppRole>[AppRole.player, AppRole.admin];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppRole>(
      tooltip: 'Switch panel',
      icon: const Icon(Icons.swap_horiz_rounded),
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

// ---------------------------------------------------------------------------
// Dashboard home
// ---------------------------------------------------------------------------

class OwnerDashboardHome extends ConsumerWidget {
  const OwnerDashboardHome({
    super.key,
    required this.onOpenCourts,
    required this.onOpenTournaments,
  });

  final VoidCallback onOpenCourts;
  final VoidCallback onOpenTournaments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final stats = ref.watch(ownerStatsProvider);
    final bookings = ref.watch(ownerBookingsProvider);
    final today = DateTime.now();

    final upcoming = bookings
        .where((b) =>
            b.status != BookingStatus.cancelled &&
            !b.start.isBefore(DateTime(today.year, today.month, today.day)))
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final recent = upcoming.take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.xl,
      ),
      children: [
        _WelcomeBanner(revenueToday: stats.revenueToday),
        const SizedBox(height: ASizes.lg),
        OwnerSectionHeader(
          title: 'Today at a glance',
          subtitle: DateFormat('EEEE, d MMMM').format(today),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _StatTile(
              icon: Icons.sports_tennis_rounded,
              tone: AColors.info,
              value: '${stats.activeCourts}',
              title: 'Active courts',
              hint: '${stats.totalCourts} total',
              onTap: onOpenCourts,
            ),
            _StatTile(
              icon: Icons.event_available_rounded,
              tone: AColors.primaryColor,
              value: '${stats.bookingsToday}',
              title: 'Bookings today',
              hint: stats.pendingToday == 0
                  ? 'All confirmed'
                  : '${stats.pendingToday} pending',
              onTap: () => showOwnerBookingsSheet(context, todayOnly: true),
            ),
            _StatTile(
              icon: Icons.receipt_long_rounded,
              tone: AColors.warning,
              value: '${stats.totalBookings}',
              title: 'All bookings',
              hint: 'Tap for the full list',
              onTap: () => showOwnerBookingsSheet(context, todayOnly: false),
            ),
            _StatTile(
              icon: Icons.payments_rounded,
              tone: AColors.success,
              value: formatEgp(stats.revenueToday),
              title: 'Revenue today',
              hint: 'Tap for the breakdown',
              onTap: () => _showRevenueSheet(context),
            ),
          ],
        ),
        const SizedBox(height: ASizes.lg),
        OwnerSectionHeader(
          title: 'Next bookings',
          subtitle: recent.isEmpty
              ? 'Nothing scheduled from today onwards'
              : 'Tap a booking to confirm or cancel it',
          trailing: TextButton(
            onPressed: () => showOwnerBookingsSheet(context, todayOnly: false),
            child: const Text('View all'),
          ),
        ),
        if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
            decoration: BoxDecoration(
              color: c.fill,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
              border: Border.all(color: c.border),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy_outlined, size: 30, color: c.textMuted),
                const SizedBox(height: 8),
                Text(
                  'No upcoming bookings',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          )
        else
          for (final booking in recent)
            _BookingTile(
              booking: booking,
              onTap: () => _showBookingActions(context, ref, booking),
            ),
        const SizedBox(height: ASizes.lg),
        const OwnerSectionHeader(
          title: 'Quick actions',
          subtitle: 'The things owners do most',
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: [
            _ActionTile(
              icon: Icons.add_business_rounded,
              label: 'Add court',
              onTap: () {
                // Land on the Courts tab first so the new card is visible
                // behind the form when it closes.
                onOpenCourts();
                openCourtEditor(context);
              },
            ),
            _ActionTile(
              icon: Icons.photo_library_rounded,
              label: 'Court photos',
              onTap: () => showCourtPickerSheet(context),
            ),
            _ActionTile(
              icon: Icons.emoji_events_rounded,
              label: 'New tournament',
              onTap: () {
                onOpenTournaments();
                openTournamentEditor(context);
              },
            ),
            _ActionTile(
              icon: Icons.dark_mode_rounded,
              label: 'Appearance',
              onTap: () => showAppearanceSheet(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showRevenueSheet(BuildContext context) {
    return showAppSheet<void>(
      context,
      title: 'Revenue today',
      subtitle: 'Per court, cancellations excluded',
      icon: Icons.payments_rounded,
      heightFactor: 0.6,
      child: const _RevenueBody(),
    );
  }

  Future<void> _showBookingActions(
    BuildContext context,
    WidgetRef ref,
    OwnerBooking booking,
  ) async {
    final notifier = ref.read(ownerBookingsProvider.notifier);
    final action = await showAppSheet<String>(
      context,
      title: booking.playerName,
      subtitle: '${booking.courtName} · ${booking.dayLabel}',
      icon: Icons.event_note_rounded,
      heightFactor: 0.55,
      child: _BookingDetailBody(booking: booking),
    );
    if (action == null) return;

    switch (action) {
      case 'confirm':
        notifier.setStatus(booking.id, BookingStatus.confirmed);
        AppFeedback.success(
          'Booking confirmed',
          '${booking.playerName} has been notified.',
        );
      case 'cancel':
        notifier.setStatus(booking.id, BookingStatus.cancelled);
        AppFeedback.warning(
          'Booking cancelled',
          '${booking.playerName} will be refunded ${booking.amountLabel}.',
        );
    }
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.revenueToday});

  final double revenueToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ASizes.md + 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AColors.brandGradient,
        ),
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: AColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: ASizes.md),
          Expanded(
            child: Obx(() {
              final session = SessionController.to;
              final name =
                  session.isSignedIn ? session.displayName : 'Court owner';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $name',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'You have taken ${formatEgp(revenueToday)} in bookings '
                    'today.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      height: 1.35,
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.tone,
    required this.value,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final IconData icon;
  final Color tone;
  final String value;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        child: Ink(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: c.soft(tone),
            borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
            border: Border.all(color: tone.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: c.onSurfaceAccent(tone), size: 22),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: c.textMuted,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: c.onSurfaceAccent(tone),
                      ),
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: c.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(ASizes.cardRadiusLg),
            border: Border.all(color: c.border),
            boxShadow: [
              BoxShadow(
                color: c.shadow,
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 22, color: c.brandText),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking, required this.onTap});

  final OwnerBooking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
          child: Ink(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.soft(booking.status.color),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    booking.status.icon,
                    size: 20,
                    color: c.onSurfaceAccent(booking.status.color),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.playerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.courtName} · ${booking.timeLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking.amountLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    OwnerStatusPill(
                      label: booking.status.label,
                      color: booking.status.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheets
// ---------------------------------------------------------------------------

/// Full booking list with confirm / cancel actions.
Future<void> showOwnerBookingsSheet(
  BuildContext context, {
  required bool todayOnly,
}) {
  return showAppSheet<void>(
    context,
    title: todayOnly ? 'Bookings today' : 'All bookings',
    subtitle: 'Confirm or cancel with a tap',
    icon: Icons.event_note_rounded,
    heightFactor: 0.85,
    child: _BookingsListBody(todayOnly: todayOnly),
  );
}

class _BookingsListBody extends ConsumerWidget {
  const _BookingsListBody({required this.todayOnly});

  final bool todayOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final all = ref.watch(ownerBookingsProvider);
    final notifier = ref.read(ownerBookingsProvider.notifier);
    final today = DateTime.now();

    final bookings = (todayOnly
        ? all.where((b) => b.isOnDay(today)).toList()
        : List<OwnerBooking>.from(all))
      ..sort((a, b) => a.start.compareTo(b.start));

    if (bookings.isEmpty) {
      return const OwnerEmptyState(
        icon: Icons.event_busy_outlined,
        title: 'No bookings',
        message: 'Bookings made by players in the app show up here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      booking.playerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  OwnerStatusPill(
                    label: booking.status.label,
                    color: booking.status.color,
                    icon: booking.status.icon,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OwnerDetailRow(
                      icon: Icons.place_outlined,
                      label: 'Court',
                      value: booking.courtName,
                    ),
                  ),
                  Expanded(
                    child: OwnerDetailRow(
                      icon: Icons.schedule_rounded,
                      label: booking.dayLabel,
                      value: booking.timeLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    booking.amountLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: c.onSurfaceAccent(AColors.primaryColor),
                    ),
                  ),
                  const Spacer(),
                  if (booking.status == BookingStatus.pending)
                    OwnerActionButton(
                      icon: Icons.check_rounded,
                      label: 'Confirm',
                      filled: true,
                      onPressed: () {
                        notifier.setStatus(
                          booking.id,
                          BookingStatus.confirmed,
                        );
                        AppFeedback.success(
                          'Booking confirmed',
                          '${booking.playerName} has been notified.',
                        );
                      },
                    ),
                  if (booking.status == BookingStatus.confirmed) ...[
                    const SizedBox(width: 8),
                    OwnerActionButton(
                      icon: Icons.close_rounded,
                      label: 'Cancel',
                      tone: AColors.error,
                      onPressed: () {
                        notifier.setStatus(
                          booking.id,
                          BookingStatus.cancelled,
                        );
                        AppFeedback.warning(
                          'Booking cancelled',
                          '${booking.playerName} will be refunded '
                              '${booking.amountLabel}.',
                        );
                      },
                    ),
                  ],
                  if (booking.status == BookingStatus.cancelled) ...[
                    const SizedBox(width: 8),
                    OwnerActionButton(
                      icon: Icons.restore_rounded,
                      label: 'Restore',
                      tone: AColors.info,
                      onPressed: () {
                        notifier.setStatus(
                          booking.id,
                          BookingStatus.confirmed,
                        );
                        AppFeedback.success(
                          'Booking restored',
                          '${booking.playerName} keeps the slot.',
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookingDetailBody extends StatelessWidget {
  const _BookingDetailBody({required this.booking});

  final OwnerBooking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      children: [
        Row(
          children: [
            OwnerStatusPill(
              label: booking.status.label,
              color: booking.status.color,
              icon: booking.status.icon,
            ),
            const Spacer(),
            Text(
              booking.amountLabel,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: ASizes.md),
        OwnerDetailRow(
          icon: Icons.place_outlined,
          label: 'Court',
          value: booking.courtName,
        ),
        const SizedBox(height: 12),
        OwnerDetailRow(
          icon: Icons.calendar_today_rounded,
          label: 'Date',
          value: booking.dayLabel,
        ),
        const SizedBox(height: 12),
        OwnerDetailRow(
          icon: Icons.schedule_rounded,
          label: 'Time',
          value: '${booking.timeLabel} (${booking.hours}h)',
        ),
        const SizedBox(height: ASizes.lg),
        if (booking.status != BookingStatus.confirmed)
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop('confirm'),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Confirm booking'),
          ),
        if (booking.status != BookingStatus.cancelled) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop('cancel'),
            icon: Icon(Icons.close_rounded, color: c.error),
            label: Text(
              'Cancel booking',
              style: TextStyle(color: c.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: c.error.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ],
    );
  }
}

class _RevenueBody extends ConsumerWidget {
  const _RevenueBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.padel;
    final bookings = ref.watch(ownerBookingsProvider);
    final today = DateTime.now();

    final billable = bookings
        .where((b) => b.isOnDay(today) && b.status != BookingStatus.cancelled)
        .toList();

    if (billable.isEmpty) {
      return const OwnerEmptyState(
        icon: Icons.payments_outlined,
        title: 'No revenue yet today',
        message: 'Confirmed bookings for today are totalled here.',
      );
    }

    final byCourt = <String, double>{};
    for (final booking in billable) {
      byCourt[booking.courtName] =
          (byCourt[booking.courtName] ?? 0) + booking.amount;
    }
    final total = byCourt.values.fold<double>(0, (sum, value) => sum + value);
    final entries = byCourt.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(ASizes.md),
          decoration: BoxDecoration(
            color: c.primarySoft,
            borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
          ),
          child: Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: c.onSurfaceAccent(AColors.primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Total today',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
              Text(
                formatEgp(total),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: c.onSurfaceAccent(AColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ASizes.md),
        for (final entry in entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      formatEgp(entry.value),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : entry.value / total,
                    minHeight: 6,
                    backgroundColor: c.surfaceElevated,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _NotificationsBody extends ConsumerWidget {
  const _NotificationsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(ownerStatsProvider);
    final courts = ref.watch(ownerCourtsProvider);
    final withoutPhotos = courts.where((c) => c.images.isEmpty).length;

    final items = <_NotificationItem>[
      if (stats.pendingToday > 0)
        _NotificationItem(
          icon: Icons.pending_actions_rounded,
          tone: AColors.warning,
          title: '${stats.pendingToday} booking'
              '${stats.pendingToday == 1 ? '' : 's'} awaiting confirmation',
          message: 'Players are waiting to hear back about today.',
          action: 'bookings',
        ),
      if (stats.pendingEntries > 0)
        _NotificationItem(
          icon: Icons.group_add_rounded,
          tone: AColors.info,
          title: '${stats.pendingEntries} tournament entry '
              '${stats.pendingEntries == 1 ? 'request' : 'requests'}',
          message: 'Accept or decline them from the tournament manager.',
          action: 'tournaments',
        ),
      if (withoutPhotos > 0)
        _NotificationItem(
          icon: Icons.add_a_photo_outlined,
          tone: AColors.primaryColor,
          title: '$withoutPhotos court'
              '${withoutPhotos == 1 ? '' : 's'} without photos',
          message: 'Courts with photos get noticeably more bookings.',
          action: 'courts',
        ),
      if (stats.liveTournaments > 0)
        _NotificationItem(
          icon: Icons.emoji_events_rounded,
          tone: AColors.success,
          title: '${stats.liveTournaments} tournament'
              '${stats.liveTournaments == 1 ? '' : 's'} running or upcoming',
          message: 'Check entry lists and move them through their statuses.',
          action: 'tournaments',
        ),
    ];

    if (items.isEmpty) {
      return const OwnerEmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'All caught up',
        message: 'Nothing needs your attention right now.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => items[index],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.icon,
    required this.tone,
    required this.title,
    required this.message,
    required this.action,
  });

  final IconData icon;
  final Color tone;
  final String title;
  final String message;
  final String action;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
        onTap: () => Navigator.of(context).pop(action),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.fill,
            borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.soft(tone),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: c.onSurfaceAccent(tone)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: TextStyle(fontSize: 12, color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: c.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Light / Dark / System picker, shared with the player drawer's control.
Future<void> showAppearanceSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    title: 'Appearance',
    subtitle: 'Applies to the whole app',
    icon: Icons.palette_outlined,
    heightFactor: 0.45,
    child: const _AppearanceBody(),
  );
}

class _AppearanceBody extends StatelessWidget {
  const _AppearanceBody();

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final controller = ThemeController.to;

    const modes = <(ThemeMode, String, String, IconData)>[
      (
        ThemeMode.light,
        'Light',
        'Always the light palette',
        Icons.light_mode_rounded
      ),
      (
        ThemeMode.dark,
        'Dark',
        'Always the dark palette',
        Icons.dark_mode_rounded
      ),
      (
        ThemeMode.system,
        'System',
        'Follow the device setting',
        Icons.brightness_auto_rounded
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ASizes.md,
        ASizes.md,
        ASizes.md,
        ASizes.lg,
      ),
      children: [
        // Obx sits inside this builder so it actually tracks `themeMode`.
        Obx(
          () => Column(
            children: [
              for (final (mode, label, description, icon) in modes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(ASizes.cardRadiusMd),
                      onTap: () {
                        controller.setMode(mode);
                        AppFeedback.info('Appearance set to $label');
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: controller.themeMode.value == mode
                              ? c.primarySoft
                              : c.fill,
                          borderRadius:
                              BorderRadius.circular(ASizes.cardRadiusMd),
                          border: Border.all(
                            color: controller.themeMode.value == mode
                                ? AColors.primaryColor
                                : c.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: c.textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: c.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.themeMode.value == mode)
                              Icon(
                                Icons.check_circle_rounded,
                                color: c.brandText,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
