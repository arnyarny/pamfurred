import 'package:flutter_riverpod/flutter_riverpod.dart';

// Function to get the list of valid pets for a service/package
Future<List<Map<String, dynamic>>> getValidPetsForService(
  List<String> servicePackagePetType,
  int servicePackageMinWeight,
  int servicePackageMaxWeight,
  AsyncValue<List<dynamic>> petProfileDataFuture,
) async {
  // Check if the pet profile data is in the 'data' state and available
  if (petProfileDataFuture is AsyncData) {
    final petProfiles = petProfileDataFuture.value;

    // Check if petProfiles is of the correct type
    if (petProfiles is List<Map<String, dynamic>>) {
      // Filter and return the list of valid pets
      return petProfiles.where((pet) {
        String petTypeFromProfile = pet['pet_type'].toString();
        num petWeight = num.tryParse(pet['pet_weight'].toString()) ?? 0;

        // Check if the pet's type matches any of the service's types
        // and if the pet's weight falls within the service's weight range
        return servicePackagePetType.contains(petTypeFromProfile) &&
            petWeight >= servicePackageMinWeight &&
            petWeight <= servicePackageMaxWeight;
      }).toList();
    }
  }

  // Return an empty list if no data is available or in an unexpected format
  return [];
}
