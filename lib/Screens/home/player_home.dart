import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart' hide Trans;
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/Features/auth/presentation/login/login_screen.dart';
import 'package:padel_management_system/Features/players/courts/court_browse.dart';
import 'package:padel_management_system/Features/players/open_matches/open_matches.dart';
import 'package:padel_management_system/Features/players/chat/chat_screen.dart';
import 'package:padel_management_system/Features/players/tournaments/tournaments.dart';
import 'package:padel_management_system/Features/players/recent_reservations_widget.dart';
import 'package:padel_management_system/Features/players/court_details/court_details_screen.dart';
import 'package:padel_management_system/Features/players/reservations/my_reservations_screen.dart';
import 'package:padel_management_system/Models/padel_court.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/Features/auth/data/provider_auth.dart';
import 'package:padel_management_system/core/const/court_images.dart';
import 'package:padel_management_system/core/const/image_string.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/controllers/theme_controller.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

class PlayerHome extends ConsumerStatefulWidget {
  const PlayerHome({super.key});

  @override
  ConsumerState<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends ConsumerState<PlayerHome> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Tabs 1..4. Tab 0 is built in `build` because it needs callbacks into
  /// this State.
  static const List<Widget> _screens = [
    CourtBrowseScreen(),
    TournamentScreen(),
    OpenMatchesScreen(),
    ChatListScreen(),
  ];

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AColors.lineargradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sports_tennis_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              'Padel',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: c.textPrimary,
              ),
            ),
            Text(
              'it',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                // Brand colour as *text*: the accent green is 1.91:1 on the
                // light app bar, so light mode uses the deeper ink.
                color: c.brandText,
              ),
            ),
          ],
        ),
        // Supplying `actions` at all suppresses the AppBar's automatic
        // end-drawer button, so the menu has to be added back explicitly —
        // otherwise the drawer is only reachable by an edge drag.
        actions: [
          const _AppearanceIconButton(),
          IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      endDrawer: _PlayerDrawer(
        onSelectTab: _goToTab,
        onSignOut: _signOut,
        currentUser: ref.watch(currentUserProvider),
      ),
      // IndexedStack, not a swap: rebuilding the selected tab from scratch on
      // every switch threw away half-filled Create Match / Create Tournament
      // forms and any scroll position.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          PlayerHomeScreen(
            onBookCourt: () => _goToTab(1),
            onSeeAllCourts: () => _goToTab(1),
          ),
          ..._screens,
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: c.brandText,
          unselectedItemColor: c.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.travel_explore_rounded),
              label: 'Courts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events_rounded),
              label: 'Tournaments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_tennis_outlined),
              activeIcon: Icon(Icons.sports_tennis_rounded),
              label: 'Matches',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await AppFeedback.confirm(
      context,
      title: 'Sign out?',
      message: 'You will be returned to the login screen.',
      confirmLabel: 'Sign out',
      icon: Icons.logout_rounded,
      destructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(authStateProvider.notifier).signOut();
    } catch (_) {
      // Offline demo build — there may be no Firebase session to end.
    }
    SessionController.to.signOut();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}

/// App-bar appearance cycler (System → Light → Dark).
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

/// The player side menu.
///
/// Rewritten from a stack of dead `Navigator.pop`-only tiles (and an alert box
/// that just told you to type "owner" twice) into a working menu with a
/// role-aware profile header, an appearance switch and real destinations.
class _PlayerDrawer extends StatelessWidget {
  const _PlayerDrawer({
    required this.onSelectTab,
    required this.onSignOut,
    required this.currentUser,
  });

