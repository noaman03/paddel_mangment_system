/// Court photography used by the demo catalogue.
///
/// These are remote URLs: the offline demo has no bundled court photos (only
/// the signup avatars under `assets/images/`), so **every** `Image.network`
/// pointing at one of these must supply an `errorBuilder` that degrades to a
/// branded placeholder — otherwise a missing image renders as a red error box.
///
/// The set used to contain four photos duplicated across nine constants, so
/// "Al Noor" and "Alexandria Courts" showed the identical venue. Each club now
/// has a distinct primary photo; the `*Alt` entries are secondary shots used in
/// galleries.
class CourtImages {
  CourtImages._();

  static const String _glassCourt =
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=900&q=80';
  static const String _indoorCourt =
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=900&q=80';
  static const String _floodlitCourt =
      'https://images.unsplash.com/photo-1599474924187-334a4ae5bd3c?auto=format&fit=crop&w=900&q=80';
  static const String _openAirCourt =
      'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?auto=format&fit=crop&w=900&q=80';

  // Primary photo per club — all four are different venues.
  static const String alNoor = _glassCourt;
  static const String alAhmar = _floodlitCourt;
  static const String athletes = _indoorCourt;
  static const String alexandria = _openAirCourt;

  // Secondary shots for galleries.
  static const String alNoorAlt = _indoorCourt;
  static const String alAhmarAlt = _openAirCourt;
  static const String athletesAlt = _glassCourt;
  static const String alexandriaAlt = _floodlitCourt;

  /// Shown while an owner has not uploaded a photo for a court yet.
  static const String uploadFallback = _openAirCourt;

  static const List<String> all = [
    alNoor,
    alAhmar,
    athletes,
    alexandria,
  ];
}
