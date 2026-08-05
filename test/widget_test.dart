import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:padel_management_system/Features/admin/admin_screen.dart';
import 'package:padel_management_system/Features/admin/controller/admin_controller.dart';
import 'package:padel_management_system/Features/auth/data/demo_accounts.dart';
import 'package:padel_management_system/Features/auth/presentation/login/controller/login_controller.dart';
import 'package:padel_management_system/Features/owner/dashboard/owner_dashboard.dart';
import 'package:padel_management_system/Features/players/open_matches/controller/open_matches_controller.dart';
import 'package:padel_management_system/Features/players/tournaments/controller/tournament_controller.dart';
import 'package:padel_management_system/Screens/home/player_home.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/controllers/session_controller.dart';
import 'package:padel_management_system/core/utils/theme/theme.dart';
import 'package:padel_management_system/main.dart';

/// These tests pin down the behaviour that was reported broken:
/// invisible dark-mode text, "join does nothing", non-functional court
/// filters, and admin/owner logins landing on the wrong panel.
void main() {
  tearDown(Get.reset);

  group('smoke', () {
    testWidgets('App starts on the login screen', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pump();

      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Demo accounts'), findsOneWidget);
    });

    testWidgets('Admin panel renders its dashboard shell', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: appTheme.lightTheme, home: const AdminScreen()),
      );
      await tester.pump();

      expect(find.text('Sign out'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('authentication routing', () {
    // The owner shortcut used to be bucketed with the admin credential and
    // landed on the admin panel; anything else silently signed in as a player.
    test('each demo account authenticates', () {
      expect(
        DemoAccounts.authenticate('ahmed@email.com', 'AMZ 123 mh')?.role,
        AppRole.player,
      );
      expect(
        DemoAccounts.authenticate('admin@email.com', 'admin123')?.role,
        AppRole.admin,
      );
      expect(DemoAccounts.authenticate('owner', 'owner')?.role, AppRole.owner);
    });

    test('email matching is case insensitive', () {
      expect(
        DemoAccounts.authenticate('  Ahmed@Email.com ', 'AMZ 123 mh')?.role,
        AppRole.player,
      );
    });

    test('wrong credentials are rejected instead of signing in as a player',
        () {
      expect(DemoAccounts.authenticate('ahmed@email.com', 'nope'), isNull);
      expect(DemoAccounts.authenticate('x', 'x'), isNull);
      // …but the account is still recognised, so the UI can say
      // "incorrect password" rather than "account not found".
      expect(DemoAccounts.byEmail('ahmed@email.com')?.role, AppRole.player);
      expect(DemoAccounts.byEmail('nobody@email.com'), isNull);
    });

    test('every role lands on its own panel', () {
      expect(LoginController.homeForRole(AppRole.player), isA<PlayerHome>());
      expect(LoginController.homeForRole(AppRole.admin), isA<AdminScreen>());
      expect(LoginController.homeForRole(AppRole.owner), isA<OwnerDashboard>());
    });
  });

  group('tournaments', () {
    late TournamentsController controller;

    setUp(() {
      controller = Get.put(TournamentsController());
      SessionController.to.signIn(DemoAccounts.player);
    });

    // "when i press on join nothing happens"
    test('joining mutates state instead of only firing a snackbar', () async {
      final target = controller.allTournaments
          .firstWhere((t) => !controller.hasJoined(t) && !controller.isFull(t));
      final id = target['id'] as String;
      final before = target['currentParticipants'] as int;
      final myBefore = controller.myTournaments.length;

      final result = await controller.joinTournament(id);

      expect(result, TournamentJoinResult.joined);
      expect(controller.tournamentById(id)!['currentParticipants'], before + 1);
      expect(controller.myTournaments.length, myBefore + 1);
      expect(controller.hasJoined(controller.tournamentById(id)!), isTrue);
    });

    test('the same tournament cannot be joined twice', () async {
      final target = controller.allTournaments
          .firstWhere((t) => !controller.hasJoined(t) && !controller.isFull(t));
      final id = target['id'] as String;

      await controller.joinTournament(id);
      final second = await controller.joinTournament(id);

      expect(second, TournamentJoinResult.alreadyRequested);
    });

    test('a full tournament reports full', () async {
      final full = controller.allTournaments.firstWhere(controller.isFull);
      expect(
        await controller.joinTournament(full['id'] as String),
        TournamentJoinResult.full,
      );
    });

    test('an unknown id does not throw', () async {
      expect(
        await controller.joinTournament('does-not-exist'),
        TournamentJoinResult.notFound,
      );
    });

    // The dropdown offers "Player Created" while the seed data says "Player",
    // so this filter used to match nothing at all.
    test('the player-created filter matches player-run tournaments', () {
      controller.updateTournamentType('Player Created');
      expect(controller.filteredTournaments, isNotEmpty);
      expect(
        controller.filteredTournaments
            .every((t) => t['organizerType'] != 'Official'),
        isTrue,
      );
    });

    test('resetFilters restores the full list', () {
      final total = controller.allTournaments.length;
      controller.searchTournaments('zzzz-no-such-tournament');
      expect(controller.filteredTournaments, isEmpty);

      controller.resetFilters();
      expect(controller.filteredTournaments.length, total);
    });

    test('accepting an entry request removes it from the queue', () {
      final id = controller.entryRequests.first['id'] as String;
      final before = controller.entryRequests.length;

      expect(controller.acceptEntryRequest(id), isNotNull);
      expect(controller.entryRequests.length, before - 1);
      // Repeat handling must not throw a StateError on the missing id.
      expect(controller.acceptEntryRequest(id), isNull);
    });
  });

  group('open matches', () {
    late OpenMatchesController controller;

    setUp(() {
      controller = Get.put(OpenMatchesController());
      SessionController.to.signIn(DemoAccounts.player);
    });

    // "same thing in matches screen"
    test('joining a match updates the roster and My Matches', () {
      final target = controller.allMatches.firstWhere(
        (m) =>
            !controller.joinedMatchIds.contains(m['id']) &&
            (m['playersNeeded'] as int) > 0,
      );
      final id = target['id'] as String;
      final playersBefore = target['currentPlayers'] as int;
      final neededBefore = target['playersNeeded'] as int;
      final myBefore = controller.myMatches.length;

      controller.joinMatch(id);

      final after = controller.matchById(id)!;
      expect(after['currentPlayers'], playersBefore + 1);
      expect(after['playersNeeded'], neededBefore - 1);
      expect(controller.joinedMatchIds.contains(id), isTrue);
      expect(controller.myMatches.length, myBefore + 1);
    });

    test('joining twice does not double-count', () {
      final target = controller.allMatches.firstWhere(
        (m) =>
            !controller.joinedMatchIds.contains(m['id']) &&
            (m['playersNeeded'] as int) > 0,
      );
      final id = target['id'] as String;

      controller.joinMatch(id);
      final players = controller.matchById(id)!['currentPlayers'] as int;
      controller.joinMatch(id);

      expect(controller.matchById(id)!['currentPlayers'], players);
    });

    test('clearFilters restores the full list', () {
      final total = controller.allMatches.length;
      controller.searchMatches('zzzz-no-such-match');
      expect(controller.filteredMatches, isEmpty);
      expect(controller.hasActiveFilters, isTrue);

      controller.clearFilters();
      expect(controller.filteredMatches.length, total);
      expect(controller.hasActiveFilters, isFalse);
    });

    test('creating a match makes it visible immediately', () {
      final before = controller.allMatches.length;
      final created = controller.createMatch(
        title: 'Sunset Doubles',
        description: 'Casual evening game',
        courtName: 'Cairo Padel Club',
        location: 'New Cairo',
        date: DateTime.now().add(const Duration(days: 3)),
        time: '19:00',
        duration: '1.5 hours',
        playersNeeded: 2,
        skillLevel: 'Intermediate',
        matchType: 'Doubles',
        price: 45,
      );

      expect(controller.allMatches.length, before + 1);
      expect(controller.filteredMatches, contains(created));
      expect(controller.myMatches.any((m) => m['title'] == 'Sunset Doubles'),
          isTrue);
    });
  });

  group('admin panel', () {
    test('operations queue and CSV export reflect the live data', () {
      final controller = Get.put(AdminController());

      expect(controller.operations, isNotEmpty);
      expect(
          controller.operationsCsv(), contains('Item,Owner,Status,Priority'));

      final before = controller.notifications.where((n) => !n.read).length;
      expect(before, greaterThan(0));
      controller.markAllNotificationsRead();
      expect(controller.notifications.every((n) => n.read), isTrue);
    });
  });

  group('theme', () {
    // The dark input theme used a white fill while the dark text theme painted
    // text white — so everything typed in dark mode was invisible.
    test('dark input fill contrasts with dark body text', () {
      final fill = appTheme.darkTheme.inputDecorationTheme.fillColor!;
      final text = appTheme.darkTheme.textTheme.bodyLarge!.color!;

      expect(fill, isNot(equals(Colors.white)));
      expect(
        _luminanceGap(fill, text),
        greaterThan(0.4),
        reason: 'typed text must be readable against the field background',
      );
    });

    test('dark app bar icons are not black on black', () {
      final iconColor = appTheme.darkTheme.appBarTheme.iconTheme!.color!;
      final background = appTheme.darkTheme.scaffoldBackgroundColor;

      expect(_luminanceGap(iconColor, background), greaterThan(0.4));
    });

    test('both themes supply an explicit ColorScheme, not the M2 fallback', () {
      expect(appTheme.lightTheme.colorScheme.primary, AColors.primaryColor);
      expect(appTheme.darkTheme.colorScheme.primary, AColors.primaryColor);
      expect(appTheme.darkTheme.colorScheme.surface, AColors.containerDark);
      // ColorScheme.fromSwatch() used to hand back a teal secondary and black
      // outlines that appear nowhere in the brand.
      expect(appTheme.darkTheme.colorScheme.outline, isNot(Colors.black));
      expect(appTheme.lightTheme.colorScheme.outline, isNot(Colors.black));
    });

    test('dark cards are opaque so they are visible on the scaffold', () {
      expect(AColors.containerDark.a, 1.0);
      expect(
        _luminanceGap(AColors.containerDark, AColors.dark),
        lessThan(0.2),
        reason: 'cards should sit just above the background, not glow',
      );
    });

    test('every component theme both modes need is configured', () {
      for (final theme in [appTheme.lightTheme, appTheme.darkTheme]) {
        expect(theme.cardTheme.color, isNotNull);
        expect(theme.dialogTheme.backgroundColor, isNotNull);
        expect(theme.drawerTheme.backgroundColor, isNotNull);
        expect(theme.dividerTheme.color, isNotNull);
        expect(theme.snackBarTheme.backgroundColor, isNotNull);
        expect(theme.bottomNavigationBarTheme.backgroundColor, isNotNull);
        expect(theme.sliderTheme.activeTrackColor, isNotNull);
        expect(theme.listTileTheme.textColor, isNotNull);
      }
    });
  });

  // The brand green is light (relative luminance 0.50), so white text on it is
  // only 1.91:1. These pin the rules that keep the palette readable.
  group('contrast', () {
    const aa = 4.5;
    const aaLarge = 3.0;

    test('filled brand surfaces carry white text at AA', () {
      expect(AColors.contrast(AColors.white, AColors.primaryDeep),
          greaterThanOrEqualTo(aa));
      // The gradient's lightest stop is the one that has to pass.
      for (final stop in AColors.brandGradient) {
        expect(AColors.contrast(AColors.white, stop), greaterThanOrEqualTo(aa),
            reason: 'white on $stop');
      }
    });

    test('the accent green is never used as white-backed fill by the theme',
        () {
      final style = appTheme.lightTheme.elevatedButtonTheme.style!;
      final bg = style.backgroundColor!.resolve({})!;
      final fg = style.foregroundColor!.resolve({})!;
      expect(AColors.contrast(fg, bg), greaterThanOrEqualTo(aa));
      expect(bg, isNot(AColors.primaryColor));
    });

    test('foregroundOn picks a readable ink for every brand and status fill',
        () {
      for (final fill in [
        AColors.primaryColor,
        AColors.primaryDeep,
        AColors.warning,
        AColors.success,
        AColors.error,
        AColors.info,
      ]) {
        final fg = AColors.foregroundOn(fill);
        expect(AColors.contrast(fg, fill), greaterThanOrEqualTo(aaLarge),
            reason: 'foreground on $fill');
      }
    });

    testWidgets('onSurfaceAccent lifts status colours to AA on both themes',
        (tester) async {
      for (final theme in [appTheme.lightTheme, appTheme.darkTheme]) {
        late PadelPalette c;
        await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: Builder(builder: (context) {
            c = context.padel;
            return const SizedBox.shrink();
          }),
        ));
        for (final tone in [
          AColors.warning,
          AColors.success,
          AColors.error,
          AColors.info,
          AColors.primaryColor,
        ]) {
          expect(
            AColors.contrast(c.onSurfaceAccent(tone), c.surface),
            greaterThanOrEqualTo(aa),
            reason: 'status $tone as text on ${c.isDark ? "dark" : "light"} '
                'surface',
          );
        }
        // The brand colour as plain text must also be readable.
        expect(
            AColors.contrast(c.brandText, c.surface), greaterThanOrEqualTo(aa));
      }
    });

    test('body text clears AA on every themed background', () {
      for (final (theme, bg) in [
        (appTheme.lightTheme, AColors.white),
        (appTheme.lightTheme, AColors.light),
        (appTheme.darkTheme, AColors.containerDark),
        (appTheme.darkTheme, AColors.dark),
      ]) {
        final body = theme.textTheme.bodyMedium!.color!;
        expect(AColors.contrast(body, bg), greaterThanOrEqualTo(aa),
            reason: 'body text on $bg');
      }
    });
  });

  group('palette', () {
    testWidgets('semantic tokens flip with brightness', (tester) async {
      late PadelPalette light;
      late PadelPalette dark;

      // Both palettes are captured from one tree so each Builder is guaranteed
      // to see its own Theme.
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Theme(
                data: appTheme.lightTheme,
                child: Builder(builder: (context) {
                  light = context.padel;
                  return const SizedBox.shrink();
                }),
              ),
              Theme(
                data: appTheme.darkTheme,
                child: Builder(builder: (context) {
                  dark = context.padel;
                  return const SizedBox.shrink();
                }),
              ),
            ],
          ),
        ),
      );

      expect(light.isDark, isFalse);
      expect(dark.isDark, isTrue);
      expect(light.background, isNot(dark.background));
      expect(light.textPrimary, isNot(dark.textPrimary));
      expect(light.surface, isNot(dark.surface));

      for (final c in [light, dark]) {
        expect(
          _luminanceGap(c.textPrimary, c.background),
          greaterThan(0.4),
          reason: 'primary text must be readable on the page background',
        );
        expect(
          _luminanceGap(c.textSecondary, c.surface),
          greaterThan(0.2),
          reason: 'secondary text must be readable on cards',
        );
      }
    });
  });
}

double _luminanceGap(Color a, Color b) =>
    (a.computeLuminance() - b.computeLuminance()).abs();
