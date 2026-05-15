import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:padelsystem/core/const/colors.dart';

class LocationController extends GetxController {
  // Location state
  final RxString currentLocation = 'Downtown, Cairo'.obs;
  final RxDouble currentLatitude = 30.0444.obs; // Cairo default
  final RxDouble currentLongitude = 31.2357.obs; // Cairo default
  final RxDouble maxDistance = 50.0.obs;
  final RxBool locationPermissionGranted = false.obs;
  final RxBool locationServiceEnabled = false.obs;
  final RxBool isUpdatingLocation = false.obs;
  final RxBool isRequestingPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
  }

  // Initialize location on app start
  Future<void> _initializeLocation() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await requestLocationPermission();
    } catch (e) {
      print('Error initializing location: $e');
    }
  }

  // Request location permission
  Future<void> requestLocationPermission() async {
    try {
      isRequestingPermission.value = true;
      print('Starting location permission request...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      locationServiceEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        await _showLocationServiceDialog();
        return;
      }

      // Check current permission status
      LocationPermission geolocatorPermission =
          await Geolocator.checkPermission();
      print('Geolocator permission status: $geolocatorPermission');

      if (geolocatorPermission == LocationPermission.denied) {
        bool shouldRequest = await _showPermissionExplanationDialog();

        if (!shouldRequest) {
          locationPermissionGranted.value = false;
          currentLocation.value = 'Location permission not requested';
          _showPermissionNotRequestedMessage();
          return;
        }

        geolocatorPermission = await Geolocator.requestPermission();
        await Future.delayed(const Duration(milliseconds: 1000));
      }

      if (geolocatorPermission == LocationPermission.deniedForever) {
        locationPermissionGranted.value = false;
        currentLocation.value = 'Location permission permanently denied';
        await _showPermanentlyDeniedDialog();
        return;
      }

      if (geolocatorPermission == LocationPermission.whileInUse ||
          geolocatorPermission == LocationPermission.always) {
        locationPermissionGranted.value = true;
        await _getCurrentLocation();
        _showLocationGrantedMessage();
      } else {
        locationPermissionGranted.value = false;
        currentLocation.value = 'Location permission denied';
        _showPermissionDeniedMessage();
      }
    } catch (e) {
      locationPermissionGranted.value = false;
      currentLocation.value = 'Error accessing location: ${e.toString()}';
      _showLocationErrorMessage(e.toString());
    } finally {
      isRequestingPermission.value = false;
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
        timeLimit: const Duration(seconds: 30),
      );

      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;
      await _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          currentLatitude.value = lastPosition.latitude;
          currentLongitude.value = lastPosition.longitude;
          await _reverseGeocode(lastPosition.latitude, lastPosition.longitude);
        } else {
          throw Exception('No location data available');
        }
      } catch (lastLocationError) {
        currentLocation.value = 'Error getting location: ${e.toString()}';
      }
    }
  }

  // Reverse geocoding
  Future<void> _reverseGeocode(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        currentLocation.value = _formatAddress(placemark);
      } else {
        currentLocation.value =
            'Location (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
      }
    } catch (e) {
      currentLocation.value =
          'Location (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
    }
  }

  // Format address from placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    if (placemark.subLocality?.isNotEmpty == true)
      parts.add(placemark.subLocality!);
    if (placemark.locality?.isNotEmpty == true)
      parts.add(placemark.locality!);
    else if (placemark.administrativeArea?.isNotEmpty == true)
      parts.add(placemark.administrativeArea!);
    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  // Calculate distance between two points
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Update location manually
  Future<void> updateLocation() async {
    try {
      isUpdatingLocation.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        await _showPermanentlyDeniedDialog();
        return;
      }

      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Required',
          'Location permission is required to update your location',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AColors.warning,
          colorText: AColors.white,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      locationPermissionGranted.value = true;
      await _getCurrentLocation();
      Get.snackbar(
        'Location Updated',
        'Your location has been updated to: ${currentLocation.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.success,
        colorText: AColors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        'Failed to update location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AColors.error,
        colorText: AColors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isUpdatingLocation.value = false;
    }
  }

  // Dialog methods
  Future<bool> _showPermissionExplanationDialog() async {
    return await Get.dialog<bool>(
          AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.location_on, color: AColors.primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text('Location Access',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PadelSystem would like to access your location to provide you with better features:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildFeatureRow(Icons.near_me, 'Find nearby courts'),
                const SizedBox(height: 12),
                _buildFeatureRow(Icons.directions, 'Show distances to courts'),
                const SizedBox(height: 12),
                _buildFeatureRow(
                    Icons.filter_list, 'Filter courts by distance'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Not Now',
                    style: TextStyle(color: AColors.darkGrey, fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AColors.primaryColor,
                  foregroundColor: AColors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Allow Location',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AColors.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Future<void> _showLocationServiceDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_disabled, color: AColors.error, size: 28),
            SizedBox(width: 12),
            Text('Location Services Disabled',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Location services are currently disabled on your device. Please enable location services in your device settings to use location-based features.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AColors.darkGrey, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AColors.primaryColor,
              foregroundColor: AColors.white,
            ),
            child: const Text('Open Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showPermanentlyDeniedDialog() async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings, color: AColors.warning, size: 28),
            SizedBox(width: 12),
            Text('Permission Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location permission has been permanently denied.',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('To enable location features, please:',
                style: TextStyle(fontSize: 15)),
            SizedBox(height: 8),
            Text(
                '1. Go to App Settings\n2. Find Permissions\n3. Enable Location permission',
                style: TextStyle(fontSize: 14, color: AColors.textsecondarry)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AColors.darkGrey, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AColors.primaryColor,
                foregroundColor: AColors.white),
            child: const Text('Open App Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Message methods
  void _showPermissionNotRequestedMessage() {
    Get.snackbar(
      'Permission Not Requested',
      'Location permission was not requested. You can still browse courts.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AColors.info,
      colorText: AColors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.info_outline, color: AColors.white),
    );
  }

  void _showLocationGrantedMessage() {
    Get.snackbar(
      'Location Access Granted',
      'Now you can find nearby courts and see distances!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AColors.success,
      colorText: AColors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.location_on, color: AColors.white),
    );
  }

  void _showPermissionDeniedMessage() {
    Get.snackbar(
      'Location Permission Denied',
      'You can still browse all courts, but nearby features won\'t be available',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AColors.warning,
      colorText: AColors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.location_off, color: AColors.white),
    );
  }

  void _showLocationErrorMessage(String error) {
    Get.snackbar(
      'Location Error',
      'Failed to access location: $error',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AColors.error,
      colorText: AColors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: AColors.white),
    );
  }

  // Status getters
  String get locationStatusText {
    if (!locationServiceEnabled.value) return 'Location services disabled';
    if (!locationPermissionGranted.value) return 'Location permission denied';
    if (isUpdatingLocation.value) return 'Updating location...';
    return currentLocation.value;
  }

  Color get locationStatusColor {
    if (!locationServiceEnabled.value || !locationPermissionGranted.value)
      return AColors.error;
    if (isUpdatingLocation.value) return AColors.warning;
    return AColors.success;
  }

  IconData get locationStatusIcon {
    if (!locationServiceEnabled.value) return Icons.location_disabled;
    if (!locationPermissionGranted.value) return Icons.location_off;
    if (isUpdatingLocation.value) return Icons.location_searching;
    return Icons.location_on;
  }

  // Get formatted distance
  String getFormattedDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}
