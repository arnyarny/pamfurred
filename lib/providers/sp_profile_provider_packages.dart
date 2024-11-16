import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pamfurred/models/package_filter_criteria.dart';
import 'package:pamfurred/models/packages.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;

final supabase = supabase_flutter.Supabase.instance.client;

final allPackagesProvider =
    FutureProvider.family<List<Package>, PackageFilterCriteria>(
        (ref, filterCriteria) async {
  final response = await supabase.rpc('get_service_provider_packages',
      params: {'spid': filterCriteria.spId});

  List<dynamic> packages = response as List<dynamic>;
// Filter out packages without required details and map them to Package objects
  List<Package> packageList = packages
      .where((package) =>
          package['sp_id'] != null &&
          package['package_id'] != null &&
          package['package_name'] != null &&
          package['package_name'].toString().isNotEmpty)
      .map((package) {
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

  // Apply client-side filtering based on string matches

  // Filter by petType if it is provided
  if (filterCriteria.petType != null && filterCriteria.petType!.isNotEmpty) {
    packageList = packageList.where((package) {
      return package.packagePetType.contains(filterCriteria.petType);
    }).toList();
  }

  // Filter by packageType if it is provided
  if (filterCriteria.packageType != null &&
      filterCriteria.packageType!.isNotEmpty) {
    packageList = packageList.where((package) {
      return package.packageType.contains(filterCriteria.packageType);
    }).toList();
  }

  // Filter by packageCategory if it is provided
  if (filterCriteria.packageCategory != null &&
      filterCriteria.packageCategory!.isNotEmpty) {
    packageList = packageList.where((package) {
      return package.category.contains(filterCriteria.packageCategory);
    }).toList();
  }

  // Filter by size if it is provided
  if (filterCriteria.size != null && filterCriteria.size!.isNotEmpty) {
    packageList = packageList.where((package) {
      return package.packageSize == filterCriteria.size;
    }).toList();
  }

  return packageList;
});
