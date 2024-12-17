import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/user_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void editPetProfile(WidgetRef ref, String currentImage, String? newImage) async {
  final fileName = currentImage.split('/').last; // Get the file name from the URL

  if (fileName != '') {
    // Delete the pet profile picture from the bucket
    await supabase.storage
        .from('pet_profile')
        .remove([fileName]); // Make sure petProfileImage is the correct path
  }

  // Upload image to Supabase storage
  final imageUrl = await uploadImage(newImage!); // Get the image URL after uploading
  print("Uploaded image URL: $imageUrl"); // Debug print

  // Assuming ref is properly defined in your context (e.g., using Riverpod)
  final userId = ref.watch(userIdProvider);

  // Insert data into pet_profile table in Supabase
  await supabase.from('pet_profile').update({
    'pet_image': imageUrl,
  }).eq('user_id', userId); // Adding a filter to update the user's pet profile

  print('Pet profile updated successfully!');
}

Future<String> uploadImage(String imagePath) async {
  final file = File(imagePath);

  // Upload image to Supabase storage
  final filePath = 'pet_profile/${file.uri.pathSegments.last}';

  try {
    await supabase.storage.from('pet_profile').upload(filePath, file);

    // If the upload is successful, get the public URL
    final publicUrl =
        supabase.storage.from('pet_profile').getPublicUrl(filePath);
    print("Generated public URL: $publicUrl");

    return publicUrl;
  } catch (e) {
    print('Error during image upload: $e');
    return ''; // Return empty string if an error occurs
  }
}
