import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  /// Check location permissions
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      print('Error checking permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Request location permissions
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      print('Error requesting permission: $e');
      return LocationPermission.denied;
    }
  }

  /// Get current position with better error handling and user feedback
  Future<Position?> getCurrentPosition({bool showUserFeedback = false}) async {
    try {
      print('=== Starting location request ===');

      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      print('Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        print('Location services are disabled');
        if (showUserFeedback) {
          print('User feedback: Location services are disabled on this device');
        }
        return null; // Return null instead of default location
      }

      // Check permissions
      LocationPermission permission = await checkPermission();
      print('Initial permission status: $permission');

      if (permission == LocationPermission.denied) {
        print('Requesting location permission...');
        permission = await requestPermission();
        print('Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          print('Location permissions denied by user');
          if (showUserFeedback) {
            print('User feedback: Location permission denied');
          }
          return null; // Return null instead of default location
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions permanently denied');
        if (showUserFeedback) {
          print(
            'User feedback: Location permissions permanently denied. Please enable in settings.',
          );
        }
        return null; // Return null instead of default location
      }

      // Get current position with timeout
      print('Attempting to get current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      print(
        'Successfully got position: ${position.latitude}, ${position.longitude}',
      );
      if (showUserFeedback) {
        print('User feedback: Current location found successfully');
      }

      return position;
    } catch (e) {
      print('Error getting current position: $e');
      if (showUserFeedback) {
        print('User feedback: Failed to get current location: $e');
      }
      return null; // Return null on error instead of default location
    }
  }

  /// Get address from coordinates
  Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  /// Get coordinates from address
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations[0];
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }
}
