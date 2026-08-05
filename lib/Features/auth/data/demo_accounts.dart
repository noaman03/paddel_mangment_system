import 'package:flutter/material.dart';
import 'package:padel_management_system/core/const/colors.dart';

/// Which part of the product a signed-in user lands in.
enum AppRole { player, admin, owner }

extension AppRoleX on AppRole {
  String get label {
    switch (this) {
      case AppRole.player:
        return 'Player';
      case AppRole.admin:
        return 'Administrator';
      case AppRole.owner:
        return 'Court Owner';
    }
  }

  String get shortLabel {
    switch (this) {
      case AppRole.player:
        return 'Player';
      case AppRole.admin:
        return 'Admin';
      case AppRole.owner:
        return 'Owner';
    }
  }

  IconData get icon {
    switch (this) {
      case AppRole.player:
        return Icons.sports_tennis_rounded;
      case AppRole.admin:
        return Icons.admin_panel_settings_rounded;
      case AppRole.owner:
        return Icons.business_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AppRole.player:
        return AColors.primaryColor;
      case AppRole.admin:
        return AColors.info;
      case AppRole.owner:
        return AColors.warning;
    }
  }
}

/// A demo login. This build ships without a live backend, so the three
/// portfolio accounts below are the source of truth for authentication.
@immutable
class DemoAccount {
  const DemoAccount({
    required this.role,
    required this.email,
    required this.password,
    required this.displayName,
    required this.description,
    this.avatarAsset,
  });

  final AppRole role;
  final String email;
  final String password;
  final String displayName;
  final String description;
  final String? avatarAsset;

  /// Emails are matched case-insensitively; passwords are matched exactly
  /// except for the `owner` shortcut, which is deliberately forgiving.
  bool matches(String inputEmail, String inputPassword) {
    final email = inputEmail.trim().toLowerCase();
    if (email != this.email) return false;
    if (role == AppRole.owner) {
      return inputPassword.trim().toLowerCase() == password;
    }
    return inputPassword.trim() == password;
  }
}

class DemoAccounts {
  DemoAccounts._();

  static const DemoAccount player = DemoAccount(
    role: AppRole.player,
    email: 'ahmed@email.com',
    password: 'AMZ 123 mh',
    displayName: 'Ahmed Hassan',
    description: 'Book courts, join matches and enter tournaments',
    avatarAsset: 'assets/images/avatar1.jpg',
  );

  static const DemoAccount admin = DemoAccount(
    role: AppRole.admin,
    email: 'admin@email.com',
    password: 'admin123',
    displayName: 'System Administrator',
    description: 'Approve clubs, moderate users and view platform stats',
  );

  static const DemoAccount owner = DemoAccount(
    role: AppRole.owner,
    email: 'owner',
    password: 'owner',
    displayName: 'Cairo Padel Club',
    description: 'Manage courts, bookings, revenue and tournaments',
  );

  static const List<DemoAccount> all = <DemoAccount>[player, admin, owner];

  /// Returns the account matching the credentials, or `null`.
  static DemoAccount? authenticate(String email, String password) {
    for (final account in all) {
      if (account.matches(email, password)) return account;
    }
    return null;
  }

  /// Whether the email belongs to a known demo account, regardless of password.
  /// Used to tell "wrong password" apart from "unknown account".
  static DemoAccount? byEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final account in all) {
      if (account.email == normalized) return account;
    }
    return null;
  }
}
