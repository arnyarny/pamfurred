import 'package:supabase_flutter/supabase_flutter.dart';

class UserAddressFetcher {
  // Function to fetch user data from Supabase and return the pet owner address as a string
  Future<String> fetchUserAddress() async {
    try {
      final userSession = Supabase.instance.client.auth.currentSession;

      if (userSession == null) {
        throw Exception("User not logged in");
      }

      // Use session data to get user info
      final userId = userSession.user.id;

      final userDetails = await Supabase.instance.client
          .from('user')
          .select()
          .eq('user_id', userId)
          .single();

      final String addressId = userDetails['address_id'];

      final addressDetails = await Supabase.instance.client
          .from('address')
          .select()
          .eq('address_id', addressId)
          .single();

      return _formatAddress(addressDetails);
    } catch (e) {
      print("Error fetching user data: $e");
      return ''; // Return empty string on error
    }
  }

  // Helper function to format the address details into a readable string
  String _formatAddress(Map<String, dynamic> addressDetails) {
    final floorUnitRoom = addressDetails['floor_unit_room']?.isNotEmpty ?? false
        ? '${addressDetails['floor_unit_room']}, '
        : '';
    final street = addressDetails['street']?.isNotEmpty ?? false
        ? '${addressDetails['street']}, '
        : '';
    final barangay = addressDetails['barangay']?.isNotEmpty ?? false
        ? '${addressDetails['barangay']}, '
        : '';
    final city = addressDetails['city'] ?? '';

    return "$floorUnitRoom$street$barangay$city";
  }
}
