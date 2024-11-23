import 'package:flutter_riverpod/flutter_riverpod.dart';

// Location State class
class LocationState {
  final double latitude;
  final double longitude;

  LocationState({required this.latitude, required this.longitude});
}

// Location Notifier
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
      : super(LocationState(latitude: 0.0, longitude: 0.0)); // Default values

  void updateLocation(double latitude, double longitude) {
    state = LocationState(latitude: latitude, longitude: longitude);
  }
}

// Location provider
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

// Store location function
Future<void> storeLocation(
    double latitude, double longitude, WidgetRef ref) async {
  // Update the location state locally using the provider
  final locationNotifier = ref.read(locationProvider.notifier);
  locationNotifier.updateLocation(latitude, longitude);

  print('Location stored locally: $latitude, $longitude');
}
