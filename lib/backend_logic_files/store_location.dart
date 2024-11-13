import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> storeLocation(
    double latitude, double longitude, String userId) async {
  final supabase = Supabase.instance.client;

  // Fetch the user and their address details based on the ID
  final response = await supabase
      .from('user') // Replace with your actual user table name
      .select(
          '*, address(address_id)')
      .eq('user_id', userId) // Filter by ID
      .single();

  // Access the user data
  final userData = response;

  // Check if the user has an associated address
  if (userData != null && userData['address'] != null) {
    final addressId = userData['address']['address_id']; // Get the address ID

    // Store the latitude and longitude in the addresses table
    await supabase
        .from('address') // Replace with your actual addresses table name
        .update({
      'latitude': latitude,
      'longitude': longitude,
    }).eq('address_id', addressId);

    print('Location updated successfully: $latitude, $longitude');
  } else {
    print('No associated address found for the service provider.');
  }
}
