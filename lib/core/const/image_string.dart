/// Bundled image assets.
///
/// Only the signup avatars ship with the app (see `assets/images/` in
/// pubspec.yaml). Court photography is remote and lives in
/// `core/const/court_images.dart`; anything rendering one of those URLs must
/// provide an `errorBuilder` so the offline demo degrades to a branded
/// placeholder rather than a red error box.
class AImages {
  AImages._();

  static const String avatar1 = 'assets/images/avatar1.jpg';
  static const String avatar2 = 'assets/images/avatar2.jpg';
  static const String avatar3 = 'assets/images/avatar3.jpg';
  static const String avatar4 = 'assets/images/avatar4.jpg';
  static const String avatar5 = 'assets/images/avatar5.jpg';

  static const List<String> avatars = [
    avatar1,
    avatar2,
    avatar3,
    avatar4,
    avatar5,
  ];

  /// Stable avatar for an arbitrary key (a user id, an email, a name), so the
  /// same person always gets the same picture.
  static String avatarFor(String seed) {
    if (seed.isEmpty) return avatar1;
    final index = seed.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return avatars[index % avatars.length];
  }
}
