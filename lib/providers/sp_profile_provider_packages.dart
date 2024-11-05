import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final supabase = supabase_flutter.Supabase.instance.client;

final allPackagesProvider =
    FutureProvider.family<List<Package>, PackageFilterCriteria>((ref, filterCriteria) async {
  final response = await supabase.rpc('get_service_provider_packages',
      params: {'spid': filterCriteria.spId});

  List<dynamic> packages = response as List<dynamic>;

  // Convert each package map to a Package object
  List<Package> packageList = packages.map((package) {
    return Package(
      packageServiceProviderId: package['sp_id'] as String? ?? '',
      packageId: package['package_id'] as String? ?? '',
      packageName: package['package_name'] as String? ?? '',
      category: package['package_category'] is List<dynamic>
          ? List<String>.from(package['package_category'] as List<dynamic>)
          : [],
      packagePrice: package['price'] as int? ?? 0,
      packageImage: package['package_image'] as String? ?? '',
      packageType: package['package_type'] is List<dynamic>
          ? List<String>.from(package['package_type'] as List<dynamic>)
          : [],
      packagePetType: package['pet_type'] is List<dynamic>
          ? List<String>.from(package['pet_type'] as List<dynamic>)
          : [],
      packageSize: package['size'] as String? ?? '',
    );
  }).toList();

  // Apply client-side filtering
  if (filterCriteria.petType != null) {
    packageList = packageList
        .where((package) =>
            package.packagePetType.any(filterCriteria.petType!.contains))
        .toList();
  }
  if (filterCriteria.packageType != null) {
    packageList = packageList
        .where((package) =>
            package.packageType.any(filterCriteria.packageType!.contains))
        .toList();
  }
  if (filterCriteria.packageCategory != null) {
    packageList = packageList
        .where((package) =>
            package.category.any(filterCriteria.packageCategory!.contains))
        .toList();
  }
  if (filterCriteria.size != null) {
    packageList = packageList
        .where((package) => package.packageSize == filterCriteria.size)
        .toList();
  }

  return packageList;
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

// Provider to manage the list of service options
final packageOptionsProvider = Provider<List<String>>((ref) {
  return [
    'Grooming Package',
    'Boarding Package',
    'Health Check Package',
    'All'
  ];
});

// Provider to manage the selected service category
final selectedPackageCategoryProvider = StateProvider<String>((ref) {
  return 'All'; // Adjust default value if needed
});
