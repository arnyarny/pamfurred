import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FetchUserAddress extends StatefulWidget {
  const FetchUserAddress({super.key});

  @override
  State<FetchUserAddress> createState() => _FetchUserAddressState();
}

class _FetchUserAddressState extends State<FetchUserAddress> {
  @override
  Widget build(BuildContext context) {
    bool isLoading = false;

    Map<String, dynamic>? mapUserAddress;

    // Function to fetch user data from Supabase
    Future<void> fetchUserData() async {
      try {
        final userSession = Supabase.instance.client.auth.currentSession;

        if (userSession == null) {
          throw Exception("User not logged in");
        }

        // Use your session data to get user info (modify as needed based on how you manage user info)
        final userId = userSession.user.id; // Get user ID from session

        final userDetails = await Supabase.instance.client
            .from('user')
            .select()
            .eq('user_id', userId) // Query based on the current user's ID
            .single();

        final String addressId = userDetails['address_id'];

        final addressDetails = await Supabase.instance.client
            .from('address')
            .select()
            .eq('address_id', addressId)
            .single();

        setState(() {
          mapUserAddress = addressDetails;
          isLoading = false;
        });
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          isLoading = false; // Stop loading even on error
        });
        // Show a snackbar on error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load user data')),
          );
        }
      }
    }

    return Container();
  }
}
