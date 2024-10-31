import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final allPackagesProvider =
    FutureProvider.family<List<dynamic>, String>((ref, spId) async {
  final supabase = supabase_flutter.Supabase.instance.client;

  final response = await supabase.rpc('get_service_provider_packages',
      params: {'spid': spId}); // Call the RPC function with sp_id

  return response as List<dynamic>;
});

// Package type provider
final packageTypeProvider = StateNotifierProvider<PackageTypeNotifier, String>(
  (ref) => PackageTypeNotifier(),
);

class PackageTypeNotifier extends StateNotifier<String> {
  PackageTypeNotifier() : super('Home service');

  void updatePackageType(String value) {
    state = value;
  }
}

// Pet type provider
final petTypePackageProvider =
    StateNotifierProvider<PetTypePackageNotifier, String>(
  (ref) => PetTypePackageNotifier(),
);

class PetTypePackageNotifier extends StateNotifier<String> {
  PetTypePackageNotifier() : super('Dog');

  void updatePetTypePackage(String value) {
    state = value;
  }
}

// Provider to manage the list of service options
final packageOptionsProvider = Provider<List<String>>((ref) {
  return ref.watch(serviceOptionsProvider);
});

// Provider to manage the selected service category
final selectedPackageCategoryProvider = StateProvider<String>((ref) {
  return 'Pet grooming services'; // Adjust default value if needed
});