  final ValueChanged<int> onSelectTab;
  final Future<void> Function() onSignOut;
  final dynamic currentUser;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Drawer(
      width: 316,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerProfileHeader(currentUser: currentUser),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                children: [
                  const _DrawerSectionLabel('Play'),
                  _DrawerTile(
                    icon: Icons.calendar_today_rounded,
                    title: 'My Reservations',
                    subtitle: 'Upcoming and past bookings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyReservationsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.sports_tennis_rounded,
                    title: 'My Matches',
                    subtitle: 'Matches you created or joined',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(3);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.emoji_events_rounded,
                    title: 'My Tournaments',
                    subtitle: 'Entries and registration status',
                    onTap: () {
                      Navigator.pop(context);
                      onSelectTab(2);
                    },
                  ),
                  const SizedBox(height: 6),
                  const _DrawerSectionLabel('Appearance'),
                  const _AppearanceSelector(),
                  const SizedBox(height: 6),
                  const _DrawerSectionLabel('Switch panel'),
                  const _RoleSwitchTile(role: AppRole.owner),
                  const _RoleSwitchTile(role: AppRole.admin),
                  const SizedBox(height: 6),
                  const _DrawerSectionLabel('Support'),
                  _DrawerTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Guides, contact and FAQ',
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpSheet(context);
                    },
                  ),
                  _DrawerTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Padelit',
                    subtitle: 'Version 1.0.0 · Demo build',
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: 'Padelit',
                        applicationVersion: '1.0.0 (demo)',
                        applicationIcon: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            gradient: AColors.lineargradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.sports_tennis_rounded,
                            color: Colors.white,
                          ),
                        ),
                        children: const [
                          Text(
                            'A padel court booking, open-match and tournament '
                            'platform with dedicated player, court-owner and '
                            'administrator experiences.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: c.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onSignOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AColors.error,
                    side:
                        BorderSide(color: AColors.error.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showHelpSheet(BuildContext context) {
    showAppSheet<void>(
      context,
      title: 'Help & Support',
      subtitle: 'Everything you need to get playing',
      icon: Icons.help_outline_rounded,
      heightFactor: 0.7,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: const [
          _HelpItem(
            icon: Icons.search_rounded,
            title: 'Finding a court',
            body: 'Open the Courts tab, then use Filters, Areas or Nearest to '
                'narrow the list. Tap a court to see photos, facilities and '
                'available time slots.',
          ),
          _HelpItem(
            icon: Icons.group_add_rounded,
            title: 'Joining an open match',
            body: 'In the Matches tab, pick any match with free slots and tap '
                'Join. The organiser reviews your request and you are notified '
                'as soon as it is accepted.',
          ),
          _HelpItem(
            icon: Icons.emoji_events_rounded,
            title: 'Entering a tournament',
            body: 'Browse the Tournaments tab, open a tournament for the full '
                'format, prize and schedule breakdown, then send an entry '
                'request before the registration deadline.',
          ),
          _HelpItem(
            icon: Icons.mail_outline_rounded,
            title: 'Still stuck?',
            body: 'Reach the support team at support@padelit.app — the demo '
                'build answers within one working day.',
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: c.brandText),
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
                    fontSize: 14,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerProfileHeader extends StatefulWidget {
  const _DrawerProfileHeader({required this.currentUser});

  final dynamic currentUser;

  @override
  State<_DrawerProfileHeader> createState() => _DrawerProfileHeaderState();
}

class _DrawerProfileHeaderState extends State<_DrawerProfileHeader> {
  /// Built once per uid rather than inline in `build`, which fired a fresh
  /// Firestore read every time the enclosing Obx rebuilt.
  late Future<DocumentSnapshot?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = _loadProfile();
  }

  @override
  void didUpdateWidget(_DrawerProfileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser?.uid != widget.currentUser?.uid) {
      _profile = _loadProfile();
    }
  }

  Future<DocumentSnapshot?> _loadProfile() {
    final uid = widget.currentUser?.uid;
    if (uid is! String) return Future<DocumentSnapshot?>.value(null);
    try {
      // `FirebaseFirestore.instance` throws *synchronously* when
      // `Firebase.initializeApp` failed (main swallows that), so the getter
      // needs the try, not just the returned future.
      return FirebaseFirestore.instance
          .collection('players')
          .doc(uid)
          .get()
          .then<DocumentSnapshot?>((snap) => snap)
          // Offline demo build: never let a Firestore failure blank the
          // drawer — fall back to the session account below.
          .onError<Object>((_, __) => null);
    } catch (_) {
      return Future<DocumentSnapshot?>.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionController.to;

    return Obx(() {
      final account = session.account.value ?? DemoAccounts.player;

      return FutureBuilder<DocumentSnapshot?>(
        future: _profile,
        builder: (context, snapshot) {
          String displayName = account.displayName;
          String email = account.email;
          String? avatarUrl;

          final data = snapshot.data?.data();
          if (data is Map<String, dynamic>) {
            final first = (data['firstName'] ?? '').toString().trim();
            final last = (data['lastName'] ?? '').toString().trim();
            final full = '$first $last'.trim();
            if (full.isNotEmpty) displayName = full;
            email = (data['email'] ?? email).toString();
            avatarUrl = data['avatarImage'] as String?;
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AColors.brandGradient,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: avatarUrl != null
                          ? Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              width: 54,
                              height: 54,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 30,
                                // The avatar disc is always white, so the
                                // accent green would sit at 1.9:1 on it.
                                color: AColors.primaryInk,
                              ),
                            )
                          : Image.asset(
                              AImages.avatar1,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 30,
                                // The avatar disc is always white, so the
                                // accent green would sit at 1.9:1 on it.
                                color: AColors.primaryInk,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(account.role.icon,
                                size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              '${account.role.label} account',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
          color: context.padel.textSecondary,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.tone,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final Color accent = tone ?? AColors.primaryColor;
    // The tint keeps the raw accent; the glyph on top of it has to be darkened
    // (light mode) or lightened (dark mode) to stay legible.
    final Color accentInk = c.onSurfaceAccent(accent);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: c.soft(accent),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: accentInk),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: c.textSecondary),
              ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: c.textSecondary,
        ),
      ),
    );
  }
}

/// Segmented Light / Dark / System control.
class _AppearanceSelector extends StatelessWidget {
  const _AppearanceSelector();

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final controller = ThemeController.to;

    const modes = <(ThemeMode, String, IconData)>[
      (ThemeMode.light, 'Light', Icons.light_mode_rounded),
      (ThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
      (ThemeMode.system, 'Auto', Icons.brightness_auto_rounded),
    ];

    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.fill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            for (final (mode, label, icon) in modes)
              Expanded(
                child: _AppearanceSegment(
                  label: label,
                  icon: icon,
                  // The filled segment uses the deep brand green so its white
                  // glyph clears 4.5:1; the accent would leave it at 1.9:1.
                  selected: controller.themeMode.value == mode,
                  onTap: () => controller.setMode(mode),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSegment extends StatelessWidget {
  const _AppearanceSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;
    final Color fill = selected ? c.brandFill : Colors.transparent;
    final Color foreground = selected ? c.foregroundOn(fill) : c.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Jumps straight into another panel of the product.
///
/// The owner panel used to be gated behind an alert box that only told the user
/// to type "owner" as both fields; there is no reason to re-authenticate inside
/// a demo, so this switches directly and updates the session role.
class _RoleSwitchTile extends StatelessWidget {
  const _RoleSwitchTile({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final account = role == AppRole.owner
        ? DemoAccounts.owner
        : role == AppRole.admin
            ? DemoAccounts.admin
            : DemoAccounts.player;

    return _DrawerTile(
      icon: role.icon,
      tone: role.color,
      title: '${role.label} panel',
      subtitle: account.description,
      onTap: () {
        Navigator.pop(context);
        SessionController.to.signIn(account);
        Get.offAll(() => LoginController.homeForRole(role));
      },
    );
  }
}

// New Player Home Screen with Recent Reservations
class PlayerHomeScreen extends StatelessWidget {
  const PlayerHomeScreen({super.key, this.onBookCourt, this.onSeeAllCourts});

  final VoidCallback? onBookCourt;
  final VoidCallback? onSeeAllCourts;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Welcome Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(20),
            constraints: const BoxConstraints(minHeight: 180),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              // The deep brand gradient: the old #29E68F top stop rendered the
              // white headline on this hero at 1.64:1.
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AColors.brandGradient,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AColors.primaryColor.withValues(alpha: 0.34),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PadelHeroPatternPainter(),
                  ),
                ),
                Positioned(
                  right: -18,
                  top: -22,
                  bottom: -20,
                  width: 190,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PadelHeroIllustrationPainter(),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Obx: `displayName` reads an Rx, so without one
                            // the banner froze on whatever account was live
                            // when this screen was first built.
                            Obx(
                              () => Text(
                                'Welcome back, '
                                '${SessionController.to.displayName.split(' ').first}!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ready for your next padel match?',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event_available_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      'Next game: Jan 20 at Al Ahmar Club',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: onBookCourt,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                // #07925E was only 3.98:1 on white.
                                foregroundColor: AColors.primaryInk,
                                elevation: 10,
                                shadowColor:
                                    Colors.black.withValues(alpha: 0.24),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                minimumSize: const Size(168, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.sports_tennis_rounded, size: 19),
                                  SizedBox(width: 9),
                                  Text(
                                    'Book a Court',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 94),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Recent Reservations Widget
          const RecentReservationsWidget(),
          const SizedBox(height: 30),

          // Featured Courts Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Popular Courts',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: onSeeAllCourts,
                      child: Text(
                        'See All',
                        style: TextStyle(color: c.brandText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Featured Courts Grid
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 10),
                    children: [
                      _buildFeaturedCourtCard(
                        context,
                        'Al Noor Club',
                        'Downtown Cairo',
                        '\$250/hour',
                        4.8,
                        12,
                        CourtImages.alNoor,
                      ),
                      const SizedBox(width: 12),
                      _buildFeaturedCourtCard(
                        context,
                        'Al Ahmar Club',
                        'New Cairo',
                        '\$300/hour',
                        4.9,
                        18,
                        CourtImages.alAhmar,
                      ),
                      const SizedBox(width: 12),
                      _buildFeaturedCourtCard(
                        context,
                        'Athletes Club',
                        'Giza',
                        '\$200/hour',
                        4.7,
                        25,
                        CourtImages.athletes,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Quick Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Stats',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(
                      child: _StatCard(
                        value: '12',
                        label: 'Courts Booked',
                        tone: AColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        value: '4.8',
                        label: 'Your Rating',
                        tone: c.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeaturedCourtCard(
    BuildContext context,
    String name,
    String location,
    String price,
    double rating,
    int reviews,
    String image,
  ) {
    final c = context.padel;

    return GestureDetector(
      onTap: () {
        // Create dummy court object and navigate to details screen
        final pricePerHour = double.tryParse(
                price.replaceAll('\$', '').replaceAll('/hour', '')) ??
            250.0;
        final court = PadelCourt(
          id: name.replaceAll(' ', '_').toLowerCase(),
          name: name,
          location: location,
          description:
              'Premium padel court with world-class facilities and professional service',
          pricePerHour: pricePerHour,
          photos: [
            image,
            ..._galleryImagesForCourt(name),
          ],
          facilities: [
            'Air Conditioning',
            'Professional Lighting',
            'Restaurant',
            'Parking',
            'Locker Rooms'
          ],
          type: CourtType.indoor,
          rating: rating,
          totalBookings: reviews * 10,
          createdAt: DateTime.now(),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourtDetailsScreen(court: court),
          ),
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          // Semantic tokens, not neutral greys: Colors.grey[800] has none of
          // the green cast of the surrounding cards and read as a foreign slab.
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: c.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                height: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      image,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildCourtImageFallback();
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _buildCourtImageFallback();
                      },
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.24),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            // Amber is a light fill: white on it is 1.62:1, so
                            // the badge takes the ink foreground instead.
                            Icon(
                              Icons.star,
                              size: 12,
                              color: c.foregroundOn(Colors.amber),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toString(),
                              style: TextStyle(
                                color: c.foregroundOn(Colors.amber),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Court Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: c.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      // The accent green is 1.91:1 on the white card; as text
                      // the brand colour has to deepen in light mode.
                      color: c.brandText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '($reviews reviews)',
                    style: TextStyle(fontSize: 9, color: c.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _galleryImagesForCourt(String name) {
    if (name.contains('Ahmar')) {
      return const [CourtImages.alAhmarAlt, CourtImages.alNoor];
    }
    if (name.contains('Athletes')) {
      return const [CourtImages.athletesAlt, CourtImages.alAhmar];
    }
    return const [CourtImages.alNoorAlt, CourtImages.alAhmar];
  }

  Widget _buildCourtImageFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AColors.brandGradient,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.sports_tennis_rounded,
          color: Colors.white.withValues(alpha: 0.9),
          size: 34,
        ),
      ),
    );
  }
}

/// One tile of the "Your Stats" row.
///
/// [tone] is the accent the card is tinted with; the value on top of it goes
/// through `onSurfaceAccent` because the raw tones (the accent green, the
/// success green) sit around 2.6:1 on the tinted card in light mode.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.tone,
  });

  final String value;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final c = context.padel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.soft(tone),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: c.onSurfaceAccent(tone),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PadelHeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (var x = -size.height; x < size.width + size.height; x += 34) {
      canvas.drawLine(
        Offset(x.toDouble(), size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }

    final courtPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final courtRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.56, 18, size.width * 0.38, size.height - 36),
      const Radius.circular(18),
    );
    canvas.drawRRect(courtRect, courtPaint);
    canvas.drawLine(
      Offset(size.width * 0.75, 24),
      Offset(size.width * 0.75, size.height - 24),
      courtPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.58, size.height * 0.5),
      Offset(size.width * 0.92, size.height * 0.5),
      courtPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PadelHeroIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(
      Offset(size.width * 0.54, size.height * 0.5),
      size.width * 0.42,
      glowPaint,
    );

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.47);
    canvas.rotate(-0.42);

    final racketStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final racketFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final headRect = Rect.fromCenter(
      center: Offset.zero,
      width: size.width * 0.52,
      height: size.width * 0.66,
    );
    canvas.drawOval(headRect, racketFill);
    canvas.drawOval(headRect, racketStroke);

    final stringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1.2;
    for (var dx = -30.0; dx <= 30; dx += 15) {
      canvas.drawLine(Offset(dx, -48), Offset(dx, 48), stringPaint);
    }
    for (var dy = -36.0; dy <= 36; dy += 18) {
      canvas.drawLine(Offset(-42, dy), Offset(42, dy), stringPaint);
    }

    final handlePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.width * 0.34),
      Offset(0, size.width * 0.72),
      handlePaint,
    );
    canvas.restore();

    final ballPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.3),
      13,
      ballPaint,
    );

    final ballLinePaint = Paint()
      ..color = const Color(0xFF0B9E63).withValues(alpha: 0.38)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.78, size.height * 0.3),
        radius: 8,
      ),
      -0.9,
      1.8,
      false,
      ballLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
