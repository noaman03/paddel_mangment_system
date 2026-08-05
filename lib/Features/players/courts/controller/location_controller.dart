import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:padel_management_system/core/const/colors.dart';
import 'package:padel_management_system/core/utils/feedback/app_feedback.dart';

/// A hand-picked area the user can drop themselves into.
///
/// The demo runs on desktop/web where the real permission flow can never
/// succeed, which used to leave the "Nearest" sheet stuck on "Enable Location"
/// forever. Picking an area sets the coordinates directly so distance sorting,
/// the distance slider and the per-card distance labels all become live.
class DemoArea {
  const DemoArea(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}

class LocationController extends GetxController {
  static const List<DemoArea> demoAreas = <DemoArea>[
    DemoArea('Downtown Cairo', 30.0444, 31.2357),
    DemoArea('New Cairo', 30.0300, 31.4700),
    DemoArea('Maadi', 29.9600, 31.2570),
    DemoArea('Zamalek', 30.0610, 31.2200),
    DemoArea('Heliopolis', 30.0910, 31.3300),
    DemoArea('Giza', 30.0130, 31.2090),
    DemoArea('Nasr City', 30.0600, 31.3400),
    DemoArea('Sheikh Zayed', 30.0130, 30.9760),
    DemoArea('6th of October', 29.9390, 30.9140),
  ];

  /// Fallback position, used before a location is set and again after it is
  /// cleared. Named constants so "clear" can never drift from the initial state.
  static const String defaultLocationName = 'Downtown, Cairo';
  static const double defaultLatitude = 30.0444;
  static const double defaultLongitude = 31.2357;
  static const double defaultMaxDistance = 50.0;

  // Location state
  final RxString currentLocation = defaultLocationName.obs;
  final RxDouble currentLatitude = defaultLatitude.obs; // Cairo default
  final RxDouble currentLongitude = defaultLongitude.obs; // Cairo default
  final RxDouble maxDistance = defaultMaxDistance.obs;

  /// True once we have a usable position, from GPS *or* from a picked area.
  final RxBool locationPermissionGranted = false.obs;
  final RxBool usingPickedArea = false.obs;
  final RxBool locationServiceEnabled = false.obs;
  final RxBool isUpdatingLocation = false.obs;
  final RxBool isRequestingPermission = false.obs;

  /// Why the device location failed, rendered inline in the Nearest sheet.
  /// Empty when there is nothing to report.
  final RxString statusMessage = ''.obs;

  /// Set when the OS reports the permission as permanently blocked, so the
  /// sheet can offer a settings shortcut instead of a dead retry button.
  final RxBool permissionBlocked = false.obs;

  /// Drop the user into a known area without touching the platform at all.
  void useDemoArea(DemoArea area) {
    currentLatitude.value = area.latitude;
    currentLongitude.value = area.longitude;
    currentLocation.value = area.name;
    usingPickedArea.value = true;
    locationPermissionGranted.value = true;
    permissionBlocked.value = false;
    statusMessage.value = '';
    AppFeedback.success('Location set', 'Showing courts near ${area.name}');
  }

  bool isSelectedArea(DemoArea area) =>
      usingPickedArea.value && currentLocation.value == area.name;

  /// Forget the current position and go back to "location not set".
  ///
  /// Nothing used to write `false` back into [locationPermissionGranted], so a
  /// single tap on an area chip locked the app into "nearest" mode for the rest
  /// of the session — distance filtering and distance sorting could never be
  /// turned off again.
  void clearLocation() {
    currentLatitude.value = defaultLatitude;
    currentLongitude.value = defaultLongitude;
    currentLocation.value = defaultLocationName;
    usingPickedArea.value = false;
    locationPermissionGranted.value = false;
    permissionBlocked.value = false;
    statusMessage.value = '';
  }

  /// Ask the device for a real position.
  ///
  /// The permission flag and coordinates are committed BEFORE any user
  /// feedback: the old version raised its "granted" snackbar inside the try
  /// block, and because `Get.snackbar` throws on this Flutter version the catch
  /// immediately flipped permission back to denied. Feedback now happens after
  /// the try/catch, where it cannot corrupt state.
  Future<void> requestLocationPermission() async {
    if (isRequestingPermission.value) return;

    isRequestingPermission.value = true;
    statusMessage.value = '';

    bool granted = false;
    bool blocked = false;
    String? failure;
    double? latitude;
    double? longitude;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      locationServiceEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        failure = 'Location services are turned off on this device.';
      } else {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.deniedForever) {
          blocked = true;
          failure = 'Location permission is blocked for this app.';
        } else if (permission == LocationPermission.denied) {
          failure = 'Location permission was denied.';
        } else {
          final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).timeout(const Duration(seconds: 20));
          latitude = position.latitude;
          longitude = position.longitude;
          granted = true;
        }
      }
    } catch (_) {
      failure = 'This device could not provide a location.';
    }

    permissionBlocked.value = blocked;

    if (granted && latitude != null && longitude != null) {
      currentLatitude.value = latitude;
      currentLongitude.value = longitude;
      currentLocation.value =
          'Location (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
      usingPickedArea.value = false;
      locationPermissionGranted.value = true;
      statusMessage.value = '';
      await _reverseGeocode(latitude, longitude);
    } else {
      statusMessage.value =
          '${failure ?? 'Location is unavailable.'} Pick an area below to keep using distance filters.';
    }

    isRequestingPermission.value = false;

    if (granted) {
      AppFeedback.success(
        'Location found',
        'Courts are now sorted by distance from you',
      );
    } else {
      AppFeedback.warning('Location unavailable', failure);
    }
  }

  /// Re-read the device position for an already granted permission.
  Future<void> updateLocation() async {
    if (usingPickedArea.value) {
      // Nothing to refresh for a manually picked area.
      AppFeedback.info(
        'Area location',
        'You are browsing from ${currentLocation.value}',
      );
      return;
    }
    isUpdatingLocation.value = true;
    await requestLocationPermission();
    isUpdatingLocation.value = false;
  }

  /// Opens the OS settings page. Guarded because there is no web/desktop
  /// implementation, and the old call site threw an uncaught UnimplementedError.
  Future<void> openLocationSettings() async {
    if (kIsWeb) {
      AppFeedback.info(
        'Not available here',
        'Allow location from your browser address bar, or pick an area below.',
      );
      return;
    }
    try {
      await Geolocator.openAppSettings();
    } catch (_) {
      AppFeedback.info(
        'Settings unavailable',
        'Open your system settings and allow location for PadelSystem.',
      );
    }
  }

  // Reverse geocoding (no-op fallback when the platform has no implementation)
  Future<void> _reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        currentLocation.value = _formatAddress(placemarks.first);
      }
    } catch (_) {
      // Web/desktop have no geocoding plugin — the raw coordinates stay.
    }
  }

  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    if (placemark.subLocality?.isNotEmpty == true) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    } else if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  /// Distance in kilometres between two coordinates.
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Status getters (rendered inline in the Nearest sheet)
  String get locationStatusText {
    if (isRequestingPermission.value) return 'Locating you...';
    if (!locationPermissionGranted.value) return 'Location not set';
    return currentLocation.value;
  }

  Color get locationStatusColor {
    if (isRequestingPermission.value) return AColors.warning;
    if (!locationPermissionGranted.value) return AColors.warning;
    return AColors.success;
  }

  IconData get locationStatusIcon {
    if (isRequestingPermission.value) return Icons.location_searching_rounded;
    if (!locationPermissionGranted.value) return Icons.location_off_rounded;
    return Icons.location_on_rounded;
  }

  String getFormattedDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }
}
