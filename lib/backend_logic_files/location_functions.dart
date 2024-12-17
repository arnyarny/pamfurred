import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pamfurred/backend_logic_files/store_location.dart';
import 'package:pamfurred/providers/user_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<Map<String, dynamic>?> retrieveLocation(String userId) async {
  final supabase = Supabase.instance.client;

  // Fetch the user and their address details based on the user ID
  final response = await supabase
      .from('user') // Replace with your actual user table name
      .select(
          '*, address(address_id, latitude, longitude)') // Select user and address details
      .eq('user_id', userId) // Filter by user ID
      .single();

  // Access the user data
  final userData = response;

  // Check if the user has an associated address
  if (userData != null && userData['address'] != null) {
    final latitude = userData['address']['latitude']; // Get the latitude
    final longitude = userData['address']['longitude']; // Get the longitude

    // Return the latitude and longitude as a map
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  } else {
    print('No associated address found for the user.');
    return null;
  }
}

// Provider to fetch address details based on location coordinates
// final addressProvider = FutureProvider<Map<String, String>>((ref) async {
//   final userId = ref.read(userIdProvider);
//   final location = await retrieveLocation(userId!);
//   if (location != null) {
//     return await fetchAddress(location['latitude'], location['longitude']);
//   }
//   return {};
// });

// Provider to fetch user and address details
final userAddressProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Extract user ID from the session (assuming userIdProvider provides the user ID)
  final userId = ref.watch(userIdProvider);

  // Fetch user details from the `user` table
  final userResponse = await Supabase.instance.client
      .from('user')
      .select()
      .eq('user_id', userId)
      .single();

  final userDetails = userResponse as Map<String, dynamic>;

  // Extract the address ID from user details
  final String? addressId = userDetails['address_id'];

  if (addressId == null) {
    throw Exception('No address ID found for the user.');
  }

  // Fetch address details from the `address` table
  final addressResponse = await Supabase.instance.client
      .from('address')
      .select()
      .eq('address_id', addressId)
      .single();

  final addressDetails = addressResponse as Map<String, dynamic>;

  // Return just the address details for easy access
  return addressDetails;
});

// Fetch longlat from the stored riverpod state without backend
final addressProviderWithoutBackend =
    FutureProvider<Map<String, String>>((ref) async {
  final location =
      ref.watch(locationProvider); // Get the current location state
  if (location.latitude != 0.0 && location.longitude != 0.0) {
    return await fetchAddress(location.latitude, location.longitude);
  }
  return {};
});

// Function to fetch address from latitude and longitude
Future<Map<String, String>> fetchAddress(
    double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    return {
      'city': placemarks[0].locality ?? '',
      'province': placemarks[0].administrativeArea ?? '',
      'street': placemarks[0].street ?? '',
      'barangay': placemarks[0].subLocality ?? '',
    };
  } catch (e) {
    print("Error retrieving address: $e");
    return {};
  }
}
