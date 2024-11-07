import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    FutureProvider.family<Map<String, dynamic>, int>((ref, petId) async {
  // Watch the petProfileProvider for data
  final petProfilesAsyncValue =
      await ref.read(petProfileProvider('some_category').future);

  // If data is available, find the pet with the given petId
  final pet = petProfilesAsyncValue.firstWhere((pet) => pet["pet_id"] == petId,
      orElse: () => {});

  // If the pet is not found, throw an error
  if (pet.isEmpty) {
    throw Exception("Pet with ID $petId not found.");
  }

  return pet;
});
