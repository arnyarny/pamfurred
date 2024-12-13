import 'package:supabase_flutter/supabase_flutter.dart';

class DeletePetProfileService {
  DeletePetProfileService();

  Future<String?> deletePetProfile(
      {required String petProfileId, required String petProfileImage}) async {
    try {
      final SupabaseClient supabaseClient = Supabase.instance.client;

      final fileName =
          petProfileImage.split('/').last; // Get the file name from the URL

      // Update the pet profile in the database, marking it as deleted
      await supabaseClient
          .from('pet_profile')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq(
              // Current timestamp in UTC
              'pet_profile_id',
              petProfileId);

      if (fileName != '') {
        // Delete the pet profile picture from the bucket
        await supabaseClient.storage.from('pet_profile').remove(
            [fileName]); // Make sure petProfileImage is the correct path
      }

      return 'Pet profile and image deleted successfully';
    } catch (e) {
      print("Error deleting pet profile: $e");
      return null;
    }
  }
}
