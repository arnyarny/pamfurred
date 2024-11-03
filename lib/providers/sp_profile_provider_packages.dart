import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/providers/sp_profile_provider_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final supabase = supabase_flutter.Supabase.instance.client;

final allPackagesProvider =
    FutureProvider.family<List<dynamic>, PackageFilterCriteria>(
        (ref, filterCriteria) async {
  final response = await supabase.rpc('get_service_provider_packages',
      params: {'spid': filterCriteria.spId});

  List<dynamic> packages = response as List<dynamic>;

  // Apply client-side filtering if needed
  if (filterCriteria.petType != null) {
    packages = packages
        .where(
            (package) => filterCriteria.petType!.contains(package['pet_type']))
        .toList();
  }
  if (filterCriteria.packageType != null) {
    packages = packages
        .where((package) =>
            filterCriteria.packageType!.contains(package['package_type']))
        .toList();
  }
  if (filterCriteria.packageCategory != null) {
    packages = packages
        .where((package) => filterCriteria.packageCategory!
            .contains(package['package_category']))
        .toList();
  }
  if (filterCriteria.size != null) {
    packages = packages
        .where((package) => package['size'] == filterCriteria.size)
        .toList();
  }

  return packages;
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
