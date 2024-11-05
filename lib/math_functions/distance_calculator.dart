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
    double distanceInKilometers =
        distanceInMeters / 1000; // Convert to kilometers
    String roundedDistance =
        distanceInKilometers.toStringAsFixed(1); // Round to one decimal place

    return ('$roundedDistance km away'); // Return the formatted distance
  } else {
    print('Could not retrieve location for user.');
    return null;
  }
}
