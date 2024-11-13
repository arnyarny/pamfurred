import 'package:geolocator/geolocator.dart';
import 'package:pamfurred/backend_logic_files/location_functions.dart';

// This function fetches the user's location and calculates the distance to a target location.
Future<String?> getDistanceToTarget(
    String userId, double targetLatitude, double targetLongitude) async {
  final location = await retrieveLocation(userId);

  if (location != null) {
    double myLat = location['latitude']; // Use retrieved latitude
    double myLon = location['longitude']; // Use retrieved longitude

    // Calculate the distance between the two points
    double distanceInMeters = Geolocator.distanceBetween(
        myLat, myLon, targetLatitude, targetLongitude);

    // Check if the distance is extremely small (e.g., close enough to be considered "near")
    if (distanceInMeters < 10) {
      return ('Nearby');  // Return a friendly message for very small distances
    }

    // Check if the distance is less than 1 km (1000 meters)
    if (distanceInMeters < 1000) {
      // If less than 1 km, return the distance in meters
      return ('${distanceInMeters.toStringAsFixed(0)} meters away');
    } else {
      // Otherwise, convert to kilometers and return
      double distanceInKilometers = distanceInMeters / 1000; // Convert to kilometers
      String roundedDistance = distanceInKilometers.toStringAsFixed(1); // Round to one decimal place
      return ('$roundedDistance km away');
    }
  } else {
    print('Could not retrieve location for user.');
    return null;
  }
}
