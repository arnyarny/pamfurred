import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/user_id.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

// The petProfileProvider fetches the pet profiles with the owner details
final petProfileProvider =
    FutureProvider.family<List<dynamic>, String>((ref, petOwnerId) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  // Call the Supabase function to get the pet profiles with owner information
  final response = await supabase.rpc('get_pet_profiles_with_owner', params: {
    'pet_owner_id_param': petOwnerId,
  });

  // Ensure the response is a List<Map<String, dynamic>>
  final dataList = List<Map<String, dynamic>>.from(response);

  return dataList;
});

// Fetch service provider details
final serviceProviderFutureProviderWithoutCategory =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  final response = await supabase.from('service_provider').select('*');

  // Ensure response is cast to List<Map<String, dynamic>>
  final dataList = List<Map<String, dynamic>>.from(response);

  return dataList;
});

// FutureProvider.family to fetch a specific pet by id
final fetchPetByIdProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, petId) async {
  // Get the user ID from the userIdProvider
  final userId = ref.watch(userIdProvider);

  print('User ID: $userId');

  // Fetch pet profiles for the user
  final petProfiles = await ref.read(petProfileProvider(userId!).future);

  // Find the pet with the given petId in the fetched profiles
  final pet = petProfiles.firstWhere(
    (pet) => pet['pet_profile_id'] == petId,
    orElse: () => <String, dynamic>{},
  );

  return pet;
});
